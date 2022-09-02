\name{caring}
\alias{caring}
\title{Produce interactive multi graphs.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\value{
This function returns a \code{mGraph} object.
The function creates a folder in your computer with an HTML document named index.html which contains the graph. This file can be directly opened with your browser.
}

\usage{
caring(filepath,arguments)
}
\arguments{
\item{filepath}{The path to the data file.}
\item{arguments}{a list with the caring exported arguments.}
}
\description{
\code{caring} produce an interactive multi graph from caring arguments.
}
\examples{
\dontrun{
filename <- "demo.sav"
arguments <- list(
  variables = c("Gender", "Income category in thousands",
    "Primary vehicle price category"),
  plot = "network"
)
graph <- caring(filename,arguments)
plot(graph)
}
}
