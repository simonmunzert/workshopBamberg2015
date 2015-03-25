### -----------------------------
### workshop setup
### simon munzert
### -----------------------------


# packages from CRAN
p_needed <- c("RCurl", "XML", "stringr", "jsonlite", "httr", "rvest", "devtools", "ggmap", "wikipediatrend", "d3Network", "RSelenium", "sp", "twitteR", "streamR", "maptools", "rgdal", "maps", "TeachingDemos")
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}

