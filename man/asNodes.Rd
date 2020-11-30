\name{asNodes}
\alias{asNodes}
\title{Nodes data frame.}
\description{Nodes data frame from either an edge list or a \code{coin} object.}
\usage{
asNodes(C, frequency = TRUE, percentages = FALSE, language = c("en","es","ca"))
}
\arguments{
  \item{C}{has to be an edge list or, better, a \code{coin} object.}
  \item{frequency}{add frequency of nodes}
  \item{percentages}{add nodes percentages}
  \item{language}{a character vector (es=spanish; en=english; ca=catalan).}
}
\value{A data frame with nodes' names and their frequency and/or percentages if the input is a \code{coin} object}
\references{
  Escobar, M. and Martinez-Uribe, L. (2020)
  Network Coincidence Analysis: The \code{netCoin} \code{R} Package.
  \emph{Journal of Statistical Software}, \bold{93}, 1-32.
  \doi{10.18637/jss.v093.i11}.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# From a random incidence matrix I(25X4)
I <- matrix(rbinom(100, 1, .5), nrow = 25, ncol = 4,
     dimnames = list(NULL, c("A", "B", "C", "D")))
C <- coin(I)
asNodes(C)
}
