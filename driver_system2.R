source("functions/system2.R")

load_movies = function(){
  myurl = "https://liangfgithub.github.io/MovieData/"
  # movies_data_location = paste0(myurl, 'movies.dat?raw=true')
  movies_data_location = 'data/movies.dat'
  movies = readLines(movies_data_location)
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
  # user_movies = c(1, 3, 4, 7, NA)
  # user_ratings = c(3, 4, 1, 5, 1)
  

  user_movies = c(1, 4, 5, 16, NA) # for some reason the UI adds a row with NA movie id.
  user_ratings = c(3, 6, 1, 4, 1)

    dat = data.table(
          MovieID = user_movies,
          Rating = user_ratings)
  dat = na.omit(dat)
  dat
}

user_ratings = generate_user_ratings()

colab_recoms = get_colab_recommendation(movies, user_ratings)
print("Final")
print(colab_recoms)
