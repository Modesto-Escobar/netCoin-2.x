caring_read_file <- function(filepath){
  ext <- gsub("^.*\\.","",filepath)

  if(ext=="sav" || ext=="dta"){
    if(ext=="sav")
      data <- haven::read_spss(file=filepath)
    if(ext=="dta")
      data <- haven::read_stata(file=filepath)
    data <- as.data.frame(data)
    colnames(data) <- make.unique(sapply(colnames(data),function(col){
      label <- attr(data[[col]],"label")
      if(!is.null(label) && length(label)==1){
        return(label)
      }
      return(col)
    }), sep = "_")
    for(col in colnames(data)){
      if(inherits(data[[col]],"haven_labelled")){
        data[[col]] <- factor(haven::as_factor(data[[col]]))
      }
    }
  }else if(ext=="xlsx"){
    data <- openxlsx::read.xlsx(filepath)
    for(col in colnames(data))
      if(inherits(data[[col]],"character"))
        data[[col]] <- factor(data[[col]])
  }else{
    enc <- as.data.frame(readr::guess_encoding(filepath))[1,1]
    if(enc!="UTF-8")
      enc <- "Latin-1"
    data <- data.table::fread(file=filepath,data.table=FALSE,encoding=enc)
    if(enc!="UTF-8")
      colnames(data) <- enc2utf8(colnames(data))
    for(i in seq_along(data)){
      if(is.character(data[,i])){
        if(enc!="UTF-8")
          data[,i] <- enc2utf8(data[,i])
        data[,i] <- as.factor(data[,i])
      }
    }
  }

  colnames(data) <- gsub('"',"'",colnames(data))

  for(col in colnames(data)){
    if(is.factor(data[[col]])){
      if(all(!is.na(suppressWarnings(as.numeric(levels(data[[col]])))))){
        data[[col]] <- as.numeric(data[[col]])
      }
    }
  }

  return(data)
}

caring_create_graphs <- function(data, arguments){
  initialvariables <- arguments[['variables']]

  if(!is.null(arguments[['weight']])){
    arguments[['weight']] <- arguments[['weight']][1]
    if((!arguments[['weight']] %in% colnames(data)) || !is.numeric(data[,arguments[['weight']]])){
      arguments[['weight']] <- NULL
    }else{
      arguments[['variables']] <- setdiff(arguments[['variables']],arguments[['weight']])
    }
  }

  pmax <- NULL
  if(is.null(arguments[['maxL']]) || !is.finite(arguments[['maxL']])){
    if(is.null(arguments[['criteria']]) || (arguments[['criteria']]=="Z" || arguments[['criteria']]=="hyp")){
      arguments[['maxL']] <- 0.5
    }
  }else{
    pmax <- arguments[['maxL']]
  }

  if(is.null(arguments[['dichotomies']])){
    dichotomies <- character(0)
    for(col in arguments[['variables']]){
      if(is.numeric(data[,col])){
        val <- unique(data[,col])
        if(!length(setdiff(val,c(0,1,NA))))
          dichotomies <- c(dichotomies,col)
      }
    }
    if(length(dichotomies)){
      arguments[['dichotomies']] <- dichotomies
      arguments[['valueDicho']] <- 1
    }
  }

  variables <- arguments[['variables']]
  if(!is.null(arguments[['dichotomies']])){
    variables <- setdiff(variables,arguments[['dichotomies']])
    if(!is.null(arguments[['metric']])){
      arguments[['metric']] <- setdiff(arguments[['metric']],arguments[['dichotomies']])
    }
  }
  if(!is.null(arguments[['metric']])){
    arguments[['variables']] <- setdiff(arguments[['variables']],arguments[['metric']])
  }

  arguments[['frequency']] <- TRUE
  arguments[['percentage']] <- TRUE
  arguments[['color']] <- "variable"
  arguments[['data']] <- data

  plots <- arguments[['plot']]
  arguments[['plot']] <- NULL

  multiArgs <- list(dir = arguments[['dir']])
  arguments[['dir']] <- NULL

  if("network" %in% plots){
    if(!is.null(arguments[['metric']]) && length(setdiff(arguments[['variables']],arguments[['metric']]))==0){
      arguments[['variables']] <- arguments[['data']][,arguments[['metric']]]
      keys <- union(names(formals(netCorr)),names(formals(netCoin)))
      arguments <- arguments[intersect(names(arguments),keys)]
      net1 <- do.call(netCorr,arguments)
    }else{
      keys <- union(names(formals(surCoin)),names(formals(netCoin)))
      arguments <- arguments[intersect(names(arguments),keys)]
      net1 <- do.call(surCoin,arguments)
    }
    multiArgs[['network']] = net1
  }
  if("scatter" %in% plots){
    scatArgs <- arguments[intersect(names(arguments),union(formalArgs("surScat"),formalArgs("netCoin")))]
    if(!length(scatArgs[['nclusters']])){
      scatArgs[['nclusters']] <- min(nrow(data)-1,6):2
    }
    scatArgs[['degreeFilter']] <- NULL
    net2 <- do.call(surScat,scatArgs)
    multiArgs[['scatter']] = net2
  }
  logs <- intersect(c("log-i.2","log-i.3","log-i.4","log-i.5"),plots)
  if(length(logs)){
    for(log in logs){
      logArgs <- arguments[intersect(names(arguments),union(formalArgs("logCoin"),formalArgs("netCoin")))]
      if(!is.null(arguments[['dichotomies']])){
        noFirstCat <- character(0)
        for(i in seq_along(arguments[['dichotomies']])){
          col <- arguments[['dichotomies']][i]
          valueDicho <- arguments[['valueDicho']][i]
          datacol <- as.character(logArgs[['data']][,col])
          logArgs[['data']][,col] <- factor(datacol,levels=union(valueDicho,setdiff(unique(datacol),valueDicho)))
          noFirstCat <- c(noFirstCat,col)
        }
        if(length(noFirstCat)){
          logArgs[['noFirstCat']] <- noFirstCat
        }
      }
      if(!is.null(pmax)){
        logArgs[['pmax']] <- pmax
      }
      logArgs[['color']] <- "var"
      logArgs[['order']] <- as.numeric(sub("log-i.","",log,fixed=TRUE))
      net3 <- do.call(logCoin,logArgs)
      multiArgs[[log]] = net3
    }
  }
  if("incidences" %in% plots){
    inciArgs <- arguments[intersect(names(arguments),union(formalArgs("allNet"),formalArgs("netCoin")))]
    inciArgs[['incidences']] <- arguments[['data']]
    if(!inciArgs[['color']] %in% colnames(inciArgs[['incidences']])){
      inciArgs[['color']] <- NULL
    }
    for(n in colnames(inciArgs[['incidences']])){
      inciArgs[['incidences']][,n] <- as.numeric(as.logical(inciArgs[['incidences']][,n]))
    }
    net4 <- do.call(allNet,inciArgs)
    multiArgs[['incidences']] = net4
  }
  if("regressions" %in% plots){
    glmArgs <- arguments[intersect(names(arguments),union(formalArgs("glmCoin"),formalArgs("netCoin")))]

    chaine <- arguments[['chaine']]
    family <- arguments[['family']]

    chaine[initialvariables %in% arguments[['exogenous']]] <- 0
    family[chaine==0] <- NA

    # data.frame para la elaboración de la fórmula (ecuación)
    A <- data.frame(v=initialvariables,
                n=chaine,
                m=family,
                stringsAsFactors = FALSE)

    A <- A[order(A$n, as.numeric(rownames(A)), decreasing=TRUE),]
    formulas <- ""

    # Bucle sobre cada fila del dataframe
    for (i in seq_len(nrow(A))) {
      subvariables <- A$v[A$n < A$n[i]]
      if (length(subvariables) > 0) {
        ecuacion <- paste(A$v[i], "~", paste(subvariables, collapse = "+"), ",", A$m[i])
        if (formulas != "") {
          formulas <- paste(formulas, ecuacion, sep = "\n")
        } else {
          formulas <- ecuacion
        }
      }
    }

    glmArgs[['formulas']] <- formulas
    glmArgs[['data']] <- data[,initialvariables]

    if(!is.null(arguments[['dichotomies']])){
      for(i in seq_along(arguments[['dichotomies']])){
        dic <- arguments[['dichotomies']][i]
        value <- arguments[['valueDicho']][i]
        glmArgs[['data']][,dic] <- 0
        glmArgs[['data']][glmArgs[['data']][,dic]==value,dic] <- 1
      }
    }

    net5 <- do.call(glmCoin,glmArgs)
    multiArgs[['regressions']] = net5
  }

  return(do.call(multigraphCreate,multiArgs))
}

caring <- function(filepath,arguments){

  data <- caring_read_file(filepath)

  graphs <- caring_create_graphs(data,arguments)

  return(graphs)
}
