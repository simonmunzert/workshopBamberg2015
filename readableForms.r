### -----------------------------
### readable forms
### simon munzert
### -----------------------------

## goals ------------------------

  # upload texts and check them on readability


## tasks ------------------------

  # inspect forms at http://read-able.com/
  # upload texts via forms
  # retrieve and process results


## packages ---------------------

library(rvest)
library(stringr)
library(XML)
library(plyr)
library(httr)

## directory --------------------

wd <- ("./data/readableForms")
dir.create(wd)
setwd(wd)


## code ---------------------


## step 1: inspect forms with new function
url <- "http://en.wikipedia.org/w/index.php?title=Special%3ASearch"
browseURL(url)
html <- html(url)

# ADCR: page 236
attr_inspector <- function(parsed_html, xpath){
  require(plyr)
  require(XML)
  x <- xpathApply(parsed_html, xpath, xmlAttrs)
  x <- lapply(x, function(x) as.data.frame(t(x)))
  do.call(rbind.fill, x)
}
attr_inspector(html, "//form")
fields <- attr_inspector(html, "//form[1]//input")[,1:5]
fields

url1 <- str_c(url, "&search=Bamberg")
url2 <- str_c(url, "&search=Bamberg","&fulltext=search")
browseURL(url1)
browseURL(url2)

url  <- "http://en.wikipedia.org/w/index.php"
resp <- 
  GET(url, 
      query = list(
        title   = "Special:Search",
        profile = "default",
        search  = "Bamberg",
        fulltext= "search"
              ))
resp

xpath = "//*[@class='mw-search-result-heading']/a"
results <- 
html_attr(
  html_nodes(
    content(resp, "parsed"), 
    xpath=xpath
  ), "title" )
  
iconv(results, "UTF8", "latin1")



## step 2: explore service at http://read-able.com/
url <- "http://read-able.com/"
browseURL(url)
attr_inspector( html(url), "//form")
attr_inspector( html(url), "//form[2]//input|//textarea|//select")


## step 3: load blog entries from r-datacollection
dominic <- html("http://www.r-datacollection.com/blog/Fifty-years-of-Christmas-at-the-Windsors/")
dominic <- html_nodes(dominic, xpath="//p")
dominic <- html_text(dominic)
dominic <- str_c(dominic, collapse="\n")

peter <- html("http://www.r-datacollection.com/blog/Introduction-to-Public-Attention-Analytics-with-Wikipediatrend/")
peter <- html_nodes(peter, xpath="//p")
peter <- html_text(peter)
peter <- str_c(peter, collapse="\n")

simon <- html("http://www.r-datacollection.com/blog/Programming-a-Twitter-bot/")
simon <- html_nodes(simon, xpath="//p")
simon <- html_text(simon)
simon <- str_c(simon, collapse="\n")

christian <- html("http://www.r-datacollection.com/blog/Hassle-free-data-from-HTML-tables-with-the-htmltable-package/")
christian <- html_nodes(christian, xpath="//p")
christian <- html_text(christian)
christian <- str_c(christian, collapse="\n")


## step 4: post texts and retrieve output
force <- F # redo or not
if ( !file.exists("dominic.html") | force==T){
  resp_d <- POST("http://read-able.com/check.php",
            body=list(directInput=dominic), 
            encode="form")
  writeBin(content(resp_d, "raw"), 
           con="dominic.html" , useBytes=T)
}

if ( !file.exists("peter.html")  | force==T){
  resp_p <- POST("http://read-able.com/check.php",
            body=list(directInput=peter), 
            encode="form")
  writeBin(content(resp_p, "raw"), 
           con="peter.html" , useBytes=T)
}
if ( !file.exists("simon.html") | force==T ){
  resp_s <- POST("http://read-able.com/check.php",
            body=list(directInput=simon), 
            encode="form")
  writeBin(content(resp_s, "raw"), 
           con="simon.html" , useBytes=T)
}

if ( !file.exists("christian.html")  | force==T){
  resp_c <- POST("http://read-able.com/check.php",
            body=list(directInput=christian), 
            encode="form")
  writeBin(content(resp_c, "raw"), 
           con="christian.html" , useBytes=T)
}


## step 5: examine output
readHTMLTable("christian.html")[[1]][1:2,]
readHTMLTable("peter.html")[[1]][1:2,]
readHTMLTable("simon.html")[[1]][1:2,]
readHTMLTable("dominic.html")[[1]][1:2,]
