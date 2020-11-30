\name{families}
\alias{families}
\docType{data}
\title{
Data: Italian families in the Renaissance.
}
\description{
Data frame with the characteristics of powerful families of Renaissance Italy.
}
\usage{data("families")}
\format{
  A data frame with 16 families (rows) and 6 characteristics.
  \describe{
    \item{\code{name}}{Family's name}
    \item{\code{f.Marriages}}{number of marriage links}
    \item{\code{f.Business}}{number of business links}
    \item{\code{wealth}}{wealth's index}
    \item{\code{priorates}}{number of priorates on control}
    \item{\code{seat}}{At least priorate}
  }
}
\source{
PADGETT, J. F. Y C. K. ANSELL (1993): "Robust Action and the Rise of the Medici, 1400-1434", in American Journal of Sociology, 98, 1259-1319. (http://www.jstor.org/stable/2781822)
}

\examples{
data("families")
head(families)
}
\keyword{datasets}
