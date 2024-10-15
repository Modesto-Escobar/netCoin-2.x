\name{toIgraph}
\alias{toIgraph}
\title{igraph object.}
\description{\code{igraph} object from a \code{netCoin} object.}
\usage{
toIgraph(net)
}
\arguments{
  \item{net}{is a \code{netCoin} object. See \code{\link{netCoin}}}
}
\value{An \code{igraph} object.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# A character column (with separator)
frame <- data.frame(A = c("Man; Women", "Women; Women",
                        "Man; Man", "Undet.; Women; Man"))
data <- dichotomize(frame, "A", sep = "; ")[2:4]
C <- coin(data) # coincidence matrix
N <- asNodes(C) # node data frame
E <- edgeList(C)
net <- netCoin(N, E)
toIgraph(net) # conversion into a igraph object
}
