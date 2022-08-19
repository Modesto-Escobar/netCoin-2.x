multigraphCreate <- function(..., mode = c("default","parallel","frame"),
  frame = 0, speed = 50, loop = FALSE, lineplots = NULL,
  dir = NULL, show = FALSE){

  diraux <- NULL
  if(!is.null(dir) && !identical(show,TRUE)){
    diraux <- dir
  }

  mode <- substr(mode[1],1,1)
  if(mode=="p"){
    obj <- rd3_multigraph(..., mode="p", dir=diraux)
  }else if(mode=="f"){
    obj <- evolNetwork_rd3(..., frame, speed, loop, lineplots, diraux)
  }else{
    obj <- rd3_multigraph(..., dir=diraux)
  }

  if(identical(show,TRUE)){
    if(is.null(dir)){
      plot(obj)
    }else{
      plot(obj,dir=dir)
    }
  }

  class(obj) <- c("mGraph",class(obj))
  return(obj)
}
