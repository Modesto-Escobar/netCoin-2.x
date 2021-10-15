\name{calCentr}
\alias{calCentr}
\title{Categorize a network}
\description{
This function calculates the centrality measures of a network.
}
\usage{
calCentr(graph,
  measures = c("degree","wdegree","closeness","betweenness","eigen"),
  order = "")
}
\arguments{
  \item{graph}{A \code{\link[netCoin]{netCoin}} object.}
  \item{measures}{Character vector of the measures to be calculated (See details).}
  \item{order}{Sort the data.frame by the different measures.}
}
\details{
This function reproduces some of the most significant classic Social Network Theory's centrality measures. See Wasserman (1994),  Freeman (1978), or Bonacich & Lloyd (2001) to know more. 

a) Degree =  Degree centrality is measured by the total amount of direct links with the other nodes.

b) Closeness = Closeness centrality is meant to measure one node to the others nodes' sum distances

c) Betweenness = Betweenness centrality measures one node undertaking "mediation" role in a network. 

d) Eigen = Eigenvector centrality measures a node's importance while giving consideration to the importance of its neighbors.

By default, measures = "all", thus all the measures will be calculated. The function can be applied to an igraph or a netCoin object. In case the graph is undirected, it will show the degree, weighted degree, closeness, betweeness and eigen degree. Moreover, if it us directed, it will show the indegree, windegree and outdegree, both weighted and unweighted (See example.).

}
\value{
This function creates a list containing two elements: 1) a data.frame (nodes) with all the centrality measures applied to the graph and 2) another data.frame (graph) with this measures applied to the whole network. 
}
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
E <- edgeList(C) # edge data frame
G <- netCoin(N, E, showArrows=TRUE) # netCoin object
calCentr(G, "all")
}
