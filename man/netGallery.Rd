\name{netGallery}
\alias{netGallery}
\title{Images in a grid gallery.}
\description{
\code{netGallery} produces an interactive image gallery. 
}
\value{
Object of class \code{netGallery}.
}

\usage{
netGallery(tree, deep = FALSE, ...)
}
\arguments{
\item{tree}{a data frame with two columns: source and target, describing relationships between nodes. It indicates a hierarchy between nodes which can be dynamically explored. Optionally, another two columns describing types can be passed.}
\item{deep}{The tree is especified in a structure that preserves paths. Each column will be a tree level, colnames as node types.}
  \item{...}{Any \link{gallery} argument.}
}
\author{
Modesto Escobar, Department of Sociology and Communication, University of Salamanca.
}
\examples{
# Create some film data
tree <- data.frame(
  parents=c("The Shawshank Redemption", "The Shawshank Redemption", "The Godfather",
    "The Godfather", "The Dark Knight", "The Dark Knight", "The Godfather Part II",
    "The Godfather Part II", "The Shawshank Redemption", "The Godfather", "The Dark Knight",
    "The Godfather Part II", "12 Angry Men", "Schindler's List",
    "The Lord of the Rings: The Return of the King", "Pulp Fiction",
    "The Lord of the Rings: The Fellowship of the Ring", "The Good, the Bad and the Ugly"),
  children=c("Tim Robbins", "Morgan Freeman", "Marlon Brando", "Al Pacino", "Christian Bale",
    "Heath Ledger", "Al Pacino", "Robert De Niro", "Frank Darabont", "Francis Ford Coppola",
    "Christopher Nolan", "Francis Ford Coppola", "Sidney Lumet", "Steven Spielberg",
    "Peter Jackson", "Quentin Tarantino", "Peter Jackson", "Sergio Leone"),
  type1="film",
  type2=c("actor", "actor", "actor", "actor", "actor", "actor", "actor", "actor", "director",
    "director", "director", "director", "director", "director", "director", "director",
    "director", "director"))

gallery <- netGallery(tree, color="type", zoom=2)

\dontrun{
plot(gallery)
}

# example with path preservation
tree <- rbind(
c("a1","b1","c1|c2"),
c("a2","b2","c3|c4"),
c("a3","b2","c4|c5"),
c("a4","b3|b4","c6|c7|c8")
)

colnames(tree) <- c("a","b","c")

gallery<-netGallery(tree,deep=TRUE,color="type")
\dontrun{
plot(gallery)
}
}
