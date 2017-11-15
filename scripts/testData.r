rm(list = ls())
source("./scripts/makeData.r")
source("./scripts/featherRasters.r")

## feathering where one raster is completely inside another.
x <- makeData(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 30
frast1 <- featherRasters(rast1, rast2, featherDist)

## plots
png("./images/centered.png", width = 960)
par(mfrow = c(1,2))
plot(merge(rast1, rast2), col = rainbow(255), main = "Unfeathered")
plot(frast1, col = rainbow(255), main = "Feathered")
dev.off()

## feathering where rasters only partially overlap.
## this needs work
## need to feather only linesegments where raster extents intersect.
x <- makeData2(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 10
frast2 <- featherRasters(rast1, rast2, featherDist)

## plots
png("./images/edge.png", width = 960)
par(mfrow = c(1,2))
plot(merge(rast1, rast2), col = rainbow(255), main = "Unfeathered")
plot(frast2, col = rainbow(255), main = "Feathered")
dev.off()

