\name{gallery}
\alias{gallery}
\title{Images in a grid gallery.}
\description{
\code{gallery} produces a gallery_rd3 object. 
}
\value{
Object of class \code{gallery_rd3}.
}

\usage{
gallery(nodes, name = NULL, label = NULL, color = NULL,
    ntext = NULL, info = NULL, image = NULL,
    zoom = 1, main = NULL, note = NULL, help = NULL,
    language = c("en", "es", "ca"), dir = NULL)
}
\arguments{
\item{nodes}{a data frame with at least three vectors of names, start and end.}
\item{name}{name of the vector with names in the nodes data frame.}
\item{label}{name of the vector with labels in the nodes data frame.}
\item{color}{name of the vector with color variable in the nodes data frame.}
\item{zoom}{a number between 0.1 and 10 to start displaying zoom.}
\item{main}{upper title of the graph.}
\item{note}{lower title of the graph.}
\item{ntext}{name of the vector with html text in the nodes data frame.}
\item{info}{name of the vector with information to display in a panel in the nodes data frame.}
\item{language}{a character vector (es=spanish; en=english; ca=catalan).}
\item{help}{help text of the graph.}
\item{image}{name of the vector with image files in the nodes data frame.}
\item{dir}{a "character" string representing the directory where the web files will be saved.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
data("finches")
finches$species <- system.file("extdata", finches$species,
        package="netCoin") # copy path to the species field
gallery(finches, image="species", main="Species in Galapagos Islands",
        note="Data source: Sanderson (2000)")
}
