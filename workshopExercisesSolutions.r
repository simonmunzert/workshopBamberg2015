### -----------------------------
### workshop exercises
### simon munzert
### -----------------------------


## load packages ----------------
library(stringr)
library(rvest)
library(XML)
library(jsonlite)
library(RCurl)


## directory --------------------

wd <- ("./data/workshopExercises")
dir.create(wd)
setwd(wd)



## introduction to rvest --------

## 1. Go to http://www.spiegel.de/schlagzeilen/ and inspect the page!
# 1.1 Use Selectorgadget to find an XPath expression that covers all headlines!
# 1.2 Write a little program in R that imports those headlines!
url <- "http://www.spiegel.de/schlagzeilen/"

content <- html(url, encoding = "utf8")
anchors <- html_nodes(content, xpath = "//a//span[1]")
headlines1 <- html_text(anchors)
anchors <- html_nodes(content, xpath = "//a//span[2]")
headlines2 <- html_text(anchors)

headlines1
headlines2


## 2. At http://en.wikipedia.org/wiki/List_of_European_Cup_and_UEFA_Champions_League_finals, you find some statistics on all Champions League finals.
# 2.1 Find a function in the rvest package that is useful for scraping data from tables!
# 2.2 Apply this function to retrieve the table "List of European Cup and UEFA Champions League finals"!
# 2.3 Based on the scraped data, identify the three nations with the most wins!
url <- "http://en.wikipedia.org/wiki/List_of_European_Cup_and_UEFA_Champions_League_finals"
content <- html(url, encoding = "utf8")
tables <- html_table(content, fill = TRUE)
finals_tab <- tables[[3]]
names(finals_tab)
names(finals_tab) <- c("Season", "Nation_Winner", )
table(finals_tab$Nation)




### regular expressions ---------

## 1. Describe the types of strings that conform to the following regular expressions and construct an example that is matched by the regular expression.

str_extract_all("Phone 150$, PC 690$", "[0-9]+\\$")
str_extract_all("This is a sentence with shorter and longer words", "\\b[a-z]{1,4}\\b")
str_extract_all(c("session.RData", "log.txt", ".txt"), ".*?\\.txt$")
str_extract("14/07/1983", "\\d{2}/\\d{2}/\\d{4}")
str_extract("<body>this is an HTML element</body>", "<(.+?)>.+?</\\1>")


## 2. Consider the mail address  chunkylover53[at]aol[dot]com.
# 2.1 Transform the string to a standard mail format using regular expressions.
# 2.2 Imagine we are trying to extract the digits in the mail address using [:digit:]. Explain why this fails and correct the expression.
email <- "chunkylover53[at]aol[dot]com"
email_new <- str_replace(email, "\\[at\\]", "@")
(email_new <- str_replace(email_new, "\\[dot\\]", "."))
str_extract(email_new, "[[:digit:]]+")



## 3. Consider the following (adapted) poem by Robert Gernhardt!
# 3.1 Restore the original poem by deleting all large and small "L"s from the text!
# 3.2 Extract all capital letters and collapse them into one word!
# 3.3 Replace every word that contains three or less characters with "bla"!

poem <- c(
  "Am Tag, an dem das L verschwand,", 
  "da war die Luft voll Klagen.",
  "Den Dichtern, ach, verschlug es glatt",
  "ihr Singen und ihr Sagen.",
  "Nun gut. Sie haben sich gefasst.",
  "Man sieht sie wieder schreiben.",
  "Jedoch:",
  "Solang das L nicht wiederkehrt,",
  "muß alles Flickwerk beiben.")

str_replace_all(poem, pattern = "[Ll]", replacement = "")
str_c(unlist(str_extract_all(poem, "[[:upper:]]")), collapse="")
str_replace_all(poem, "\\<[[:alpha:]]{1,3}\\>", "bla")



### xpath ------------------------

## 1. http://www.transparency.org/ is the webpage of Transparency International, an anti-corruption NGO.
# 1.1 Store the page in a local folder!
# 1.2 Parse the page from the local file!
# 1.3 Construct an XPath expression that extracts all hyperlinks on the homepage and apply it on the parsed page!
# 1.4 Construct an XPath expression that extracts all the headlines in the "highlights" section!
# 1.5 Collect the category names that are listed under the "Media" field at the bottom of the page!

url <- "http://transparency.org"
download.file(url, destfile = "transparency.html")
content <- html("transparency.html")
anchors <- html_nodes(content, xpath="//a")

html_attr(anchors, "href")
xpathSApply(content, "//a", xmlGetAttr, "href")
getHTMLLinks(content)

xpath <- '//*[(@id = "Highlights")]//*[contains(concat( " ", @class, " " ), concat( " ", "headerRegular", " " ))]//a'
xpath <- '//h3[@class="headerRegular"]'
xpathSApply(content, xpath, xmlValue)

xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "sitemapGroup", " " )) and (((count(preceding-sibling::*) + 1) = 4) and parent::*)]//a'
xpathSApply(content, xpath, xmlValue)


## 2. Go to http://en.wikipedia.org/wiki/List_of_MPs_elected_in_the_United_Kingdom_general_election,_1992 and extract the table containing the elected MPs int the United Kingdom general election of 1992. Which party has most Sirs?
url <- "http://en.wikipedia.org/wiki/List_of_MPs_elected_in_the_United_Kingdom_general_election,_1992"

tables <- readHTMLTable(url, encoding = "utf-8")
names(tables)
mps <- tables[[4]]
head(mps)

# clean up
head(mps)
names(mps) <- c("con", "name", "party")
mps <- mps[-1,]
mps <- mps[!is.na(as.character(mps$party)),]
nrow(mps)

# look for Sirs
mps$name <- as.character(mps$name)
mps$sir <- str_detect(mps$name, "^Sir ")
table(mps$party, mps$sir)
prop.table(table(mps$party, mps$sir), 1)




### json data ----------------------------

## 1. The file `oscartweets.json' provides some  data on tweets that were posted during the 2014 Academy Awards ceremony.
# 1.1 Import the data into R and try to figure out what information the dataset contains! Which R object classes do the elements of the parsed object have?
# 1.2 Extract the tweets from the dataset and store them into a character vector!
# 1.3 Construct a dataset which contains some user information, and append the tweet itself and its date of creation!

tweets <- fromJSON("oscartweets.json")
class(tweets)
names(tweets)
sapply(tweets, class)

tweets_text <- tweets$text

tweetsUsers <- tweets$user
names(tweetsUsers)
sapply(tweetsUsers, class)

tweetsUsers$oscarTweet <- tweets_text
tweetsUsers$oscarTweetTime <-  tweets$created_at



### social media and apis ----------------

## 1. Yahoo! provides a free weather RSS feed that enables you to get up-to-date weather information for any location. 
# 1.1 Explore the API at https://developer.yahoo.com/weather/documentation.html!
# 1.2 The API requires a WOEID to identify the location. Try to find a source on the Web that returns a WOEID for a written location name (e.g., 'Berlin').
# 1.3 Access the API with R and transform the data into a useful format, e.g., a data.frame object!


feed_url <- "http://weather.yahooapis.com/forecastrss"
feed <- getForm(feed_url , .params = list(w = "636766", u = "c"))

parsed_feed <- xmlParse(feed)

# get current conditions
xpath <- "//yweather:location|//yweather:wind|//yweather:condition"
conditions <- unlist(xpathSApply(parsed_feed, xpath, xmlAttrs))

# get forecast
location <- t(xpathSApply(parsed_feed, "//yweather:location", xmlAttrs))
forecasts <- t(xpathSApply(parsed_feed, "//yweather:forecast", xmlAttrs))
forecast <- merge(location, forecasts)


# get WOEID with Yahoo Places API
#Yahoo ID: rdatacollection
yahooid = c("yahooid=v.m4rTvV34GgKVVL5PEAG1uIcHyKfmY8mCJjqSl7Gx3Jkp3s2B14xCc89rQYKOmN8nc.OFbL")
fname <- paste0(normalizePath("~/"),".Renviron")
writeLines(yahooid, fname)
Sys.getenv("yahooid")

baseurl <- "http://where.yahooapis.com/v1/places.q('%s')"
woeid_url <- sprintf(baseurl, URLencode("Hoboken, NJ, USA")) # careful: URL encoding!
parsed_woeid <- xmlParse((getForm(woeid_url, appid = Sys.getenv("yahooid"))))
woeid <- xpathSApply(parsed_woeid, "//*[local-name()='locality1']", xmlAttrs)[2,] # careful: namespaces!


# build wrapper function
getWeather <- function(place = "New York", ask = "current", temp = "c") {
  if (!ask %in% c("current","forecast")) {
    stop("Wrong ask parameter. Choose either 'current' or 'forecast'.")
  }
  if (!temp %in%  c("c", "f")) {
    stop("Wrong temp parameter. Choose either 'c' for Celsius or 'f' for Fahrenheit.")
  }	
  ## get woeid
  base_url <- "http://where.yahooapis.com/v1/places.q('%s')"
  woeid_url <- sprintf(base_url, URLencode(place))
  parsed_woeid <- xmlParse((getForm(woeid_url, appid = Sys.getenv("yahooid"))))
  woeid <- xpathSApply(parsed_woeid, "//*[local-name()='locality1']", xmlAttrs)[2,]
  ## get weather feed
  feed_url <- "http://weather.yahooapis.com/forecastrss"
  parsed_feed <- xmlParse(getForm(feed_url, .params = list(w = woeid, u = temp)))
  ## get current conditions
  if (ask == "current") {
    xpath <- "//yweather:location|//yweather:condition"
    conds <- data.frame(t(unlist(xpathSApply(parsed_feed, xpath, xmlAttrs))))
    message(sprintf("The weather in %s, %s, %s is %s. Current temperature is %s°%s.", conds$city, conds$region, conds$country, tolower(conds$text), conds$temp, toupper(temp)))
  }
  ## get forecast	
  if (ask == "forecast") {
    location <- data.frame(t(xpathSApply(parsed_feed, "//yweather:location", xmlAttrs)))
    forecasts <- data.frame(t(xpathSApply(parsed_feed, "//yweather:forecast", xmlAttrs)))
    message(sprintf("Weather forecast for %s, %s, %s:", location$city, location$region, location$country))
    return(forecasts)
  }
}

getWeather(place = "Paris", ask = "current", temp = "c")
getWeather(place = "Bamberg", ask = "current", temp = "c")
getWeather(place = "New York", ask = "forecast", temp = "c")





### advanced scraping scenarios ---------

## 1. The Wikipedia article at http://en.wikipedia.org/wiki/List_of_cognitive_biases provides several lists of various types of cognitive biases.
# 1.1 Parse the page with R and store it in an object!
# 1.2 Extract the information stored in the table on social biases and store it in an R data frame!
# 1.3 Fetch all footnotes!
# 1.4 Each of the entries in the table on social biases points to another, more detailed article on Wikipedia. First, fetch all the links. Next, store the the list of references from each of these articles in an adequate R object.
url <- "http://en.wikipedia.org/wiki/List_of_cognitive_biases"
browseURL(url)

# parse document
bias_parsed <- htmlParse(url, encoding = "UTF-8")

# extract table on social biases
table_social <- readHTMLTable(bias_parsed)[[2]]
names(table_social)

# get HTML links
bias_links <- getHTMLLinks(bias_parsed, xpQuery="//span[@id='Social_biases']/following::table[position()=1]//b//@href")
full_links <- str_c("http://en.wikipedia.org", bias_links)

# create function
refExt <- function(links_url){
  links_parsed <- htmlParse(links_url, encoding = "UTF-8")
  reference <- xpathSApply(links_parsed, "//span[@id='References']/following::ol[position()=1]/li//span[@class='reference-text']|//span[@id='References']/following::ul[position()=1]/li", fun = xmlValue)
  return(reference)
}

# apply function on full links
referenceList <- lapply(full_links, refExt)
names(referenceList) <- table_social$Name
referenceList$`Worse-than-average effect`


