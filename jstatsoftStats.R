### -----------------------------
### scraping jstatsoft statistics
### simon munzert
### -----------------------------



## goals ------------------------

# fetch and analyze jstatsoft download statistics


## tasks ------------------------

# inspect page
# setup url scraper
# download sources
# parse and tidy data


## packages ---------------------

library(rvest)
library(magrittr)
library(stringr)
library(tm)


## directory --------------------
wd <- ("./data/jstatsoftStats")
dir.create(wd)
setwd(wd)


## code -------------------------

## step 1: construct list of urls
baseurl <- "http://www.jstatsoft.org/"
volurl <- paste0("v", seq(1,62,1))
volurl[1:9] <- paste0("v0", seq(1, 9, 1))
brurl <- paste0("b0", seq(1,9,1))
urls_list <- paste0(baseurl, volurl)
urls_list <- paste0(rep(urls_list, each = 9), "/", brurl)
names <- paste0(rep(volurl, each = 9), "_", brurl, ".html")


## step 2: download pages
folder <- "htmls_reviews/"
dir.create(folder)
for (i in 1:length(urls_list)) {
  if (!file.exists(paste0(folder, names[i]))) {
  download.file(urls_list[i], destfile = paste0(folder, "/", names[i]))
  Sys.sleep(runif(1, 0, 1))
}
}


## step 3: access pages
listFiles <- list.files(folder, pattern = "v.*")
url <- character()
volume <- character()
reviewer <- character()
title <- character()
reference <- character()
authors <- character()
publisher <- character()
year <- numeric()
isbn <- character()
numDownload <- numeric()
date <- character()
for (i in 1:length(listFiles)) {
htmlOut <- html(paste0(folder, listFiles[i]), encoding = "utf8")
TableOut <- html_table(htmlOut)
if (length(TableOut) != 0) {
TableOut <- TableOut[[1]]
url[i] <- urls_list[i]
volume[i] <- names[i]
reviewer[i] <- TableOut[1,2]
#reference[i] <- TableOut[3,2]
authors[i] <- TableOut[5,2]
publisher[i] <- TableOut[7,2]
title[i] <- TableOut[6,2]
isbn[i] <- TableOut[8,2]
year[i] <- TableOut[9,2] %>% as.numeric
numDownload[i] <- TableOut[2,2] %>% str_extract(pattern = perl("(?<=\\()[[:digit:]]+")) %>% as.numeric
date[i] <- TableOut[3,2] %>% str_extract(pattern = "[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$")
} else {
url[i] <- ""
volume[i] <- ""
reviewer[i] <- ""
#reference[i] <- ""
authors[i] <- ""
publisher[i] <- ""
title[i] <- ""  
isbn[i] <- ""
year[i] <- NA
numDownload[i] <- NA
date[i] <- ""
}
}


## step 4: construct data frame
dat <- data.frame(url = url, volume = volume, reviewer = reviewer, authors = authors, publisher = publisher, title = title, isbn = isbn, year = year, numDownload = numDownload)
dat <- dat[dat$title!="",]
names(dat)


# manual approach
url <- "http://www.jstatsoft.org/v61/b01"
htmlOut <- html(url)
TableOut <- html_table(htmlOut)
TableOut <- TableOut[[1]]
TableOut[,1]


## step 5: data inspection

# publisher
dat$publisher <- as.character(dat$publisher)
sort(table(dat$publisher))
dat$publisher[str_detect(dat$publisher, "Wiley")] <- "Wiley" 
dat$publisher[str_detect(dat$publisher, "Springer")] <- "Springer" 
dat$publisher[str_detect(dat$publisher, "Chapman|CRC")] <- "Chapman Hall/CRC" 
dat$publisher[str_detect(dat$publisher, "Reilly")] <- "O'Reilly" 
dat$publisher[str_detect(dat$publisher, "Cambridge")] <- "Cambridge Univ. Press" 
dat$publisher[str_detect(dat$publisher, "Manning")] <- "Manning"
dat$publisher[str_detect(dat$publisher, "World Scientific Publishing")] <- "World Scientific Publishing" 
sort(table(dat$publisher))

# download statistics
dattop <- dat[order(dat$numDownload, decreasing = TRUE),]
dattop[1:10,]
summary(dat$numDownload)
hist(dat$numDownload, breaks=30)
plot(density(dat$numDownload), yaxt="n", ylab="", xlab="Number of downloads", main="Distribution of download statistics, book reviews")

# year
table(dat$year)




## step 6: analyze sentiment in reviews

# download pdfs
folder <- "pdfs_reviews/"
dir.create(folder)
urls <- paste0(dat$url, "/paper")
names <- str_sub(dat$volume, 1, -6)
for (i in 1:length(urls)) {
  if (!file.exists(paste0(folder, names[i], ".pdf"))) {
    download.file(urls[i], destfile = paste0("pdfs/", names[i], ".pdf"), mode = "wb")
  }
}

pdftotext <- function(fname){
  path_to_pdftotext <-
    "C:/xpdf/pdftotext.exe"
  fname_txt <- str_replace(fname, ".pdf", ".txt")
  command <- str_c(path_to_pdftotext,
                   fname,
                   fname_txt, sep=" ")
  shell(command)
}



pdfFiles <- list.files(folder, pattern = ".+\\.pdf")
for (i in 1:length(pdfFiles)) {
  pdftotext(pdfFiles[i])
}


txtFiles <- list.files(folder, pattern = ".+\\.txt$")
reviewsTxt <- character()
for (i in 1:length(txtFiles)) {
reviewsTxt[i] <- paste0(readLines(paste0(folder, txtFiles[i])), collapse="")
}

# create corpus
reviews <- Corpus(DataframeSource(data.frame(reviewsTxt)))

# preparation
reviews <- tm_map(reviews, removeNumbers)
reviews <- tm_map(reviews, removeWords, words = stopwords("en"))
reviews <- tm_map(reviews, tolower)
reviews <- tm_map(reviews, stemDocument, language = "english")
reviews <- tm_map(reviews, PlainTextDocument)


# load dictionary
pos <- readLines("../dictionary/positive-words.txt")
pos <- pos[!str_detect(pos, "^;")]
pos <- pos[2:length(pos)]
neg <- readLines("../dictionary/negative-words.txt")
neg <- neg[!str_detect(neg, "^;")]
neg <- neg[2:length(neg)]

# stem words
pos <- stemDocument(pos, language = "english")
pos <- pos[!duplicated(pos)]
neg <- stemDocument(neg, language = "english")
neg <- neg[!duplicated(neg)]


# generate Document-Term-Matrix
tdm.reviews.bin <- TermDocumentMatrix(reviews, control = list(weighting = weightBin))
tdm.reviews.bin <- removeSparseTerms(tdm.reviews.bin, 1-(5/length(reviews)))
tdm.reviews.bin

# score texts
pos.mat <- tdm.reviews.bin[rownames(tdm.reviews.bin) %in% pos,]
neg.mat <- tdm.reviews.bin[rownames(tdm.reviews.bin) %in% neg,]
pos.out <- apply(pos.mat, 2, sum)
neg.out <- apply(neg.mat, 2, sum)
senti.diff <- pos.out - neg.out
senti.diff[senti.diff == 0] <- NA


dat$neg.out <- neg.out
dat$pos.out <- pos.out
dat$senti.diff <- senti.diff
dat$nchar <- nchar(reviewsTxt)
dat$neg.share <- dat$neg.out/dat$nchar
dat$pos.share <- dat$pos.out/dat$nchar

save(dat, file="jstatsoftdata.RData")

View(dat)
datneg <- dat[order(dat$neg.share, decreasing = TRUE),]


