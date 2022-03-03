
# library

library(tidyverse)
library(gtrendsR)
library(streamliner)
library(bigrquery)
library(dplyr)


# Pull data function ------------------------------------------------------

pull_gtrends <- function(x){
  
  # get states df
  state <- data.frame(state.abb) %>%
    mutate(state.abb = paste0("US-",state.abb)) %>%
    add_row(state.abb = "US") 
  
  # Pull trend data for each state (plus the US) over the most recent 7 day period, into a list
  
  school_list <- purrr::map(
    state$state.abb,
    ~ gtrends(keyword = x, geo = .x, time = "now 7-d"))
  
  # Name the list by state
  
  names(school_list) = state$state.abb
  
  # Bind interest over time by state
  # Make hits a character variable
  # add datetime for when we pull the data
  
  purrr::map_dfr(school_list, function(x) {
    x = x$interest_over_time
    x %>% 
      mutate(hits = as.character(hits)) 
  }) %>%
    mutate(datetime_pulled = Sys.time())
}


# Pull data frames -------------------------------------------------------------

# all terms

df_allterms <- pull_gtrends(c("school closing", "snow day", "virtual school"))

# school closing

df_close <- pull_gtrends(c("school closing"))

# snow day

df_snow <- pull_gtrends(c("snow day"))

# virtual school

df_virtual <- pull_gtrends(c("virtual school"))


# Push to Big Query -------------------------------------------------------


# authorization

token = metagce::gce_token()
bigrquery::bq_auth(token = token, cache = FALSE)

# get project name

project <- metagce::gce_project()

# set dataset name

dataset <- "raw_gtrends_school"

# set table name

table_all <- "raw_gtrends_allterms"

table_close <- "raw_gtrends_close"

table_snow <- "raw_gtrends_snow"

table_virtual <- "raw_gtrends_virtual"

# create bq table (from bigrquery)

bqtable_all <- bq_table(project, dataset, table_all)

bqtable_close <- bq_table(project, dataset, table_close)

bqtable_snow <- bq_table(project, dataset, table_snow)

bqtable_virtual <- bq_table(project, dataset, table_virtual)

# push to big query (from streamliner)

table_push(bqtable_all, df_allterms)

table_push(bqtable_close, df_close)

table_push(bqtable_snow, df_snow)

table_push(bqtable_virtual, df_virtual)





