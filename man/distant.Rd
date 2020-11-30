\name{distant}
\alias{distant}
\title{
Distance matrix.
}
\description{
Convert a similarity matrix into a distance matrix.
}
\usage{
distant(s, t = FALSE)
}
\arguments{
  \item{s}{a similarity matrix}
  \item{t}{return the same matrix if t=FALSE}
}
\details{
For better resultas, use the parameter distance in \code{\link{sim}} function.
}
\value{
A distance matrix.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# From a random incidence matrix I(25X4)
I <- matrix(rbinom(100, 1, .5), nrow = 25, ncol = 4,
     dimnames = list(NULL, c("A", "B", "C", "D")))
J <- sim(I, "Jaccard")
distant(J, t = TRUE)
#Same results
sim(I, "Jaccard", distance = TRUE)
}
