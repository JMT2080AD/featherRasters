rm(list = ls())
source("./scripts/makeData.r")
source("./scripts/featherRasters.r")

## feathering where one raster is completely inside another.
x <- makeData(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 30
frast1 <- featherRasters(rast1, rast2, featherDist)

## unfeathered
png("./images/centered_unfeathered.png")
plot(merge(rast1, rast2), col = rainbow(255), main = "Unfeathered")
dev.off()

## feathered
png("./images/centered_feathered.png")
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

## unfeathered
png("./images/edge_unfeathered.png")
plot(merge(rast1, rast2), col = rainbow(255), main = "Unfeathered")
dev.off()

## feathered
png("./images/edge_feathered.png")
plot(frast2, col = rainbow(255), main = "Feathered")
dev.off()

