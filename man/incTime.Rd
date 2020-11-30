\name{incTime}
\alias{incTime}
\title{Time incidences.}
\description{
Convert a data frame with two numbers (normally a beginning year and end year) into an incidences matrix whose rows are the intermediate numbers, and whose columns are the content of the names column.
}
\usage{
incTime(data, name = "name", beginning = "birth", end= "death")
}
\arguments{
  \item{data}{a data frame a name and two numbers.}
  \item{name}{Column with the names (default= "name").}
  \item{beginning}{Column with the beginning number to include (default= "birth").}
  \item{end}{Column with the end number to include (default= "death").}
}
\value{
A data frame in which the two first columns are source and target. The rest of the columns are sim.=(1+threshold-real difference) and dist.=(difference between numbers)
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# From sociologists data
data("sociologists")
head(incTime(sociologists))[,1:5]
}
