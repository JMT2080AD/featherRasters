require(akima)
require(raster)

makeData <- function(plotRast = F){
    set.seed(1)
    
    res <- 1000

    dataL <- data.frame(x = sort(runif(100, 0, res)),
                        y = runif(100, 0, res),
                        data = seq(0.1, 10, 0.1))

    largeSurface <- interp(dataL$x,
                           dataL$y,
                           dataL$data,
                           nx = res,
                           ny = res,
                           xo = c(1:res),
                           yo = c(1:res),
                           linear = T)

    largeRast <- raster(largeSurface)

    dataS <- data.frame(x = runif(100, res * 0.51, res * 0.75),
                        y = runif(100, res * 0.51, res * 0.75),
                        data = seq(0.1, 10, 0.1))

    smallSurface <- interp(dataS$x,
                           dataS$y,
                           dataS$data,
                           nx = res * 0.25,
                           ny = res * 0.25,
                           xo = c((res * 0.51):(res * 0.75)),
                           yo = c((res * 0.51):(res * 0.75)),
                           linear = T)

    smallRast <- raster(smallSurface)

    if(plotRast == T){ 
        plot(largeRast, legend = F)
        plot(smallRast, col = rainbow(255), add = T, legend = F)
    }
    
    return(list(smallRast, largeRast))
}



