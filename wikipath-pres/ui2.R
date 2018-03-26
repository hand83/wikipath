library(shiny)
shinyUI(
    pageWithSidebar(
        headerPanel("Wiki refer-O-meter"),
        
        sidebarPanel(
            
            h3("Wikipedia referring page calculator"),
            
            p("This app calculates the number of referring Wikipedia pages to a specified Wikipedia article. 
              The app utilizes the Wikipedia \"Special:WhatLinksHere\" application. The Wikipedia listing for a 
              certain article is then scraped by this app and the number of references are sent for subsequent 
              processing."),
            br(),
            
            h4("Find references for a custom article"),
            
            p("Type an expression to find the related article on Wikipedia. After hitting the submit button, 
              the app will check if the an article about the expression exists and finds the number of referring
              pages. The results are displayed on the right panel. Please note that some articles to which several 
              pages are referring require some seconds to obtain the results."),
            
            textInput(inputId = "singleIP", label = "Expression: "),
            actionButton("singleSubmit", "Submit"),
        ),
        
        mainPanel(
            
            a("Don't forget to donate to Wikimedia Foundation to maintain Wikipedia!",
            href = "https://donate.wikimedia.org/"),
            br(),
            
            h3("References to a custom Wikipedia article"),
            p("Sumbit an expression on the right panel to obtain the number of referring pages to its 
              Wikipedia article. Please be patient, getting the result may take some time."),
            textOutput("singleOP"),
            tags$head(tags$style("#singleOP{ 
                                 color: red;
                                 font-size: 16px;
                                 }")
                      )
        )
    )
)