rm(list = ls())
source("./scripts/makeData.r")
source("./scripts/featherRasters.r")

x <- makeData(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 50
frast1 <- featherRasters(rast1, rast2, featherDist)
plot(frast1[[3]], col = rainbow(255))

## edges need work
## need to feather only linesegments where raster extents intersect.
x <- makeData2(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 50
frast2 <- featherRasters(rast1, rast2, featherDist)
plot(frast2[[3]], col = rainbow(255))
