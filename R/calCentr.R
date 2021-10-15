calCentr <-function(graph, measures=c("degree","wdegree","closeness","betweenness","eigen"), order="") {
  if (any(measures=="all",  measures=="ALL")) measures <- c("degree", "wdegree", "closeness","betweenness","eigen")
  if (inherits(graph,"netCoin")) graph <- toIgraph(graph)
  m <- tolower(substring(measures,1,1))
  if(is.null(attr(igraph::V(graph),"name"))) igraph::V(graph)$name <- igraph::V(graph)
  G <- data.frame(nodes=igraph::V(graph)$name)
  H <- data.frame(nodes="Total")
  if("d" %in% m) {
    R    <- igraph::centr_degree(graph)
    G$degree  <- R$res
    if("w" %in% m) G$wdegree <- igraph::strength(graph, weights=igraph::E(graph)$N)
    if(igraph::is_directed(graph)) {
      Rin  <- igraph::centr_degree(graph, "in")
      Rout <- igraph::centr_degree(graph, "out")
      G$indegree   <- Rin$res
      if("w" %in% m) G$windegree  <- igraph::strength(graph, mode="in", weights=igraph::E(graph)$N)      
      G$outdegree  <- Rout$res
      if("w" %in% m) G$woutdegree <- igraph::strength(graph, mode="out", weights=igraph::E(graph)$N)
    }
    H$degree <- R$centralization
  }
  if("c" %in% m) {
    R <- suppressWarnings(igraph::centr_clo(graph))
    G$closeness <- R$res
    H$closeness <- R$centralization
  }
  if("b" %in% m) {
    R <- igraph::centr_betw(graph)
    G$betweenness <- R$res
    H$betweenness <- R$centralization
  }
  if("e" %in% m) {
    R <- igraph::centr_eigen(graph)
    G$eigen <- R$vector
    H$eigen <- R$centralizacion
  }
  if (order %in% measures) G <- G[order(-G[[order]]),, drop=FALSE]
  list(nodes=G,graph=H)
}
