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


### introduction to rvest -------

## 1. Go to http://www.spiegel.de/schlagzeilen/ and inspect the page!
# 1.1 Use SelectorGadget to find an XPath expression that covers all headlines!
# 1.2 Write a little program in R that imports those headlines!
url <- "http://www.spiegel.de/schlagzeilen/"

## 2. At http://en.wikipedia.org/wiki/List_of_European_Cup_and_UEFA_Champions_League_finals, you find some statistics on all Champions League finals.
# 2.1 Find a function in the rvest package that is useful for scraping data from tables!
# 2.2 Apply this function to retrieve the table "List of European Cup and UEFA Champions League finals"!
# 2.3 Based on the scraped data, identify the three nations with the most wins!
url <- "http://en.wikipedia.org/wiki/List_of_European_Cup_and_UEFA_Champions_League_finals"


### regular expressions ---------

## 1. Describe the types of strings that conform to the following regular expressions and construct an example that is matched by the regular expression.

str_extract_all("Phone 150$, PC 690$", "[0-9]+\\$") # example
"\\b[a-z]{1,4}\\b"
".*?\\.txt$"
"\\d{2}/\\d{2}/\\d{4}"
"<(.+?)>.+?</\\1>"


## 2. Consider the mail address  chunkylover53[at]aol[dot]com.
# 2.1 Transform the string to a standard mail format using regular expressions.
# 2.2 Imagine we are trying to extract the digits in the mail address using [:digit:]. Explain why this fails and correct the expression.
email <- "chunkylover53[at]aol[dot]com"


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


### xpath ------------------------

## 1. http://www.transparency.org/ is the webpage of Transparency International, an anti-corruption NGO.
# 1.1 Store the page in a local folder!
# 1.2 Parse the page from the local file!
# 1.3 Construct an XPath expression that extracts all hyperlinks on the homepage and apply it on the parsed page!
# 1.4 Construct an XPath expression that extracts all the headlines in the "highlights" section!
# 1.5 Collect the category names that are listed under the "Media" field at the bottom of the page!


## 2. Go to http://en.wikipedia.org/wiki/List_of_MPs_elected_in_the_United_Kingdom_general_election,_1992 and extract the table containing the elected MPs int the United Kingdom general election of 1992. Which party has most Sirs?
url <- "http://en.wikipedia.org/wiki/List_of_MPs_elected_in_the_United_Kingdom_general_election,_1992"






### json data ----------------------------

## 1. The file `oscartweets.json' provides some  data on tweets that were posted during the 2014 Academy Awards ceremony.
# 1.1 Import the data into R and try to figure out what information the dataset contains! Which R object classes do the elements of the parsed object have?
# 1.2 Extract the tweets from the dataset and store them into a character vector!
# 1.3 Construct a dataset which contains some user information, and append the tweet itself and its date of creation!



### social media and apis ----------------

## 1. Yahoo! provides a free weather RSS feed that enables you to get up-to-date weather information for any location. 
# 1.1 Explore the API at https://developer.yahoo.com/weather/documentation.html!
# 1.2 The API requires a WOEID to identify the location. Try to find a source on the Web that returns a WOEID for a written location name (e.g., 'Berlin').
# 1.3 Access the API with R and transform the data into a useful format, e.g., a data.frame object!




### advanced scraping scenarios ------------


## 1. The Wikipedia article at http://en.wikipedia.org/wiki/List_of_cognitive_biases provides several lists of various types of cognitive biases.
# 1.1 Parse the page with R and store it in an object!
# 1.2 Extract the information stored in the table on social biases and store it in an R data frame!
# 1.3 Fetch all footnotes!
# 1.4 Each of the entries in the table on social biases points to another, more detailed article on Wikipedia. First, fetch all the links. Next, store the the list of references from each of these articles in an adequate R object.
url <- "http://en.wikipedia.org/wiki/List_of_cognitive_biases"
browseURL(url)



