get_empty_run_df <- function(){
  empty_run_df <- matrix(data = '', nrow = 1, ncol = length(all_vars)) %>% data.frame()
  names(empty_run_df) <- all_vars
  return(empty_run_df)
}

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

convert_time_to_seconds <- function(time_vec){
  if(!is.null(time_vec)){
    colon_pos <- time_vec %>% str_locate(pattern = ':') %>% data.frame() %>% select('start') %>% unlist()
    total_mins <- time_vec %>% str_sub(start = 1, end = colon_pos-1) %>% str_trim() %>% as.numeric()
    total_secs <- time_vec %>% str_sub(start = colon_pos+1, end = nchar(time_vec)) %>% str_trim() %>% as.numeric()
    overall_secs <- total_mins*60 + total_secs  
  } else {
    overall_secs <- 0
  }
  return(overall_secs)
}

calculate_total_distance <- function(run_df){
  distance_col <- run_df[,'Total distance']
  start_pos <- 1
  end_pos <- str_locate(distance_col, pattern = ' km') %>% data.frame()
  end_pos <- end_pos[,1]
  total_distance <-
    substr(distance_col, start_pos, end_pos) %>% 
    stringr::str_trim(side = 'both') %>% 
    as.numeric()
  return(total_distance)
}

calculate_moving_time_sec <- function(run_df){
  moving_time <- run_df[,'Moving time']
  seconds_in_total <- moving_time %>% convert_time_to_seconds()
  return(seconds_in_total)
}
  
calculate_average_speed <- function(run_df){
  speed_col <- run_df[,'Average moving speed']
  km_pos <-
    str_locate(speed_col, pattern = ' km') %>% 
    data.frame() %>% 
    select('start') %>% 
    unlist(use.names = FALSE)
  speed_kmph <- str_sub(speed_col, start = 1, end = km_pos) %>% 
    str_trim(side = 'both') %>% 
    as.numeric()
  return(speed_kmph)
}

calculate_average_pace <- function(run_df){
  pace_col <- run_df[,'Average moving pace']
  min_pos <-
    str_locate(pace_col, pattern = ' min/km') %>% 
    data.frame() %>% 
    select('start') %>% 
    unlist(use.names = FALSE)
  pace_seconds_per_km <- str_sub(pace_col, start = 1, end = min_pos) %>% 
    str_trim(side = 'both') %>% convert_time_to_seconds()
  return(pace_seconds_per_km)
}
  
add_variables <- function(run_df){
  run_date <- as.Date(run_df[,'OpenTracks Name'])
  total_distance_km <- calculate_total_distance(run_df)
  total_moving_time_seconds <- calculate_moving_time_sec(run_df)
  average_speed_kmph <- calculate_average_speed(run_df)
  average_pace_seconds <- calculate_average_pace(run_df)
  var_df <- data.frame(
    'Date of run' = run_date,
    'Distance (km)' = total_distance_km,
    'Moving Time (sec)' = total_moving_time_seconds,
    'Average Speed (kmph)' = average_speed_kmph,
    'Average Pace (sec)' = average_pace_seconds,
    check.names = FALSE
  )
  updated_run_df <- bind_cols(run_df, var_df)
  return(updated_run_df)
}


