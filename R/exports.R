# netCoin -> igraph
toIgraph <- rd3_toIgraph
# igraph -> netCoin
fromIgraph <- function(G, ...){
  net <- rd3_fromIgraph(G, ...)
  class(net) <- c("netCoin",class(net))
  return(net)
}

layoutCircle <- rd3_layoutCircle
layoutGrid <- rd3_layoutGrid
addTutorial <- add_tutorial_rd3
