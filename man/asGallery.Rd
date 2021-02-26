\name{asGallery}
\alias{asGallery}
\title{Images in a grid gallery.}
\description{
\code{asGallery} produces a gallery_rd3 object. 
}
\value{
Object of class \code{gallery_rd3}.
}

\usage{
asGallery(net)
}
\arguments{
  \item{net}{is a \code{network_rd3} object. See \code{\link{network_rd3}}}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
data("Galapagos")
data("finches")
finches$species <- system.file("extdata", finches$species,
        package="netCoin") # copy path to the species field
Net <- allNet(Galapagos, nodes=finches, criteria="hyp", maxL=.05,
        image="species",
        main="Species coincidences in Galapagos Islands",
        note="Data source: Sanderson (2000)")
gallery <- asGallery(Net)
}
