\name{pieCoin}
\alias{pieCoin}
\title{
pie charts.
}
\description{
It generates pie charts from a coin object.
}
\usage{
pieCoin(x, colors = c("#000000","#8dc7e6", "#ffffff","#005587"),
  nodes = NULL, links = NULL, name = NULL, lcolor = NULL, expected = TRUE,
  abline = NULL, main = NULL, note = NULL, showLegend = TRUE, help = NULL,
  helpOn = FALSE, cex = 1, language = c("en", "es", "ca"), dir = NULL)
}
\arguments{
  \item{x}{a \code{coin} object.}
  \item{nodes}{a data frame with information for each event.}
  \item{links}{a data frame with information for each pie.}
  \item{name}{name of the column with names in the nodes data frame.}
  \item{colors}{a vector of colors to be used when filling the slices.}
  \item{lcolor}{name of the column with color variable in the links data frame.}
  \item{expected}{Should expected coincidences be displayed?}
  \item{abline}{adds one or more straight lines between pies.}
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
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
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
