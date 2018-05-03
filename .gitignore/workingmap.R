# Set working directory
library(magrittr)
file.path("C:/Users/cdaquieno/Documents") %>% setwd

# Get Twitter API credentials
library(ROAuth)
library(rstudioapi)
oauth <- OAuthFactory$new(consumerKey = "eqjnjOnvAuxeJF8zXirl5DBZT", 
                          consumerSecret = "GgKtxbXq3UvePci4qWNHkZB1s4o5N9t1TZTeGTr6rJWcYiKm48", 
                          requestURL = "https://api.twitter.com/oauth/request_token", 
                          accessURL = "https://api.twitter.com/oauth/access_token", 
                          authURL = "https://api.twitter.com/oauth/authorize")
oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

# Provide Twitter login to authorize the application.
# Copy character string following "&oauth_verifier=" in the URL.
# Paste character string into RStudio console and click "Enter".

# Get boundary box encompassing United States
library(fiftystater)
bbox <- c(min(fifty_states$long), min(fifty_states$lat),
          max(fifty_states$long), max(fifty_states$lat))

# Stream Tweets from Twitter API
library(streamR)
tweets_path<- "tweets.txt"
filterStream(file.name = tweets_path,
             locations = bbox,
             language = "en",
             timeout =
               askForPassword("How many seconds of streaming Tweets? ") %>%
               as.numeric, 
             oauth = oauth,
             verbose = T)

# Parse Tweets in RDJSON format
library(jsonlite)
tweets_file <- file(tweets_path, open = "r", encoding = "UTF-8")
tweets <- stream_in(tweets_file) %>% flatten
close(tweets_file)

# Extract text from Tweets
text <- tweets$extended_tweet.full_text
no_full_text <- is.na(text)
text[no_full_text] <- tweets[no_full_text, ]$text

# Remove Twitter entities (user mentions, hashtags, and URLs) from text
library(stringi)
text <-
  text %>%
  gsub("@\\w+", "", .) %>%
  gsub("#\\w+", "", .) %>%
  gsub("https?:\\/\\/\\S+", "", .) %>%
  trimws %>%
  lapply(function(x) {
    x %>%
      stri_trans_general("latin-ascii") %>%
      iconv(from = "latin1", to = "ASCII", sub = "")
  }) %>% unlist

# Get coordinates or centroid of associated place
coords <- tweets$coordinates.coordinates
no_coords <- coords %>% lapply(is.null) %>% unlist %>% which
coords[no_coords] <-
  tweets[no_coords, ]$place.bounding_box.coordinates %>%
  lapply(function(x) c(x[1], x[5]))
incomplete <- coords %>% lapply(is.null) %>% unlist %>% which
text <- text[-incomplete]
coords <- coords[-incomplete]
long <- coords %>% lapply(function(x) x[1]) %>% unlist
lat <- coords %>% lapply(function(x) x[2]) %>% unlist
points <- data.frame(text = text, long = long, lat = lat, stringsAsFactors = F) %>% na.omit

# Get sentiment scores of text
library(syuzhet)
sents <- get_sentiment(points$text)

# Display text of Tweets with positive and negative sentiment
text[sents > 0]
text[sents < 0]

# Get US shapefile
library(raster)
us <- getData('GADM', country = 'USA', level = 2) 

# Get states of origin or associated place
library(rgdal)
coordinates(points) <- ~ long + lat
proj4string(points) <- proj4string(us)
states <- over(points, us)$NAME_1

# Get average sentiment by state
state_sents <-
  data.frame(states = states %>% tolower, sents) %>%
  na.omit %>%
  aggregate(. ~ states, data = ., FUN = . %>% mean %>% round(2))

# Plot choropleth of sentiment by state
library(ggplot2)
choropleth <- ggplot(state_sents, aes(map_id = states)) + 
  geom_map(aes(fill = sents), map = fifty_states) + 
  expand_limits(x = fifty_states$long, y = fifty_states$lat) +
  coord_map() +
  scale_x_continuous(breaks = NULL) + 
  scale_y_continuous(breaks = NULL) +
  labs(x = "", y = "") +
  theme(legend.position = "bottom", 
        panel.background = element_blank())

# Display choropleth
choropleth

save(choropleth, file = "choropleth.rda")

load("choropleth.rda")


