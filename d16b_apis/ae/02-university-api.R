# AE 09 - APIs
# 02 - University API
# -----------------------------------------------
# In this exercise you'll query the Hipolabs
# Universities API (https://universities.hipolabs.com/)
# -- no API key required.
#
# Tasks are marked with TODO comments.
# -----------------------------------------------

library(tidyverse)
library(httr)
library(jsonlite)

# -----------------------------------------------
# Part A: Single-country query
# -----------------------------------------------

# TODO: Make a GET request to the Hipolabs search endpoint.
#       Search for universities in a country of your choice.
#       Base URL: https://universities.hipolabs.com/search
#       Query parameter: country = "Your Country Here"

response <- GET(
  "https://universities.hipolabs.com/search",
  query = list(
    country = ___    # TODO: fill in a country name (e.g. "United States")
  )
)

# Check the HTTP status
status_code(response)

# TODO: Parse the JSON body into an R object called `universities`
universities <- content(response, as = "text", encoding = "UTF-8") %>%
  ___(flatten = TRUE)    # TODO: fill in the fromJSON call

glimpse(universities)

# -----------------------------------------------
# Part B: Tidy the data frame
# -----------------------------------------------

# TODO: Select name, country, state-province, and web_pages.
#       Rename state-province to "state" and web_pages to "website".
#       Unnest the website column (it is a list-column).

uni_df <- universities %>%
  select(
    name,
    country,
    state   = ___,    # TODO: fill in the original column name
    website = ___     # TODO: fill in the original column name
  ) %>%
  unnest(___)         # TODO: fill in the list-column to unnest

uni_df

# -----------------------------------------------
# Part C: Multiple countries
# -----------------------------------------------

# TODO: Choose 3 countries and store them in a vector
countries <- c(___, ___, ___)   # TODO: fill in three country names

# TODO: Use map_dfr() to query each country and row-bind the results.
#       For each country, keep only the name and country columns
#       and the first 10 rows (use head(10)).

all_unis <- map_dfr(countries, function(ctry) {
  resp <- GET(
    "https://universities.hipolabs.com/search",
    query = list(country = ___)    # TODO: fill in the loop variable
  )

  content(resp, as = "text", encoding = "UTF-8") %>%
    fromJSON(flatten = TRUE) %>%
    select(___, ___)  %>%         # TODO: select name and country
    head(___)                     # TODO: first 10 rows
})

# How many universities per country did we collect?
all_unis %>%
  count(___, sort = TRUE)         # TODO: count by country

# -----------------------------------------------
# Part D: Write a helper function
# -----------------------------------------------

# TODO: Complete the function below so it:
#   1. Builds the query params (always includes country; adds name if provided)
#   2. Makes the GET request with tryCatch so network errors return tibble()
#   3. Checks the status code and warns + returns tibble() on non-200
#   4. Parses the JSON and returns it as a tibble

get_universities <- function(country, name = NULL) {
  params <- list(country = ___)   # TODO: fill in
  if (!is.null(name)) params$name <- name

  result <- tryCatch({
    resp <- GET(
      "https://universities.hipolabs.com/search",
      query = ___                 # TODO: pass params
    )

    if (status_code(resp) != 200) {
      warning("API request failed with status: ", status_code(resp))
      return(tibble())
    }

    content(resp, as = "text", encoding = "UTF-8") %>%
      fromJSON(flatten = TRUE) %>%
      as_tibble()
  }, error = function(e) {
    warning("API request failed: ", conditionMessage(e))
    tibble()
  })

  result
}

# Test the function
wake_forest_unis <- get_universities("United States", name = "Wake Forest")
glimpse(wake_forest_unis)

# -----------------------------------------------
# Bonus challenge
# -----------------------------------------------
# Use get_universities() to fetch universities in
# five countries. Count and visualise the results
# with a bar chart ordered by number of universities.
