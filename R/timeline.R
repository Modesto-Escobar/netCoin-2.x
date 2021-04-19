timeCoin <- function(periods, name = "name", start = "start", end = "end", group = NULL,
                     text = NULL, main = NULL, note = NULL, info = NULL, 
                     events = NULL, eventNames = "name", eventPeriod = "period", eventTime = "date",
                     eventColor = NULL, eventShape = NULL,
                     cex = 1, language = c("en","es","ca"), dir = NULL){
  time <- timeline_rd3(periods, name = name, start = start, end = end,
                       group = group, text = text, main = main, note = note, info = info,
                       events = events, eventChild = eventNames, eventParent = eventPeriod,
                       eventTime = eventTime, eventColor = eventColor, eventShape = eventShape,
                       cex = cex, language = language, dir = dir)
  class(time) <- c("timeCoin",class(time))
  return(time)
}

summary.timeCoin <- function(object, ...){
  cat(dim(object$nodes)[1], "categories.\n")
  cat(object$options$start, "'s distribution:","\n",sep="")
  print(summary(object$nodes[[object$options$start]]))
  cat(object$options$end, "'s distribution:","\n",sep="")
  print(summary(object$nodes[[object$options$end]]))
}

