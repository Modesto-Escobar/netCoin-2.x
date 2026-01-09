\name{propCoin}
\alias{propCoin}
\title{
Express Coin Entries as Fraction of Marginal Table
}
\description{
This is like 'prop.table' for 'coin' objects.
}
\usage{
propCoin(x, margin= 0, decimals=1)
}
\arguments{
  \item{x}{'coin' object.}
  \item{margin}{index, or vector of indices to generate margin for.}
  \item{decimals}{integer indicating the number of decimal places to be used.}
}
\value{
Table like 'x' expressed relative to 'margin'.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
## Random incidence matrix: 25 scenarios, 4 events.
I <- matrix(rbinom(100, 1, .5), nrow = 25, ncol = 4,
            dimnames = list(NULL, c("A", "B", "C", "D")))
C <- coin(I, sort = TRUE)

propCoin(C, 1)
}
