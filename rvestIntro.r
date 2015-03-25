### -----------------------------
### simon munzert
### rvest introduction
### -----------------------------


## packages -------------------------

library(rvest)
library(stringr)

## Wickham's rvest package ----------
# see also: https://github.com/hadley/rvest

  # convenient package to scrape information from web pages
  # builds on other packages like RCurl, XML, and httr
  # provides very intuitive functions to import and process webpages


## sample functionality -------------

# html() parses an HTML page; automatically starts a GET request
url <- "http://spiegel.de"
content <- html(url, encoding = "utf8")
class(content)
content

# html_nodes() selects nodes from an HTML document

  # excursion: SelectorGadget
  browseURL("http://selectorgadget.com/")

headlines <- html_nodes(content, xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "headline", " " ))]')
class(headlines)
headlines 

# html_text() extracts content (attributes, text, tag names) from html content
headlines_string <- html_text(headlines)
headlines_string
str_replace_all(headlines_string, '\\\"', "'")

# html_table() parses an html table into a data frame
html_table(content)



### glossary: main functions --------------
html()
html_node()
html_tag()
html_text()
html_attr()
html_attrs()

xml()
xml_node()
xml_tag()
xml_text()
xml_attr()
xml_attrs()

html_table()
html_form()
set_values()
submit_form()

guess_encoding()
repair_encoding()

html_session()
jump_to()
follow_link()
back()
forward()
submit_form()