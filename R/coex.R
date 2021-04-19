#### Modesto Escobar
# Sat Apr 03 18:46:49 2021 ------------------------------
# Páginas de sociólogos

coexist <- function(periods, name="name", start="start", end="end", inform=names(periods), 
                    plusstart=0, minusend=0, igraph=FALSE, ...){

  periods <- periods[!(is.na(periods[[start]]) | duplicated(periods[[name]])),]
  minimum <- min(periods[[start]], na.rm=TRUE)+plusstart
  maximum <- max(periods[[end]], na.rm=TRUE)-minusend
  anos <- minimum:maximum

# E is a matrix of incidences of Years
  E<-matrix(NA,nrow=nrow(periods),ncol=length(anos))
  colnames(E)<-anos

# datos is a data frame of incidences of sociologists in Years
  for(i in 1:nrow(periods)) E[i,]<-ifelse(anos>=periods[[start]][i]+plusstart & (anos<=periods[[end]][i]-minusend | is.na(periods[[end]][i])),1,0)
  Sociologist<-as.character(periods[[name]])
  datos<-as.data.frame(t(E))
  colnames(datos)<-Sociologist

# coexisten is the edgeList of coexistence
  coexistence <- edgeList(coin(datos), procedures=c("F"), criteria="F", min=1)
  arguments <- list(nodes=periods[, inform], links=coexistence, ...)
  xNx <- do.call(netCoin, arguments)
  if (igraph) return(toIgraph(xNx)) else return(xNx)
}

dyncohort <- function(periods, name="name", start="start", inform=names(periods), years=0, igraph=FALSE, ...) {
  D<-matrix(NA, nrow=nrow(periods), ncol=nrow(periods))
  colnames(D) <- rownames(D) <- periods[[name]]
  for(i in 1:nrow(periods))D[i,]=ifelse(abs(periods[[start]][i]-t(periods[[start]]))<=years,abs(periods[[start]][i]-t(periods[[start]])+1),0)
  diag(D)<-0
 
  cogeneradin<-edgeList(D, procedures="shape")
  cogeneradin$value <- 2+years-cogeneradin$value
  colnames(cogeneradin)<-c("Source","Target","Prox.")
  arguments <- list(nodes=periods[, inform], links=cogeneradin, ...)
  xNx <- do.call(netCoin, arguments)
  if (igraph) return(toIgraph(xNx)) else return(xNx)
}
