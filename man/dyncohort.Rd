\name{dyncohort}
\alias{dyncohort}
\title{Interactive graphs of dynamic cohorts.}
\description{
\code{dyncohort} produces interactive graphs representing dynamic cohorts. Two periods or lifes belongs to the same cohort if there are a difference of years in their start less or equal to a given number. In case of people's life, 15 or 25 are appropiate quantities to set. If year is equal to 0, a cohort is defined a those periods or lifes that begin at the same year. 
}
\usage{
dyncohort(periods, name="name", start="start", fields=names(periods), 
          years=0, igraph=FALSE, ...)
}
\arguments{
\item{periods}{a data frame with at least two vectors with name and start of the periods or lives.}
\item{name}{name of the vector with names in the data frame.}
\item{start}{name of the vector with starts in the data frame.}
\item{fields}{vector of the names of the periods data frame to be taken into account.}
\item{years}{number of years to be considered as length of the cohort.}
\item{igraph}{produces an igraph object instead of a netCoin class.}
\item{...}{Any \link{netCoin} argument.}
}

\value{
This function creates a timeCoin object (or igraph) and, if plotted, a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.

A netCoin object has three elements:
\item{nodes}{A data frame with the periods.}
\item{links}{A data frame with the events.}
\item{options}{A list of options for the interactive graph.}
}

\note{
Periods could be the life of people, in whose case start is their birth year.
}

\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}


%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{timeCoin}} and \code{\link{coexist}}
}

\examples{
# With sociologists data.
data(sociologists)
dyncohort(sociologists, start="birth")
# Condider 15 year dynamic cohort:
sociologists$picture <- system.file("extdata", sociologists$picture,
        package="netCoin") # copy path to the picture field
dyncohort(sociologists, start="birth", year=15, image="picture", imageName="name")
}
