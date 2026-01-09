\name{glmCoin}
\alias{glmCoin}
\title{Regression Graphs}
\description{
produces a netCoin object from a set of glm regressions.
}
\usage{
glmCoin(formulas, data, weights=NULL, pmax=.05, 
                    twotail=FALSE, showArrows=TRUE,
                    frequency = FALSE, percentage = TRUE, 
                    color="variable", lwidth="z.value", 
                    circle= NA, language=c("en","es","ca"),
                    igraph=FALSE, ...)
}
\arguments{
  \item{formulas}{
A set of formulas separated, folowed by the family and a return.
For example:
model <- "counts ~ outcome + treatment, poisson
          counts ~ outcome, poisson"
}
  \item{data}{Data frame containing the variables in the model.}
  \item{weights}{Optional vector of weights to be used in the fitting process.}
  \item{pmax}{Selection of links with Pr(>|z|) less than p (one-tail by default).}
  \item{twotail}{Logical value indicating if twotail test must be appied. Defaul=FALSE.}
  \item{showArrows}{a logical value true if the directional arrows are to be shown. Default = FALSE.}
  \item{frequency}{a logical value true if frequencies are to be shown. Default=FALSE.}
  \item{percentage}{a logical value true if percentages are to be shown. Default=TRUE.}
  \item{color}{Nodes' attribute to be used for expressing color ("variable" by default).}
  \item{lwidth}{Nodes' attribute to be used for widht of arrows ("z.value" by default).}
  \item{circle}{Degre of rotation in case of fixed circled dependent variables.}
  \item{language}{Language of the graph controls.}
  \item{igraph}{Produces an igraph object instead of a netCoin object if TRUE.}
  \item{...}{Any \link{netCoin} argument.}
}
\value{
This function creates a netCoin object (or igraph) and, if stated, a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}

\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}

\examples{
## Dobson (1990) Page 93: Randomized Controlled Trial :
counts <- c(18,17,15,20,10,20,25,13,12)
outcome <- gl(3,1,9)
treatment <- gl(3,3)
Dobson <- data.frame(counts=counts, outcome=outcome, treatment=treatment)
model <- "counts ~ outcome + treatment, poisson"
glmCoin(model,Dobson)
}
