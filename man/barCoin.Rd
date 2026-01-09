\name{barCoin}
\alias{barCoin}
\title{Networked coincidences.}
\description{
\code{barCoin} produces a barCoin object. 
}
\value{
Object of class \code{barCoin}.
}

\usage{
barCoin(data, variables = colnames(data), commonlabel = NULL,
        dichotomies = c("_all","_none"), valueDicho = 1, weight = NULL,
        subsample = FALSE, sort = NULL, decreasing = TRUE, nodes = NULL,
        name = NULL, select = NULL, scalebar = FALSE, note = NULL, 
        label = NULL, text = NULL, color = NULL, defaultColor = "#1f77b4", 
        expected = FALSE, confidence = FALSE, level = .95, significance = FALSE, 
        minimum = 1 , maximum = nrow(data), percentages = FALSE, 
        criteria = c("Z","hyp"), Bonferroni = FALSE, 
        support = 1, minL = -Inf, maxL = 1,
        language = c("en","es","ca"), cex = 1.0, dir = NULL)
}
\arguments{
\item{data}{a data frame}
\item{variables}{a vector of variables included in the previous data frame}
\item{commonlabel}{a vector of variables whose names are to be included in nodes labels}
\item{dichotomies}{a vector of dichotomous variables to appear as just one categorie}
\item{valueDicho}{value to be selected for dichotomous variables. Default is 1}
\item{weight}{a vector of weights. Optimal for data.framed tables.}
\item{subsample}{retrict the analysis to scenarios with at least one event.}
\item{sort}{name of the vector in the nodes data frame to order the graph.}
\item{decreasing}{decreasing or increasing sort of the graph order.}
\item{nodes}{a data frame with at least two vectors of names and incidences.}
\item{name}{name of the vector with names in the nodes data frame.}
\item{select}{Name of the event (in nodes name column) to start the visualization.}
\item{scalebar}{Should the bars fill the screen height? Default = FALSE.}
\item{note}{lower title of the graph.}
\item{label}{name of the vector with labels in the nodes data frame.}
\item{text}{name of the vector with html text in the nodes data frame.}
\item{color}{name of the vector with color variable in the nodes data frame.}
\item{defaultColor}{a character vector giving a valid html color.}
\item{expected}{name of the vector with expected coincidences in the links data frame.}
\item{confidence}{name of the vector with confidence interval in the links data frame.}
\item{level}{confidence level}
\item{significance}{name of the vector with significance in the links data frame.}
\item{minimum}{minimum frequency to be considered.}
\item{maximum}{maximum frequency to be considered.}
\item{percentages}{a logical value true if percentages are to be shown. Default = TRUE.}
\item{criteria}{statistic to be use for selection criteria.}
\item{Bonferroni}{Bonferroni criterium of the signification test.}
\item{support}{minimum value of the frequency of the coincidence to be edged.}
\item{minL}{minimum value of the statistic to include the edge in the list.}
\item{maxL}{maximum value of the statistic to include the edge in the list.}
\item{language}{a character vector (es=spanish; en=english; ca=catalan).}
\item{cex}{number indicating the amount by which plotting text should be scaled relative to the default. Default = 1.}
\item{dir}{a "character" string representing the directory where the web files will be saved.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
# A character column (with separator)
frame <- data.frame(A = c("Man; Women", "Women; Women",
                        "Man; Man", "Undet.; Women; Man"))
data <- dichotomize(frame, "A", sep = "; ")[2:4]

barCoin(data,dichotomies="_all")
barCoin(data,dichotomies="_all",confidence=TRUE,percentages=TRUE)
}
