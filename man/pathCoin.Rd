\name{pathCoin}
\alias{pathCoin}
\title{Structural Equation Models Graphs.}
\description{
\code{pathCoin} produces a netCoin object from a lavaan object, i.e., parameters of structural equation model. 
}
\value{
The function creates a netCoin object and eventually a folder in the computer with an HTML document named index.html which contains the produced graph. This file can be directly opened with your browser and sent to a web server to work properly.
}
\usage{
pathCoin(model, estimates=c("b","se","z","pvalue","beta"), 
         fitMeasures=c("chisq", "cfi", "rmsea"), ...)
}
\arguments{
\item{model}{a lavaan object.}
\item{estimates}{A vector with at least one element amongst "b", "se", "z", "pvalue", "beta".}
\item{fitMeasures}{Default values: "chisq", "df", "pvalue", "cfi", "rmsea"}

\item{...}{Any \link{netCoin} argument.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
# Classic Wheaton et al. model
library(lavaan)
lower <- '
11.834
6.947 9.364
6.819 5.091 12.532
4.783 5.028 7.495 9.986
-3.839 -3.889 -3.841 -3.625 9.610
-21.899 -18.831 -21.748 -18.775 35.522 450.288 '
wheaton.cov <- lav_getcov(lower, 
               names = c("anomia67", "powerless67","anomia71", "powerless71",
                         "education", "sei"))
wheaton.model <- '
# latent variables
ses =~ education + sei
alien67 =~ anomia67 + powerless67
alien71 =~ anomia71 + powerless71
# regressions
alien71 ~ alien67 + ses
alien67 ~ ses
# correlated residuals
anomia67 ~~ anomia71
powerless67 ~~ powerless71
'
fit <- sem(wheaton.model, sample.cov = wheaton.cov, sample.nobs = 932)

pathCoin(fit)
}

