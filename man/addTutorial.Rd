\name{addTutorial}
\alias{addTutorial}
\title{Adds a tutorial for the gallery.}
\description{
\code{addTutorial} adds a tutorial for a gallery. 
}
\value{
Object of class \code{gallery_rd3}.
}

\usage{
addTutorial(x, image = NULL, description = NULL)
}
\arguments{
\item{x}{object of class \code{gallery_rd3}.}
\item{image}{character vector indicating the image path, header for the tutorial.}
\item{description}{a character string indicating a desription text to insert in the tutorial.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
data("finches")
finches$species <- system.file("extdata", finches$species,
        package="netCoin") # copy path to the species field
g <- gallery(finches, image="species", main="Species in Galapagos Islands",
        note="Data source: Sanderson (2000)")

g <- addTutorial(g, 
  description="Here you can see different finches species in Galapagos islands.")

\dontrun{
plot(g)
}
}
