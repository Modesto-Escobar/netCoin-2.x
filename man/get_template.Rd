\name{get_template}
\alias{get_template}
\title{Create a drop-down vignette for nodes from different items (for galleries).}
\usage{
get_template(
  data,
  title = NULL,
  title2 = NULL,
  text = NULL,
  img = NULL,
  wiki = NULL,
  width = 300,
  color = "auto",
  cex = 1,
  roundedImg = FALSE,
  mode = 1
)
}
\arguments{
\item{data}{data frame which contains the data.}

\item{title}{column name which contains the first title of the vignette.}

\item{title2}{column name which contains the secondary title of the vignette.}

\item{text}{column name which contains the main text of the vignette.}

\item{img}{column name which contains the names of the image files.}

\item{wiki}{column name which contains the wiki URL for the vignette.}

\item{width}{length of the vignette's width.}

\item{color}{color of the vignette's strip (It also could be a column name which contains colors).}

\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default.}

\item{roundedImg}{Display images with rounded borders.}

\item{mode}{2 display images next to the text. 1 by default.}
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
sociologists$picture <- system.file("extdata", sociologists$picture,
        package="netCoin")
sociologists$html <- get_template(sociologists, title="name",
  title2="birth_country", text="school",img="picture", mode=2)
plot(gallery(sociologists, ntext="html"))
}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}

