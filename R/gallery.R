gallery <- function(nodes, name = NULL, label = NULL, color = NULL,
    ntext = NULL, info = NULL, image = NULL,
    zoom = 1, main = NULL, note = NULL, help = NULL,
    language = c("en", "es", "ca"), dir = NULL){
  color <- setAttrByValueKey("color",color,nodes)
  return(gallery_rd3(nodes, name, label, color, ntext, info, image, zoom, main, note, help, language))
}
