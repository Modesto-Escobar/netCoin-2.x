\name{sociologists}
\alias{sociologists}
\docType{data}
\title{
Data: Classical sociologists.
}
\description{
Data frame with names, birth and death year data, birth country and movement.
}
\usage{data("sociologists")}
\format{
  A data frame with life's period of 16 sociologists and the following 11 variables to study time coincidences:
  \describe{
    \item{\code{name}}{: name and last name of the sociologist.}
    \item{\code{birth}}{: birth year.}
    \item{\code{death}}{: death year.}
    \item{\code{birth_place}}{: birth place.}
    \item{\code{birth_country}}{: birth country.}
    \item{\code{death_place}}{: death place.}
    \item{\code{death_country}}{: death country.}
    \item{\code{label}}{: combination of name, birth and death dates.}
    \item{\code{generation}}{: generation (every 25 years) of the sociologists.}
    \item{\code{school}}{: school of thought.}
    \item{\code{picture}}{: name of the file where their picture is.}
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
