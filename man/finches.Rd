\name{finches}
\alias{finches}
\docType{data}
\title{
Data: Finches'attributes in Galapagos islands.
}
\description{
Data frame with events as result.
}
\usage{data("finches")}
\format{
  A data frame with 13 observations (pinches) and 4 variables (name and characteristics):
  \describe{
    \item{\code{name}}{: Genus and species of the finche}
    \item{\code{frequency}}{: number of islands where the finche can be found}
    \item{\code{type}}{: Genus of the finche}
    \item{\code{species}}{: name of the file containing the picture of the finche}
    }
}
\references{
Sanderson, James (2000). Testing Ecological Patterns: A Well-known Algorithm from Computer Science Aids the Evaluation of Species Distributions. American Scientist, 88, pp. 332-339.
}
\examples{
data(finches)
head(finches,10)
}
\keyword{datasets}