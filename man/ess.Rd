\name{ess}
\alias{ess}
\docType{data}
\title{
Data: European Social Survey, Round-8.
}
\description{
A sample size of 1,000 respondents from the European Social Survey, Round-8.
}
\usage{data("ess")}
\format{
  A data frame with 1000 cases (respondents) and 5 variables:
  \describe{
    \item{\code{Gender}}{Gender (factor vector): Female, Male.}
    \item{\code{Age}}{Age (recoded factor vector): 15-29, 30-30, 40-49, 50-59, 60-69, 70 and +.}
    \item{\code{Social participation}}{Social participation (factor vector): No, Yes.}
    \item{\code{Political participation}}{Political participation (factor vector): No, Yes.}
    \item{\code{cweight}}{cweight (numeric vector): Cases weight.}
    }
}
\references{
ESS Round 8: European Social Survey Round 8 Data (2016). Data file edition 2.1. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC. \href{https://www.europeansocialsurvey.org/data/download.html?r=8}{doi:10.21338/NSD-ESS8-2016}.
}
\examples{
data("ess")
head(ess,10)
}
\keyword{datasets}