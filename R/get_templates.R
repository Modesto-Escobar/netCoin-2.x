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
  if(is.character(img)){
    src <- ""
    if(img=="auto"){
      src <- "_auto_"
    }else if(length(data[[img]])){
      for(i in (1:nrow(data))){
        imgpath <- as.character(data[i,img])
        if(file.exists(imgpath)){
          data[i,img] <- paste0("data:",mime(imgpath),";base64,",base64encode(imgpath))
        }
      }
      src <- data[[img]]
    }
    if(mode==2){
      if(roundedImg){
        roundedImg <- 'border-radius:50%;object-fit:cover;aspect-ratio:1/1;'
      }else{
        roundedImg <- ''
      }
      templateImg <- paste0('<img style="display:block;width:100%;',roundedImg,'" src="',src,'"/>')
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
      templateImg <- paste0('<div style="',roundedImg,heightstyle,'overflow:hidden;"><img style="width:100%;height:100%;display:block;',fit,'" src="',src,'"/></div>')
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
  templateText <- '<p class="template-text"></p>'
  if(is.character(text) && !length(setdiff(text,names(data)))){
    if(length(text)==1){
      txt <- data[[text]]
    }else{
      txt <- apply(data,1,function(d){
        paste0(d[text],collapse="<br/>")
      })
    }
    txt <- gsub("\\|",", ",txt)
    templateText <- paste0('<p class="template-text">',txt,'</p>')
  }
  templateWiki <- ''
  if(is.character(wiki) && length(data[[wiki]])){
    templateWiki <- paste0('<h3><img style="width:20px;vertical-align:bottom;margin-right:10px;" src="https://www.wikipedia.org/portal/wikipedia.org/assets/img/Wikipedia-logo-v2.png"/>Wikipedia: <a target="_blank" href="',data[[wiki]],'">',wiki,'</a></h3>')
    templateWiki[!checkwiki(data[[wiki]])] <- ""
  }
  if(!identical(templateImg,'') && mode==2){
    celldiv <- '<div style="display: inline-block; width: 50%; vertical-align: top;">'
    templateContent <- paste0(templateTitle,celldiv,'<div style="max-height:300px;overflow-y:auto;',padding,'">',templateTitle2,templateText,templateWiki,'</div></div>',celldiv,templateImg,'</div>')
  }else{
    templateContent <- paste0(templateImg,templateTitle,'<div style="',padding,'">',templateTitle2,templateText,templateWiki,'</div>')
  }
  return(paste0('<div class="info-template" style="font-size:',as.numeric(cex),'em;',margin,widthstyle,'">',templateContent,'</div>'))
}

get_template2 <- function(data, title=NULL, title2=NULL, text=NULL, wiki=NULL) {
  templateTitle <- ''
  if(is.character(title) && length(data[[title]])){
    templateTitle <- paste0('<h2>',data[[title]],'</h2>')
  }
  templateTitle2 <- ''
  if(is.character(title2) && length(data[[title2]])){
    templateTitle2 <- paste0('<h3>', data[[title2]],'</h3>')
  }
  templateText <- '<p class="template-text"></p>'
  if(is.character(text) && !length(setdiff(text,names(data)))){
    if(length(text)==1){
      txt <- data[[text]]
    }else{
      txt <- apply(data,1,function(d){
        paste0(d[text],collapse="<br/>")
      })
    }
    txt <- gsub("\\|",", ",txt)
    templateText <- paste0('<p class="template-text">',txt,'</p>')
  }
  templateWiki <- ''
  if(is.character(wiki) && length(data[[wiki]])){
    templateWiki <- paste0('<h3><img style="width:20px;vertical-align:bottom;margin-right:10px;" src="https://www.wikipedia.org/portal/wikipedia.org/assets/img/Wikipedia-logo-v2.png"/>Wikipedia: <a target="mainframe" href="',data[[wiki]],'">',wiki,'</a></h3>')
    templateWiki[!checkwiki(data[[wiki]])] <- ""
  }

  templateContent <- paste0(templateTitle,"<div>",templateTitle2,templateText,templateWiki,"</div>")

  return(paste0('<div class="info-template">',templateContent,'</div>'))
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
  if(is.character(img)){
    if(img=="auto"){
      images <- paste0('<center><img style="max-width:100%;" src="_auto_"/></center>')
    }else if(length(data[[img]])){
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

renderLinks <- function(data,columns,labels=NULL,target="_blank",sites=NULL){
  if(is.null(sites)){
    sites <- known_sites
  }
  if(!is.character(target)){
    target <- '_self'
  }
  if(!is.null(labels) && is.null(data[[labels]])){
    labels <- NULL
    warning("labels: missing column in 'data'")
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
    if(!is.null(labels)){
      label <- unlist(strsplit(data[i,labels],"|",fixed=TRUE))
      if(length(label)==length(links)){
        texts <- label
      }
    }
    html[i] <- paste0('<ul>',paste0('<li><a target="',target,'" href="', links, '"><img style="width:30px;height:30px;object-fit:contain;vertical-align:middle;margin-right:5px;" src="', icons, '"/>', texts, '</a></li>', collapse=""),'</ul>')
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

translateColumns <- function(language){
  language <- language[1]
  if(language=="es"){
    return(c("Q", "Nombre", "Descripci\uF3n", "Nacimiento", "Lugar nacimiento", "Pa\uEDs nacimiento", "Defunci\uF3n", "Lugar defunci\uF3n", "Pa\uEDs defunci\uF3n", "G\uE9nero", "Ocupaci\uF3n", "wiki"))
  }else if(language=="ca"){
    return(c("Q", "Nom", "Descripci\uF3", "Naixement", "Lloc naixement", "Pa\uEDs naixement", "Defunci\uF3", "Lloc defunci\uF3", "Pa\uEDs defunci\uF3", "G\uE8nere", "Ocupaci\uF3", "wiki"))
  }
  return(c("Q", "Name", "Description", "Birth", "Birth Place", "Birth Country", "Death", "Death Place", "Death Country", "Gender", "Occupation", "wiki"))
}

makeT <- function(data, imageDir=NULL, imageDefault=NULL, language=c("en","es","ca")) {  
  f_D <- c("entity", "entityLabel", "entityDescription", "byear", "bactualplaceLabel", "bcountryLabel", "dyear", "dactualplaceLabel", "dcountryLabel", "gender", "occupation", "wikipedias")
  if(length(setdiff(f_D,colnames(data)))){
    stop("data: wrong data input, missing columns")
  }
  D <- as.data.frame(data[, f_D])

  language <- language[1]
  f_E <- translateColumns(language)
  linksname <- "LINKS"
  if(language=="es"){
    linksname <- "ENLACES"
  }else if(language=="ca"){
    linksname <- "ENLLA\uC7OS"
  }
  names(D) <- f_E

  D[[12]] <- gsub("\\|.*","", D[[12]]) # wiki
  D$wikidata <- paste0("https://m.wikidata.org/wiki/", D[[1]])
  D[[3]] <- paste0(toupper(substr(D[[3]], 1, 1)), substr(D[[3]], 2, nchar(D[[3]]))) # description

  D$td <- ifelse(is.na(D[[7]]), 
               paste0(D[[2]], " (", D[[4]],"-)"), 
               paste0(D[[2]], " (", D[[4]],"-",D[[7]],")"))

  D$img <- NA
  if(!is.null(imageDir) && file.exists(imageDir)){
    for(type in c("jpg","jpeg","gif","png","svg")){
      subset <- is.na(D$img)
      if(sum(subset)){
        images <- file.path(imageDir,paste0(D[subset,1],".",type))
        imgexists <- file.exists(images)
        if(sum(imgexists)){
          D$img[subset & imgexists] <- images[imgexists]
        }
      }
    }
  }
  if(!is.null(imageDefault) && file.exists(imageDefault[1])){
    D$img[is.na(D$img)] <- imageDefault[1]
  }

  D$links    <- paste0('</p><h3>',linksname,':</h3>', renderLinks(D, c("wikidata", "wiki"), NULL, "mainframe"))
  D$info     <- get_template2(D, title="td", text="links")
  
  return(D[, c(f_E[c(-1,-12)], "img", "info")])
}

makeT2 <- function(entityLabel, image=NA, entityDescription=NA,
    byear=NA, bplace=NA, bcountry=NA, dyear=NA, dplace=NA, dcountry= NA,
    gender=NA, occupation=NA, language=c("en","es","ca")) {
  if(!is.vector(entityLabel)) {
    stop("entityLabel: must be a character vector")
  }

  entity <- NA
  wikipedias <- NA
  D <- data.frame(entity, entityLabel, entityDescription, byear, bplace, bcountry, dyear, dplace, dcountry, gender, occupation, wikipedias)

  translatedColumns <- translateColumns(language)
  names(D) <- translatedColumns

  image[is.na(image) | !file.exists(image)] <- NA
  D$img <- image
  D$info <- get_template2(D, title=names(D)[2])

  return(D[,c(-1,-12)])
}

checkwiki <- function(wikis){
  grepl("^(http(s)?://)?[a-z][a-z](\\.m)?\\.wikipedia\\.org",wikis)
}

pop_up <- function(data, title="name", title2=NULL, info=TRUE, entity="entity", links=c("wikidata", "wiki"), 
                   wikilangs="en") {
  sites <- data.frame(
    url=c("wikipedia.org","wikidata.org","brumario.usal.es","museoreinasofia.es","viaf.org", "bne.es", "historia-hispanica.rah.es", "id.loc.gov", "isni.org"),
    name=c("Wikipedia","Wikidata","USAL","MNCARS","VIAF", "BNE", "RAH", "LOC", "ISNI"),
    icon=c("https://www.wikipedia.org/static/favicon/wikipedia.ico","https://www.wikidata.org/static/favicon/wikidata.ico",
           "https://sociocav.usal.es/me/pics/LogoBUSAL.png",
           "https://static5.museoreinasofia.es/sites/all/themes/mrs_twitter_bootstrap/images/misc/favicon-32x32.png",
           "https://viaf.org/viaf/images/viaf.ico", 
           "https://sociocav.usal.es/me/pics/BNE.png",
           "https://sociocav.usal.es/me/pics/RAH.png",           
           "https://sociocav.usal.es/me/pics/LOC.png",           
           "https://isni.org/images/isni-logo.png")
  )
  
  langs <- unlist(strsplit(wikilangs, "\\|"))
  for(e in links) {
    if(e=="wikidata" & !is.element(e, names(data))) {
      data$wikidata <- ifelse(substr(data[[entity]], 1, 1)!="Q", NA, paste0("https://m.wikidata.org/wiki/", data[[entity]]))
    }
    if(e=="wiki" & !is.element(e, names(data))){
      wikis <- w_Wikipedias(data[[entity]], wikilangs=wikilangs)[,c(1,6)]
      wikis$wiki <- sub("\\.wikipedia",".m.wikipedia", sub("\\|.*","", wikis$pages))
      if (info) {
        names <- ifelse(is.na(wikis$wiki) | wikis$wiki=="", " ", sub(".*/","", wikis$wiki))
        wikis$info <- sub("character\\(0\\)", "", as.character(extractWiki(names,language=langs)))
      }else{
        wikis$info <- NA
      }
      data <- merge(data, wikis, by.x=entity, by.y="entity", all.x=TRUE, sort=FALSE)
      data$wiki <- ifelse(is.na(data$pages) | data$pages=="", NA, data$pages)
      data$info <- ifelse(is.na(data$info), "", data$info)
      data$pages <- wikis <- names <- NULL
    }
    if(e=="BNE") {
      data$BNE <- ifelse(is.na(data[["BNE"]]) | data[["BNE"]]=="", NA, 
                         sub("\\|.*", "", paste0("https://datos.bne.es/persona/", data[["BNE"]])))
    }
    if(e=="RAH") {
      data$RAH <- ifelse(is.na(data[["RAH"]]) | data[["RAH"]]=="", NA, 
                         sub("\\|.*", "", paste0("https://historia-hispanica.rah.es/", data[["RAH"]])))
    }
    if(e=="MNCARS") {
      data$MNCARS <- ifelse(is.na(data[["MNCARS"]]) | data[["MNCARS"]]=="", NA,
                          sub("\\|.*", "", paste0("https://museoreinasofia.es/coleccion/autor/", data[["MNCARS"]])))
    }
    if(e=="LOC") {
      data$LOC <- ifelse(is.na(data[["LOC"]]) | data[["LOC"]]=="", NA, 
                         sub("\\|.*", "", paste0("https://id.loc.gov/authorities/names/", data[["LOC"]])))
    }
    
  }

  linksList <- renderLinks(data, links, NULL, "mainframe", sites=sites)
  data$links <- ifelse(is.na(data$wiki) & is.na(data$wikidata), data$info,
                       paste0(data$info, '</p><h3>ENLACES:</h3>', linksList))
  data$pop_up <- get_template2(data, title=title, title2=title2, text="links")
  data[, union(c("links", "linksList", "info", "names", "wiki", "wikidata"), links)] <- NULL
  return(data)
}
