\name{shinyCoin}
\alias{shinyCoin}
\title{Include netCoin Plots in Shiny.}
\description{Load a netCoin plot to display in shiny.}
\usage{
shinyCoin(x)
}
\arguments{
  \item{x}{is a \code{netCoin}, \code{barCoin} or \code{timeCoin} object.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
\dontrun{
# A character column (with separator)
frame <- data.frame(A = c("Man; Women", "Women; Women",
                        "Man; Man", "Undet.; Women; Man"))
data <- dichotomize(frame, "A", sep="; ")[2:4]
C <- coin(data) # coincidence matrix
N <- asNodes(C) # node data frame
E <- edgeList(C) # edge data frame
net <- netCoin(N, E) # netCoin object
shinyCoin(net)
}
}
