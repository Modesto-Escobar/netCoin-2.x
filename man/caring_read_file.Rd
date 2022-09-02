\name{caring_read_file}
\alias{caring_read_file}
\title{Read sav, dta, xlsx, tsv and csv files.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\value{
This function returns a data frame.
}

\usage{
caring_read_file(filepath)
}
\arguments{
\item{filepath}{The path to the data file.}
}
\description{
\code{caring_read_file} reads sav, dta, xlsx, tsv and csv files and prepares data for caring.
}
\examples{
\dontrun{
filename <- "demo.sav"
data <- caring_read_file(filename)
}
}
