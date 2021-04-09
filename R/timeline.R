timeCoin <- function(nodes, name = "name", start = "start", end = "end", group = NULL,
                     text = NULL, main = NULL, note = NULL, info = NULL, events = NULL,
                     eventChild = "eventChild", eventParent = "eventParent", eventTime = "Time",
                     eventColor = NULL, eventShape = NULL,
                     cex = 1, language = c("en","es","ca"), dir = NULL){
  time <- timeline_rd3(nodes, name = name, start = start, end = end,
                       group = group, text = text, main = main, note = note, info = info,
                       events = events, eventChild = eventChild, eventParent = eventParent,
                       eventTime = eventTime, eventColor = eventColor, eventShape = eventShape,
                       cex = cex, language = language, dir = dir)
  class(time) <- c("timeCoin",class(time))
  return(time)
}
