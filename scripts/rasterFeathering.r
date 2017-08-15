require(raster)
require(rgeos)
source("./scripts/makeData.r")

buildEdgePolygon <- function(rast){
    rb <- boundaries(rast, type = "inner")
    rbp <- xyFromCell(rb, which(getValues(rb) == 1))
    rpbd <- as.matrix(dist(rbp))

    point1 <- 1
    point2 <- min(which(rpbd[,1] != 0))
    pointOrder <- c(point1, point2)

    pointRem <- (1:ncol(rpbd))[!1:ncol(rpbd) %in% pointOrder]

    while(length(pointRem) > 1){
        pointVal <- min(rpbd[!(1:nrow(rpbd)) %in% pointOrder , pointOrder[length(pointOrder)]])
        pointNow <- min(as.numeric(names(which(rpbd[!(1:nrow(rpbd)) %in% pointOrder ,
                                                    pointOrder[length(pointOrder)]] == pointVal))))
        pointOrder <- c(pointOrder, pointNow)
        pointRem <- pointRem[!pointRem %in% pointOrder]
    }
    
    pointOrder <- c(pointOrder, pointRem)
    edgePoly <- SpatialPolygons(list(Polygons(list(Polygon(rbp[pointOrder,])), ID = 1)))
    edgeLine <- SpatialLines(list(Lines(list(Line(rbp[pointOrder,])), ID = 1)))
    return(list(poly = edgePoly, line = edgeLine))
}

featherRasters <- function(rast1, rast2, featherDist){
## rast1 is on top of rast2; rast1 values are shown over rast2; prioritzation is same as raster::merge

    ## prepare rast1
    rast1Edge <- buildEdgePolygon(rast1)
    rast1Poly <- rast1Edge[["poly"]]
    rast1Line <- rast1Edge[["line"]]
    
    rast1Buff <- gBuffer(rast1Line, width = featherDist)
    rast1Buff <- gIntersection(rast1Buff, rast1Poly)

    rast1Poly <- gDifference(rast1Poly, rast1Buff)

    rast1Buff <- gBuffer(rast1Poly, width = featherDist)
    rast1Bord <- gDifference(rast1Buff, rast1Poly)

    rast1Insi <- mask(rast1, rast1Poly)
    rast1Dist <- distance(rast1Insi)
    rast1Dist <- mask(rast1Dist, rast1Bord)

    rast1DistNa <- 1 - (rast1Dist / cellStats(rast1Dist, max))
    rast1Dist   <- rast1DistNa
    rast1Dist[is.na(rast1Dist)] <- 1

    rast1 <- mask(rast1, rast1Buff)
    rast1 <- rast1 * rast1Dist

    ## prepare rast1
    rast2Cells <- data.frame(extract(rast2, rast1Poly, cellnumbers = T)[[1]])
    rast2Cells <- rast2Cells[!is.na(rast2Cells$value),]
    
    rast2      <- mask(rast2, rast1Poly, inverse = T)
    rast2Dist  <- 1 - rast1DistNa
    rast2Dist  <- resample(rast1Dist, rast2)
    rast2Dist[is.na(rast2Dist)] <- 1
    rast2 <- rast2 * resample(rast2Dist, rast2)
    rast2[rast2Cells$cell] <- 0

    ## merge rasters
    rast2Edge <- buildEdgePolygon(rast2)
    
    merge(rast1, rast2)

    return(rast, rastBuff, rastDist)
    
}
