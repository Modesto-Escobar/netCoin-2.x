pieCoin <- function(x, colors = c("#000000","#8dc7e6", "#ffffff","#005587"), nodes = NULL, links = NULL, name = NULL, lcolor = NULL, expected = TRUE, abline = NULL, main = NULL, note = NULL, showLegend = TRUE, help = NULL, helpOn = FALSE, cex = 1, language = c("en", "es", "ca"), dir = NULL){
  stopifnot(inherits(x, "coin"))
  labels <- c("XY","X","","Y")
  v <- piefromCoin(x)
  w <- v$W
  v <- v$V
  v <- v[,,c(1,2,4,3)]
  colnames(v) <- rownames(v) <- colnames(x)
  if(expected){
    diag(w[,,1]) <- NA
    diag(w[,,2]) <- NA
  }else{
    w <- NULL
  }
  pie <- pie_rd3(v,w,labels,colors,nodes,links,name,"Source","Target",lcolor,abline,abline,TRUE,main,note,showLegend,help,helpOn,cex,language,dir)
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
  v <- aperm(v, c(3,2,1))
  w <- array(w, dim=c(2, dimens, dimens))
  w <- aperm(w, c(3,2,1))
  return(list(V=v, W=w))
}

