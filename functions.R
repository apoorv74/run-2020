download_kml_files <- function(){
  list_all_files <- googledrive::drive_ls(path = 'https://drive.google.com/open?id=1EDKTQvET9K2Rvv40NLOAtneVUq9Vo0ar')
  #find index of the kml.zip file
  kml_zip_index <- which(list_all_files$name == 'kml.zip')
  if(length(kml_zip_index) > 1){
    stop('multiple dumps present, check on drive')
  }
  zip_file_id <- as_id(list_all_files$id[[kml_zip_index]])
  googledrive::drive_download(zip_file_id,path = 'kml_files/kml.zip', overwrite = TRUE)
  list_of_files_downloaded <- unzip(zipfile = "kml_files/kml.zip", overwrite = TRUE, exdir = "kml_files/unzipped")
  return(list_of_files_downloaded)
}

read_run_files <- function(kml_file_path){
  kml_file <- sf::st_read(kml_file_path)
  if(!length(kml_file$Description) < 2){
    track_description <- as.character(kml_file$Description[[2]])
    return(track_description)
  }
}

fetch_variables <- function(track_description){
  if(!is.null(track_description)){
  var_list <- c()
  for(var_id in 1:length(all_vars)){
    start_pattern <- glue::glue("{all_vars[var_id]}: ")
    if(var_id < length(all_vars)){
      end_pattern <- glue::glue(" {all_vars[var_id+1]}:")
      start_pos <- stringr::str_locate(string = track_description, pattern = start_pattern)[1,2] %>% unlist()
      end_pos <- stringr::str_locate(string = track_description, pattern = end_pattern)[1,1] - 1 %>% unlist()
    } else {
      start_pos <- stringr::str_locate(string = track_description, pattern = start_pattern)[1,2] %>% unlist
      end_pos <- nchar(track_description)
    }
    var_value <-
      stringr::str_sub(track_description, start = start_pos, end = end_pos) %>% stringr::str_trim(side = 'both') %>% as.character()
    var_list <- c(var_list, var_value)
  }
  var_df <- var_list %>% data.frame(row.names = NULL) %>% t() %>% data.frame()
  names(var_df)[] <- all_vars
  var_df[, all_vars] <- sapply(var_df[, all_vars], as.character)
  return(var_df)
  }
}

get_empty_run_df <- function(){
  empty_run_df <- matrix(data = '', nrow = 1, ncol = length(all_vars)) %>% data.frame()
  names(empty_run_df) <- all_vars
  return(empty_run_df)
}
