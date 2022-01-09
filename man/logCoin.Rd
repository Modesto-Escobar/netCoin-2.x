\name{logCoin}
\alias{logCoin}
\title{Networked log-linear models.}
\description{
\code{logCoin} produces a network object from loglinear models parameters. 
}
\value{
This function creates a netCoin object (or igraph) and, if stated, a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}

\usage{
logCoin(data, variables=names(data), exogenous=NULL, noFirstCat= NULL,
        weight=NULL, order= 2, pairwise=FALSE, twotails = FALSE,
        pmax = 0.05, frequency = FALSE, percentage = FALSE, 
        directed=FALSE, igraph=FALSE, ...)
}
\arguments{
  \item{data}{a data frame.}
  \item{variables}{a vector of names of variables included in the previous data frame.}
  \item{exogenous}{a vector of names of variables whose relations amongst them are of no interest. None by default.}
  \item{noFirstCat}{a vector of names of dichotomous variables to appear without the category (no characteristic).}
  \item{weight}{a vector of weights. Optimal for dataframed tables.}
  \item{order}{maximum order parameters to be included in the loglinear model (default=2)}
  \item{pairwise}{Pairwise mode of handling missing values if TRUE. Listwise by default.}
  \item{twotails}{Application of twotail tests to the parameters (default: FALSE, i.e., onetail)}
  \item{pmax}{maximum value of the statistic to include the edge in the list. By default is 0.05, but 0.5 is recommended if data has not been sampled.}
  \item{frequency}{a logical value true if frequencies are to be shown. Default=FALSE.}
  \item{percentage}{a logical value true if percentages are to be shown. Default=TRUE.}
  \item{directed}{includes arrows to the links (target would be the categories of first mention variables).}
  \item{igraph}{Produces an igraph object instead of a netCoin object if TRUE.}
  \item{...}{Any \link{netCoin} argument.}
}

\references{
  Escobar, M. and Martinez-Uribe, L. (2020)
  Network Coincidence Analysis: The \code{netCoin} \code{R} Package.
  \emph{Journal of Statistical Software}, \bold{93}, 1-32.
  \doi{10.18637/jss.v093.i11}.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# A n=1,000 sample from the European Social Survey.(Round 8, 2016)
data("ess")
logCoin(ess, c("Social participation", "Political participation"), 
  noFirstCat=c("Social participation", "Political participation"),  
  exogenous=c("Age", "Gender"),  weight = "cweight", 
  order=3, pmax=.05,percentage = TRUE, frequency = TRUE ) # network object
}

