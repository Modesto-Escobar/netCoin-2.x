glmCoin <- function(formulas, data, weights=NULL, pmax=.05,
        robust=FALSE, twotail=FALSE, showArrows=TRUE,
        frequency = FALSE, percentage = TRUE, 
        color="variable", lwidth="s.value", lcolor="estimate",
        circle= NA, language=c("en","es","ca"),
        igraph=FALSE, ...) {
  vcov <- stats::vcov
  if(robust){
    vcov <- "HC1"
  }

  cleanVariables <- function(x){
    x <- iconv(x,to="ASCII//TRANSLIT")
    x <- gsub(" ",".",x)
    return(gsub("[^a-zA-z_]",".",x))
  }
  originalNames <- colnames(data)
  colnames(data) <- cleanVariables(colnames(data))
  cleanedNamesIndex <- which(originalNames!=colnames(data))
  aux <- originalNames[cleanedNamesIndex]
  cleanedNamesIndex <- cleanedNamesIndex[order(nchar(aux),decreasing=TRUE)] # reorder to check first longest strings
  for(i in cleanedNamesIndex){
    formulas <- gsub(originalNames[i],colnames(data)[i],formulas,fixed=TRUE)
  }
  if (is.character(weights)){
    weights <- cleanVariables(weights)
    weights<-data[[weights]]
  }

  prenet <- contr.gw(formulas, data=data, weights=weights, vcov=vcov)
  arguments <- list(nodes = prenet$Nodes, links = prenet$Links,
    showArrows=showArrows, color=color, linkFilter=paste0("p.value<",pmax),
    lwidth=lwidth, lcolor=lcolor, language=language, ...)
  arguments$linkBipolar <- TRUE
  for(i in cleanedNamesIndex){
    arguments$nodes[,'name'] <- gsub(colnames(data)[i],originalNames[i],arguments$nodes[,'name'],fixed=TRUE)
    arguments$links[,'Source'] <- gsub(colnames(data)[i],originalNames[i],arguments$links[,'Source'],fixed=TRUE)
    arguments$links[,'Target'] <- gsub(colnames(data)[i],originalNames[i],arguments$links[,'Target'],fixed=TRUE)
    arguments$links[,'Model'] <- gsub(colnames(data)[i],originalNames[i],arguments$links[,'Model'],fixed=TRUE)
 }
  if(arguments$language[1]!="en"){
    colnames(arguments$nodes)[colnames(arguments$nodes)=="name"] <- getByLanguage(nameList,arguments$language[1])
  }
  net <- do.call(netCoin, arguments)
  if(igraph) net <- toIgraph(net)
  return(net)
}
