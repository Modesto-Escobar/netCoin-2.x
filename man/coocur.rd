\name{coocur}
\alias{coocur}
\title{
Coocurrence matrix.
}
\description{
A coocurrence object consists of a matrix with the number of ocurrences in its main diagonal and the number of coocurrences outside this diagonal.
Besides, this object has two attributes: 1) n is the total of the sum of the ocurrences in each row.2) m is the sum of the maximum number of ocurrences in each row.
}
\usage{
coocur(ocurrences, minimum = 1, maximum = Inf,
       sort = FALSE, decreasing = TRUE)
}
\arguments{
  \item{ocurrences}{an ocurrence matrix or data frame}
  \item{minimum}{minimum frequency to be considered}
  \item{maximum}{maximum frequency to be considered}
  \item{sort}{sort the coincidence matrix according to frequency of events}
  \item{decreasing}{decreasing or increasing sort of the matrix}
}
\details{
Produce a matrix of coocurrences from a matrix of occurences.
}
\value{
An object of \code{cooc} class with a coocurrence matrix. It has two attributes:
\item{n}{Total sum of occurences)}
\item{m}{Sum of maximum occurences in each row of the ocurrence matrix}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
## Tossing two coins five times.
D<-data.frame(Head=c(2,1,1,0,2),Tail=c(0,1,1,2,0))
coocur(D)
}
