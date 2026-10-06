# =============================================================================
# Using CoordinateCleaner to flag recurrent errors in collection databases
# WiNoDa School 2025 - Herbaria Case Study
# Maria Judith Carmona Higuita & Prof. Dr. Alexander Zizka (University of Marburg)
#
# Tutorial: https://mariajudithch.github.io/CoordinateCleaner_WiNoDa/coordinate_cleaner_epiphytes.html
# Run from the project root (folder containing data/ and output/).
# =============================================================================


# ---- 1. Install packages (run once) -----------------------------------------
# install.packages(c(
#   "CoordinateCleaner", "countrycode", "dplyr", "ggplot2", "maps",
#   "rgbif", "rnaturalearth", "rnaturalearthdata", "sf", "tibble", "readr"
# ))


# ---- 2. Load libraries ------------------------------------------------------
library(CoordinateCleaner)
library(countrycode)
library(dplyr)
library(ggplot2)
library(rgbif)
library(sf)
library(tibble)
library(readr)


# ---- 3. Obtain herbarium data from GBIF -------------------------------------
# Set to TRUE to download fresh data from GBIF (needs internet, takes a while
# and overwrites data/herbaria_raw_epiphytes.csv). FALSE uses the saved copy.
download_from_gbif <- FALSE

if (download_from_gbif) {
  herbaria <- c("COL", "HUA", "MO")

  gbif_list <- lapply(herbaria, function(inst) {
    message("Downloading records for institutionCode = ", inst)
    res <- occ_search(
      institutionCode = inst,
      hasCoordinate   = TRUE,
      limit           = 5000
    )
    res$data
  })

  dat_raw <- dplyr::bind_rows(gbif_list)
  str(dat_raw)

  if (!dir.exists("data")) dir.create("data")
  readr::write_csv(dat_raw, "data/herbaria_raw_epiphytes.csv")
}

# Load the saved dataset
dat_raw <- readr::read_csv("data/herbaria_raw_epiphytes.csv",
                           show_col_types = FALSE, guess_max = Inf)
dim(dat_raw)


# ---- 4. Column selection + filter -------------------------------------------
prepare_data <- function(x) {
  x %>%
    dplyr::select(
      species,
      decimalLongitude,
      decimalLatitude,
      countryCode,
      year,
      basisOfRecord,
      individualCount,
      institutionCode,
      datasetName,
      gbifID
    ) %>%
    dplyr::filter(!is.na(decimalLongitude),
                  !is.na(decimalLatitude)) %>%
    dplyr::filter(basisOfRecord == "PRESERVED_SPECIMEN") %>%
    dplyr::rename(lon = decimalLongitude,
                  lat = decimalLatitude) %>%
    dplyr::mutate(lon = as.numeric(lon),
                  lat = as.numeric(lat))
}

dat <- prepare_data(dat_raw)
glimpse(dat)


# ---- 5. First look at the raw data ------------------------------------------
nrow(dat_raw)
names(dat_raw)
head(dat_raw)

nrow(dat)
str(dat)
summary(dat[, c("lon", "lat")])

# Map of raw coordinates
world_map <- borders("world", colour = "gray70", fill = "gray90")

ggplot() +
  world_map +
  coord_fixed() +
  geom_point(
    data = dat,
    aes(x = lon, y = lat, colour = institutionCode),
    size = 0.7,
    alpha = 0.7
  ) +
  labs(
    title = "Raw herbarium records from GBIF",
    subtitle = "Colour indicates institutionCode",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_bw()


# ---- 6. Record-level tests --------------------------------------------------
# IMPORTANT: with value = "flagged", CoordinateCleaner returns
#   TRUE  = record passes the test (clean, keep it)
#   FALSE = record is flagged (problematic)

plot_flags <- function(data, keep, title) {
  data_kept    <- data[keep, ]
  data_flagged <- data[!keep, ]

  ggplot() +
    borders("world", colour = "gray70", fill = "gray90") +
    coord_fixed() +
    geom_point(data = data_kept, aes(lon, lat),
               color = "darkgreen", size = 0.6, alpha = 0.7) +
    geom_point(data = data_flagged, aes(lon, lat),
               color = "red", size = 0.8, alpha = 0.8) +
    labs(title = title, subtitle = "Green = kept, Red = flagged") +
    theme_bw()
}

report_test <- function(keep, name) {
  cat(name, "\n")
  cat("  Total records:  ", length(keep), "\n")
  cat("  Kept (clean):   ", sum(keep, na.rm = TRUE), "\n")
  cat("  Flagged:        ", sum(!keep, na.rm = TRUE), "\n\n")
}

# Land reference for the sea test, downloaded from Natural Earth.
# (cc_sea() uses scale 110 by default; clean_coordinates() uses scale 50.)
# If the download fails (no internet / server down), fall back to the
# country polygons shipped with rnaturalearthdata, so the test still runs.
get_land <- function(scale) {
  tryCatch(
    rnaturalearth::ne_download(scale = scale, type = "land",
                               category = "physical", returnclass = "sf"),
    error = function(e) {
      message("Natural Earth download failed; using country polygons instead.")
      rnaturalearth::ne_countries(scale = scale, returnclass = "sf")
    }
  )
}

land_110 <- get_land(110)
land_50  <- get_land(50)


# 6.1 Invalid coordinates
keep_val <- cc_val(x = dat, lon = "lon", lat = "lat", value = "flagged")
report_test(keep_val, "Invalid coordinates test")


# 6.2 Zero coordinates
keep_zero <- cc_zero(x = dat, lon = "lon", lat = "lat", value = "flagged")
report_test(keep_zero, "Zero coordinates test")


# 6.3 Sea coordinates
keep_sea <- cc_sea(x = dat, lon = "lon", lat = "lat",
                   ref = land_110, value = "flagged")
report_test(keep_sea, "Sea coordinates test")
plot_flags(dat, keep_sea, "Sea coordinates flagged by cc_sea()")

dat <- dat[keep_sea, ]
nrow(dat)


# 6.4 Country mismatch (cc_coun needs ISO3 codes)
dat <- dat %>%
  dplyr::mutate(
    countryCode = countrycode(countryCode,
                              origin = "iso2c",
                              destination = "iso3c")
  )

keep_country <- cc_coun(x = dat, lon = "lon", lat = "lat",
                        iso3 = "countryCode", value = "flagged")
report_test(keep_country, "Country mismatch test")
plot_flags(dat, keep_country, "Country mismatches flagged by cc_coun()")

dat <- dat[keep_country, ]
nrow(dat)


# 6.5 Duplicated records (same species + same coordinates)
keep_dupl <- cc_dupl(x = dat, lon = "lon", lat = "lat",
                     species = "species", value = "flagged")
report_test(keep_dupl, "Duplicates test")
plot_flags(dat, keep_dupl, "Duplicated records flagged by cc_dupl()")

dat <- dat[keep_dupl, ]
nrow(dat)


# 6.6 Institution coordinates
keep_inst <- cc_inst(x = dat, lon = "lon", lat = "lat", value = "flagged")
report_test(keep_inst, "Institution coordinates test")
plot_flags(dat, keep_inst, "Institution coordinates flagged by cc_inst()")

dat <- dat[keep_inst, ]
nrow(dat)


# 6.7 Capitals and centroids
keep_cap <- cc_cap(x = dat, lon = "lon", lat = "lat", value = "flagged")
keep_cen <- cc_cen(x = dat, lon = "lon", lat = "lat", value = "flagged")
report_test(keep_cap, "Capitals test")
report_test(keep_cen, "Centroids test")

keep_capcen <- keep_cap & keep_cen
plot_flags(dat, keep_capcen, "Capital/centroid coordinates flagged by cc_cap() + cc_cen()")

dat <- dat[keep_capcen, ]
nrow(dat)


# ---- 7. All-in-one cleaning with clean_coordinates() ------------------------
dat_cc <- prepare_data(dat_raw) %>%
  dplyr::mutate(
    countryCode = countrycode(countryCode,
                              origin = "iso2c",
                              destination = "iso3c")
  ) %>%
  as.data.frame()

flags_all <- clean_coordinates(
  x = dat_cc,
  lon = "lon",
  lat = "lat",
  species = "species",
  countries = "countryCode",
  seas_ref = land_50,
  tests = c(
    "capitals",
    "centroids",
    "equal",
    "zeros",
    "countries",
    "institutions",
    "seas",
    "duplicates",
    "gbif",
    "validity"
  )
)

summary(flags_all)
table(flags_all$.summary)

cleaned_all <- dat_cc[flags_all$.summary, ]
nrow(dat_cc); nrow(cleaned_all)

ggplot() +
  world_map +
  coord_fixed() +
  geom_point(data = dat_cc, aes(x = lon, y = lat),
             color = "gray60", size = 0.4, alpha = 0.6) +
  geom_point(data = cleaned_all, aes(x = lon, y = lat),
             color = "darkgreen", size = 0.6, alpha = 0.8) +
  labs(
    title = "Epiphyte GBIF records before (gray) and after cleaning (green)",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_bw()


# ---- 8. Optional: spatial outliers ------------------------------------------
# keep_out <- cc_outl(
#   x = cleaned_all,
#   lon = "lon",
#   lat = "lat",
#   species = "species",
#   method = "quantile",
#   mltpl = 5,
#   tdi = 1000,
#   value = "flagged"
# )
# cleaned_no_out <- cleaned_all[keep_out, ]
# nrow(cleaned_all); nrow(cleaned_no_out)
# plot_flags(cleaned_all, keep_out, "Spatial outliers flagged by cc_outl()")


# ---- 9. Export the cleaned dataset ------------------------------------------
if (!dir.exists("output")) dir.create("output")
write_csv(cleaned_all, "output/epiphytes_cleaned_coordinates.csv")

flag_cols <- setdiff(names(flags_all), c(names(dat_cc), ".summary"))
removed   <- sapply(flags_all[flag_cols], function(x) sum(!x, na.rm = TRUE))

data.frame(
  test = flag_cols,
  removed_records = as.integer(removed)
)
