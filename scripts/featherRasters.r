require(raster)
require(rgeos)

rad2deg <- function(rad){
    return((rad * 180) / pi)
}

deg2rad <- function(deg){
    return((deg * pi) / 180)
}

plen <- function(p1x, p2x, p1y, p2y){
    return(sqrt((p1x - p2x)^2 + (p1y - p2y)^2))
}

pang <- function(p1x, p2x, p3x, p1y, p2y, p3y){
    p12 <- plen(p1x, p2x, p1y, p2y)
    p13 <- plen(p1x, p3x, p1y, p3y)
    p23 <- plen(p2x, p3x, p2y, p3y)
    return(rad2deg(acos((p12^2 + p13^2 - p23^2)/(2 * p12 * p13))))
}

lineVertexRemove <- function(coords, angleTol = 0){
    if(identical(coords[nrow(coords),], coords[1,])){
        coords <- coords[1:(nrow(coords) - 1),]
    }

    p2x <- coords[nrow(coords),1]
    p1x <- coords[1,1]
    p3x <- coords[2,1]

    p2y <- coords[nrow(coords),2]
    p1y <- coords[1,2]
    p3y <- coords[2,2]

    angVec <- c(pang(p1x, p2x, p3x, p1y, p2y, p3y))

    for(i in 2:(nrow(coords)-1)){
        p2x <- coords[i-1,1]
        p1x <- coords[i,1]
        p3x <- coords[i+1,1]

        p2y <- coords[i-1,2]
        p1y <- coords[i,2]
        p3y <- coords[i+1,2]

        angVec <- c(angVec, pang(p1x, p2x, p3x, p1y, p2y, p3y))
    }

    p2x <- coords[nrow(coords) - 1,1]
    p1x <- coords[nrow(coords),1]
    p3x <- coords[1,1]

    p2y <- coords[nrow(coords) - 1,2]
    p1y <- coords[nrow(coords),2]
    p3y <- coords[1,2]

    angVec <- abs(c(angVec, pang(p1x, p2x, p3x, p1y, p2y, p3y)) - 180)

    coords <- coords[angVec > angleTol,]

    return(coords)
}

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
    rbp <- rbp[pointOrder,]
    rbp <- lineVertexRemove(rbp)

    edgePoly <- SpatialPolygons(list(Polygons(list(Polygon(rbp)), ID = 1)))
    edgeLine <- SpatialLines(list(Lines(list(Line(rbp)), ID = 1)))
    return(list(poly = edgePoly, line = edgeLine))
}

featherRasters <- function(rast1, rast2, featherDist){
    ## rast1 is on top of rast2;
    ## rast1 values are shown over rast2;
    ## prioritzation is same as raster::merge

    ## prepare rast1
    rast1Edge <- buildEdgePolygon(rast1)
    rast1Poly <- rast1Edge[["poly"]]
    rast1Line <- rast1Edge[["line"]]

    rast1Buff <- gIntersection(gBuffer(rast1Line, width = featherDist), rast1Poly)

    rast1Poly <- gDifference(rast1Poly, rast1Buff)

    if(is.null(rast1Poly)){
        stop("Input parameter for `featherDist` consumes all of 2nd raster. Use a smaller value.")
    }

    rast1Buff <- gBuffer(rast1Poly, width = featherDist)
    rast1Bord <- gDifference(rast1Buff, rast1Poly)

    rast1Insi <- mask(rast1, rast1Poly)
    rast1Dist <- mask(distance(rast1Insi), rast1Bord)

    rast1DistNa <- 1 - (rast1Dist / cellStats(rast1Dist, max))
    rast1Dist   <- rast1DistNa
    rast1Dist[is.na(rast1Dist)] <- 1

    rast1 <- mask(rast1, rast1Buff)
    rast1 <- rast1 * rast1Dist

    ## prepare rast2
    rast2Cells <- data.frame(extract(rast2, rast1Poly, cellnumbers = T)[[1]])
    rast2Cells <- rast2Cells[!is.na(rast2Cells$value),]

    rast2      <- mask(rast2, rast1Poly, inverse = T)
    rast2Dist  <- 1 - rast1DistNa
    rast2Dist  <- resample(rast2Dist, rast2)
    rast2Dist[is.na(rast2Dist)] <- 1
    rast2      <- rast2 * resample(rast2Dist, rast2)
    rast2[rast2Cells$cell] <- 0

    ## merge rasters
    rastNewPoly <- rast1Edge[["poly"]]
    rastNew <- merge(rast1, rast2)
    rast1   <- resample(rast1, rastNew)
    rast2   <- resample(rast2, rastNew)

    ## add blended rasters
    rast0 <- merge(rast1, rast2)
    rast0[!is.na(rast0)] <- 0 
    rast1 <- merge(rast1, rast0)
    rast2 <- merge(rast2, rast0)
    return(rast1 + rast2)
}
