# AE 09 - APIs
# 01 - Weather API
# -----------------------------------------------
# In this exercise you'll query the Open-Meteo API
# (https://open-meteo.com/) -- no API key required.
#
# Follow along with the slides and fill in the ___
# blanks as we go.
# -----------------------------------------------

library(tidyverse)
library(httr)
library(jsonlite)

# -----------------------------------------------
# Step 1: Make the request
# -----------------------------------------------

# The base URL for Open-Meteo forecasts
base_url <- "https://api.open-meteo.com/v1/forecast"

# Make a GET request for Winston-Salem, NC
# Hint: look up the coordinates at https://latlong.net
response <- GET(
  base_url,
  query = list(
    latitude  = ___,      
    longitude = ___,      
    models              = "gfs_seamless",
    current             = "temperature_2m",
    wind_speed_unit     = "mph",
    precipitation_unit  = "inch",
    temperature_unit    = "fahrenheit"
  )
)

# Check the status code -- 200 means success
status_code(response)

# -----------------------------------------------
# Step 2: Parse the JSON response
# -----------------------------------------------

# Guard against a failed request
if (is.null(response)) {
  stop("Request failed: response is NULL.")
}

if (status_code(response) != 200) {
  stop(paste0("Request failed with status ", status_code(response)))
}

# Extract the body as text and parse it
weather_data <- content(response, as = "text", encoding = "UTF-8") %>%
  fromJSON()

# What top-level fields did we get back?
names(___)    

# -----------------------------------------------
# Step 3: Explore the current conditions
# -----------------------------------------------

# Pull out the current-conditions block
current <- weather_data$___   

current

# -----------------------------------------------
# Step 4: Build a tidy tibble from the hourly forecast
# -----------------------------------------------

hourly <- weather_data$hourly

tidy_forecast <- tibble(
  time        = ___,  
  temperature = ___    
)

tidy_forecast

# -----------------------------------------------
# Step 5: Visualise the hourly temperature
# -----------------------------------------------

tidy_forecast %>%
  mutate(time = as.POSIXct(time)) %>%
  ggplot(aes(x = ___, y = ___)) +   
  geom_line() +
  labs(
    title = "Hourly temperature forecast – Winston-Salem, NC",
    x     = "Time",
    y     = "Temperature (°F)"
  )

# -----------------------------------------------
# Bonus challenge
# -----------------------------------------------
# Modify the request to also retrieve hourly
# "precipitation" and "wind_speed_10m".
# Add them to your tidy tibble and plot them.
