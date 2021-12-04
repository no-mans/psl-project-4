source("functions/system1.R")

load_movies = function(){
  myurl = "https://liangfgithub.github.io/MovieData/"
  movies = readLines(paste0(myurl, 'movies.dat?raw=true'))
  movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
  movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
  movies = data.frame(movies, stringsAsFactors = FALSE)
  colnames(movies) = c('MovieID', 'Title', 'Genres')
  movies$MovieID = as.integer(movies$MovieID)
  movies$Title = iconv(movies$Title, "latin1", "UTF-8")
  movies
}
movies = load_movies()
movie_genres = readLines('data/genres.dat')

genre = movie_genres[3]

print(paste("Calling with genre:",genre))

get_recommendation_by_genre(movies, genre)
