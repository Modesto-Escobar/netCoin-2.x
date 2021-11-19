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
gallery(nodes, name = NULL, label = NULL, color = NULL, border = NULL,
    ntext = NULL, info = NULL, image = NULL, zoom = 1,
    itemsPerRow = NULL, main = NULL, note = NULL,
    showLegend = TRUE, frequencies = FALSE,
    help = NULL, helpOn = FALSE, description = NULL,
    descriptionWidth = NULL, roundedItems = FALSE, controls = 1:2,
    cex = 1, language = c("en", "es", "ca"), dir = NULL)
}
\arguments{
\item{nodes}{a data frame with at least three columns of names, start and end.}
\item{name}{column name with image names in the nodes data frame.}
\item{label}{column name with image labels in the nodes data frame.}
\item{color}{column name with image background color variable in the nodes data frame.}
\item{border}{column name with image border width variable in the nodes data frame or a numeric vector.}
\item{ntext}{column name with html text in the nodes data frame.}
\item{info}{column name with information to display in a panel in the nodes data frame.}
\item{image}{column name which indicates the image paths in the nodes data frame.}
\item{zoom}{a number between 0.1 and 10 as initial displaying zoom.}
\item{itemsPerRow}{number of items in each row.}
\item{main}{upper title of the graph.}
\item{note}{lower title of the graph.}
\item{frequencies}{a logical value true if barplots representing node attributes frequencies will be added to the final graph.}
\item{showLegend}{a logical value true if the legend is to be shown.}
\item{help}{a character string indicating a help text of the graph.}
\item{helpOn}{Should the help be shown at the beginning?}
\item{description}{a character string indicating a desription text for the graph.}
\item{descriptionWidth}{a percentage indicating a width for the description panel (25 by default).}
\item{roundedItems}{Display items with rounded borders.}
\item{controls}{a numeric vector indicating which controls will be shown. 1 = topbar, 2 = export buttons. NULL hide all controls, negative values deny each control and 0 deny all.}
\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default.}
\item{language}{a character string indicating the language of the graph (en=english (default); es=spanish; ca=catalan).}
\item{dir}{a character string representing the directory where the web files will be saved.}
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
