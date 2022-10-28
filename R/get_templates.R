get_template <- function(data, title=NULL, title2=NULL, text=NULL, img=NULL, wiki=NULL, width=300, color="auto", cex=1, roundedImg=FALSE, mode=1) {
  autocolor <- ''
  colorstyle <- ''
  if(length(color)){
    color <- color[1]
    if(color=="auto"){
      autocolor <- 'class="auto-color" '
    }else{
      if(length(data[[color]])){
        color <- data[[color]]
      }
      colorstyle <- paste0('background-color:',color,';')
    }
  }
  if(length(width)){
    widthstyle <- paste0(" width: ",width,"px;")
  }else{
    widthstyle <- ""
  }
  padding <- c(13,19)
  if(length(padding)){
    margin <- paste0("margin:",paste0(-padding,"px",collapse=" "),";")
    padding <- paste0("padding:",paste0(padding,"px",collapse=" "),";")
  }else{
    padding <- ""
    margin <- ""
  }

  borderRadius <- 'border-radius:12px 12px 0 0;'
  templateImg <- ''
  if(is.character(img) && length(data[[img]])){
    for(i in (1:nrow(data))){
      if(file.exists(data[i,img])){
        data[i,img] <- paste0("data:",mime(data[i,img]),";base64,",base64encode(data[i,img]))
      }
    }
    if(mode==2){
      templateImg <- paste0('<img style="display: block; width: 100%;" src="',data[[img]],'"/>')
    }else{
      fit <- ''
      heightstyle <- ''
      if(roundedImg){
        roundedImg <- 'border-radius:50%;'
        if(length(width)){
          heightstyle <- paste0('height:',width,'px;')
        }
        fit <- 'object-fit:cover;'
      }else{
        roundedImg <- borderRadius
      }
      borderRadius <- ''
      templateImg <- paste0('<div style="',roundedImg,heightstyle,'overflow:hidden;"><img style="width:100%;height:100%;display:block;',fit,'" src="',data[[img]],'"/></div>')
    }
  }
  templateTitle <- ''
  if(is.character(title) && length(data[[title]])){
    templateTitle <- paste0('<h2 ',autocolor,'style="font-size:2em;',colorstyle,padding,'margin:-3px 0 0 0;',borderRadius,'">',data[[title]],'</h2>')
  }
  templateTitle2 <- ''
  if(is.character(title2) && length(data[[title2]])){
    templateTitle2 <- paste0('<h3>', data[[title2]],'</h3>')
  }
  templateText <- '<p></p>'
  if(is.character(text) && length(data[[text]])){
    templateText <- paste0('<p>',gsub("\\|",", ",data[[text]]),'</p>')
  }
  templateWiki <- ''
  if(is.character(wiki) && length(data[[wiki]])){
    templateWiki <- paste0('<h3><img style="width:20px;vertical-align:bottom;margin-right:10px;" src="https://www.wikipedia.org/portal/wikipedia.org/assets/img/Wikipedia-logo-v2.png"/>Wikipedia: <a target="_blank" href="',data[[wiki]],'">',wiki,'</a></h3>')
  }
  if(templateImg!='' && mode==2){
    celldiv <- '<div style="display: inline-block; width: 50%; vertical-align: top;">'
    templateContent <- paste0(templateTitle,celldiv,'<div style="',padding,'">',templateTitle2,templateText,templateWiki,'</div></div>',celldiv,templateImg,'</div>')
  }else{
    templateContent <- paste0(templateImg,templateTitle,'<div style="',padding,'">',templateTitle2,templateText,templateWiki,'</div>')
  }
  return(paste0('<div class="info-template" style="font-size:',as.numeric(cex),'em;',margin,widthstyle,'">',templateContent,'</div>'))
}

get_panel_template <- function(data, title=NULL, description=NULL, img=NULL,  text=NULL, cex=1){
  images <- ""
  if(is.character(img) && length(data[[img]])){
    images <- data[[img]]
    for(i in seq_along(images)){
      if(file.exists(images[i])){
        images[i] <- paste0("data:",mime(images[i]),";base64,",base64encode(images[i]))
      }
    }
    images <- paste0('<center><img src="',images,'"/></center>')
  }
  return(paste0('<div class="panel-template auto-color" style="padding:24px;font-size:',as.numeric(cex),'em;"><h2 style="padding-bottom:12px;color:#ffffff;font-weight:bold;">',data[[title]],'</h2><div style="background-color:#ffffff;padding:12px;"><p>',gsub("\\|",", ",data[[description]]),'</p>',images,'<p></p>',gsub("\\|",", ",data[[text]]),'</div></div>'))
}

base64encode <- function(filename) {
  to.read = file(filename, "rb")
  fsize <- file.size(filename)
  sbit <- readBin(to.read, raw(), n = fsize, endian = "little")
  close(to.read)
  b64c <- "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  shfts <- c(18,12,6,0)
  sand <- function(n,s) bitwAnd(bitwShiftR(n,s),63)+1
  slft <- function(p,n) bitwShiftL(as.integer(p),n)
  subs <- function(s,n) substring(s,n,n)
  npad <- ( 3 - length(sbit) %% 3) %% 3
  sbit <- c(sbit,as.raw(rep(0,npad)))
  pces <- lapply(seq(1,length(sbit),by=3),function(ii) sbit[ii:(ii+2)])
  encv <- paste0(sapply(pces,function(p) paste0(sapply(shfts,function(s)(subs(b64c,sand(slft(p[1],16)+slft(p[2],8)+slft(p[3],0),s)))))),collapse="")
  if (npad > 0) substr(encv,nchar(encv)-npad+1,nchar(encv)) <- paste0(rep("=",npad),collapse="")
  return(encv)
}

mime <- function(name) {
  mimemap <- c(jpeg = "image/jpeg", jpg = "image/jpeg", png = "image/png", svg = "image/svg", gif = "image/gif")
  ext <- sub("^.*\\.","",name)
  mime <- unname(mimemap[tolower(ext)])
  return(mime)
}