rm(list = ls())
source("./scripts/makeData.r")
source("./scripts/featherRasters.r")

## feathering where one raster is completely inside another.
x <- makeData(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 100
frast1 <- featherRasters(rast1, rast2, featherDist)

## unfeathered
plot(rast2, col = rainbow(225))
plot(rast1, col = rainbow(225), add = T)

## feathered
plot(frast1, col = rainbow(255))

## feathering where rasters only partially overlap.
## this needs work
## need to feather only linesegments where raster extents intersect.
x <- makeData2(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 50
frast2 <- featherRasters(rast1, rast2, featherDist)

## unfeathered
plot(rast2, col = rainbow(225))
plot(rast1, col = rainbow(225), add = T)

## feathered
plot(frast2, col = rainbow(255))

