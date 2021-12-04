source("functions/system2.R")

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


generate_user_ratings = function() {
  movies = c(1, 7, 11)
  ratings = c(3, 1, 5)
  dat = data.table(MovieID = movies,
                   Rating = ratings)
  dat
}

user_ratings = generate_user_ratings()

print("Calling with user_ratings:")
print(user_ratings)

get_recommendation_by_genre(movies, user_ratings)
