# featherRasters
Functions for feathering rasters in a raster merge.

These functions will merge two rasters together feathering the edges so that the first raster will blend into the second based on a `featherDist` value. 

This function works best when the first raster is completely inside the second. More work needs to be done to allow the first raster to be overlapping partially with the second. `featherRasters()` will work in this condition but the results are not ideal. 
