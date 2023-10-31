gallery <- gallery_rd3

netGallery <- function(tree, deep = FALSE, initialType = NULL, tableformat = FALSE, ...){
  arguments <- list(...)
  net <- treeGallery_rd3(tree, deep, initialType, tableformat, ...)
  if(!is.null(net$options$nodeTypes) && !is.null(net$options$nodeText)){
    net$nodes[[net$options$nodeText]] <- sapply(seq_len(nrow(net$nodes)),function(i){
      ntext <- net$nodes[i,net$options$nodeText]
      if(!is.na(ntext) && grepl('class="info-template"',ntext,fixed=TRUE)){
        name <- net$nodes[i,net$options$nodeName]
        relatives <- list()
        for(type in net$options$nodeTypes){
          if(name %in% net$tree[,1]){
            aux <- net$tree[net$tree[,1]==name & net$tree[,4]==type,2]
          }
          if(name %in% net$tree[,2]){
            aux <- net$tree[net$tree[,2]==name & net$tree[,3]==type,1]
            if(!length(aux)){
              parent <- net$tree[net$tree[,2]==name,1]
              for(p in parent){
                aux <- c(aux,net$tree[net$tree[,1]==p & net$tree[,4]==type,2])
              }
            }
          }
          if(length(aux)){
            aux <- unique(aux)
            label <- aux
            if(!is.null(net$options$nodeLabel) && (net$options$nodeLabel!=net$options$nodeName)){
              labels <- net$nodes[[net$options$nodeLabel]]
              names(labels) <- net$nodes[[net$options$nodeName]]
              label <- labels[aux]
            }
            aux <- paste0('<span nodename="',aux,'">',label,'</span>')
            relatives[[type]] <- paste0(aux,collapse=", ")
          }
        }
        relatives <- paste0(paste0('<b>',names(relatives),':</b> ',relatives),collapse="<br/>")
        ntext <- sub('<p class="template-text">',paste0('<div class="tree-relatives">',relatives,'</div><p class="template-text">'),ntext,fixed=TRUE)
      }
      return(ntext)
    })
  }
  class(net) <- c("netGallery",class(net))
  return(net)
}

asGallery <- function(net){
  if(inherits(net,"network_rd3")){
    options <- net$options
    gallery <- gallery_rd3(nodes = net$nodes, name = options$nodeName, label = options$nodeLabel,
      color = options$nodeColor, border = options$nodeBorder, ntext = options$nodeText, info = options$nodeInfo, image = options$imageItems,
      zoom = options$zoom, main = options$main, note = options$note,
      showLegend = options$showLegend, frequencies = options$frequencies,
      help = options$help, helpOn = options$helpOn, cex = options$cex, language = options$language)
    return(gallery)
  }else{
    stop("net: must be a network object")
  }
}
