\name{expectedList}
\alias{expectedList}
\title{Expected list.}
\description{Converts a \code{coin} object to a links data frame with coincidences and expected values.}
\usage{
expectedList(data, names = NULL, min = 1, confidence=FALSE)
}
\arguments{
  \item{data}{is a \code{coin} object. See \code{\link{coin}}}
  \item{names}{a character vector.}
  \item{min}{minimum value of the statistic to include the edge in the list.}
  \item{confidence}{add the confidence interval if TRUE.}
}
\value{A links data frame with coincidences and expected values.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
# A character column (with separator)
frame <- data.frame(A = c("Man; Women", "Women; Women",
                        "Man; Man", "Undet.; Women; Man"))
data <- dichotomize(frame, "A", sep = "; ")[2:4]
C <- coin(data) # coincidence matrix
expectedList(C) # edge data frame
}
