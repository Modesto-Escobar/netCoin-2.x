\name{mobileEdges}
\alias{mobileEdges}
\title{Mobile Edges.}
\description{
Convert a data frame with one number (normally a year) into an edge list form with those whose numbers (years) have a difference lower or equal to a quantity.
}
\usage{
mobileEdges(data, name = 1, number = 2, difference=0)
}
\arguments{
  \item{data}{a data frame with a name and a number (year).}
  \item{name}{Column with the names (default= first column).}
  \item{number}{Column with the number (year) to compare (default= second column.}
  \item{difference}{Minimum difference between numbers of every two pair of names to create the edge or link (default=15).}

}
\value{
A data frame in which the two first columns are source and target. The rest of the columns are sim.=(1+threshold-real difference) and dist.=(difference between numbers)
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
# From a random incidence matrix I(25X4)
data("sociologists")
mobileEdges(sociologists)
}
