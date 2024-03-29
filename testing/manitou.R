library(geoviz)
library(rayshader)

# Coordinates 
lat = 45.110742
lon = -86.018200
square_km = 5

# Set max tiles to request from 'mapzen' and 'stamen'.
# Increase this for a higher resolution image.
max_tiles = 40

# Get elevation data. Increase max_tiles for a higher resolution image.
# Set max_tiles = 40 to reproduce the example above.
dem <- mapzen_dem(lat, lon, square_km, max_tiles = max_tiles)

# Get a stamen overlay (or a satellite overlay etc. by changing image_source)
overlay_image <-
  slippy_overlay(dem,
                 image_source = "stamen",
                 image_type = "watercolor",
                 png_opacity = 0.3,
                 max_tiles = max_tiles)

# Render the 'rayshader' scene.
elmat = matrix(
  raster::extract(dem, raster::extent(dem), method = 'bilinear'),
  nrow = ncol(dem),
  ncol = nrow(dem)
)

scene <- elmat %>%
  sphere_shade(sunangle = 270, texture = "bw") %>% 
  add_overlay(overlay_image)  # %>% 

#  For a slower but higher quality render with more realistic shadows (see 'rayshader' documentation)
#  add_shadow(
#    ray_shade(
#      elmat,
#      anglebreaks = seq(30, 60),
#      sunangle = 270,
#      multicore = TRUE,
#      lambert = FALSE,
#      remove_edges = FALSE
#    )
#  ) %>%
#  add_shadow(ambient_shade(elmat, multicore = TRUE, remove_edges = FALSE))

rayshader::plot_3d(
  scene,
  elmat,
  zscale = raster_zscale(dem) / 3,  #exaggerate elevation by 3x 
  solid = TRUE,
  shadow = FALSE,
  soliddepth = -raster_zscale(dem),
  water=TRUE,
  waterdepth = 0,
  wateralpha = 0.5,
  watercolor = "lightblue",
  waterlinecolor = "white",
  waterlinealpha = 0.5
)

rgl::view3d(theta =290, phi = 18, zoom = 0.5, fov = 5)
