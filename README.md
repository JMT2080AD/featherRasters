# featherRasters
Functions for feathering rasters in a raster merge.

These functions will merge two rasters together feathering the edges so that the first raster will blend into the second based on a `featherDist` value. 

This function works best when the first raster is completely inside the second. More work needs to be done to allow the first raster to be overlapping partially with the second. `featherRasters()` will work in this condition but the results are not ideal. 

View `test.r` to see usage for `featherRasters()`. It will produce the following graphics:

['./images/centered_unfeathered.jpg'](raster centered unfeathered)
['./images/centered_feathered.jpg'](raster centered feathered)
['./images/edge_unfeathered.jpg'](raster edge unfeathered)
['./images/edge_feathered.jpg'](raster edge feathered)
  
Here it can be seen that rastered that have overlapping, where one is not enclosed inside the other have odd efects and the function needs work.

Also, this function is quite slow and would benefit from better memory managment, or at least one will need to subset there data to only the merge area, then add back to thier original raster, when using in production.
