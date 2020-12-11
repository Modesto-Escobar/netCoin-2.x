\name{layoutGrid}
\alias{layoutGrid}
\title{Produce a layout of any number of nodes.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\value{
This function returns the input data frame of nodes with the resulting layout applied.
}

\usage{
layoutGrid(N,string,name=NULL,byrow=FALSE)
}
\arguments{
\item{N}{a data frame of nodes.}

\item{string}{a character vector specifing grouped nodes.}

\item{name}{name of column with node names.}
\item{byrow}{logical. If 'FALSE' (the default) the layout is filled by columns, otherwise the layout is filled by rows.}
}
\description{
\code{layoutGrid} produces a grid layout of any number of nodes.
}
\examples{
A <- data.frame(name=letters)

L <- layoutGrid(A,"a,b,c,d,e.f,g,h,i,j.k,l,m,n,o,p.q,r,s,t,u.v,w,x,y,z","name")

netCoin(A,layout=L)
}
