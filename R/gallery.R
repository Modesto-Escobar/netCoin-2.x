gallery <- function(nodes, name = NULL, label = NULL, color = NULL,
    ntext = NULL, info = NULL, image = NULL, zoom = 1,
    itemsPerRow = NULL, main = NULL, note = NULL,
    showLegend = TRUE, frequencies = FALSE,
    help = NULL, helpOn = FALSE, description = NULL,
    descriptionWidth = NULL, roundedItems = FALSE, controls = 1:2,
    cex = 1, language = c("en", "es", "ca"), dir = NULL){
  color <- setAttrByValueKey("color",color,nodes)
  return(gallery_rd3(nodes, name = name, label = label, color = color,
                     ntext = ntext, info = info, image = image,
                     zoom = zoom, itemsPerRow = itemsPerRow,
                     main = main, note = note, showLegend = showLegend,
                     frequencies = frequencies,
                     help = help, helpOn = helpOn, description = description,
                     descriptionWidth = descriptionWidth, roundedItems = roundedItems,
                     controls = 1:2, cex = cex, language = language, dir = dir))
}

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
