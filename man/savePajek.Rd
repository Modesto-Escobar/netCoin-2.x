\name{savePajek}
\alias{savePajek}
\title{Save a netCoin object as a .net (.paj) file to be read in Pajek, Gephi, ...}
\description{
\code{savePajek} produces a .net (.paj) file from a netCoin object. 
}
\value{
The function creates a file with vertices and arcs or edges of a netCoin objetct. Vectors and partitions can be also included. .
}
\usage{
savePajek(net, file="file.net", arcs=NULL, edges=NULL, 
          partitions=NULL, vectors=NULL)
}
\arguments{
\item{net}{a netCoin object.}
\item{file}{The name of the file without extension. It will be .net or .paj acoording to data. The default is file.net or file.paj}
\item{arcs}{Names of netCoin$links to be included and considered as arcs in the Pajek file..}
\item{edges}{Names of netCoin$links to be included and considered as edges in the Pajek file..}
\item{partitions}{Names of netCoin$nodes to be included and considered as partitions in the Pajek file.}
\item{vectors}{Names of netCoin$nodes to be included and considered as vectors in the Pajek file.}
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
graph <- allNet(data) # graph from an incidence matrix

savePajek(graph,"graph",edges="Haberman") # save graph.net file
}
}

