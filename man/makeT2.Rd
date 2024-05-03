\name{makeT2}
\alias{makeT2}
\title{Create a vignette (for galleries).}
\usage{
makeT2(entityLabel, image=NA, entityDescription=NA,
    byear=NA, bplace=NA, bcountry=NA, dyear=NA, dplace=NA, dcountry=NA,
    gender=NA, occupation=NA, language=c("en","es","ca"))
}
\arguments{
\item{entityLabel}{A character string of names.}
\item{image}{A character string of image paths.}
\item{entityDescription}{A character string of descriptions.}
\item{byear}{A character string of birth years.}
\item{bplace}{A character string of birth places.}
\item{bcountry}{A character string of birth countries.}
\item{dyear}{A character string of death years.}
\item{dplace}{A character string of death places.}
\item{dcountry}{A character string of death countries.}
\item{gender}{A character string of genders.}
\item{occupation}{A character string of occupations.}
\item{language}{a character string indicating the language of the graph (en=english (default); es=spanish; ca=catalan).}
}
\value{
a data frame wich includes a column of html formatted vignettes called 'info'.
}
\description{
Create a vignette from some specific information supplied (for galleries).
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca. See \url{https://sociocav.usal.es/blog/modesto-escobar/}
}

