\name{get_panel_template}
\alias{get_panel_template}
\title{Create an html panel for nodes from different items (for galleries).}
\usage{
get_panel_template(data, title=NULL, description=NULL, img=NULL,
                   text=NULL, color="auto", cex=1, mode = 1)
}
\arguments{
\item{data}{data frame which contains the data.}
\item{title}{column name which contains the first title of the vignette.}
\item{description}{column name which contains the main text of the vignette.}
\item{img}{column name which contains the names of the image files.}
\item{text}{column name which contains the main text of the vignette.}
\item{color}{color of the panel (It also could be a column name which contains colors).}
\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default.}
\item{mode}{There are two display modes.}
}
\value{
a character vector of html formatted panel.
}
\description{
Create an html panel for nodes from different items (for galleries).
}
\examples{
\dontrun{
data("sociologists")
sociologists$picture <- system.file("extdata", sociologists$picture,
        package="netCoin")
sociologists$html <- get_panel_template(sociologists, title="name",
  description="birth_country",img="picture", text="school")
plot(gallery(sociologists, info="html"))
}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}

