\name{pieCoin}
\alias{pieCoin}
\title{
pie charts.
}
\description{
It generates pie charts from a coin object.
}
\usage{
pieCoin(x, main = NULL, note = NULL, showLegend = TRUE,
  help = NULL, helpOn = FALSE, cex = 1,
  language = c("en", "es", "ca"), dir = NULL)
}
\arguments{
  \item{x}{a \code{coin} object.}
  \item{main}{upper title of the graph.}
  \item{note}{lower title of the graph.}
  \item{showLegend}{a logical value true if the legend is to be shown.}
  \item{help}{a character string indicating a help text of the graph.}
  \item{helpOn}{Should the help be shown at the beginning?}
  \item{cex}{number indicating the amount by which plotting text should be scaled relative to the default.}
  \item{language}{a character vector (es=spanish; en=english; ca=catalan).}
  \item{dir}{a "character" string representing the directory where the web files will be saved.}
}
\value{
a \code{pieCoin} object.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
## Hair by Eye by Sex table from M. Friendly (2000)
data(HairEyeColor)
H<-as.data.frame(HairEyeColor)
W<-H$Freq
I<-dichotomize(H,c("Hair","Eye","Sex"),add=FALSE)
C <- coin(I,w=W)
pie <- pieCoin(C)
\dontrun{
plot(pie)
}
}
