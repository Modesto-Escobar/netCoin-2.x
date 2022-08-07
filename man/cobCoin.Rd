\name{cobCoin}
\alias{cobCoin}
\title{CobWeb graph (Upton).}
\description{
\code{cobCoin} produces a netCoin object to graph a CoWeb graphic (Upton 2000). 
}
\value{
This function creates a netCoin object (or igraph) and, if stated, a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}
\usage{
cobCoin(data, variables=names(data), degree=0, significance=.05, ...)
}
\arguments{
  \item{data}{a data frame.}
  \item{variables}{a vector of variables included in the previous data frame.}
  \item{degree}{degree to rotate the categories of the graph}
  \item{significance}{p value maximum to represent the links}
  \item{...}{Any \link{surCoin} or \link{netCoin} argument.}
}
\references{
  Upton, Graham J.G. (2000)
  Cobweb diagrams for multiway contingency tables.
  \emph{The Statistician}, \bold{49}(1), 79-85.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# A data frame with two variables Gender and Opinion
frame <- data.frame(Gender=c(rep("Man",3),rep("Woman",3)),
                    Opinion=c("Yes","Yes","No","No","No","Yes"))
cobCoin(frame, significance=.5, degree=45) # netCoin object

# A data frame with two variables (Gender and Hand) and nodes
input <- data.frame(
  Gender = c("Women", "Men", "Men", "Women", "Women","Men",
             "Men", "Men", "Women", "Women", "Men", "Women"),
  Hand   = c("Right", "Left","Right", "Right", "Right", "Right",
             "Left", "Right", "Right", "Left","Right", "Right"))
nodes <- data.frame(
  name  = c("Gender:Men","Gender:Women", "Hand:Left", "Hand:Right"),
  label = c("Women(50\u25)","Men(50\u25)",
            "Left hand(25\u25)", "Right hand(75\u25)"))
G <- cobCoin(input, nodes=nodes, label="label", degree=22.5,
             showArrows=TRUE, significance=1)
}