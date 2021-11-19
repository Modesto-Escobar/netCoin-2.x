## Programs to apply net coin analysis
# Image is a files vector with length and order equal to nrow(nodes). Place as nodes field
# Batch

netCoin <- function(nodes = NULL, links = NULL, tree = NULL,
        community = NULL, layout = NULL,
        name = NULL, label = NULL, group = NULL, groupText = FALSE,
        labelSize = NULL, size = NULL, color = NULL, shape = NULL,
        border = NULL, legend = NULL, sort = NULL, decreasing = FALSE,
        ntext = NULL, info = NULL, image = NULL, imageNames = NULL,
        centrality = NULL,
        nodeBipolar = FALSE, nodeFilter = NULL, degreeFilter = NULL,
        lwidth = NULL, lweight = NULL, lcolor = NULL, ltext = NULL,
        intensity = NULL, linkBipolar = FALSE, linkFilter = NULL,
        repulsion = 25, distance = 10, zoom = 1,
        fixed = showCoordinates, limits = NULL,
        main = NULL, note = NULL, showCoordinates = FALSE, showArrows = FALSE,
        showLegend = TRUE, frequencies = FALSE, showAxes = FALSE,
        axesLabels = NULL, scenarios = NULL, help = NULL, helpOn = FALSE,
        mode = c("network","heatmap"), controls = 1:4, cex = 1,
        background = NULL, defaultColor = "#1f77b4",
        language = c("en","es","ca"), dir = NULL)
{
  if(is.null(links) &&  is.null(nodes)){
    stop("You must explicit a nodes or links data frame, or a netCoin object.")
  }

  if(inherits(nodes,"netCoin")){
    links <- nodes$links
    tree <- nodes$tree
    options <- nodes$options
    nodes <- nodes$nodes

    arguments <- names(as.list(match.call()))

    getOpt <- function(opt,item=opt){
      if(item %in% arguments){
        return(get0(item))
      }else{
        if(!is.null(options[[opt]])){
          return(options[[opt]])
        }else{
          return(NULL)
        }
      }
    }

    name <- getOpt("nodeName","name")

    cex <- getOpt("cex")
    distance <- getOpt("distance")
    repulsion <- getOpt("repulsion")
    zoom <- getOpt("zoom")
    scenarios <- getOpt("scenarios")
    limits <- getOpt("limits")
    main <- getOpt("main")
    note <- getOpt("note")
    help <- getOpt("help")
    background <- getOpt("background")
    language <- getOpt("language")
    nodeBipolar <- getOpt("nodeBipolar")
    linkBipolar <- getOpt("linkBipolar")
    helpOn <- getOpt("helpOn")
    frequencies <- getOpt("frequencies")
    defaultColor <- getOpt("defaultColor")
    controls <- getOpt("controls")
    mode <- getOpt("mode")
    axesLabels <- getOpt("axesLabels")
    fixed <- getOpt("fixed")
    showCoordinates <- getOpt("showCoordinates")
    showArrows <- getOpt("showArrows")
    showLegend <- getOpt("showLegend")
    showAxes <- getOpt("showAxes")

    label <- getOpt("nodeLabel","label")
    labelSize <- getOpt("nodeLabelSize","labelSize")
    group <- getOpt("nodeGroup","group")
    groupText <- getOpt("groupText")
    size <- getOpt("nodeSize","size")
    color <- getOpt("nodeColor","color")
    shape <- getOpt("nodeShape","shape")
    border <- getOpt("nodeBorder","border")
    legend <- getOpt("nodeLegend","legend")
    ntext <- getOpt("nodeText","ntext")
    info <- getOpt("nodeInfo","info")
    sort <- getOpt("nodeOrder","sort")
    decreasing <- getOpt("decreasing")
    image <- getOpt("imageItems","image")
    imageNames <- getOpt("imageNames")

    lwidth <- getOpt("linkWidth","lwidth")
    lweight <- getOpt("linkWeight","lweight")
    lcolor <- getOpt("linkColor","lcolor")
    ltext <- getOpt("linkText","ltext")
    intensity <- getOpt("linkIntensity","intensity")
  }else{
    name <- nameByLanguage(name,language,nodes)
    if(!is.null(nodes)){
      if (all(inherits(nodes,c("tbl_df","tbl","data.frame"),TRUE))) nodes<-as.data.frame(nodes) # convert haven objects
    }
    if(!is.null(links)){
      if (all(inherits(links,c("tbl_df","tbl","data.frame"),TRUE))) links<-as.data.frame(links) # convert haven objects
    }
  }

  color <- setAttrByValueKey("color",color,nodes)
  shape <- setAttrByValueKey("shape",shape,nodes)
  lcolor <- setAttrByValueKey("lcolor",lcolor,links)

  net <- network_rd3(nodes = nodes, links = links, tree = tree,
        community = community, layout = layout,
        name = name, label = label, group = group, groupText = groupText,
        labelSize = labelSize, size = size, color = color, shape = shape,
        border = border, legend = legend,
        sort = sort, decreasing = decreasing, ntext = ntext, info = info,
        image = image, imageNames = imageNames,
        nodeBipolar = nodeBipolar, nodeFilter = nodeFilter, degreeFilter = degreeFilter,
        source = "Source", target = "Target",
        lwidth = lwidth, lweight = lweight, lcolor = lcolor, ltext = ltext,
        intensity = intensity, linkBipolar = linkBipolar, linkFilter = linkFilter,
        repulsion = repulsion, distance = distance, zoom = zoom,
        fixed = fixed, limits = limits,
        main = main, note = note, showCoordinates = showCoordinates, showArrows = showArrows,
        showLegend = showLegend, frequencies = frequencies, showAxes = showAxes,
        axesLabels = axesLabels, scenarios = scenarios, help = help, helpOn = helpOn,
        mode = mode, controls = controls, cex = cex,
        background = background, defaultColor = defaultColor,
        language = language, dir = dir)
  class(net) <- c("netCoin",class(net))

  if(!is.null(centrality)){
    columns <- calCentr(net, centrality)$nodes
    for(col in setdiff(colnames(columns),c("nodes","degree"))){
      net$nodes[[col]] <- columns[[col]]
    }
  }

  return(net)
}

setAttrByValueKey <- function(name,item,items){
    if(is.list(item) && !is.data.frame(item)){
      checkedlist <- list()
      for(k in names(item)){
        if(!k %in% colnames(items) || !(is.character(items[[k]]) || is.factor(items[[k]]))){
          warning(paste0(name,": the names in the list must match character columns of the items, but '",k,"' doesn't"))
        }else{
          if(!is.character(item[[k]]) || is.null(names(item[[k]]))){
            warning(paste0(name,": each item in the list must be a named character vector describing value-",name,", but '",k,"' doesn't"))
          }else{
            checkedlist[[k]] <- unname(item[[k]][items[[k]]])
          }
        }
      }
      if(length(checkedlist)){
        item <- as.data.frame(checkedlist)
      }else{
        item <- NULL
      }
    }
    return(item)
}


# Program to apply nets to correlations

netCorr<-function(variables, weight=NULL, pairwise=FALSE,
                  minimum=-Inf, maximum=Inf, sort=FALSE, decreasing=TRUE,
                  frequency=FALSE, means=TRUE, 
                  method="pearson", criteria="p", Bonferroni=FALSE,
                  minL=0, maxL=Inf,
                  sortL=NULL, decreasingL=TRUE,
                  igraph=FALSE, ...)
{
  arguments <- list(...)
  arguments$name <- nameByLanguage(arguments$name,arguments$language,arguments$nodes)
  if(!("size" %in% names(arguments))) arguments$size <- "mean"
  if(!("lwidth" %in% names(arguments))) arguments$lwidth <- "value"
  if(!("lweight" %in% names(arguments))) arguments$lweight <- "value"
  if (!pairwise) variables<-na.omit(variables)
  cases<-nrow(variables)
  if (criteria=="p" & maxL==Inf)  maxL<-.5
  if (criteria=="p" & Bonferroni) maxL<-maxL/choose(cases,2)
  statistics <-data.frame(name=colnames(variables),
                          mean=round(apply(variables,2,mean, na.rm=TRUE),2),
                          std=round(sqrt(apply(variables,2,var, na.rm=TRUE)),2),
                          min=apply(variables,2,min, na.rm=TRUE),
                          max=apply(variables,2,max, na.rm=TRUE))
  colnames(statistics)[1] <- arguments$name
  if(!is.null(arguments$nodes)) arguments$nodes <- merge(statistics, arguments$nodes, by=arguments$name, all.x=TRUE)
  else arguments$nodes <- statistics
  if (pairwise) use <- "pairwise.complete.obs"
  else use <- "complete.obs"
  R<-cor(variables[,arguments$nodes[,2]>=minimum & arguments$nodes[,2]<=maximum],method=method, use=use)
  E<-edgeList(R, "shape", min=-1, max=1, directed=FALSE, diagonal=FALSE)
  E$z<-E$value*sqrt(cases)
  E$p<-1-pt(E$z,cases-1)
  E<-E[E[[criteria]]>=minL & E[[criteria]]<=maxL,]
  if (!is.null(sortL)) E<-E[order((-1*decreasingL+!decreasingL)*E[[sortL]]),]
  arguments$links <- E
  
  xNx <- do.call(netCoin,arguments)
  if (igraph) return(toIgraph(xNx))
  else return(xNx)
}

# Complete netCoin from an incidences matrix

allNet<-function(incidences, weight = NULL, subsample = FALSE, pairwise = FALSE,
                 minimum=1, maximum = nrow(incidences), sort = FALSE, decreasing = TRUE,
                 frequency = FALSE, percentages = TRUE, 
                 procedures = "Haberman", criteria = "Z", Bonferroni = FALSE,
                 support = -Inf, minL = -Inf, maxL = Inf,
                 directed = FALSE, diagonal = FALSE, sortL = NULL, decreasingL = TRUE,
                 igraph = FALSE, dir=NULL, ...)
{
  arguments <- list(...)
  arguments$dir<-dir
  if((criteria=="Z" | criteria=="hyp") & maxL==Inf) maxL=.5
  if(!("language" %in% names(arguments))) arguments$language <- "en"
  arguments$name <- nameByLanguage(arguments$name,arguments$language,arguments$nodes)
  if (!("size" %in% names(arguments)))
    if(percentages)
      arguments$size <- "%"
  if (!("level" %in% names(arguments))) level<-.95 else level <-arguments$level
  if (!pairwise) incidences<-na.omit(incidences)
  if (all(is.na(incidences) | incidences==0 | incidences==1)) {
    C<-coin(incidences, minimum, maximum, sort, decreasing, weight=weight, subsample=subsample, pairwise = pairwise)
    if(exists("size",arguments))if(arguments$size=="frequency")frequency=TRUE
    O<-asNodes(C,frequency,percentages,arguments$language)
    names(O)[1]<-arguments$name
    if (is.null(arguments$nodes)){
      if(any(sapply(incidences,function(X) {"label" %in% names(attributes(X))}))) {
        label <- "label"
        if(arguments$language %in% c("es","ca")){
          label <- "etiqueta"
        }
        O[[label]] <- "NULL"
        O[[label]] <- ifelse(sapply(incidences, attr, "label")=="NULL", O[[arguments$name]], sapply(incidences, attr, "label"))
        arguments$label <- label
      }
      arguments$nodes<-O
    }else{
      nodesOrder<-as.character(arguments$nodes[[arguments$name]])
      arguments$nodes<-merge(O,arguments$nodes[,setdiff(names(arguments$nodes),frequencyList),drop=FALSE],by.x=arguments$name,by.y=arguments$name,all.y=TRUE, sort=FALSE)
      row.names(arguments$nodes)<-arguments$nodes[[arguments$name]]
      arguments$nodes<-arguments$nodes[nodesOrder,]
    }
    procedures<-union(procedures,unlist(arguments[c("lwidth","lweight","lcolor","ltext")]))
    arguments$links<-edgeList(C, procedures, criteria, level, Bonferroni, minL, maxL, support, 
                              directed, diagonal, sortL, decreasingL)
    for(lattr in c("lwidth","lweight","lcolor","ltext"))
      if(!is.null(arguments[[lattr]])) arguments[[lattr]]<-i.method(c.method(arguments[[lattr]]))
    if(is.character(arguments$layout)){
      if(tolower(substr(arguments$layout,1,2))=="mc")arguments$layout<-layoutMCA(incidences)
      else if(tolower(substr(arguments$layout,1,2))=="pc")arguments$layout<-layoutPCA(C)
    }
    arguments$scenarios <- attr(C,"n")
    xNx <- do.call(netCoin,arguments)
    if (igraph) return(toIgraph(xNx))
    else return(xNx)
  }
  else warning("Input is not a dichotomous matrix of incidences")
}


# surCoin is a wrapper to build a netCoin object from an original non-dichotomized data.frame. See below dichotomize()

surCoin<-function(data,variables=names(data), commonlabel=NULL,
                  dichotomies=NULL, valueDicho=1, metric=NULL, exogenous=NULL,
                  weight=NULL, subsample=FALSE, pairwise=FALSE,
                  minimum=1, maximum=nrow(data), sort=FALSE, decreasing=TRUE,
                  frequency=FALSE, percentages=TRUE,
                  procedures="Haberman", criteria="Z", Bonferroni=FALSE,
                  support=-Inf, minL=-Inf, maxL=Inf,
                  directed=FALSE, diagonal=FALSE, sortL=NULL, decreasingL=TRUE,
                  igraph=FALSE, coin=FALSE, dir=NULL, ...)
{
  arguments <- list(...)
  if((criteria=="Z" | criteria=="hyp") & maxL==Inf) maxL=.5
  varOrder  <- variables # To order variables later before coin
  #Check methods. No necessary because edgeList call these routines.
  #procedures<-i.method(c.method(procedures))
  #criteria<-i.method(c.method(criteria))
  procedures<-union(procedures,unlist(arguments[c("lwidth","lweight","lcolor","ltext")]))
  
  #Metrics 
  if(!is.null(metric)) {
    variables<-setdiff(variables,metric)
    procedures<-intersect(union(procedures,"Z"),c("Pearson","Haberman","Z"))
    criteria<-intersect(union(criteria,"Z"),c("Pearson","Haberman","Z"))[1]
  }
  
  #Names  
  if(!("language" %in% names(arguments))) arguments$language <- "en"
  nodes <- arguments$nodes
  if (inherits(nodes,"tbl_df")) nodes<-as.data.frame(nodes)
  name <- arguments$name <- nameByLanguage(arguments$name,arguments$language,arguments$nodes)
  if (!("level" %in% names(arguments))) level<-.95 else level <-arguments$level
  
  #Data.frame  
  if (all(inherits(data,c("tbl_df","tbl","data.frame"),TRUE))) data<-as.data.frame(data) # convert haven objects
  if (inherits(weight,"character")) variables <- setdiff(variables,weight)
  allvar<-union(union(metric,dichotomies),variables)
  
  if (!pairwise & inherits(weight,"character")) {
    if (!is.null(weight)) weight <- data[rowSums(is.na(data[,allvar]))<1,weight]
    data <- data[complete.cases(data[,allvar]),]
  }
  
  if(!is.null(weight)) {
    if(inherits(weight,"character")){
      weight<-data[,weight]
      data<-data[,allvar]
    }
    else{
      if(length(weight)!=dim(data)[1]) stop("Weights have not the correct dimensions")
      if (pairwise) data <- cbind(data[,allvar],weight)[,1:length(data[,allvar])]
      else data <- na.omit(cbind(data[,allvar],weight))[,1:length(data[,allvar])]
    }
  }
  else data<-data[,allvar]
  
  data[,variables]<-as_factor(data[,variables])
  arguments$scenarios <- sum(rowSums(!is.na(data))>0) # Number of scenarios

  #Size 
  if(!("size" %in% names(arguments)))
    if(percentages)
      arguments$size <- "%"
  
  #Dichotomies    
  if(!is.null(dichotomies)){
    if(length(valueDicho)>1 & !is.list(valueDicho)) stop("valueDicho must be a value or a list")
    dichos<-dicho(data, dichotomies, valueDicho, newlabel = FALSE)
    variables<-setdiff(variables,dichotomies)
  }
  
  #Dichotomize
  if (length(variables)>0){
    incidences<-dichotomize(data, variables, "", min=minimum, length=0, values=NULL, sparse=FALSE, add=FALSE, sort=sort, nas=NULL)
    if(!is.null(dichotomies)) incidences<-cbind(dichos,incidences)
  } 
  else if(exists("dichos")) incidences<-dichos
  
  #Nodes filter  
  if (!is.null(nodes)) {
    nonAmong  <-setdiff(as.character(nodes[[name]]),names(incidences))
    nodeList  <-setdiff(as.character(nodes[[name]]),nonAmong)
    incidences<-incidences[,nodeList, drop=FALSE]
    nonAmongM <- setdiff(metric, as.character(nodes[[name]]))
    metric    <- setdiff(metric,nonAmongM)
    if (length(metric)==0) metric <-NULL
    if (length(nonAmong)>0)
      warning(paste0(toString(nonAmong)," is/are not present in the data frame."))
    # nodes <- nodes[as.character(nodes[[name]]) %in% union(names(incidences),metric),]
  }
  
  #Nodes elaboration
  if (!exists("incidences") | ncol(incidences)<2) stop("There are no more than 1 qualitative category. Try netCorr.")
  if (all(is.na(incidences) | incidences==0 | incidences==1)) {
    incidences <- incidences[,names(incidences)[order(match(sub(":.*","",names(incidences)),varOrder))], drop=FALSE]
    C<-coin(incidences, minimum, maximum, sort, decreasing, weight=weight, subsample=subsample, pairwise = pairwise)
    if(coin) return(C)
    O<-asNodes(C,frequency,percentages,arguments$language)
    names(O)[1]<-name
    O$variable <- sub(":.*","",O[,name])
    if(!is.null(nodes)) {
      O<-merge(O,nodes[,setdiff(names(nodes),frequencyList),drop=FALSE],by.x=name,by.y=name,all.x=TRUE)
    }else {
      if (!is.null(commonlabel)) { # Preserve the prename (variable) of a node if specified in commonlabel
        arguments$label<-getByLanguage(labelList,arguments$language)
        provlabels<-as.character(O[[name]])
        O[[arguments$label]]<-ifelse(substr(O[[name]],1,regexpr('\\:',O[[name]])-1) %in% commonlabel,provlabels,substr(O[[name]],regexpr('\\:',O[[name]])+1,1000000L))
      }
    }
    
    #Links elaboration
    E<-edgeList(C, procedures, criteria, level, Bonferroni, minL, maxL, support, 
                directed, diagonal, sortL, decreasingL, pairwise)
    for(lattr in c("lwidth","lweight","lcolor","ltext"))
      if(!is.null(arguments[[lattr]])) arguments[[lattr]]<-i.method(c.method(arguments[[lattr]]))
    
    if(!is.null(arguments$layout)) {
      layout2 <- layout <- arguments$layout
      if (inherits(layout,"matrix") && is.null(metric)){
        if (!is.null(nodes)){
          if(nrow(layout)==nrow(nodes)){
            Oxy <- matrix(NA,nrow(O),2)
            rownames(Oxy) <- as.character(O[,name])
            rownames(layout) <- as.character(nodes[,name])
            layoutnames <- intersect(rownames(Oxy),rownames(layout))
            Oxy[layoutnames,] <- layout[layoutnames,]
            arguments$layout <- Oxy
          } else warning("layout must have a coordinate per node")
        } else warning("layout must be applied to the nodes variable")
      } else {
        if(is.character(layout)){
          if(tolower(substr(layout,1,2))=="mc")arguments$layout<-layoutMCA(incidences)
          else if(tolower(substr(layout,1,2))=="pc")arguments$layout<-layoutPCA(C)
        }
        else if(!is.null(metric)) arguments$layout<-NULL # There is metric information and not MCA or PCA
      }
    }

    if(!is.null(metric)) {
      #Metric nodes elaboration
      if(percentages) O$mean<-O$`%`/100
      O$min<-0
      O$max<-1
      means<-sapply(na.omit(data[,metric, drop=F]),mean)
      mins<-sapply(na.omit(data[,metric, drop=F]),min)
      maxs<-sapply(na.omit(data[,metric, drop=F]),max)
      P<-(means-mins)/(maxs-mins)*100
      O2<-data.frame(name=names(means),mean=means,min=mins,max=maxs,P=P,variable=names(means))
      colnames(O2)[1] <- name
      colnames(O2)[5] <- "%"
      if(!is.null(nodes)){
        O2 <- O2[as.character(O2[[name]]) %in% as.character(nodes[[name]]),] #nodes filter 
        for(col in as.character(O2[[name]]))
          O2[as.character(O2[[name]])==col,colnames(nodes)] <- nodes[as.character(nodes[[name]])==col,]
      }
      O<-rbind.all.columns(O,O2)

      #Metric links elaboration
      methods<-union(procedures,criteria)
      if (pairwise) R <- corrp(data[,metric, drop=F], cbind(incidences, data[,metric, drop=F]), weight=weight)
      else R <- corr(data[,metric, drop=F], cbind(incidences,data[,metric, drop=F]), weight=weight)      
      if (nrow(R)==1) row.names(R)<-metric
      allvar<-union(as.character(nodes[[name]]),c(names(incidences),metric))
      order1<-intersect(allvar,rownames(R))
      order2<-intersect(allvar,colnames(R))
      R<-R[order1,order2, drop=F]
      Pearson<-mats2edges(R)
      colnames(Pearson)[3]<-"Pearson"
      D<-as.data.frame(Pearson)
      if("Haberman" %in% methods){
        H<-R*sqrt(nrow(incidences))
        Haberman<-mats2edges(H)
        D<-cbind(D,Haberman[,3]); colnames(D)[length(D)]<-"Haberman"
      }
      if("Z" %in% methods) {
        t<-R/sqrt((1-pmin(1L,R))/(nrow(incidences)-2))
        Z <- mats2edges(1-pt(t,nrow(incidences)-2))
        D<-cbind(D,Z[,3]); colnames(D)[length(D)]<-"Z"
      }
      D<-D[,c("Source","Target",methods)]
      D<-D[D[criteria] > minL & D[criteria] < maxL,]
      colnames(D)<-sub("^Z$","p(Z)",colnames(D))
      if(is.null(E))E<-D
      else E<-rbind.all.columns(E,D)

      #Layout
      if (inherits(layout,"matrix")){
        if (!is.null(nodes)){
          if(nrow(layout2)==nrow(nodes)){
            Oxy <- matrix(NA,nrow(O),2)
            rownames(Oxy) <- as.character(O[,name])
            rownames(layout2) <- as.character(nodes[,name])
            layoutnames <- intersect(rownames(Oxy),rownames(layout2))
            Oxy[layoutnames,] <- layout2[layoutnames,]
            layout2 <- Oxy
          } else warning("layout must have a coordinate per node")
        } else warning("layout must be applied to the nodes variable")
        arguments$layout <- layout2
      }
    }
    if (!is.null(exogenous)) {
      exogenous2<-intersect(exogenous,c(metric,dichotomies))
      E$chaine<-ifelse(((substr(E$Source,1,regexpr("\\:",E$Source)-1) %in% exogenous) |
                                  (E$Source %in% exogenous2))  &
                                 ((substr(E$Target,1,regexpr("\\:",E$Target)-1) %in% exogenous) |
                                    (E$Target %in% exogenous2)),"No","Yes")
      arguments$linkFilter<-paste(ifelse(is.null(arguments$linkFilter),"",paste(arguments$linkFilter,"&")),"chaine=='Yes'")
    }
    if("showArrows" %in% names(arguments$options) & exists("nodes")) E<-orderEdges(E,nodes[[name]])
    if(exists("ltext",arguments)) {
      if(toupper(arguments$ltext) == "Z") arguments$ltext <- "p(Z)"
      if(arguments$ltext =="Fisher") arguments$ltext <- "p(Fisher)"
    }

    if(!is.null(dir)){
      arguments$dir <- dir
    }
    arguments$nodes <- O
    arguments$links <- E
    xNx <- do.call(netCoin,arguments)
    if (igraph) {
      return(toIgraph(xNx))
    } else {
      return(xNx)
    }
  } else warning("Input is not a dichotomous matrix of incidences")
}

# surScat is a wrapper to build a netCoin object from an original non-dichotomized data.frame and see frequencies.

surScat <- function(data, variables=names(data), active=variables, type= c("mca", "pca"), nclusters=2, maxN=2000, ...) {
  if(type[1]=="mca") {
    B <- as.data.frame(droplevels(as_factor(na.omit(data[,variables]))))
    b <- B[,active]
    m <- as.matrix(dichotomize(b,variables=names(b), sort=F, add=F, nas=NULL))
    cc <- layoutMca(m, rows=T)
  }
  else {
    B <- na.omit(data[,variables])
    b <- as.data.frame(sapply(B[,active], as.numeric))
    factors <- setdiff(variables, active)
    B[, factors] <- as.data.frame(droplevels(as_factor(B[,factors])))
    B[, active]  <- b
    m  <- prcomp(b, center = TRUE, scale. = TRUE)
    cc <- m$x[,1:2]
  }
  for(i in nclusters) {
    G <- stats::kmeans(cc, centers=i)
    g <- paste0("Grupos(",sprintf(paste0("%0",length(levels(G$cluster)),"d"),i),")")
    B[[g]] <- paste0("Grupo: ",sprintf(paste0("%0",length(levels(G$cluster)),"d"),G$cluster))
  }
  arguments <- list(...)
  arguments$name <- nameByLanguage(NULL,arguments$language,NULL)
  if(class(rownames(B))=="character")  B[[arguments$name]] <- rownames(B)
  else B[[arguments$name]] <- sprintf(paste0("%0",nchar(nrow(B)),"d"),as.numeric(rownames(B)))
  B <- B[, c(active, setdiff(names(B), active))]
  if(nrow(B)>maxN) {
    set.seed(2020)
    rcases <- sample(1:nrow(B), maxN)
    B  <- B[rcases,]
    cc <- cc[rcases,]
  }
  arguments$nodes <- B
  arguments$layout <- cc
  arguments$color <- g
  arguments$frequencies <- TRUE
  arguments$showAxes <- TRUE
  arguments$showCoordinates <- TRUE
  arguments$degreeFilter <- NULL
  if(is.null(arguments$label)) arguments$label <- ""
  if(is.null(arguments$controls)) arguments$controls <- c(1,4)  
  return(do.call(netCoin, arguments))
}

# Elaborate a netCoin object from a lavaan object.

pathCoin<-function(model, estimates=c("b","se","z","pvalue","beta"), fitMeasures=c("chisq", "cfi", "rmsea"), ...){
  arguments <- list(...)
  if(!("language" %in% names(arguments))) arguments$language <- "en"
  if(!("linkBipolar" %in% names(arguments))) arguments$linkBipolar <- TRUE
  if(!("showArrows" %in% names(arguments))) arguments$showArrows <- TRUE
  arguments$name <- nameByLanguage(arguments$name,arguments$language,arguments$nodes)
  M<-pathParameter(model,estimates=estimates)
  names(M$nodes)[1]<-arguments$name
  
  
  if(!is.null(arguments$note)) arguments$note<-paste0(catFit(model,fitMeasures),arguments$note)
  else if(!is.null(fitMeasures)) arguments$note<-catFit(model,fitMeasures)
  
  if("nodes" %in% names(arguments)) {
    vvnodes<-setdiff(names(arguments$nodes),arguments$name)
    arguments$nodes<-merge(arguments$nodes,M$nodes,by.x=arguments$name,by.y=arguments$name,sort=F)
    arguments$nodes<-arguments$nodes[,c(names(M$nodes),vvnodes)]
  }
  else arguments$nodes<-M$nodes
  arguments$links<-M$links
  
  do.call(netCoin,arguments)
}

# dichotomize: Transform character and factor objects into dichotomies.

dichotomize <- function(data,variables, sep="", min=1, length=0, values=NULL,
                        sparse=FALSE, add=TRUE, sort=TRUE, nas="None") {
  if(is.data.frame(data)){
    if (min>0 & min<1) min = min*nrow(data)
    
    if(!is.null(nas) & sep=="C") { #Different columns, same factor levels or character.
      oldData<-data
      if(inherits(data,"tbl_df")) data<-as_factor(data[,variables])
      if(sep=="C")sep<-"|"
      String<-do.call(paste,c(data,sep=sep))
      String<-gsub(paste0("\\",sep,"NA"), "", String)
      String<-gsub("NA", nas, String)
      data<-data.frame(String=String)
      variables<-"String"
    }
    
    cn <- colnames(data)
    names(cn) <- cn
    if (length(sep)!=length(variables)) sep = rep(sep[1],length(variables))
    names(sep) <- variables
    
    for(c in variables){
      if (sep[c]!="")
        L <- lapply(strsplit(as.character(data[[c]]), sep[c],fixed=TRUE), paste, sep[c] ,sep="") # Sep at the end of each element
      else {
        sep[c]<-"??"
        L <- paste(na.omit(data[[c]]),sep[c],sep="")
      }
      if (is.null(values)) Z <- valuesof(L,length,min,sort,sep)
      else                 Z <- paste(values, sep[c],sep="")
      Z <- paste(sep[c],Z,sep="") # To search
      C <- paste(sep[c],data[[c]],sep[c],sep="")  # Searched    
      Q <- Matrix(0,nrow=length(Z),ncol=nrow(data),sparse=TRUE) # Result
      
      for(X in 1:length(Z)) {
        N <- grep(Z[X],C,fixed=TRUE)
        if (length(N) > 0) Q[X,N]<-1
      }
      Z <- substring(Z,nchar(sep[c])+1,nchar(Z)-nchar(sep[c]))
      Z[Z==""]<-".ND."
      if (min>0 & !is.null(values)) {
        VF <- apply(Q,1,sum)
        if (length(VF[VF>=min])>1) {
          Q <- Q[VF>=min,]
          Z <- Z[VF>=min]
        }
        else warning("min > empirical observations")
        if (sort==TRUE) {
          Q<-Q[order(-VF[VF>=min]),]
          Z<-Z[order(-VF[VF>=min])]
        }
        if (length>0) {
          Q<-Q[1:min(length,nrow(Q)),]
          Z<-Z[1:min(length,nrow(Q))]
        }
      }
      if(length(variables)>1)
        Z <- paste(cn[c],Z,sep=":")
      if (sparse==TRUE) {
        Q<-t(Q)
        colnames(Q)<-Z
        if (!exists("R_Data")) R_Data<-Q
        else R_Data<-cbind(R_Data,Q)
      }
      else {
        W <- as.data.frame(t(as.data.frame(as.matrix(Q), row.names=Z)))
        if (!is.null(nas)) W[[paste0(c,":<NA>")]] <- ifelse(apply(W,1,sum)==0,1,0)
        W[apply(W,1,sum)==0,] <- NA
        if (add==TRUE) {
          if (exists("oldData")) data<-oldData
          data <- cbind(data,W)
        }
        else {
          if (!exists("R_Data")) R_Data<-W
          else R_Data<-cbind(R_Data,W)
        }
      }
    }
    if (!exists("R_Data")) R_Data<-data
    if (!is.null(nas) & sparse==FALSE) {
      names(R_Data)<-gsub("\\:<NA>",paste0("\\:",nas),names(R_Data))
      names(R_Data)<-gsub("\\.ND\\.",nas,names(R_Data))
    }
    return(R_Data)
  }
  else warning("You must pass a data frame!")
}

valuesof<-function(x,length=0,min=0,sort=TRUE,sep="") {
  x <- table(unlist(x))
  if (sort) x <- x[order(-x)]
  if (min>0) x<-as.matrix(x[x>=min])
  if (nrow(x)==0) return(NULL)
  if (length>0) x<- x[x>=(x[order(-x)][min(length,nrow(x))])]
  return(rownames(x))
}

# Links. See below funcs="shape"
edgeList <- function(data, procedures="Haberman", criteria="Z", level = .95, Bonferroni=FALSE, min=-Inf, max=Inf, support=-Inf, 
                     directed=FALSE, diagonal=FALSE, sort=NULL, decreasing=TRUE, pairwise=FALSE) {
  level <- checkLevel(level)
  if (tolower(substr(criteria,1,2))%in%c("z","hy") & substr(tolower(procedures[1]),1,2)!="sh") {
    if (max==Inf) max<-.50
    if (Bonferroni ) max<-max/choose(nrow(data),2) # Changes of Z max criterium (Bonferroni)
  }
  if (substr(tolower(procedures)[1],1,2)!="sh") { # For coin objects
    if (!inherits(data,"coin")) stop("Error: input must be a coin object (see coin function)")
    funcs<-c.method(procedures)
    if(!is.null(sort)) funcs<-union(c.method(sort),funcs)
    criteria<-c.method(criteria)
    todas<-union(funcs,criteria)
    matrices<-sim(data,todas,level=level, pairwise=pairwise)
    funcs<-i.method(funcs)
    criteria<-i.method(criteria)
    if (length(union(funcs,criteria))==1) {
      M<-new.env()
      M[[funcs]]<-matrices
      matrices<-as.list(M)
    }
    matrices<-matrices[i.method(todas)]
    Mat<-mats2edges(data[,],matrices,criteria=criteria,min=min,max=max,support=support,directed=directed,diagonal=diagonal)
  }
  else {
    if (!inherits(data,"matrix") && !inherits(data,"data.frame"))
      stop("Error: input must be a matrix (shape) or a data.frame (tree)")    
    if (inherits(data,"matrix")){
      if(min==-Inf)min<-1    
      #funcs="value"
      #M<-new.env()
      #M[[criteria]]<-M[[funcs]]<-data
      #matrices<-as.list(M)
      #data<-list(f=M[[funcs]],n=NA)
      Mat<-mats2edges(data,min=min,max=max,directed=directed,diagonal=diagonal)
    }
    if (inherits(data,"data.frame")) {
      lines<-sapply(data,as.character)
      lines<-rbind(c(lines[1,1],rep(NA,ncol(lines)-1)),lines) # Add one blank case in order to avoid mXm problem.
      lines<-ifelse(lines=="",NA,lines)
      adjlist<-split(lines,seq(nrow(lines))) # splits the character strings into list with different vector for each line
      adjlist<-sapply(adjlist,na.omit)
      Source=unlist(lapply(adjlist,function(x) rep(x[1],length(x)-1))) # establish first column of edgelist by replicating the 1st element (=ID number) by the length of the line minus 1 (itself)
      Target=unlist(lapply(adjlist,"[",-1)) # the second line I actually don't fully understand this command, but it takes the rest of the ID numbers in the character string and transposes it to list vertically
      return(as.data.frame(cbind(Source,Target),stringsAsFactors = FALSE,row.names=FALSE))
    }
  }  
  
  # Last transformations: c.Conditional c.Probable and sort
  
  if(length(Mat)>0) {
    if (!is.null(Mat$c.conditional)) 
      Mat$c.conditional<-factor(Mat$c.conditional,levels=c(0:8),
                                labels=c("Null","Mere","Conditional","Significant","Quite significant","Very significant","Subtotal","Suptotal","Total"))
    if (!is.null(Mat$c.probable)) 
      Mat$c.probable<-factor(Mat$c.probable,levels=c(0:8),
                             labels=c("Null","Mere","Probable","Significant","Quite significant","Very significant","Subtotal","Suptotal","Total"))
    if (!is.null(sort)) {
      if (substr(tolower(procedures)[1],1,2)!="sh") Mat<-Mat[order(Mat[[i.method(c.method(sort))]],decreasing = decreasing),]
      else Mat<-Mat[order(Mat$value,decreasing=decreasing),]
    }
  }
  else return(NULL)
  names(Mat)[names(Mat)=="Z"]<-"p(Z)"
  names(Mat)[names(Mat)=="Fisher"]<-"p(Fisher)"
  return(Mat)
}

c.method<-function(method) {
  if(is.null(method))return(NULL)
  method<-toupper(method)
  if ("ALL"==method[1]) method<-c("M","T","G","S","B","J","D","A","O","K","N","Y","P","V","C","R","E","L","H","Z","f","F","X","I","0","Q","U")
  method<-sub("FIS","W",method)
  method<-sub("HYP","W",method)
  method<-sub("HAM","NNH",method)
  method<-sub("CC" ,"UC" ,method)
  method<-sub("CP" ,"QC" ,method)  
  method<-sub("OD" ,"CD" ,method)
  method<-sub("RO" ,"TA" ,method)
  method<-sub("AND","BER",method)
  method<-sub("TET","VET",method)
  method<-sub("CON","LCO",method)
  method<-sub("II" ,"0"  ,method)
  method<-sub("COI","F", method)
  method<-substr(method,1,1)
  return(method)
}

i.method<-function(method) {
  similarities<-matrix(c("matching","Rogers","Gower","Sneath", "Anderberg",
                         "Jaccard","dice", "antiDice","Ochiai","Kulczynski",
                         "Hamann", "Yule", "Pearson", "odds", "Russell", "expected", "Haberman", "confidence", "Z",
                         "coincidences", "relative", "sConditional","tConditional", "c.conditional","c.probable","tetrachoric","Fisher"), 
                       nrow=1, dimnames=list("Similarity", c("M","T","G","S","B","J","D","A","O","K","N","Y","P","C","R","E","H","L","Z","F","X","I","0","U","Q","V","W")))
  similarities<-similarities[,method]
  if("L" %in% method) {
    cade <- c("conf.L","confidence","conf.U")
    posi <- match("confidence",similarities)
    if (posi ==1) similarities <- c(cade,similarities[-1])
    else if (posi == length(similarities)) similarities<-c(similarities[-length(similarities)], cade)
    else similarities <- c(similarities[c(1:max(1,posi-1))], cade,
                           similarities[(match("confidence",similarities)+1):length(similarities)]) 
  }
  return(similarities)
}

checkLevel <- function(level){
  if (level >=1 & level < 100)
    level <- level/100
  if (level <=0 | level >=100) {
    level <- .95
    warning("Not valid level")
  }
  return(level)
}

# Similatities
sim<-function (input, procedures="Jaccard", level=.95, distance=FALSE, minimum=1, maximum=Inf, sort=FALSE, decreasing=FALSE, 
               weight=NULL, pairwise=FALSE) {
  level <- checkLevel(level)
  method<-c.method(procedures)
  if (is.matrix(input) && !inherits(input,"coin")) {
    if (is.null(colnames(input))) dimnames(input)<-list(NULL,paste("X",1:ncol(input),sep=""))
    input<-as.data.frame(input)
  }
  if (is.data.frame(input)) {
    C<-coin(input, minimum, maximum, sort, decreasing, weight=weight, pairwise=pairwise)
    a<-C[,]
  }
  else if (inherits(input,"coin")) {
    C <- input
    a <- input[(diag(input)>=minimum & diag(input)<=maximum),(diag(input)>=minimum &diag(input)<=maximum)]
  }
  else stop("Error: 1st parameter has to be a data frame or a coin object (see coin function)")
  
  if (pairwise) {
    N <- attr(C, "m")
   NN <- max(C)
    X <- attr(C, "x")
  }
  else {
    N <- attr(C,"n")
    X <- matrix(0, nrow=dim(a)[1], ncol = dim(a)[2])
  }
  
  if (sort==TRUE | decreasing==TRUE) {
    orderM <- order(diag(a),decreasing=decreasing)
    a <- a[orderM , orderM]
    if (pairwise) N <- N[orderM , orderM]
    if (pairwise) X <- X[orderM , orderM]
  }
  
  
  b<--(a-diag(a))-t(X)
  c<-t(b)
  d=N-a-b-c
  if (any(c("G","B","O","K","Y","P","V") %in% method)) m<-ifelse(a+d==N,1,ifelse(b+c==N,-1,0)) #Special values of distances
  s<-new.env()
  
  if ("M" %in% method) s$matching <- distant((a + d)/(a + b + c + d),distance)
  if ("T" %in% method) s$Rogers <- distant((a + d)/(a + 2 * (b + c) + d), distance)
  if ("G" %in% method) {
    s$Gower <- distant(a * d/sqrt((a + b) * (a + c) * (d + b) * (d + c)),distance)
    s$Gower <- ifelse(is.na(s$Gower),distant(pmax(m,0),distance),s$Gower)
  }
  if ("S" %in% method) s$Sneath <- distant(2*(a+d)/(2*(a+d)+(b+c)),distance)
  if ("B" %in% method) {
    s$Anderberg <- distant((a/(a+b)+a/(a+c)+d/(c+d)+d/(b+d))/4,distance)
    s$Anderberg <- ifelse(is.na(s$Anderberg),distant(pmax(m,0),distance),s$Anderberg)
  }
  if ("J" %in% method) s$Jaccard <- distant(a/(a + b + c),distance)
  if ("D" %in% method) s$dice <- distant(2 * a/(2 * a + b + c), distance)
  if ("A" %in% method) s$antiDice <- distant(a/(a + 2 * (b + c)),distance)
  if ("O" %in% method) {
    s$Ochiai <- distant(a/sqrt((a + b) * (a + c)),distance)
    s$Ochiai <- ifelse(is.na(s$Ochiai),distant(pmax(m,0),distance),s$Ochiai)    
  }
  if ("K" %in% method) {
    s$Kulczynski <- distant((a/(a+b)+a/(a+c))/2, distance)
    s$Kulczynski <- ifelse(is.na(s$Kulczynski),distant(pmax(m,0),distance),s$Kulczynski)
  }
  if ("N" %in% method) s$Hamann <- distant((a - (b + c) + d)/(a + b + c + d), distance)
  if ("Y" %in% method) {
    s$Yule <- distant((a*d-b*c)/(a*d+b*c))
    s$Yule <- ifelse(is.na(s$Yule),distant(m,distance),s$Yule)
  }
  if ("P" %in% method) {
    s$Pearson <- distant((a * d - b * c)/sqrt((a + b) * (a + c) * (b + d) *  (d + c)),distance)
    s$Pearson <- ifelse(is.na(s$Pearson),distant(m,distance),s$Pearson)
  }
  if ("V" %in% method) {
    s$tetrachoric<-((a*d/(b*c))^(pi/4)-1)/((a*d/(b*c))^(pi/4)+1)
    s$tetrachoric <- ifelse(is.na(s$tetrachoric),distant(m,distance),s$tetrachoric)
  }
  if ("C" %in% method) {
    s$odds <- (pmax(a,.5)*pmax(d,.5))/(pmax(b,.5)*pmax(c,.5))
    if (distance) s$odds<--s$odds
    diag(s$odds)<-ifelse(distance,-Inf,Inf)
  }
  if ("R" %in% method) {
    s$Russell <- distant(a/(a + b + c + d),distance)
    if (!distance) diag(s$Russell) <- 1
  }
  if ("E" %in% method) s$expected <- (a+b)*(a+c)/N
  if ("L" %in% method) {
    s$'conf.L' <- pmax(a-qt(level+(1-level)/2, N-1)*sqrt(((a+b)*(a+c)/N)*((1-(a+b)/N)*(1-(a+c)/N))),0)
    signo<-2*(((a+b)*(a+c)/N)<a)-1
    s$confidence <- pmax((a+b)*(a+c)/N+signo*qt(level,N-1)*sqrt(((a+b)*(a+c)/N)*((1-(a+b)/N)*(1-(a+c)/N))),0)
    diag(s$confidence) <- diag(a)
    s$'conf.U' <- pmin(a+qt(level+(1-level)/2, N-1)*sqrt(((a+b)*(a+c)/N)*((1-(a+b)/N)*(1-(a+c)/N))),N)
  }
  if ("H" %in% method) {
    s$Haberman <- sqrt(N) * (a * d - b * c)/sqrt((a + b) * (a + c) * (b + d) *  (d + c))
    if (pairwise) s$Haberman[is.na(s$Haberman)]<-sqrt(NN)
    else s$Haberman[is.na(s$Haberman)]<-sqrt(N)[is.na(s$Haberman)]
    if (distance) s$Haberman<-(N+s$Haberman)/(2*N)
  }
  if ("Z" %in% method) {
    s$Z <- 1-pt(sqrt(N) * (a * d - b * c)/sqrt((a + b) * (a + c) * (b + d) *  (d + c)),N)
    s$Z[is.na(s$Z)]<-0
  }
  if ("W" %in% method) s$Fisher<-1-phyper(a-1,pmin((a+b),(a+c)),N-pmin((a+b),(a+c)),pmax((a+b),(a+c)))
  if ("x" %in% method) {
    s$Fisher<-matrix(NA,nrow=nrow(a),ncol=ncol(a))
    for (Ro in c(1:nrow(a))) {
      for (Co in c(Ro:ncol(a))) {
        inMatrix=matrix(c(a[Ro,Co],b[Ro,Co],c[Ro,Co],d[Ro,Co]),nrow=2)
        (s$Fisher[Ro,Co]<-fisher.test(inMatrix,alternative="greater")$p.value)
        s$Fisher[Co,Ro] = s$Fisher[Ro,Co]
      }
    }
    # diag(s$Fisher)<-0
    rownames(s$Fisher)<-colnames(s$Fisher)<-rownames(a)
  }
  if ("F" %in% method) s$coincidences <- a
  if ("X" %in% method) s$relative <- a/N*100
  if ("I" %in% method) s$sConditional <-a/(a+c)*100
  if ("0" %in% method) s$tConditional <-a/(a+b)*100
  if ("U" %in% method) {
    Z <- 1-pt(sqrt(N) * (a * d - b * c)/sqrt((a + b) * (a + c) * (b + d) *  (d + c)),N)
    s$c.conditional<-matrix(ifelse(b+c==0, 8,
                                   ifelse(c==0,  7,                        
                                          ifelse(b==0,  6,
                                                 ifelse(Z<.001,5,
                                                        ifelse(Z<.01, 4,
                                                               ifelse(Z<.05, 3,
                                                                      ifelse(Z<.50, 2,       
                                                                             ifelse(a>0, 1, 0)))))))),nrow=nrow(a),dimnames=dimnames(a))
  }
  if ("Q" %in% method) {
    Z <- 1-pt((a/(a+c)-.50)/(1/(2*sqrt(a+c))),(a+c))
    s$c.probable<-matrix(ifelse(b+c==0, 8,
                                ifelse(c==0,   7,                        
                                       #                                  ifelse(b==0,  "Subtotal",
                                       ifelse(Z<.001, 5,
                                              ifelse(Z<.01,  4,
                                                     ifelse(Z<.05,  3,
                                                            ifelse(Z<.50,  2,      
                                                                   ifelse(a>0, 1, 0))))))),nrow=nrow(a),dimnames=dimnames(a))
  }  
  if (length(method)==1) return(s[[names(s)[1]]])
  else return(as.list(s,sorted=TRUE))
}

# Convert similatities into dissimilarities
distant<-function(s,t=FALSE) {
  if (t==TRUE) s<-as.dist(1-s)
  return(s)
}
# http://pbil.univ-lyon1.fr/ade4/ade4-html/dist.binary.html


# Print lower matrices

lower<-function(matrix,decimals=3) { # Add an option to hiden diagonal
  m<-as.matrix(matrix)
  form=paste("%1.",decimals,"f",sep="")
  lower<-apply(m,1,function(x) sprintf(form,x))
  lower[upper.tri(lower)]<-""
  lower<-as.data.frame(lower, stringsAsFactors=FALSE)
  if (ncol(m)==1) rownames(lower)<-colnames(lower)<-names(matrix)
  rownames(lower)<-names(lower)
  return(lower)
}

# List of coincidences

coin<-function(incidences,minimum=1, maximum=nrow(incidences), sort=FALSE, decreasing=TRUE, 
               total=FALSE, subsample=FALSE, weight=NULL, pairwise=FALSE) {
  if (pairwise){
    n <- sum(rowSums(!is.na(incidences))>0)
    nomiss     <- ifelse(is.na(incidences),0,1)
    incidences <- replace(incidences,is.na(incidences),0)
  }
  else {
    if (!is.null(weight)) weight <- weight[rowSums(is.na(incidences))<1]
    incidences<-na.omit(incidences)
  }
  if (subsample){
    vector<-apply(incidences,1,sum)
    incidences<-incidences[vector>0,]
  }
  if (total & is.null(weight)) incidences<-data.frame(Total=1,incidences)
  if (all(is.na(incidences) | incidences==0 | incidences==1)) {
    if (!pairwise) n <- nrow(incidences)
    names(n)<-"n"
    if (is.null(weight)) f<-crossprod(as.matrix(incidences))
    else {
      if (length(weight)!=dim(incidences)[1]) warning("weight has not the appropiate length!")
      f<-crossprod(t(crossprod(as.matrix(incidences),diag(weight,length(weight)))),as.matrix(incidences))
      n<-maximum<-sum(weight)
    }    
    if (is.null(colnames(f))) dimnames(f)<-list(paste("X",1:ncol(f),sep=""),paste("X",1:ncol(f),sep=""))
    d<-diag(f)
    if (sort) d<-sort(d,decreasing=decreasing)
    S<-names(d[(d>=minimum &  d<=maximum)])
    if (total & is.null(weight)) S<-c("Total",S)
    if (total & !is.null(weight)) warning("total cannot be applied in weighted tables")
    if (length(S)>0) {
      if (!pairwise) structure(f[S,S], n=n, class=c("coin"))
      else {
        colnames(nomiss) <- colnames(incidences)
        nomiss <- nomiss[,S]
        incidences <- incidences[,S]
        if (is.null(weight)) {
          m<-crossprod(as.matrix(nomiss))
          x<-crossprod(1-as.matrix(nomiss),as.matrix(incidences))
        }
        else {
          if (length(weight)!=dim(nomiss)[1]) warning("weight has not the appropiate length!")
          m<-crossprod(t(crossprod(as.matrix(nomiss),diag(weight,length(weight)))),as.matrix(nomiss))
          x<-crossprod(t(crossprod(1-as.matrix(nomiss),diag(weight,length(weight)))),as.matrix(incidences))
        }
        structure(f[S,S], n=n, m=m[S,S], x=x[S,S], class=c("coin"))
      }
    }
    else cat("No variables left")
  }
  else warning("All data in incidence matrix has to be dichotomous.")
}

coocur<-function (ocurrences, minimum = 1, maximum = Inf, sort = FALSE, decreasing=TRUE) 
{
  result <- matrix(nrow = ncol(ocurrences), ncol = ncol(ocurrences), dimnames = list(colnames(ocurrences), 
                                                                                     colnames(ocurrences)))
  for (val in c(1:nrow(result))) {
    for (cal in c(val:ncol(result))) {
      result[cal, val] <- sum(pmin(ocurrences[, cal], ocurrences[, val]))
      if (val != cal) 
        result[val, cal] = result[cal, val]
    }
  }
  d<-diag(result)
  if (sort) d<-sort(d,decreasing=decreasing)
  S<-names(d[(d>=minimum &  d<=maximum)])
  if (length(S)>=1) {
    result<-result[S,S]
    if (length(S)==1) names(result)<-S
    n <- sum(ocurrences[,S])
    m <- sum(apply(as.matrix(ocurrences[,S]), 1, max))
    attr(result, "n") <- n
    attr(result, "m") <- m
    structure(result, class = "cooc")
  }
  else cat("No variables left")
}

print.coin<-function(x, ...) {
  cat("n= ",attr(x,"n"),"\n",sep="")
  print(lower(x,0))
}

print.cooc<-function(x, ...) {
  cat("n= ",attr(x,"n"),"; m= ", attr(x,"m"),"\n",sep="")
  print(lower(x,0))
}

tempDir <- function(){
  dir.create("temp", showWarnings = FALSE)
  return(paste("temp",round(as.numeric(Sys.time())),sep="/"))
}

plot.coin <- function(x, dir=tempDir(), language=c("en","es","ca"), ...){
    N <- asNodes(x, language = language)
    colnames(N)[2] <- "incidences"
    E <- edgeList(x,c("Frequencies","Expected"))
    barplot_rd3(N, E, name = names(N)[1], coincidences = "coincidences", incidences = "incidences", expected = "expected", cex = 1, language = language, dir = dir)
    browseURL(normalizePath(paste(dir, "index.html", sep = "/")))
}

summary.coin <- function(object, ...){
  cat(attr(object,"n"),"scenarios and", dim(object[,])[1], "events\n")
  diag(object[,])/attr(object,"n")
}

summary.netCoin <- function(object, ...){
  summaryNet(object)
}

summary.barCoin <- function(object, ...){
  summaryNet(object)
}


summaryNet <- function(x){
  cat(dim(x$nodes)[1], "nodes and", dim(x$links)[1], "links.\n")
  freq <- frequencyList[frequencyList %in% names(x$nodes)]
  if(length(freq)==1) {
    cat(freq," distribution of nodes:","\n", sep="")
    print(summary(x$nodes[[freq]]))
  }
  lwidth <- NULL
  if(!is.null(x$options$linkWidth))
    lwidth <- x$options$linkWidth
  else if(length(x$links)>2)
    lwidth <- names(x$links)[3]
  if(length(lwidth)==1){
    cat(lwidth, "'s distribution:","\n",sep="")
    print(summary(x$links[[lwidth]]))
  }
}

propCoin<-function(x, margin= 0, decimals=1) {
  if (!inherits(x,"coin")) stop("Error: input must be a coin object (see coin function)")
  if ("m" %in% names(attributes(x))) n <- attr(x, "m")
  else n <- attr(x,"n")
  x <- x[,]
  switch(format(margin),
         "0" = round(100 * x / n, decimals),
         "1" = round(100 * x / diag(x), decimals),
         "2" = round(t(100 * x / diag(x)), decimals))
}

# Transform a coin object into a data frame with name and frequency
asNodes<-function(C, frequency = TRUE, percentages = FALSE, language = c("en","es","ca")){
  nodes <- NULL
  if (inherits(C,"coin")) {
    if ("m" %in% names(attributes(C))) divider <- diag(attr(C,"m"))
    else divider <- attr(C,"n")
    if (!percentages & frequency) nodes<-data.frame(name=as.character(colnames(C)),frequency=diag(C))
    else if (!frequency & percentages) nodes<-data.frame(name=as.character(colnames(C)),"%"=diag(C)/divider*100,check.names=FALSE)
    else if (percentages & frequency)nodes<-data.frame(name=as.character(colnames(C)),frequency=diag(C), "%"=diag(C)/divider*100,check.names=FALSE)
    else nodes<-data.frame(name=as.character(colnames(C)),check.names=FALSE)
    if(language[1]!="en"){
      colnames(nodes)[colnames(nodes)=="frequency"] <- getByLanguage(frequencyList,language)
      colnames(nodes)[colnames(nodes)=="name"] <- getByLanguage(nameList,language)
    }     
  }
  else if (min(c("Source", "Target") %in% names(C))) nodes<-data.frame(name=sort(union(C$Source,C$Target)))
  else warning("Is neither a coin object or an edge data frame")
  return(nodes)
}

rescale <- function(x) {
  to <- c(0, 1)
  from <- range(x, na.rm = TRUE, finite = TRUE)
  return((x - from[1]) / diff(from) * diff(to) + to[1])
}

toColorScale <- function(items){
  if(is.numeric(items)){
    return(hsv(1,1,rescale(items)))
  }else{
    colors <- c(
  "#1f77b4", # blue
  "#2ca02c", # green
  "#d62728", # red
  "#9467bd", # purple
  "#ff7f0e", # orange
  "#8c564b", # brown
  "#e377c2", # pink
  "#7f7f7f", # grey
  "#bcbd22", # lime
  "#17becf", # cyan
  "#aec7e8", # light blue
  "#98df8a", # light green
  "#ff9896", # light red
  "#c5b0d5", # light purple
  "#ffbb78", # light orange
  "#c49c94", # light brown
  "#f7b6d2", # light pink
  "#c7c7c7", # light grey
  "#dbdb8d", # light lime
  "#9edae5" # light cyan
     )
    items <- as.numeric(as.factor(items))
        items <- ((items-1) %% length(colors))+1
    return(colors[items])
  }
}

savePajek<-function(net, file="file.net", arcs=NULL, edges=NULL, partitions= NULL, vectors=NULL){
  if(length(setdiff(partitions,names(net[["nodes"]])))>0) stop("At least one partition is not amongst ",paste(names(net$nodes),collapse=", "),".")
  if(length(setdiff(vectors,names(net[["nodes"]])))>0) stop("At least one vector is not amongst ",paste(names(net$nodes),collapse=", "),".")
  if(length(setdiff(arcs,names(net[["links"]])))>0) stop("At least one arc is not amongst ",paste(names(net$links),collapse=", "),".")
  if(length(setdiff(edges,names(net[["links"]])))>0) stop("At least one edge is not amongst ",paste(names(net$links),collapse=", "),".")
  
  if(!grepl("\\.",file))file<-paste0(file,".net")
  if(!is.null(vectors) | !is.null(partitions)) file<-gsub(".net",".paj",file)
  connec<-file(file,"w")
  writeLines(paste0("*Network ",net[["options"]]$main),con=connec)
  close(connec)
  connec<-file(file,"a")
  writeLines(paste0("*Vertices ",as.character(nrow(net[["nodes"]]))),con=connec)
  writeLines(paste0(seq(1:nrow(net[["nodes"]])),' "',net[["nodes"]]$name,'" '), con=connec)
  N<-cbind(n=seq(1:nrow(net[["nodes"]])),net[["nodes"]][1])
  L<-cbind(N[unlist(net[["links"]]$Source),1],N[unlist(net[["links"]]$Target),1])
  
  if(!is.null(arcs)) {
    cont=1
    for(weights in arcs) {
      writeLines(paste0("*Arcs : ",cont,' "',weights,'"'), con=connec)
      writeLines(paste(L[,1],L[,2],net[["links"]][[weights]]), con=connec)
      cont=cont+1
    }
  }
  if(!is.null(edges)) {
    ifelse(exists("cont"),cont<-cont,cont<-1)
    for(weights in edges) {
      writeLines(paste0("*Edges : ",cont,' "',weights,'"'), con=connec)
      writeLines(paste(L[,1],L[,2],net[["links"]][[weights]]), con=connec)
      cont=cont+1
    }
  }
  if(!is.null(partitions)){
    for(partition in partitions) {
      writeLines(paste0("*Partition ", partition), con=connec)
      writeLines(paste0("*Vertices ", nrow(net$nodes)), con=connec)
      writeLines(as.character(as.numeric(as.factor(net[["nodes"]][[partition]]))),con=connec)
    }
  }
  if(!is.null(vectors)){
    for(vector in vectors) {
      writeLines(paste0("*Vector ", vector), con=connec)
      writeLines(paste0("*Vertices ", nrow(net$nodes)), con=connec)
      Line<-as.character(net[["nodes"]][[vector]])
      Line[is.na(Line)]<-"0"
      writeLines(Line, con=connec)
    }   
  }
  close(connec)
}

saveGhml <- function(net, file="netCoin.graphml"){
  if(!inherits(net, "netCoin")) stop("This program only works with netCoin objects")
  if(!grepl("\\.",file))file<-paste0(file,".graphml")
  graph <- toIgraph(net)
  write_graph(graph, file=file, format="graphml")
}

expectedList<- function(data, names=NULL, min=1, confidence=FALSE) {
  if (!inherits(data,"coin")) stop("Error: input must be a coin object")
  if (!is.null(names)) colnames(data[,])<-rownames(data[,])<-names
  a<-data[,]
  b<--(a-diag(a))
  c<--t((t(a)-diag(a)))
  d=attr(data,"n")-a-b-c
  attr(data,"e")<-(a+b)*(a+c)/(a+b+c+d)
  E<-edgeList(attr(data,"e"),"shape",min=0,max=Inf)
  F<-edgeList(data[,],"shape",min=0,max=Inf)
  if (!confidence) {
    dataL<-cbind(F,E[,3])[F[,3]>=min,]
    colnames(dataL)[3:4]<-c("coincidences","expected")
  }
  else {
    N<-a+b+c+d
    signo<-2*(((a+b)*(a+c)/N)<a)-1
    attr(data,"l") <- pmax((a+b)*(a+c)/N+signo*1.64*sqrt(((a+b)*(a+c)/N)*((1-(a+b)/N)*(1-(a+c)/N))),0)
    diag(attr(data,"l")) <- diag(a)
    L<-edgeList(attr(data,"l"),"shape",min=-Inf,max=Inf)
    dataL<-cbind(F,E[,3],L[,3])[F[,3]>=min,]
    colnames(dataL)[3:5]<-c("coincidences","expected","confidence")
  }
  return(dataL)
}

mats2edges<-function(data,list=NULL,criteria=1,min=-Inf,max=Inf,support=-Inf,directed=FALSE,diagonal=FALSE){
  
  # Input control
  if (!is.null(list)) {
    if (!identical(dim(data),dim(list[[1]]))) {
      warning("data & list must have the same dimensions")
      return()
    }
    if (criteria!=1 & !(criteria %in% names(list))) warning("criteria are not in the matrices list")
  }
  if (is.null(rownames(data))) rownames(data)<-as.character(1:nrow(data))
  if (is.null(colnames(data))) colnames(data)<-as.character(1:ncol(data))
  
  #  type of edgelist
  if (nrow(data)<ncol(data)) { # For asymmetric matrices. Improve later for directed cases.
    l<-data>-Inf
    l[,rownames(l)]<-lower.tri(l[,rownames(l)])
  }
  else { # For symmetric matrices
    if (directed) l <- as.vector(lower.tri(data,diag=diagonal) | upper.tri(data))
    else l <- as.vector(lower.tri(data,diag=diagonal))
  }
  # data.frame building
  sources<-rep(colnames(data),each=dim(data)[1])
  targets<-rep(rownames(data),dim(data)[2])
  Mat <- data.frame(Source=sources,Target=targets)
  value <- as.vector(data)
  
  # data.frame for matrices list
  if (!is.null(list)) {
    c <- as.vector(list[[criteria]])
    a<-as.data.frame(lapply(list,as.vector))
    Mat<-cbind(Mat,a)[l==TRUE & c<=max & c>=min & value>=support,]
  }
  # data.frame for alone matrix
  else Mat<-{
    if (criteria!=1) warning("Criteria don't apply for only one matrix. Use min and max")
    cbind(Mat,value)[l==TRUE & value<=max & value>=min,]
  }
  # return
  if (nrow(Mat)>0) {
    row.names(Mat)<-NULL
    return(Mat)
  }
  else return(NULL)
}

orderEdges<-function(links,nodes){ #Used in surCoin to order arrows
  A<-unlist(sapply(paste0("^",links[,"Source"],"$"),grep,x=nodes))
  B<-unlist(sapply(paste0("^",links[,"Target"],"$"),grep,x=nodes))
  links[A>B,c("Source","Target")]<-links[A>B,c("Target","Source")]
  links<-links[!is.na(links$Source) & !is.na(links$Target),]
  return(links)
}

dicho<-function(input,variables,value,newlabel=TRUE) {
  datum<-as.data.frame(ifelse(input[,variables, drop=FALSE]==value,1,0))
  j=0
  for (i in variables) {
    j=j+1
    if (!is.null(attributes(input[[i]]))) {
      if (newlabel) names(datum)[j] <- ifelse(exists("label",attributes(input[[i]])),attr(input[[i]],"label"),i)
    }
  }
  return(datum)
}

languages <- c("en","es","ca")

nameList <- c('name','nombre','nom')
names(nameList) <- languages

frequencyList <- c("frequency","frecuencia","freq\uFC\uE8ncia","%")
names(frequencyList) <- languages

labelList <- c('label','etiqueta','etiqueta')
names(labelList) <- languages

nameByLanguage <- function(name,language,nodes){
  if(is.null(name)){
    name <- getByLanguage(nameList,language)
  }
  if(!is.null(nodes)){
    if(!(name %in% colnames(nodes)))
      warning(paste0("name: '",name,"' column missing in nodes data frame"))
    else if(sum(duplicated(nodes[[name]])))
      warning(paste0("name: '",name,"' column values must be unique"))
  }
  return(name)
}

getByLanguage <- function(varlist,language){
  if(!is.null(language) && language[1] %in% names(varlist))
    language <- language[1]
  else
    language <- "en"
  return(unname(varlist[language]))
}

rbind.all.columns <- function(x, y) {
  x.diff <- setdiff(colnames(x), colnames(y))
  y.diff <- setdiff(colnames(y), colnames(x))
  
  x[, c(as.character(y.diff))] <- NA
  y[, c(as.character(x.diff))] <- NA
  
  return(rbind(x, y))
}

pathParameter<-function(model,estimates=c("b","se","z","pvalue","beta")){
  if(inherits(model,"lavaan")){
    links<-lavaan::parameterEstimates(model,standardized = T)
    names(links)<-gsub("^est$","b",names(links))
    names(links)<-gsub("^std.all$","beta",names(links))
    links<-links[links$op=="~",c("rhs","lhs",estimates)]
    names(links)[1:2]<-c("Source","Target")
    if(length(intersect(union(links$Source,links$Target),model@Data@ov$name))>0) {
      nodes<-as.data.frame(model@Data@ov,stringsAsFactors=F)[,intersect(names(model@Data@ov),c("name","mean","var"))]
      nodes$stdev<-sqrt(nodes$var)
      row.names(nodes)<-nodes$name
    }
    else {
      nodes<-data.frame(name=union(links$Source,links$Target))
    }
    # nodes<-nodes[,c("name","mean","stdev")]
    nodes$name<-iconv(nodes$name,"","UTF-8")
    links<-links[,c("Source","Target",estimates)]
    links$Source<-iconv(links$Source,"","UTF-8")
    links$Target<-iconv(links$Target,"","UTF-8")  
    structure(list(links = links, nodes = nodes))
  }
  else stop("Model has to be a lavaan object")
}

catFit<-function(model,fitMeasures){
  if("chisq" %in% fitMeasures) fitMeasures<-union(fitMeasures,c("df","pvalue"))
  fit<-lavaan::fitMeasures(model,fitMeasures)
  text<-NULL
  if("chisq" %in% names(fit)) text<-paste(text, paste0("Chi2=",format(fit["chisq"],digits=4)," (",fit["df"]," df)",", pvalue=", format(fit["pvalue"],digits=2)), sep=". ")
  if("cfi" %in% names(fit)) text<-paste(text, paste0("CFI= ",format(fit["cfi"],digits=3)), sep=". ") 
  if("rmsea" %in% names(fit)) text<-paste(text, paste0("RMSEA= ",format(fit["rmsea"],digits=3)), sep=". ")
  paste0(gsub("^. ","<p>",text),".</p>")
}

corr <- function (a, b = a, weight = NULL )
{
  if (is.null(weight)) weight= rep(1/nrow(a), nrow(a))
  s<-complete.cases(cbind(a,b,weight))
  a<-as.matrix(a[s,]);b<-as.matrix(b[s,])
  # normalize weights
  weight <- weight[s] / sum(weight[s])
  
  # center matrices
  a <- sweep(a, 2, apply((a * weight),2,sum))
  b <- sweep(b, 2, apply((b * weight),2,sum))
  
  # compute weighted correlatio
  t(a*weight) %*% b / sqrt(apply((a**2 *weight),2,sum) %*% t(apply((b**2 *weight),2,sum))) 
  
}

corrp <- function (a, b = a, weight = NULL ){
  count <- 0
  CC <- matrix( NA , nrow=(ncol(a)), ncol=ncol(b))
  rownames(CC) <- colnames(a)
  colnames(CC) <- colnames(b)
  for(i in colnames(a)) {
    for(j in colnames(b)) {
      if(i==j) CC[i,j] <- 1
      else {
        CC[i,j] <- corr(b[j],a[i],weight=weight)
      }
    }
    count <- count +1
  }
  return(CC)
}

layoutMCA<-function(matrix) { # Correspondencias simples clasicas aplicadas a dicotomicas.
  matrix<-cbind(matrix,1-matrix)
  n<-sum(matrix)
  P=matrix/n
  column.masses<-colSums(P)
  row.masses=rowSums(P)
  E=row.masses %o% column.masses
  R=P-E
  I=R/E
  Z=R/sqrt(E) # Corrected
  SVD=svd(Z)
  rownames(SVD$v)=colnames(P)
  standard.coordinates.columns = sweep(SVD$v[1:(ncol(Z)/2),1:2], 1, sqrt(column.masses[1:(ncol(Z)/2)]), "/")
  principal.coordinates.columns = sweep(standard.coordinates.columns, 2, SVD$d[1:2], "*")
  colnames(principal.coordinates.columns)<-c("F1","F2")
  return(principal.coordinates.columns)
}

layoutMca<-function(matrix, nfactors=2, rows=FALSE){ # Correspondencias simples clasicas aplicadas a dicotomicas.
  P=matrix/nrow(matrix)
  column.masses<-colSums(P)
  row.masses=rowSums(P)
  E=row.masses %o% column.masses
  R=P-E
  I=R/E
  Z=R/sqrt(E) # Corrected
  SVD=svd(Z)
  rownames(SVD$v)=colnames(P)
  CC <-list()
  CC$standard.coordinates.rows = sweep(SVD$u, 1, sqrt(row.masses), "/")
  CC$principal.coordinates.rows = sweep(CC$standard.coordinates.rows, 2, SVD$d, "*")
  CC$standard.coordinates.columns = sweep(SVD$v, 1, sqrt(column.masses), "/")
  CC$principal.coordinates.columns = sweep(CC$standard.coordinates.columns, 2, SVD$d, "*")
  CC <- lapply(CC, function(X){X<-X[,2:(nfactors+1)];colnames(X) <- paste0("F",1:nfactors); return(X)})
  if(rows) return(CC$principal.coordinates.rows)
  else return(CC$principal.coordinates.columns)
}

layoutPCA<-function(coin) { # Coordenadas a partir de Pearson: Haberman/raiz(n)
  A<-eigen(sim(coin,"P"))
  C<-sweep(A$vectors[,1:2],2,sqrt(A$values[1:2]),"*")
  rownames(C)<-rownames(coin)
  colnames(C)<-c("F1","F2")
  return(C)
}

mobileEdges<-function(data, name=1, number=2, difference=0) {
  if(!is.numeric(data[[number]])) data[[number]]<-as.numeric(paste(data[[number]]))
  DC<-matrix(NA,nrow=nrow(data),ncol=nrow(data))
  colnames(DC)<-rownames(DC)<-data[[name]]
  for(i in 1:nrow(data))DC[i,]=ifelse(abs(data[[number]][i]-t(data[[number]]))<=difference,(1+difference-abs(data[[number]][i]-t(data[[number]]))),0)
  diag(DC)<-0
  DCLinks<-edgeList(DC,"shape",min=1)
  colnames(DCLinks)[3]<-"sim."
  DCLinks$dist.<-(1+difference-DCLinks$sim.)
  return(DCLinks)
}

incTime<-function(data, name="name", beginning="birth", end="death") {
  if(!is.integer(data[[beginning]])) data[[beginning]]<-as.integer(paste(data[[beginning]]))
  if(!is.integer(data[[end]])) data[[end]]<-as.integer(paste(data[[end]]))
  anos<-min(na.omit(data[[beginning]])):max(na.omit(data[[end]]))
  E<-matrix(NA,nrow=nrow(data),ncol=length(anos))
  colnames(E)<-anos
  for(i in 1:nrow(data)) E[i,]<-ifelse(anos>=data[[beginning]][i] & (anos<=data[[end]][i] | is.na(data[[end]][i])),1,0)
  Datos<-as.data.frame(t(E))
  colnames(Datos)<-data[[name]]
  return(Datos)
}

shinyCoin <- function(x){
  shiny_rd3(x)
}

# Atencion a lwidth y en lenguaje espanol o catalan
glmCoin <- function(formulas, data, weights=NULL, pmax=.05, twotail=FALSE, showArrows=TRUE,
                  frequency = FALSE, percentage = TRUE, 
                  color="variable", lwidth="z.value", circle= NA, language=c("en","es","ca"),
                  igraph=FALSE, ...){
  if (is.character(weights)) weights<-data[[weights]]
  Links <- data.frame(A=NA,B=NA,C=NA,D=NA, E=NA, G=NA, H=NA)[-1,]
  names(Links)  <- headreg(language)
  if (lwidth=="z.value" & language[1]!="en") lwidth<-"val.z"
  Formulas  <- as.list(gsub("[[:space:]]","",unlist(strsplit(formulas,"\n"))))
  formulas  <- sapply(Formulas,function(X){substr(X,start=1,stop=as.numeric(gregexpr(",",X))-1)})
  familias  <- sapply(Formulas,family)
  # dependent <- sapply(Formulas,function(X){substr(X,start=1,stop=as.numeric(gregexpr("\u7E",X))-1)})
  # dependent <- gsub("\u60","",dependent)
  variables<-extract(formulas, data)
  
  for(instance in 1:length(formulas)) {
    m <- net_lm(formulas[instance], familias[instance], data, weights, pmax, twotail)
    if (nrow(m)>0) {
      names(m) <- headreg(language)[-7]
      m[[headreg(language)[7]]] <- gsub("`","",formulas[instance])
      Links <-rbind(Links,m)
    }
  }
  
  if (!("nodes" %in% names(list(...)))) {
    Nodes<-data.frame(name=iconv(union(Links$Source,Links$Target),to="UTF-8"),
                variable=gsub(":.*","",iconv(union(Links$Source,Links$Target),to="UTF-8"))
                ,stringsAsFactors = FALSE)
    row.names(Nodes)<-Nodes$name
    arguments<-list(nodes=Nodes, links=Links, showArrows = showArrows, color = color, lwidth = lwidth, language = language, ...)
  }
  else arguments<-list(links=Links, showArrows = showArrows, color = color, lwidth = lwidth, language = language, ...)
  
  if (frequency | percentage) arguments$nodes<-meanPer(data, variables, arguments$nodes, names(arguments$nodes)[1] , frequency, percentage, weights)
  
#ADD to N percentages/means. vid extract.R and as.nodes(surCoin)
  
  if (!"name" %in% names(arguments)) {
    arguments$name <- nameByLanguage(arguments$name,language,arguments$nodes)
    names(arguments$nodes)[1]<-nameList[language[1]]
  }
  
  if (!is.na(circle)) arguments$layout <- layoutCircle(arguments$nodes, variables$D, circle)
  
  if(nrow(arguments$nodes)+nrow(arguments$links)>0) {
    xNx <- do.call(netCoin,arguments)
  }
  else(stop("No nodes, no relations"))
 # xNx$nodes$name<-iconv(xNx$nodes$name,to="UTF-8")
 # xNx$links[[c("Source","Target")]]<-iconv(xNx$links[[c("Source","Target")]],to="UTF-8")
  if (igraph) return(toIgraph(xNx))
  else return(xNx)
}

net_lm<-function(formula, family=gaussian, data, weights=NULL, pmax=.05, twotail=FALSE, ...){
    arguments <- list(formula=formula, family=family, data= data, weights= weights, ...)
    glm       <- do.call(glm, arguments)
    links     <- linkregress(remodel(glm),pmax=pmax,twotails=twotail)
    return(links)
}

remodel<-function(model){
  DD <- model$model
  FO <- model$formula
  FF <- model$family$family
  if (!is.null(model$model$`(weights)`)) WW <- model$model$`(weights)`
  else WW<-NULL
  C  <- model$coefficients
  ## VV<-row.names(attr(terms(F),"factors"))[-1]
  VV <- gsub("[[:space:]]","",unlist(strsplit(strsplit(FO,"\\~")[[1]][2],"\\+")))
   V <- VV[vapply(DD[VV],inherits,TRUE,what="factor")]
  if (length(V)==0) return(model)
  Vq <- paste0("^",V)
  y  <- lapply(Vq,grep,names(model$coefficients))
  names(y) <- Vq
  if (is.null(names(y))) colnames(y)<-gsub("\\^","",colnames(y))
  else names(y)<-gsub("\\^","",names(y))

  c<-f<-m<-z<-list()
  for (i in names(y)) {
    z[i]<-list(C[y[[i]]])
    m[i]<-which.min(unlist(z[i]))
    f[i]<-ifelse(z[[i]][m[[i]]]<0,m[[i]],0)
    if(f[i]>0) DD[[i]] <- relevel(DD[[i]],sub(names(z[i]),"",names(z[[i]])[f[[i]]]))
    c[[i]]<-matriz(DD[[i]])
  }
  if (is.null(WW)) neomodel<-glm(FO, contrasts= c, data=DD, family=FF)
  else neomodel <- glm(FO, contrasts= c, data=cbind(DD,WW), family=FF, weights = WW)
  return(neomodel)
}


linkregress<-function(model, pmax=0.05, twotails=FALSE){
  pmax<-abs(ifelse(twotails,qnorm(pmax/2,FALSE),qnorm(pmax,FALSE)))
  q<-summary(model)$coefficients
  y<-names(model$xlevels) #names(model$model)[-1]
  for (i in y) {
  rownames(q)<-gsub(paste0("(^",i,")"),"\\1:",rownames(q))
  }
  m<-data.frame(Source=rownames(q),Target=names(model$model)[1], q, stringsAsFactors = FALSE)
  rownames(m)<-NULL
  names(m)[-c(1:2)]<-colnames(q)
  m<-m[-1,]
  crit<-names(m)[grep(" value",names(m))]
  if (twotails) m <- m[abs(m[[crit]])>pmax,]
  else m <- m[m[[crit]]>pmax,]
  row.names(m)<-NULL
  return(m)
}

matriz<-function(factor){
  T<-t(table(factor)/length(factor))
  M<-matrix(rep(T,length(T)),nrow=length(T),
            dimnames=list(colnames(T),colnames(T)))
  M[,2:dim(M)[1]]<--M[,2:dim(M)[1]]
  diag(M)[2:dim(M)[1]]<-1-M[2:dim(M)[1],1]
  m<-t(matrix(M[,2:dim(M)[2]],nrow=dim(M)[2],dimnames=list(colnames(T),colnames(T)[-1])))
  m.t<-rbind(constant=1/ncol(m),m)
  matriz<-matrix(solve(m.t)[,-1], nrow=nrow(m.t), dimnames=list(colnames(m.t),rownames(m.t)[-1]))
  return(matriz)
}

family<-function(formula) {
  FAM <- ifelse(as.numeric(gregexpr(",",formula))==-1,
           "",
           substr(formula,start=as.numeric(gregexpr(",",formula))+1,1E6))
  family<-c.family(FAM)
  return(family)
}
c.family<-function(method=NULL) {
  if (is.null(method) | method=="") family<-"GAU"
  else {
    family<-substr(toupper(method),1,3)  
    if (family=="QUA" & nchar(method)>5) family<-substr(toupper(method),1,6)
  }
    families<-matrix(c("gaussian","binomial","Gamma","inverse.gaussian","poisson","quasi","quasibinomial","quasipoisson"),
                       nrow=1, dimnames=list("Family", c("GAU","BIN","GAM","INV","POI","QUA","QUASIB","QUASIP")))
  return(families[,family])
}

headreg<-function(language){
  switch (language[1],
          en = c('Source','Target','Estimate','Std.error', 'z.value', 'Pr(>|z|)','Equation'),
          es = c('Source','Target','Estimador','Err.t\uEDp.', 'val.z', 'Pr(>|z|)','Ecuaci\uF3n'),
          ca = c('Source','Target','Estimador','Err.t\uEDp.', 'val.z', 'Pr(>|z|)', 'Ecuaci\uF3')
  )
}

extract <- function(formulas, data) {
  formulas<-gsub("`","",formulas)
  dependent<-variables<-factors<-NULL
  for (formula in formulas) {
    dependent <- union(dependent, gsub("[[:space:]]","",unlist(strsplit(strsplit(formula,"\\~")[[1]][1],"\\+"))))
    variables <- union(variables, gsub("[[:space:]]","",unlist(strsplit(strsplit(formula,"\\~")[[1]][2],"\\+"))))
    factors   <- union(factors, variables[vapply(data[variables],inherits,TRUE,what="factor")])
  }
  independent<-setdiff(variables,factors)
  variables<-list(D=dependent, I=independent, F=factors)
  return(variables)
}


meanPer<-function(data, variables, frame, name=names(frame[1]), frequency= FALSE, percentage= TRUE, weights = NULL){
  if (is.null(weights)) weights <- rep(1, nrow(data))
  columns<-setdiff(names(frame),c(name, "n.","%"))
  l.frame<-length(frame)
  row.names(frame)<-frame[[name]]
  frame.order<-row.names(frame)
  quantitatives<-c(variables$D,variables$I)
  data<-na.omit(cbind(as.data.frame(data)[,unlist(variables)],weights))
  if (length(variables$F)>0) {
    data<-dichotomize(data, variables$F, "")
    quantitatives<-setdiff(names(data),union(weights,variables$F))
  }
  sta<-data.frame(names=quantitatives)
  row.names(sta)<-sta$names
  if (frequency & !is.null(weights)) sta$N. <-round(apply(data[,quantitatives]*data$weights, 2, sum),0)
  if (percentage) {
    means<-apply(data[,quantitatives], 2, weighted.mean, data$weights)
    maxs <-apply(data[,quantitatives], 2, max)
    mins <-apply(data[,quantitatives], 2, min)
    sta$M.<-(means-mins)/(maxs-mins)*100
  }
  frame<-merge(frame,sta[,-1,drop=F], by="row.names", all.x = TRUE)[,-1]
  row.names(frame)<-frame[[name]]
  adds<-c()
  if (frequency)  {
    frame$n. <- frame$N.
    adds <- "n."
    }
  if (percentage) {
    frame$`%`<- frame$M.
    adds <- c(adds, "%")
    }
  out<- grep('^[KLMN]\\.$',names(frame))
  frame<-frame[,-c(out)]
  return(frame[frame.order,c(name,adds,columns)])
}

