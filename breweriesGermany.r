### -----------------------------
### mapping breweries in germany
### simon munzert
### -----------------------------


## goals ------------------------

# generate map of brewery locations in Germany


## tasks ------------------------

# fetch list of breweries
# geocode them
# plot them on a map



## packages ---------------------

library(rvest)
library(stringr)
library(ggmap)


## directory --------------------

wd <- ("./data/breweriesGermany")
dir.create(wd)
setwd(wd)


## code -------------------------

## step 1: fetch list of cities with breweries
url <- "http://www.biermap24.de/brauereiliste.php"
browseURL(url)
content <- html(url, encoding = "utf8")
anchors <- html_nodes(content, xpath = "//tr/td[2]")
cities <- html_text(anchors)
cities
cities <- str_trim(cities)
cities <- cities[str_detect(cities, "^[[:upper:]]+.")]
length(cities)
length(unique(cities))
sort(table(cities))


## step 2: geocode cities

# geocoding takes a while -> save results
# 2500 requests allowed per day
if ( !file.exists("breweries_geo.RData")){
  pos <- geocode(cities)
  geocodeQueryCheck()
  save(pos, file="breweries_geo.RData")
} else {
  load("breweries_geo.RData")
}
head(pos)



## step 3: plot breweries in Germany

# fetch German boundaries
url <-
  "http://biogeo.ucdavis.edu/data/gadm2/R/DEU_adm1.RData"
fname <- basename(url)
if ( !file.exists(fname) ){
  download.file(url, fname, mode="wb")
}
load(fname)

bb <- data.frame(lon = 10.89, lat = 49.89)

breweryMap <-
  ggplot(data=gadm, aes(x=long, y=lat)) +
  geom_polygon(data = gadm, aes(group=group), fill="white") +
  geom_path(color="black", aes(group=group)) +
  geom_point(data = pos,
             aes(x = lon, y = lat),
             colour = "#F54B1A70", size=2, na.rm=T) +
  geom_point(data = bb, aes(x = lon, y = lat), size = 3, colour = "blue") +
  coord_map(xlim=c(5, 16), ylim=c(47,55.5)) +
  theme_bw()
breweryMap
