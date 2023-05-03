get_template <- function(data, title=NULL, title2=NULL, text=NULL, img=NULL, wiki=NULL, width=300, color="auto", cex=1, roundedImg=FALSE, mode=1) {
  autocolor <- ''
  colorstyle <- ''
  fontcolor <- ''
  if(length(color)){
    color <- color[1]
    if(color=="auto"){
      autocolor <- 'class="auto-color" '
    }else{
      if(length(data[[color]])){
        color <- data[[color]]
      }
      colorstyle <- paste0('background-color:',color,';')
      fontcolor <- getFontColor(color)
      fontcolor <- paste0('color:',fontcolor,';')
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
    templateTitle <- paste0('<h2 ',autocolor,'style="font-size:2em;',colorstyle,fontcolor,padding,'margin:-3px 0 0 0;',borderRadius,'">',data[[title]],'</h2>')
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
  if(!identical(templateImg,'') && mode==2){
    celldiv <- '<div style="display: inline-block; width: 50%; vertical-align: top;">'
    templateContent <- paste0(templateTitle,celldiv,'<div style="',padding,'">',templateTitle2,templateText,templateWiki,'</div></div>',celldiv,templateImg,'</div>')
  }else{
    templateContent <- paste0(templateImg,templateTitle,'<div style="',padding,'">',templateTitle2,templateText,templateWiki,'</div>')
  }
  return(paste0('<div class="info-template" style="font-size:',as.numeric(cex),'em;',margin,widthstyle,'">',templateContent,'</div>'))
}

get_panel_template <- function(data, title=NULL, description=NULL, img=NULL,  text=NULL, color="auto", cex=1, mode=1){
  autocolor <- ''
  colorstyle <- ''
  fontcolor <- ''
  if(length(color)){
    color <- color[1]
    if(color=="auto"){
      autocolor <- ' auto-color'
    }else{
      if(length(data[[color]])){
        color <- data[[color]]
      }
      colorstyle <- paste0('background-color:',color,';')
      fontcolor <- getFontColor(color)
      fontcolor <- paste0('color:',fontcolor,';')
    }
  }

  images <- ""
  if(is.character(img) && length(data[[img]])){
    images <- data[[img]]
    for(i in seq_along(images)){
      if(is.na(images[i])){
        images[i] <- ""
      }else{
        if(file.exists(images[i])){
          images[i] <- paste0("data:",mime(images[i]),";base64,",base64encode(images[i]))
        }
        images[i] <- paste0('<center><img style="max-width:100%;" src="',images[i],'"/></center>')
      }
    }
  }
  if(mode==2){
    return(paste0('<div class="panel-template',autocolor,' mode-2" style="font-size:',as.numeric(cex),'em;height:100%;"><h2 style="padding:24px 24px 12px 24px;',fontcolor,'font-weight:bold;font-size:2em;',colorstyle,'">',data[[title]],'</h2><div style="padding:24px;"><p style="text-align:justify">',gsub("\\|",", ",data[[description]]),'</p>',images,'<p></p>',gsub("\\|",", ",data[[text]]),'</div></div>'))
  }else{
    return(paste0('<div class="panel-template',autocolor,' mode-1" style="padding:24px;min-height:calc(100% - 48px);font-size:',as.numeric(cex),'em;display:flex;flex-direction:column;',colorstyle,'"><h2 style="padding-bottom:12px;',fontcolor,'font-weight:bold;font-size:2em;">',data[[title]],'</h2><div style="background-color:#ffffff;padding:12px;flex-grow:1;"><p style="text-align:justify">',gsub("\\|",", ",data[[description]]),'</p>',images,'<p></p>',gsub("\\|",", ",data[[text]]),'</div></div>'))
  }
}

known_sites <- data.frame(
  url=c("wikipedia.org","wikidata.org","wikimedia.org","twitter.com","facebook.com"),
  name=c("Wikipedia","Wikidata","Wikimedia","Twitter","Facebook"),
  icon=c("https://www.wikipedia.org/static/favicon/wikipedia.ico","https://www.wikidata.org/static/favicon/wikidata.ico","https://foundation.wikimedia.org/favicon.ico","https://abs.twimg.com/favicons/twitter.2.ico","https://static.xx.fbcdn.net/rsrc.php/yb/r/hLRJ1GG_y0J.ico")
)

renderLinks <- function(data,columns,target="_blank",sites=NULL){
  if(is.null(sites)){
    sites <- known_sites
  }
  if(!is.character(target)){
    target <- '_self'
  }
  html <- character(nrow(data))
  for(i in seq_len(nrow(data))){
    links <- data[i,intersect(columns,names(data))]
    links <- links[!is.na(links)]
    texts <- links
    icons <- rep('https://upload.wikimedia.org/wikipedia/commons/6/6a/External_link_font_awesome.svg',length(links))
    for(j in seq_along(links)){
      for(k in seq_len(nrow(sites))){
        if(grepl(sites[k,'url'],links[j])){
          texts[j] <- sites[k,'name']
          icons[j] <- sites[k,'icon']
          break
        }
      }
    }
    html[i] <- paste0('<ul>',paste0('<li><a target="',target,'" href="', links, '"><img style="width:30px;vertical-align:bottom;margin-right:5px;" src="', icons, '"/>', texts, '</a></li>', collapse=""),'</ul>')
  }
  return(html)
}

getFontColor <- function(color){
  return(sapply(color,function(x){
        rgb <- col2rgb(x)[,1]
        if(((0.2126*rgb[1] + 0.7152*rgb[2] + 0.0722*rgb[3])/255)>0.75){
          return("#000000")
        }else{
          return("#ffffff")
        }
  }))
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
