library(sf); library(mapview); library(tidyverse)
library(tmap)
unzip("data/HC Directory.kmz", exdir = "data/")

# Read the KML file
kml_data <- 
  st_read("data/HC Members.kml") %>%
  select(-Description)

centroids_sf <- kml_data %>%
  summarize(geometry = st_union(geometry)) %>% 
  st_centroid %>%
  mutate(Name = "Center")

kml_data <- kml_data %>% bind_rows(centroids_sf)

# View the data
print(kml_data)
mapview(kml_data)

plot(kml_data)
tmap_mode("view")
hc_map <-
  tm_shape(kml_data) +
  tm_fill() +
  tm_borders() +
  tm_symbols()

tmap_save(hc_map, "hc_map.html")
