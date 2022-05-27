pieCoin <- function(x, main = NULL, note = NULL, showLegend = TRUE, help = NULL, helpOn = FALSE, cex = 1, language = c("en", "es", "ca"), dir = NULL){
  stopifnot(inherits(x, "coin"))
  colors <- c("black","cadetblue2", "white","cadetblue3")
  labels <- c("XY","X","","Y")
  x <- piefromCoin(x)
  x$V <- x$V[,,c(1,2,4,3)]
  pie <- pie_rd3(x,labels,colors,main,note,showLegend,help,helpOn,cex,language,dir)
  class(pie) <- c("pieCoin",class(pie))
  return(pie)
}

piefromCoin <- function(C) {
  stopifnot(inherits(C, "coin"))
  n <- attr(C,"n"); names(n)<-""
  v <- c(); w <- c()
  dimens <- nrow(C)
  for (i in 1:dimens) {
    for (j in 1:dimens) {
  v <- c(v, c(a=C[i,j],b=C[i,i]-C[i,j], c=C[j,j]-C[i,j],  d=n+C[i,j]-C[i,i]-C[j,j]))
  w <- c(w, c(x=C[i,i]*C[j,j]/n, y=n-C[i,i]*C[j,j]/n))
    }
  }
  v <- array(v, dim=c(4, dimens, dimens))
  v <- aperm(v, c(2,3,1))
  w <- array(w, dim=c(2, dimens, dimens))
  w <- aperm(w, c(2,3,1))
  return(list(V=v, W=w))
}

