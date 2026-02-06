glmCoin2 <- function(formulas, data, weights=NULL, pmax=.05,
        robust=FALSE, twotail=FALSE, showArrows=TRUE,
        frequency = FALSE, percentage = TRUE, 
        color="variable", lwidth="s.value", lcolor="estimate",
        circle= NA, language=c("en","es","ca"),
        igraph=FALSE, ...) {
  vcov <- stats::vcov
  if(robust){
    vcov <- "HC1"
  }
  prenet <- contr.gw(formulas, data=data, weights=weights, vcov=vcov)
  linkFilter=paste0("p.value<",pmax)
  net <- netCoin(prenet$Nodes, prenet$Links, showArrows=showArrows, color=color, linkFilter = linkFilter,
                 lwidth=lwidth, lcolor=lcolor, linkBipolar = TRUE, language=language, ...)
  if(igraph) net <- toIgraph(net)
  return(net)
}
