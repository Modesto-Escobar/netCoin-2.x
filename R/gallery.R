gallery <- gallery_rd3

asGallery <- function(net){
  if(inherits(net,"network_rd3")){
    nodes <- net$nodes
    options <- net$options
    gallery <- gallery_rd3(nodes = nodes, name = options$nodeName, label = options$nodeLabel,
      color = options$nodeColor, ntext = options$nodeText, info = options$nodeInfo, image = options$imageItems,
      zoom = options$zoom, main = options$main, note = options$note,
      showLegend = options$showLegend, frequencies = options$frequencies,
      help = options$help, helpOn = options$helpOn, cex = options$cex, language = options$language)
    return(gallery)
  }else{
    stop("net: must be a network object")
  }
}