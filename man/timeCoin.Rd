\name{timeCoin}
\alias{timeCoin}
\title{Networked coincidences.}
\description{
\code{timeCoin} produces a timeCoin object. 
}
\value{
Object of class \code{timeCoin}.
}

\usage{
timeCoin(periods, name = "name", start = "start", end = "end", group = NULL,
         text = NULL, main = NULL, note = NULL, info = NULL, 
         events = NULL, eventNames = "name", eventPeriod = "period",
         eventTime = "date", eventColor = NULL, eventShape = NULL,
         cex = 1, language = c("en","es","ca"), dir = NULL)
}
\arguments{
\item{periods}{a data frame with at least three vectors of name, start and end of the periods.}
\item{name}{name of the vector with names in the periods data frame.}
\item{start}{name of the vector with starts in the periods data frame.}
\item{end}{name of the vector with ends in the periods data frame.}
\item{group}{name of the vector with groups in the periods data frame.}
\item{text}{name of the vector with html text in the periods data frame.}
\item{main}{upper title of the graph.}
\item{note}{lower title of the graph.}
\item{info}{name of the vector with information to display in a panel in the periods data frame.}
\item{events}{a data frame of events included into the periods with three columns: event name, periodParent and eventTime}
\item{eventNames}{name of the vector with names in the events data frame.}
\item{eventPeriod}{name of the vector with period names in the events data frame.}
\item{eventTime}{name of the vector with time points in the events data frame.}
\item{eventColor}{name of the vector with color criteria in the events data frame.}
\item{eventShape}{name of the vector with shape criteria in the events data frame.}
\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default. Default = 1.}
\item{language}{a character vector (es=spanish; en=english; ca=catalan).}
\item{dir}{a "character" string representing the directory where the web files will be saved.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}

\examples{
# Database of the classical sociologists.
# Only periods
data(sociologists)
timeCoin(sociologists, "name", "birth", "death", "school")

# Periods and events
data(works)
timeCoin(sociologists, "name", "birth", "death", "school",
         events=works, eventNames="label", eventPeriod="author", eventTime="date")
}
