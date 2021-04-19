\name{coexist}
\alias{coexist}
\title{\code{coexist} Interactive network of time coexistences of periods.}
\description{
\code{coexist} produces interactive graphs representing coexistence. Two periods or lifes coexist if they share a given number of years.
}
\usage{
coexist(periods, name="name", start="start", end="end", 
        inform=names(periods), plusstart=0, minusend=0, igraph=FALSE, ...)
}
\arguments{
\item{periods}{a data frame with at least three vectors with name, start and end of the periods.}
\item{name}{name of the vector with names in the periods data frame.}
\item{start}{name of the vector with starts in the periods data frame.}
\item{end}{name of the vector with ends in the periods data frame.}
\item{inform}{vector of the names of the periods data frame to be taken into account.}
\item{plusstart}{number of years to be trimmed at the beginning of each period.}
\item{minusend}{number of years to be trimmd at the end of each period,}
\item{igraph}{produces an igraph object instead of a netCoin class.}
\item{...}{Any \link{netCoin} argument.}
}

\details{
Two periods coexists if they have at least one year in common. Periods can be trimmed at the begining or at the end.
}

\value{
This function creates a netCoin object (or igraph) and, if plotted, a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.

A netCoin object has three elements:
\item{nodes}{A data frame with the periods.}
\item{links}{A data frame with the events.}
\item{options}{A list of options for the interactive graph.}
}
\note{
Periods could be the life of people, in whose case start is their birth and end their death year.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\seealso{
\code{\link{timeCoin}} and \code{\link{dyncohort}}
}

\examples{
# With sociologists data.
data(sociologists)
coexist(sociologists, start="birth", end="death")
# Omit as coexistence the 15 firts years of life, and produce an igraph object:
coexist(sociologists, start="birth", end="death", minusstart=15, igraph=TRUE)
}
