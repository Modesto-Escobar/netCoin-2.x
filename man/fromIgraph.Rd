\name{fromIgraph}
\alias{fromIgraph}
\title{Produce interactive networks from igraph objects.}
\references{
  Escobar, M. and Martinez-Uribe, L. (2020)
  Network Coincidence Analysis: The \code{netCoin} \code{R} Package.
  \emph{Journal of Statistical Software}, \bold{93}, 1-32.
  \doi{10.18637/jss.v093.i11}.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\value{
This function returns a \code{netCoin} object.
If the 'dir' attribute is specified, the function creates a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}
\usage{
fromIgraph(G, ...)
}
\arguments{
\item{G}{an igraph object.}
\item{...}{Any \link{netCoin} argument.}
}
\description{
\code{fromIgraph} produce an interactive network from an igraph object.
}
\examples{
g <- igraph::make_ring(10)
fromIgraph(g)
}
