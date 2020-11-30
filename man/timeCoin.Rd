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
timeCoin(nodes, name = "name", start = "start", end = "end", group = NULL,
         text = NULL, main = NULL, note = NULL, info = NULL, events = NULL,
         eventChild = "eventChild", eventParent = "eventParent", eventTime = "Time",
         eventColor = NULL, eventShape = NULL,
         cex = 1, language = c("en","es","ca"), dir = NULL)
}
\arguments{
\item{nodes}{a data frame with at least three vectors of names, start and end.}
\item{name}{name of the vector with names in the nodes data frame.}
\item{start}{name of the vector with starts in the nodes data frame.}
\item{end}{name of the vector with ends in the nodes data frame.}
\item{group}{name of the vector with groups in the nodes data frame.}
\item{text}{name of the vector with html text in the nodes data frame.}
\item{main}{upper title of the graph.}
\item{note}{lower title of the graph.}
\item{info}{name of the vector with information to display in a panel in the nodes data frame.}
\item{events}{a data frame of events realted to nodes with three columns: node name, event name and event date}
\item{eventChild}{name of the vector with sources in the events data frame.}
\item{eventParent}{name of the vector with targets in the events data frame.}
\item{eventTime}{name of the vector with time points in the events data frame.}
\item{eventColor}{name of the vector with color criteria in the events data frame.}
\item{eventShape}{name of the vector with shape criteria in the events data frame.}
\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default. Default = 1.}
\item{language}{a character vector (es=spanish; en=english; ca=catalan).}
\item{dir}{a "character" string representing the directory where the web files will be saved.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}

\examples{
# Database of 19th century sociologists
data(sociologists)
timeCoin(sociologists,"name","birth","death","birthcountry")
}
