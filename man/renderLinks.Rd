\name{renderLinks}
\alias{renderLinks}
\title{Create an html list of links.}
\usage{
renderLinks(data,columns)
}
\arguments{
\item{data}{data frame which contains the data.}
\item{columns}{column name which contains the urls.}
}
\value{
a character vector of html formatted links.
}
\description{
Create an html list of links.
}
\examples{
links <- data.frame(name = c(
    "Camarhynchus psitticula",
    "Camarhynchus pauper",
    "Camarhynchus parvulus"
  ), wikipedia=c(
    "https://en.wikipedia.org/wiki/Large_tree_finch",
    "https://en.wikipedia.org/wiki/Medium_tree_finch",
    "https://en.wikipedia.org/wiki/Small_tree_finch"
  ),wikidata=c(
    "https://www.wikidata.org/wiki/Q578835",
    "https://www.wikidata.org/wiki/Q1125857",
    "https://www.wikidata.org/wiki/Q1086136"
  ))
html <- renderLinks(links,c("wikipedia","wikidata"))
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}

