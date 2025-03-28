\name{pop_up}
\alias{pop_up}
\title{Create a drop-down vignette for nodes from different items (for galleries).}
\usage{
pop_up(data, title="name", title2=NULL, info=TRUE, entity="entity",
    links=c("wikidata", "wiki"), wikilangs="en")
}
\arguments{
\item{data}{Data frame which contains the data.}
\item{title}{Column name which contains the first title of the vignette.}
\item{title2}{Column name which contains the secondary title of the vignette.}
\item{info}{Extract the first paragraph of a Wikipedia article.}
\item{entity}{Column name which contains a vector of Wikidata entities.}
\item{links}{Column names which contains the URLs for the vignette.
'wikidata' and 'wiki' by default, if this columns are missing,
they will be generated through 'entity' argument.}
\item{wikilangs}{List of languages to limit the search, using "|" as
separator. Wikipedias page titles are returned in same order as languages in
this parameter. If wikilangs='' the function returns Wikipedia page titles
in any language, not sorted.}
}
\value{
a character vector of html formatted vignettes attached to 'data' in a column named 'pop_up'.
}
\description{
Create a drop-down vignette for nodes from different items (for galleries).
}
\examples{
\dontrun{
data("sociologists")
sociologists$entity <- sub(".png","",sociologists$picture)
sociologists <- pop_up(sociologists, title="name",
  title2="birth_country", entity="entity")
plot(exhibit(sociologists, label="name", ntext="pop_up"))
}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}

