\name{events}
\alias{events}
\docType{data}
\title{
Data: Attributes of the dice events.
}
\description{
Data frame with the attributes of the events of dice.
}
\usage{data("events")}
\format{
  A data frame with 10 observations on the following 4 variables:
  \describe{
    \item{\code{name}}{: a factor vector with 10 levels}
    \item{\code{label}}{: a factor vector with 10 levels}
    \item{\code{frequency}}{: a numeric vector}
    \item{\code{type}}{: a factor vector with 2 levels}
  }
}
\source{
data(dice);
coin.dice<-coin(dice);
asNodes(coin.dice)
}
\references{
See \code{\link{dice}}.
}
\examples{
data(events)
events
}
\keyword{datasets}
