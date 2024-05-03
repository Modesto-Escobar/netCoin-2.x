\name{makeT}
\alias{makeT}
\title{Create a vignette (for galleries).}
\usage{
makeT(data, imageDir=NULL, imageDefault=NULL, language=c("en","es","ca"))
}
\arguments{
\item{data}{A data-frame created with \code{w_EntityInfo} from wikiTools package.}
\item{imageDir}{A directory where images will be found. The name must be the 'entity' column content follow by the image extension and the allowed formats are jpg, jpeg, gif, png and svg.}
\item{imageDefault}{This image will be assigned if 'entity' image is not found in \code{imageDir} or no \code{imageDir} is specified.}
\item{language}{a character string indicating the language of the graph (en=english (default); es=spanish; ca=catalan).}
}
\value{
a data frame wich includes a column of html formatted vignettes called 'info'.
}
\description{
Create a vignette from w_EntityInfo from wikiTools package (for galleries).
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}

