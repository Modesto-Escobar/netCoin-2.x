\name{multigraphCreate}
\alias{multigraphCreate}
\title{Produce interactive multi graphs.}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\value{
The function creates a folder in your computer with an HTML document named index.html which contains the graph. This file can be directly opened with your browser.
}

\usage{
multigraphCreate(..., mode = c("default","parallel","frame"),
  frame = 0, speed = 50, lineplots = NULL,
  dir = "MultiGraph", show = TRUE)
}
\arguments{
\item{...}{rD3plot graphs (network_rd3, barplot_rd3, timeplot_rd3) objects or html "directories".}
\item{mode}{a string specifying the displaying mode. The "default" displays graphs one by one, "parallel" splits screen and "frame" allows dinamic graphs in time.}
\item{frame}{number of frame to start a dynamic network.}
\item{speed}{a percentage for frame speed in dynamic networks.}
\item{lineplots}{a character vector giving the node attributes to show as lineplots.}
\item{dir}{a "character" string representing the directory where the graph will be saved.}
\item{show}{a logical value true if the graph is to be shown. Default = TRUE.}
}
\description{
\code{multigraphCreate} produce an interactive multi graph.
}
\examples{
\dontrun{
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
multigraphCreate("Bar graph" = bC,
                  "Conditional bar graph" = cC, 
                  "Net graph"=nC, 
                  dir="./example") # See ./example/index.html file
}
}
