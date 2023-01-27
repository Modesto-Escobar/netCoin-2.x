\name{addDescription}
\alias{addDescription}
\title{Adds a description to a 'netCoin' object.}
\description{
\code{addDescription} adds a description to a 'netCoin' object.
}
\value{
A 'netCoin' object.
}

\usage{
addDescription(x, description)
}
\arguments{
\item{x}{A 'netCoin' object.}
\item{description}{the description text.}
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
Net <- addDescription(Net,"Species coincidences in Galapagos Islands")

\dontrun{
multi <- multigraphCreate(Network=Net)
multiPages(multi,"Graph description example",show=TRUE)
}
}
