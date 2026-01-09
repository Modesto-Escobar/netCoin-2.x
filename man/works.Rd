\name{works}
\alias{works}
\docType{data}
\title{
Data: Classical sociological works.
}
\description{
Data frame with classical sociological works writen by authors in the sociologists data frame.
}
\usage{data("sociologists")}
\format{
  A data frame with 54 observations (events) and the following 4 variables to study coincidences in time:
  \describe{
    \item{\code{name}}{: name and last name of the author of the work.}
    \item{\code{label}}{: abbreviation of the complete name.}
    \item{\code{works}}{: work's name.}
    \item{\code{date}}{: year of its first publication.}
    }
}
\source{
Own elaboration from manuals of sociology.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\references{
See \code{\link{events}.}
}
\examples{
data(works)
head(works, 10)
tail(works, 10)
}
\keyword{datasets}
