\name{saveGhml}
\alias{saveGhml}
\title{Save a netCoin object as a .graphml file to be read in Gephi, Pajek, ...}
\description{
\code{saveGhml} produces a .graphml file from a netCoin object. 
}
\value{
The function creates a file with vertices and arcs or edges of a netCoin object. 
}
\usage{
saveGhml(net, file="netCoin.graphml")
}
\arguments{
\item{net}{A netCoin object.}
\item{file}{The name of the file. If not extension, .gexf is used as default.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
\dontrun{
# A character column (with separator)
frame <- data.frame(A = c("Man; Women", "Women; Women",
                        "Man; Man", "Undet.; Women; Man"))
data <- dichotomize(frame, "A", add=FALSE, sep = "; ")
graph <- allNet(data, maxL=.5) # graph from an incidence matrix

saveGhml(graph,"graph") # save graph.net file
}
}

