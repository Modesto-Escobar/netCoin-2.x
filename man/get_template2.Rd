\name{get_template2}
\alias{get_template2}
\title{Create a drop-down vignette for nodes from different items (for galleries).}
\usage{
get_template2(data, title=NULL, title2=NULL, text=NULL, wiki=NULL)
}
\arguments{
\item{data}{data frame which contains the data.}
\item{title}{column name which contains the first title of the vignette.}
\item{title2}{column name which contains the secondary title of the vignette.}
\item{text}{column name which contains the main text of the vignette.}
\item{wiki}{column name which contains the wiki URL for the vignette.}
}
\value{
a character vector of html formatted vignettes.
}
\description{
Create a drop-down vignette for nodes from different items (for galleries).
}
\examples{
\dontrun{
data("sociologists")
sociologists$html <- get_template2(sociologists, title="name",
  title2="birth_country", text="school")
plot(gallery2(sociologists, ntext="html"))
}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}

