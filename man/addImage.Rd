\name{addImage}
\alias{addImage}
\title{Adds an image to a 'netCoin' object.}
\description{
\code{addImage} adds an image to a 'netCoin' object.
}
\value{
A 'netCoin' object.
}

\usage{
addImage(x, img)
}
\arguments{
\item{x}{A 'netCoin' object.}
\item{img}{character vector indicating the image path.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
data(finches)
data(Galapagos)

Net<-allNet(Galapagos,nodes=finches, criteria="hyp", maxL=.05,
        lwidth ="Haberman",lweight="Haberman",
        size="frequency", color="species", layout="mds",
        main="Species coincidences in Galapagos Islands",
        note="Data source: Sanderson (2000)")

img <- system.file("extdata", "p.Crassirostris.png",
        package="netCoin")
Net <- addImage(Net,img)

\dontrun{
multi <- multigraphCreate(Network=Net)
multiPages(multi,"Graph image example",show=TRUE)
}
}
