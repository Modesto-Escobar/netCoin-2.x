\name{surCoin}
\alias{surCoin}
\title{Networked coincidences from a data frame.}
\description{
\code{surCoin} produces a network object of coincidences from a data frame converting variables into dichotomies. 
}
\value{
This function creates a netCoin object (or igraph) and, if stated, a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}

\usage{
surCoin(data,variables=names(data), commonlabel=NULL,
        dichotomies=NULL, valueDicho=1, metric=NULL, exogenous=NULL,
        weight=NULL, subsample=FALSE, pairwise=FALSE,
        minimum=1, maximum=nrow(data), sort=FALSE, decreasing=TRUE,
        frequency=FALSE, percentages=TRUE,
        procedures="Haberman", criteria="Z", Bonferroni=FALSE,
        support=-Inf, minL=-Inf, maxL=Inf,
        directed=FALSE, diagonal=FALSE, sortL=NULL, decreasingL=TRUE,
        igraph=FALSE, coin=FALSE, dir=NULL, ...)
}
\arguments{
  \item{data}{a data frame.}
  \item{variables}{a vector of variables included in the previous data frame.}
  \item{commonlabel}{a vector of variables whose names are to be included in nodes labels.}
  \item{dichotomies}{a vector of dichotomous variables to appear as just one category.}
  \item{valueDicho}{value or values to be selected for dichotomous variables. Default is 1.}
  \item{metric}{a vector of metrics.}
  \item{exogenous}{a vector of variables whose relations amongst them are of no interest. None by default.}
  \item{weight}{a vector of weights. Optimal for data.framed tables.}
  \item{subsample}{retrict the analysis to scenarios with at least one event.}
  \item{pairwise}{Pairwise mode of handling missing values if TRUE. Listwise by default.}
  \item{minimum}{minimum frequency to be considered.}
  \item{maximum}{maximum frequency to be considered.}
  \item{sort}{sort the coincidence matrix according to frequency of events.}
  \item{decreasing}{decreasing or increasing sort of the matrix.}
  \item{frequency}{a logical value true if frequencies are to be shown. Default=FALSE.}
  \item{percentages}{a logical value true if percentages are to be shown. Default=TRUE.}
  \item{procedures}{a vector of statistics of similarity. See below.}
  \item{criteria}{statistic to be use for selection criteria.}
  \item{Bonferroni}{Bonferroni criterium of the signification test.}
  \item{support}{minimum value of the frequency of the coincidence to be edged.}
  \item{minL}{minimum value of the statistic to include the edge in the list.}
  \item{maxL}{maximum value of the statistic to include the edge in the list. By default is +Inf, except if criteria="Z" or criteria="hyp", in which case it is .5. It is recommnended to change it to .05 if data has been sampled.}
  \item{directed}{includes same edges only once.}
  \item{diagonal}{includes auto-links.}
  \item{sortL}{sort the list according to the values of a statistic. See below.}
  \item{decreasingL}{order in a decreasing way.}
  \item{igraph}{Produces an igraph object instead of a netCoin object if TRUE.}
  \item{coin}{Only return the coincidences matrix if TRUE.}
  \item{dir}{a "character" string representing the directory where the web files will be saved.}
  \item{...}{Any \link{netCoin} argument.}
}
\details{
Possible measures in procedures are 
\itemize{
\item{Frequencies (f), Relative frequencies (x), Conditional frequencies (i), Coincidence degree (cc), Probable degree (cp),}
\item{Expected (e), Confidence interval (con)}
\item{Matching (m), Rogers & Tanimoto (t), Gower (g), Sneath (s), Anderberg (and),}
\item Jaccard (j), Dice (d), antiDice (a), Ochiai (o), Kulczynski (k),
\item Hamann (ham), Yule (y), Pearson (p), odds ratio (od), Rusell (r), 
\item Haberman (h), Z value of Haberman (z), 
\item Hypergeometric p greater value (hyp).
\item Convert a matrix into an edge list (shape).
}
}
\references{
  Escobar, M. and Martinez-Uribe, L. (2020)
  Network Coincidence Analysis: The \code{netCoin} \code{R} Package.
  \emph{Journal of Statistical Software}, \bold{93}, 1-32.
  \doi{10.18637/jss.v093.i11}.
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}
\examples{
# A data frame with two variables Gender and Opinion
frame <- data.frame(Gender=c(rep("Man",3),rep("Woman",3)),
                    Opinion=c("Yes","Yes","No","No","No","Yes"))
surCoin(frame,commonlabel="") # network object

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
G <- surCoin(input, nodes=nodes, proc=c("h","i"), label="label",
             ltext="i", showArrows=TRUE, maxL=.99)
}

