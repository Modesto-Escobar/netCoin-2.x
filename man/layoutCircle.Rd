\name{layoutCircle}
\alias{layoutCircle}
\title{Produce a circle layout of any number of nodes.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\value{
This function returns the input data frame of nodes with the resulting layout applied.
}

\usage{
layoutCircle(N,nodes=seq_len(nrow(N)),deg=0,name=NULL)
}
\arguments{
\item{N}{a data frame of nodes.}

\item{nodes}{a vector specifing nodes.}

\item{deg}{degrees to rotate.}

\item{name}{name of column with node names.}
}
\description{
\code{layoutCircle} produces a circle layout of any number of nodes.
}
\examples{
A <- data.frame(name=letters)

L <- layoutCircle(A,name="name")

netCoin(A,layout=L)
}
