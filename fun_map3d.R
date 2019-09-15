library(rayshader); library(geoviz); library(tidyverse)

#Get elevation data from Mapzen
dem <- 
  mapzen_dem(
    lat = 41.618540, 
    long = 14.066357, 
    square_km = 2, 
    max_tiles = 90 # ~60 for a hi-res (but slower) image
  )

elev_matrix <- 
  matrix(
    raster::extract(dem, raster::extent(dem), method = 'bilinear'),
    nrow = ncol(dem), ncol = nrow(dem)
  ) 

overlay <-
  slippy_overlay(
    dem,
    image_source = "mapbox",
    image_type = "satellite",
    png_opacity = 0.6,
    api_key = Sys.getenv("mapbox_key")
  )

scene <- 
  elev_matrix %>% 
  sphere_shade(sunangle = 270, texture = "bw") %>%
  # add_water(detect_water(elev_matrix), color = "desert")%>%
  add_overlay(overlay)

scene <- 
  elev_matrix %>%
  sphere_shade(sunangle = 270, texture = "bw") %>%
  add_overlay(overlay) %>%
  #The next two lines create deep shadows but are slow to run at high quality
  add_shadow(
    ray_shade(
      elev_matrix,
      anglebreaks = seq(30, 60),
      sunangle = 270,
      multicore = TRUE,
      lambert = FALSE,
      remove_edges = FALSE
    )
  ) %>%
  add_shadow(
    ambient_shade(
      elev_matrix, 
      multicore = TRUE, 
      remove_edges = FALSE
    )
  )


rayshader::plot_3d(
  scene, elev_matrix,
  zscale = raster_zscale(dem),
  solid = FALSE, #water = TRUE,
  shadow = TRUE,
  shadowdepth = -150
)

rgl::view3d(theta = 290, phi = 18, zoom = 0.95, fov = 5)

rayshader::render_depth(
  focus = 0.5,
  fstop = 18,
  filename = "scene.png"
)


rayshader::render_snapshot("scene.png")
rayshader::render_movie("scene.mp4")
