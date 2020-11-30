\name{lower}
\alias{lower}
\title{
Similarity/distance matrix display.
}
\description{
Display the lower part of a matrix with a specified number of decimals.
}
\usage{
lower(matrix, decimals = 3)
}
\arguments{
  \item{matrix}{a symmetric similarity/distance matrix}
  \item{decimals}{number of decimals to be displayed}
}
\value{
A data frame of characters.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# From a random incidence matrix I(25X4)
I <- matrix(rbinom(100, 1, .5), nrow = 25, ncol = 4,
     dimnames = list(NULL, c("A", "B", "C", "D")))
lower(sim(I, "Jaccard"), 2)
}
