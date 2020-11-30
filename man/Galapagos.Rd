\name{Galapagos}
\alias{Galapagos}
\docType{data}
\title{
Data: Finches' presence in Galapagos Islands.
}
\description{
Data frame with absence(0) presence(1) of finches in the Galagos Islands.
}
\usage{data("Galapagos")}
\format{
  A data frame with 17 localizations (islands) and 13 variables (Genus and species of the finches):
  \describe{
    \item{\code{Geospiza magnirostris}}{}
    \item{\code{Geospiza fortis}}{}
    \item{\code{Geospiza fuliginosa}}{}
    \item{\code{Geospiza difficilis}}{}
    \item{\code{Geospiza scandens}}{}
    \item{\code{Geospiza conirostris}}{}
    \item{\code{Camarhynchus psitticula}}{}
    \item{\code{Camarhynchus pauper}}{}   
    \item{\code{Camarhynchus parvulus}}{}
    \item{\code{Platyspiza crassirostris}}{}
    \item{\code{Cactospiza pallida}}{}
    \item{\code{Cactospiza heliobates}}{}
    \item{\code{Certhidea olivacea}}{}
    }
}
\references{
Sanderson, James (2000). Testing Ecological Patterns: A Well-known Algorithm from Computer Science Aids the Evaluation of Species Distributions. American Scientist, 88, pp. 332-339.
}
\examples{
data(Galapagos)
head(Galapagos,10)
}
\keyword{datasets}