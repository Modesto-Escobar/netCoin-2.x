\name{surScat}
\alias{surScat}
\title{Networked coincidences from a data frame.}
\description{
\code{surScat} produces a network object of coincidences from a data frame converting variables into dichotomies. 
}
\value{
This function creates a netCoin object (or igraph) and, if stated, a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}

\usage{
surScat(data, variables=names(data), active=variables, type=c("mca", "pca"), nclusters=2,
        maxN=2000, ...)
}
\arguments{
  \item{data}{a data frame.}
  \item{variables}{a vector of variables included in the previous data frame.}
  \item{active}{a vector of variables actived in the previous data frame.}
  \item{type}{Factorial type: mca for qualitative active variables, pca for quantitative active variables.}
  \item{nclusters}{number of clusters.}
  \item{maxN}{Maximum number or rows.}
  \item{...}{Any \link{netCoin} argument.}
}
\details{
Possible measures in procedures are 
\itemize{
\item{Frequencies (f), Relative frequencies (x), Conditional frequencies (i), Coincidence degree (cc), Probable degree (cp),}
\item{Expected (e), Confidence interval (con)}
\item{Matching (m), Rogers & Tanimoto (t), Gower (g), Sneath (s), Anderberg (and),}
\item{Jaccard (j), Dice (d), antiDice (a), Ochiai (o), Kulczynski (k),}
\item{Hamann (ham), Yule (y), Pearson (p), odds ratio (od), Rusell (r),}
\item{Haberman (h), Z value of Haberman (z),}
\item{Hypergeometric p greater value (hyp).}
\item{Convert a matrix into an edge list (shape).}
}
}
\references{
  Escobar, M. and Martinez-Uribe, L. (2020)
  Network Coincidence Analysis: The \code{netCoin} \code{R} Package.
  \emph{Journal of Statistical Software}, \bold{93}, 1-32.
  \doi{10.18637/jss.v093.i11}.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
# A data frame with two variables Gender and Opinion
frame<-data.frame(Gender=c(rep("Man",3),rep("Woman",3)),
                  Opinion=c("Yes","Yes","No","No","No","Yes"))
surScat(frame) # network object
}

