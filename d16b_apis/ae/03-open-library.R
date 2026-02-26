# AE 09 - APIs
# 03 - Open Library API
# -----------------------------------------------
# In this exercise you'll query the Open Library
# Search API (https://openlibrary.org/developers/api)
# -- no API key required.
#
# Docs: https://openlibrary.org/dev/docs/api#anchor_SearchAPI
# Example: https://openlibrary.org/search.json?q=psychology&limit=10
# -----------------------------------------------

library(tidyverse)
library(httr)
library(jsonlite)

# -----------------------------------------------
# Step 1: Search for books on a topic
# -----------------------------------------------

# TODO: Choose a search topic (e.g., "psychology", "statistics")
topic <- ___    # TODO: fill in your search term as a string

# Make a GET request to the Open Library Search API
# Base URL : https://openlibrary.org/search.json
# Key query parameters:
#   q       - search query
#   fields  - comma-separated list of fields to return
#   limit   - max number of results
#   sort    - "new" | "old" | "rating" | "random"

response <- GET(
  "https://openlibrary.org/search.json",
  query = list(
    q      = ___,                              # TODO: your topic variable
    fields = "title,author_name,first_publish_year,isbn",
    limit  = 20,
    sort   = "rating"
  )
)

# Check the status code
status_code(response)

# -----------------------------------------------
# Step 2: Parse the response
# -----------------------------------------------

if (is.null(response) || status_code(response) != 200) {
  stop("Open Library request failed. Check your query and try again.")
}

# Parse the JSON body
raw <- content(response, as = "text", encoding = "UTF-8") %>%
  fromJSON(flatten = TRUE)

# How many total results matched? (hint: raw$numFound)
raw$___    # TODO: fill in

# The actual book records live in raw$docs
books_raw <- raw$docs

glimpse(books_raw)

# -----------------------------------------------
# Step 3: Build a tidy data frame
# -----------------------------------------------

# TODO: Create a tidy tibble called `books` with columns:
#   title  - book title
#   author - first author name (author_name is a list-column; use map_chr)
#   year   - first_publish_year
#
# Hint for author: map_chr(author_name, ~ .x[1] %||% NA_character_)
# The %||% operator returns the right side if the left is NULL/NA.

books <- books_raw %>%
  as_tibble() %>%
  mutate(
    author = map_chr(author_name, ~ if (length(.x) > 0) .x[[1]] else NA_character_)
  ) %>%
  select(
    title  = ___,              # TODO: fill in
    author,
    year   = ___               # TODO: fill in
  )

books

# -----------------------------------------------
# Step 4: Explore the results
# -----------------------------------------------

# How many unique authors appear in the results?
books %>%
  summarise(n_unique_authors = n_distinct(___))   # TODO: fill in

# What is the range of publication years?
books %>%
  summarise(
    earliest = min(___, na.rm = TRUE),   # TODO: fill in
    latest   = max(___, na.rm = TRUE)    # TODO: fill in
  )

# -----------------------------------------------
# Step 5: Visualise
# -----------------------------------------------

# TODO: Create a histogram of publication years
books %>%
  filter(!is.na(year)) %>%
  ggplot(aes(x = ___)) +      # TODO: fill in
  geom_histogram(binwidth = 10, fill = "steelblue", color = "white") +
  labs(
    title = paste("Open Library results for:", topic),
    x     = "First publication year",
    y     = "Count"
  )

# -----------------------------------------------
# Bonus challenge
# -----------------------------------------------
# Write a reusable function `search_books(query, limit = 20)`
# that:
#   1. Makes the GET request with tryCatch
#   2. Returns a clean tibble with title, author, and year columns
#   3. Returns an empty tibble (with the correct column names) on failure
#
# Use the function to search for two different topics and
# bind the results together with a `topic` column for faceting.
