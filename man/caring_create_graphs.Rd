\name{caring_create_graphs}
\alias{caring_create_graphs}
\title{Produce interactive multi graphs.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\value{
This function returns a \code{mGraph} object.
The function creates a folder in your computer with an HTML document named index.html which contains the graph. This file can be directly opened with your browser.
}

\usage{
caring_create_graphs(data,arguments)
}
\arguments{
\item{data}{A data frame.}
\item{arguments}{a list with the caring exported arguments.}
}
\description{
\code{caring_create_graphs} produce an interactive multi graph from caring arguments.
}
\examples{
data <- data.frame(Gender=c(rep("Man",3),rep("Woman",3)),
                    Opinion=c("Yes","Yes","No","No","No","Yes"))
arguments <- list(
  variables = c("Gender", "Opinion"),
  dichotomies = "Opinion",
  valueDicho = "Yes",
  plot = c("surCoin","network")
)
graph <- caring_create_graphs(data,arguments)
\dontrun{
plot(graph)
}
}
