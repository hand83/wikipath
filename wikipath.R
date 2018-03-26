########## LIBRARIES ##########
library(RCurl)
library(XML)
library(googleVis)

########## FUNCTIONS ##########

##### FUNCTION: returns parsed HTML from URL
##
htmlParser <- function(link) {
  connection <- getURL(link, .opts = list(ssl.verifypeer = FALSE), followlocation=TRUE, .mapUnicode = FALSE)
  htmlParse(connection, asText = TRUE)
}

###### FUNCTION: tests if Wikipedia article exists. Returns its exact title if exists
## uses htmlParser()
wikiExists <- function(term) {
  term <- gsub(" ", "_", term)
  term <- gsub("[^[:graph:]]+", "", term)
  term <- gsub("[%{}<>]+", "", term)
  term <- gsub("\\[+", "", term)
  term <- gsub("\\]+", "", term)
  wikiURL <- "https://en.wikipedia.org/wiki/"
  link <- paste0(wikiURL, term)
  html <- htmlParser(link)
  MSG <- xpathSApply(html, "//td/b", xmlValue)[1]
  nofoundMSG <- "Wikipedia does not have an article with this exact name."
  if (MSG == nofoundMSG) {
    FALSE
  } else {
    redirected <- xpathSApply(html, "//link[@rel = 'canonical']/@href")
    gsub(wikiURL, "", unname(redirected))
  }
}

##### FUNCTION: reads referencing page titles on te current page
##
readValues <- function(html){
  values <- character()
  MSG <- xpathSApply(html, "//body/div/div/div/p", xmlValue)[1]
  foundvaluesMSG <- "The following pages link to"
  if (grepl(foundvaluesMSG, MSG)){
    values <- xpathSApply(html, 
                  "//ul//a[@title and starts-with(@href, '/wiki/') and 
                  not(contains(@href, ':')) and
                  not(@class) and
                  not(@accesskey)
                  ]", xmlValue)
  }
  length(values)
}

##### FUNCTION: finds and returns the forward paging link
##
stepForward <- function(html) {
  relative <- xpathSApply(html, 
                "//a[
                contains(@title, 'Special:WhatLinksHere/') and
                contains(@href, '&from=') and
                contains(@href, '&back=') and
                not(contains(@href, '&hide')) and
                not(contains(@href, '&limit'))
                ]/@href")

  rightIndices <- function(rel) {
    posfrom <- regexpr("&from=[0-9]+", rel)
    posback <- regexpr("&back=[0-9]+", rel)
    fromvalue <- substr(rel, posfrom+6, posfrom + unlist(attributes(posfrom)[1]) - 1)
    backvalue <- substr(rel, posback+6, posback + unlist(attributes(posback)[1]) - 1)
    if (fromvalue != backvalue) {
      TRUE
    } else FALSE
  }
  forwardlink <- unique(unname(relative))
  rightselect <- sapply(forwardlink, rightIndices)
  rightselect <- unname(rightselect)
  forwardlink <- forwardlink[rightselect]
  if (length(forwardlink) == 1) {
    wikiShortURL <- "https://en.wikipedia.org"
    paste0(wikiShortURL, forwardlink)
  } else FALSE
}

##### FUNCTION: collects all referencing page titles 
## uses htmlParser()
## uses stepForward()
collector <- function(wikiterm) {
  whatLinksURL1 <- "https://en.wikipedia.org/w/index.php?title=Special%3AWhatLinksHere&target="
  whatLinksURL2 <- "&namespace=0"
  stepURL <- paste0(whatLinksURL1, wikiterm, whatLinksURL2)
  refnumber <- 0
  while (stepURL != FALSE) {
    wikiLinksHTML <- htmlParser(stepURL)
    refnumber <- refnumber + readValues(wikiLinksHTML)
    stepURL <- stepForward(wikiLinksHTML)
  }
  refnumber
}

##### FUNCTION: gets a random wikipedia page and finds the number of referring sites
## function parameter sets the number of runs
## uses htmlParser()
## uses collector()
randomizer <- function(n){
  randomURL <- "https://en.wikipedia.org/wiki/Special:Random"
  sets <- numeric()
  setnames <- character()
  for (i in 1:n) {
    randomHTML <- htmlParser(randomURL)
    redirected <- xpathSApply(randomHTML, "//link[@rel = 'canonical']/@href")
    wikiURL <- "https://en.wikipedia.org/wiki/"
    term <- gsub(wikiURL, "", unname(redirected))
    termname <- xpathSApply(randomHTML, "//h1", xmlValue) ## !!!! termname could be displayed if necessary !!!!
    numrefs <- collector(term)
    sets <- c(sets, numrefs)
    setnames <- c(setnames, termname)
  }
  names(sets) <- setnames
  sets
}

########## CUSTOM INPUT - PROCESS ##########
## uses wikiExists()
## uses collector()
inputFunction <- function(inputterm) {
  destExpression <- inputterm
  destWiki <- wikiExists(destExpression)
  if (destWiki != FALSE) {
    paste0("Number of refering articles to ", "'", destExpression,"': ", collector(destWiki))
  } else paste0("'", destExpression, "'", " article does not exist on Wikipedia.")
}

########## RANDOM LOOP INPUT - PROCESS ##########
## uses randomizer()
randomRunFunction <- function(n) {
  runs <- n
  sets <- randomizer(runs)
  df <- data.frame(id = names(sets), refers = sets)
  title <- paste("Distribution of references to", length(sets), "random Wikipedia pages", sep = " ")
  gvisHistogram(df, options=list(
    legend = "{ position: 'none' }",
    hAxis = "{title: 'No. of referring pages'}",
    vAxis = "{title: 'Frequency'}",
    title = title,
    colors = "['#5aaeff']",
    width = 600,
    height = 600),
    chartid = "WikiRefs")
}