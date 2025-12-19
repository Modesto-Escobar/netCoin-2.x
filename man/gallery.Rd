\name{gallery}
\alias{gallery}
\title{Images in a grid gallery.}
\description{
\code{gallery} produces an interactive image gallery. 
}
\value{
Object of class \code{gallery_rd3}.
}

\usage{
gallery(nodes, name = NULL, label = NULL, color = NULL,
    border = NULL, ntext = NULL, info = NULL, infoFrame = c("right","left"),
    image = NULL, imageCopy = NULL, noFilterCols = NULL,
    zoom = 1, itemsPerRow = NULL, main = NULL, note = NULL,
    showLegend = TRUE, frequencies = FALSE, labelTooltip = TRUE,
    cexTooltip = 1, help = NULL, helpOn = FALSE, tutorial = FALSE,
    description = NULL, descriptionWidth = NULL, roundedItems = FALSE,
    ntextctrl = FALSE, controls = 1:5, cex = 1, defaultColor = "#1f77b4",
    language = c("en", "es", "ca"), dir = NULL)
}
\arguments{
\item{nodes}{a data frame with at least one column with the names of the gallery's elements.}
\item{name}{name of the vector with names in the nodes data frame.}
\item{label}{column name with image labels in the nodes data frame.}
\item{color}{column name with image background color variable in the nodes data frame.}
\item{border}{column name with image border width variable in the nodes data frame or a numeric vector.}
\item{ntext}{column name with html text in the nodes data frame.}
\item{info}{column name with information to display in a panel in the nodes data frame.}
\item{infoFrame}{In which panel should the information be displayed? The left panel is only available if frequencies are not showing.}
\item{image}{column name which indicates the image paths in the nodes data frame.}
\item{imageCopy}{column name which indicates the image copyright and attribution in the nodes data frame.}
\item{noFilterCols}{disable filtering by especified column names.}
\item{zoom}{a number between 0.1 and 10 as initial displaying zoom.}
\item{itemsPerRow}{number of items in each row.}
\item{main}{upper title of the graph.}
\item{note}{lower title of the graph.}
\item{frequencies}{a logical value true if barplots representing node attributes frequencies will be added to the final graph.}
\item{labelTooltip}{show label on mouseover.}
\item{cexTooltip}{number indicating the amount by which plotting text should be scaled relative to the default in the label tooltip.}
\item{showLegend}{a logical value true if the legend is to be shown.}
\item{help}{a character string indicating a help text of the graph.}
\item{helpOn}{Should the help be shown at the beginning?}
\item{tutorial}{Should tutorial be displayed?}
\item{description}{a character string indicating a desription text for the graph.}
\item{descriptionWidth}{a percentage indicating a width for the description panel (25 by default).}
\item{roundedItems}{Display items with rounded borders.}
\item{ntextctrl}{Previous tooltips will be closed unless you hold down the control key (FALSE by default).}
\item{controls}{a numeric vector indicating which controls will be shown. 1 = topbar, 2 = xlsx exportation, 3 = table, 4 = netCoin logo, 5 = topbar buttons. NULL hide all controls, negative values deny each control and 0 deny all.}
\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default.}
\item{defaultColor}{a character vector giving a valid html color for node representation.}
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
