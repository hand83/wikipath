README for Wikipath

Auhor: Andras Horvath
Date: August 23, 2015


Wikipath is a shiny application for web platform. This app calculates the number of referring Wikipedia pages to a specified Wikipedia article. The app utilizes the Wikipedia "Special:WhatLinksHere" application.

The Wikipath app works with two kind of input:
1. The first option is to submit a single expression. The algorithm checks if a Wikipedia article exists for that 	algoritm. If the article exists, the program scrapes the referring pages through the https://en.wikipedia.org/wiki/Special:WhatLinksHere site. The output is the number of link counts.

2. The second option is to test how many links are directed to random Wikipedia articles. The number of randomization loop is optional. The program uses the https://en.wikipedia.org/wiki/Special:Random site to obtain random articles. The program scrapes the number of links directed to the randomly called articles. After that a histogram is generated from the results by googleVis.

The R packages required for constructing the app are:
RCurl
XML
googleVis
shiny

The constructing files are ui.R and server.R. wikipath.R can be run from R console.

