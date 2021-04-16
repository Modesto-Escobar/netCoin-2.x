gallery <- function(nodes, name = NULL, label = NULL, color = NULL,
    ntext = NULL, info = NULL, image = NULL,
    zoom = 1, itemsPerRow = NULL,
    main = NULL, note = NULL, showLegend = TRUE,
    help = NULL, helpOn = FALSE, description = NULL,
    descriptionWidth = NULL, roundedItems = FALSE,
    language = c("en", "es", "ca"), dir = NULL){
  color <- setAttrByValueKey("color",color,nodes)
  return(gallery_rd3(nodes, name = name, label = label, color = color,
                     ntext = ntext, info = info, image = image,
                     zoom = zoom, itemsPerRow = itemsPerRow,
                     main = main, note = note, showLegend = showLegend,
                     help = help, helpOn = helpOn, description = description,
                     descriptionWidth = descriptionWidth, roundedItems = roundedItems,
                     language = language, dir = dir))
}
