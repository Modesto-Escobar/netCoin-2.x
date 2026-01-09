\name{coin}
\alias{coin}
\title{
Coincidence matrix.
}
\description{
A coin object is a squared matrix of coincidences with its names and the frequency of events as attributes.
}
\usage{
coin(incidences, minimum = 1, maximum = nrow(incidences),
     sort = FALSE, decreasing = TRUE, 
     total = FALSE, subsample = FALSE,
     weight = NULL, pairwise = FALSE)
}
\arguments{
  \item{incidences}{an incidence matrix or data frame with only 0/1 variables}
  \item{minimum}{minimum frequency to be considered}
  \item{maximum}{maximum frequency to be considered}
  \item{sort}{sort the coincidence matrix according to frequency of events}
  \item{decreasing}{decreasing or increasing sort of the matrix}
  \item{total}{add one first row and column with total}
  \item{subsample}{retrict the analysis to scenarios with at least one event}
  \item{weight}{a vector of weights. Optimal for data.framed tables}
  \item{pairwise}{Pairwise mode of handling missing values if TRUE. Listwise by default.}
}
\details{
Produce a matrix of coincidences from a matrix of incidences.
}
\value{
An object of \code{coin} class
\item{n}{Number of scenarios (rows of the incidence matrix)}
\item{f}{Coincidence matrix}
}
\references{
  Escobar, M. and Martinez-Uribe, L. (2020)
  Network Coincidence Analysis: The \code{netCoin} \code{R} Package.
  \emph{Journal of Statistical Software}, \bold{93}, 1-32.
  \doi{10.18637/jss.v093.i11}.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
## Random incidence matrix: 25 scenarios, 4 events.
I <- matrix(rbinom(100, 1, .5), nrow = 25, ncol = 4,
            dimnames = list(NULL, c("A", "B", "C", "D")))
coin(I, sort = TRUE)

## Hair by Eye by Sex table from M. Friendly (2000)
data(HairEyeColor)
H<-as.data.frame(HairEyeColor)
W<-H$Freq
I<-dichotomize(H,c("Hair","Eye","Sex"),add=FALSE)
coin(I,w=W)
}
