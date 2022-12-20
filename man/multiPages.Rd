\name{multiPages}
\alias{multiPages}
\title{Produces a gallery of 'netCoin' graphs.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. 
}
\value{
The function creates a folder in your computer with an HTML document named index.html which contains the graph. This file can be directly opened with your browser.
}

\usage{
multiPages(x, title = NULL, columns = NULL, cex = 1, dir = tempDir(), show = FALSE)
}
\arguments{
\item{x}{is a \code{mGraph} object. See \code{\link{multigraphCreate}}}
\item{title}{the text for a main title.}
\item{columns}{a numeric vector giving the number of columns to display items in gallery. Default = 3.}
\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default. Default = 1.}
\item{dir}{a "character" string representing the directory where the graph will be saved.}
\item{show}{a logical value true if the graph is to be shown. Default = FALSE.}
}
\description{
\code{multiPages} produces a gallery page to explore multiple 'netCoin' graphs.
}
\examples{
# A character column (with separator)
frame <- data.frame(A = c("Man; Women", "Women; Women",
                        "Man; Man", "Undet.; Women; Man"))
data <- dichotomize(frame, "A", sep = "; ")[2:4]
C <- coin(data) # coincidence matrix
N <- asNodes(C) # node data frame
E <- edgeList(C,c("frequency","expected","haberman")) # edge data frame
bC<- barCoin(data,dichotomies="_all") # barCoin object
cC<- barCoin(data,dichotomies="_all",expected=TRUE) # barCoin object
nC<- netCoin(N,E) # netCoin object
multi <- multigraphCreate("Bar graph" = bC,
                  "Conditional bar graph" = cC, 
                  "Net graph"=nC)
\dontrun{
multiPages(multi,"Some graphs",show=TRUE)
}
}
