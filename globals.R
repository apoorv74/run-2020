library(packrat)
library(listviewer)
library(stringr)
library(glue)
library(googledrive)
library(tidyverse)
library(flexdashboard)
library(hms)
library(lubridate)
library(knitr)
library(kableExtra)
library(fs)
library(git2r)

all_vars <-
  c('OpenTracks Name',
    'Activity type',
    'Description',
    'Total distance',
    'Total time',
    'Moving time',
    'Average speed',
    'Average moving speed',
    'Max speed',
    'Average pace',
    'Average moving pace',
    'Fastest pace',
    'Max elevation',
    'Min elevation',
    'Elevation gain',
    'Max grade',
    'Min grade',
    'Recorded'
  )

graph_color <- '#c7d1dd'