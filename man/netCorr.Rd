\name{netCorr}
\alias{netCorr}
\title{Networked correlations.}
\description{
\code{netCorr} produces a network object of correlations. Its input has to be at least one set of quantitative variables. 
}
\value{
The function creates a netCoin object and eventually a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}
\usage{
netCorr(variables, weight=NULL, pairwise=FALSE,
        minimum=-Inf, maximum=Inf, sort=FALSE, decreasing=TRUE,
        frequency=FALSE, means=TRUE, 
        method="pearson", criteria="p", Bonferroni=FALSE,
        minL=0, maxL=Inf,
        sortL=NULL, decreasingL=TRUE,
        igraph=FALSE, ...)
}
\arguments{
\item{variables}{a data frame with at least two quantitative variables.}
\item{weight}{a vector of weights. Optimal for data.framed tables}
\item{pairwise}{Pairwise mode of handling missing values if TRUE. Listwise by default.}
\item{minimum}{minimum frequency to be considered}
\item{maximum}{maximum frequency to be considered}
\item{sort}{sort the correlation matrix according to the frequency of the events}
\item{decreasing}{decreasing or increasing sort of the matrix}
\item{frequency}{a logical value true if frequencies are to be shown. Default=FALSE.}
\item{means}{a logical value true if means are to be shown. Default=TRUE.}
\item{method}{a vector of statistics of similarity. Pearson correlation by default. spearman and kendall are also possible}
\item{criteria}{statistic to be use for selection criteria.}
\item{Bonferroni}{Bonferroni criterium of the signification test.}
\item{minL}{minimum value of the statistic to include the edge in the list.}
\item{maxL}{maximum value of the statistic to include the edge in the list.}
\item{sortL}{sort the list according to the values of a statistic. See below}
\item{decreasingL}{order in a decreasing way.}
\item{igraph}{Produces an igraph object instead of a netCoin object if TRUE}
\item{...}{Any \link{netCoin} argument.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# A character column (with separator)
data(iris)
netCorr(iris[,1:4],ltext="value",
 main="Correlations between measurements of Iris Species",
 note="Anderson, Edgar (1935) y Fisher, R. A. (1936)") # network object
}

