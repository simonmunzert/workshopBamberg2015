### -----------------------------
### name maps from phonebook entries
### simon munzert
### -----------------------------


## goals ------------------------

# generate maps that plot the distribution of family names


## tasks ------------------------

# fetch phonebook entries
# extract addresses
# locate them on a map

# 1. Identify appropriate page: http://www.dastelefonbuch.de/
# 2. Develop a strategy:
# a) entries can be requested with GET mechanism
# b) a maximum of 2000 entries are displayed --> not enough for popular names!
# c) search can be restricted with postcodes
# d) strategy: construct a set of get entries and scrape every single page. what varies is the zipcode restriction:
# 3. Apply strategy: retrieve data, extract information, cleanse data, document practical problems
# 4. Visualize / analyze data
# 5. Generalize scraping task if the task has to be repeated over and over again



## packages ---------------------

library(stringr)
library(RCurl)
library(XML)
library(maptools)
library(rgdal)
library(maps)
library(TeachingDemos) # shadowtext() function


## directory --------------------

wd <- ("./data/phonebookNamemaps")
dir.create(wd)
setwd(wd)


## code -------------------------

source("cs-namemaps-scraping-function.r")
source("cs-namemaps-extraction-function.r")
source("cs-namemaps-mapping-function.r")


namesScrape("Huber")
gruber_df <- namesParse("Huber")
namesPlot(gruber_df, "Huber", save.pdf = FALSE, show.map = TRUE)

