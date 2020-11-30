\name{sociologists}
\alias{sociologists}
\docType{data}
\title{
Data: Sociologists born in the 19th century.
}
\description{
Data frame with names, birth and death year data, birth country and movement.
}
\usage{data("sociologists")}
\format{
  A data frame with 33 observations and the following 4 variables (events) to study coincidences in time:
  \describe{
    \item{\code{name}}{: name and last name of the sociologist}
    \item{\code{birth}}{: birth year}
    \item{\code{death}}{: death year}
    \item{\code{birthcountry}}{: birth country}
    \item{\code{movements}}{: movement or school of thought}
    }
}
\source{
Own elaboration from manuals of sociology.
}
\references{
See \code{\link{events}.}
}
\examples{
data(sociologists)
head(sociologists, 10)
tail(sociologists, 10)
}
\keyword{datasets}
