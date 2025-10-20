library(googledrive)
library(data.table)
library(stringr)

# Generic utilities for working with SF files, CSV files, and Google Drive
# Antranig Basman, 2023-2025

roundmulti <- function (multi, digits) {
  multi <- lapply(multi, function (matrix) {
    matrix <- lapply(matrix, function (coords) {
      round(coords, digits)
    })
  })
  return (st_multipolygon(multi))
}

roundpoly <- function (poly, digits) {
  poly <- lapply(poly, function (matrix) {
    round(matrix, digits)
  })
  return (st_polygon(poly))
}

round_sf <- function (fc, digits=4, tolerance=0.0001) {
  # https://gis.stackexchange.com/questions/329110/removing-empty-polygon-from-sf-object-in-r
  simple  <- fc %>% st_simplify(preserveTopology = TRUE, dTolerance = tolerance) %>% dplyr::filter(!st_is_empty(.))
  geom <- simple$geometry
  geom <- lapply(geom, function (one) {
    if (inherits(one, "MULTIPOLYGON")) {
      one <- roundmulti(one, digits)
    } else if (inherits(one, "POLYGON")) {
      one <- roundpoly(one, digits)
    } else if (inherits(one, "XY")) {
      one <- round(one)
    } else if (!st_is_empty(one)) {
      stop(paste("I don't know what it is ", class(one)))
    }
  })
  simple$geometry <- st_sfc(geom)
  simple
}

timedRead <- function (toread) {
  start <- Sys.time()
  frame <- read.csv(toread)
  end <- Sys.time()
  cat("Read ", nrow(frame), " rows from ", toread, " in ", (end - start), "s")
  frame
}

timedFread <- function (toread) {
  start <- Sys.time()
  frame <- data.table::fread(toread)
  end <- Sys.time()
  cat("Read ", nrow(frame), " rows from ", toread, " in ", (end - start), "s")
  # Otherwise traditional R indexing notation fails
  as.data.frame(frame)
}

timedWrite <- function (x, towrite) {
  start <- Sys.time()
  # Approach for selective quoting taken from https://stackoverflow.com/a/25810538/1381443
  commas <- which(sapply(x, function(y) any(grepl(",",y))))
  write.csv(x, towrite, na = "", row.names = FALSE, quote = commas)
  end <- Sys.time()
  cat("Written ", nrow(x), " rows to ", towrite, " in ", (end - start), "s")
}

lat_lon <- function (data) {
  return(st_transform(data, "+proj=longlat +datum=WGS84"))
}

expand_bbox = function(bb, e) {
	dx = diff(bb[c("xmin", "xmax")])
	dy = diff(bb[c("ymin", "ymax")])
	st_bbox(setNames(c(
	    bb["xmin"] - e * dx,
		bb["ymin"] - e * dy,
		bb["xmax"] + e * dx,
		bb["ymax"] + e * dy), c("xmin", "ymin", "xmax", "ymax")))
}

mx_read <- function (filename) {
  st_data <- st_read(filename, quiet=TRUE);
  dropped <- st_zm(st_data, drop = T, what = "ZM")
  return(lat_lon(dropped));
}

# Helpful utility to template an arbitrary list of string arguments and then dump them to the console with a terminating newline
wg <- function (...) {
  args <- list(...)
  line <- paste(sapply(args, str_glue, .envir = parent.frame()), collapse = "")
  
  # Output the result using writeLines
  writeLines(line)
}

# Other incarnation at https://github.com/usda-nifa-b-team/b-team/blob/main/scripts/utils.R

downloadGdrive <- function (id, file_path) {
    if (!file.exists(file_path)) {
        drive_download(as_id(id), path = file_path, overwrite = FALSE)
    }
}

idToDrib <- function (id) {
  path <- str_glue("https://drive.google.com/drive/folders/{id}")
  drib <- drive_get(as_id(path))
}

# Adapted from https://stackoverflow.com/a/64687628
downloadGdriveFolder <- function (id, file_path, skip_if_exists = TRUE) {
  exists <- file.exists(file_path)
  if (!exists || !skip_if_exists) {
    if (!exists) {
      dir.create(file_path)
    }
    # folder link to id
    folder_drib = idToDrib(id)
    
    # find files in folder
    files = drive_ls(folder_drib)
    
    cat("Fetching ", nrow(files), " files in folder ", folder_drib$name, "\n")
    
    # loop dirs and download files inside them
    for (i in seq_along(files$name)) {
      resource <- files$drive_resource[[i]]
      
      target <- str_c(file_path, "/", resource$name)
      if (resource$mimeType == "application/vnd.google-apps.folder") {
        cat (resource$name, " is a folder\n")
        downloadGdriveFolder(resource$id, target, skip_if_exists)
        # If there were subfolders, this would list them:
        # i_dir = drive_ls(files[i, ])
      }
      else {
        
        try({
          if (file.exists(target)) {
            wg("File {target} already exists, skipping download")
          } else {
            drive_download(as_id(files$id[i]), path = target)
          } 
        })
      }
    }
  } else {
    wg("Path {file_path} already exists, skipping download\n")
  }
}
