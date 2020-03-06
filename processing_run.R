source("globals.R")
source("functions.R")

## Steps:

## Download the files form google drive
kml_dump <- download_kml_files()

## Rename the latest dump on drive
run_description <- lapply(kml_dump, read_run_files)

## Process downloaded `KML` files
all_runs_df <- lapply(run_description, fetch_variables) %>% dplyr::bind_rows()

## Add custom variables to the dataframe
updated_runs_df <- add_variables(all_runs_df)
readr::write_rds(x = updated_runs_df, path = 'all_runs.rds')

## Render flexdashboard
rmarkdown::render("run-dashboard.Rmd")
fs::file_copy("run-dashboard.html","index.html",overwrite = TRUE)
fs::file_delete("run-dashboard.html")

## Deploy to behindbars
cred <- git2r::cred_token()
git2r::status()
git2r::add(path = ".")
git2r::commit(message = glue("render dashboard - {Sys.Date()}"))
git2r::push(object = ".", name = 'origin',refspec = "refs/heads/master",credentials = cred)
