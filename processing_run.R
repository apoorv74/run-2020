source("libraries.R")
source("functions.R")

## Steps:
## Download the files form google drive
kml_dump <- download_kml_files()

## Rename the latest dump on drive
run_description <- lapply(kml_dump, read_run_files)

## Process downloaded `KML` files
all_runs_df <- lapply(run_description, fetch_variables) %>% dplyr::bind_rows()

## Store runs in a SQLite file
## Process metrics [what-to-track.md]
## Prepare graphs
## Prepare page
## Deploy to behindbars

