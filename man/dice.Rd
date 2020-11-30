\name{dice}
\alias{dice}
\docType{data}
\title{
Data: Roll a die (100 times).
}
\description{
Data frame with events as result.
}
\usage{data("dice")}
\format{
  A data frame with 100 observations (scenarios) on the following 11 variables (events):
  \describe{
    \item{\code{dice}}{: a numeric vector, representing dice results}
    \item{\code{1}}{: a dichotomous vector of the elemental event "1"}
    \item{\code{2}}{: a dichotomous vector of the elemental event "2"}
    \item{\code{3}}{: a dichotomous vector of the elemental event "3"}
    \item{\code{4}}{: a dichotomous vector of the elemental event "4"}
    \item{\code{5}}{: a dichotomous vector of the elemental event "5"}
    \item{\code{6}}{: a dichotomous vector of the elemental event "6"}
    \item{\code{odd}}{: a dichotomous vector of odd events}
    \item{\code{even}}{: a dichotomous vector of even events}
    \item{\code{small}}{: a dichotomous vector of small number events}
    \item{\code{large}}{: a dichotomous vector of large number events}
    }
}
\source{
Random extraction via \code{sample(1:6,100,replace=TRUE)}
}
\references{
See \code{\link{events}.}
}
\examples{
data(dice)
head(dice,10)
}
\keyword{datasets}