# featherRasters
Functions for feathering rasters in a raster merge.

These functions will merge two rasters together feathering the edges so that the first raster will blend into the second based on a `featherDist` value. 

This function works best when the first raster is completely inside the second. More work needs to be done to allow the first raster to be overlapping partially with the second. `featherRasters()` will work in this condition but the results are not ideal. 

From `test.r`:

```{r}
rm(list = ls())
source("./scripts/makeData.r")
source("./scripts/featherRasters.r")

x <- makeData(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 50
frast1 <- featherRasters(rast1, rast2, featherDist)
plot(frast[[3]], col = rainbow(255))

## edges need work
## need to feather only line segments where raster extents intersect.
x <- makeData2(res = 500, seed = 5)
rast1 <- x[[1]]
rast2 <- x[[2]]
featherDist <- 50
frast2 <- featherRasters(rast1, rast2, featherDist)
plot(frast[[3]], col = rainbow(255))
```
