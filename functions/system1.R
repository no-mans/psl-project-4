# system1

library(dplyr)
library(ggplot2)
library(recommenderlab)
library(DT)
library(data.table)
library(reshape2)
library(Matrix)
library(proxy)
library(doBy) # to get top-n elements

myurl = "https://liangfgithub.github.io/MovieData/"
# ratings_data_location = paste0(myurl, 'ratings.dat?raw=true')
ratings_data_location ='./ratings.dat'
ratings = read.csv(ratings_data_location, 
                   sep = ':',
                   colClasses = c('integer', 'NULL'), 
                   header = FALSE)
colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')


# movies_data_location = paste0(myurl, 'movies.dat?raw=true')
movies_data_location = './movies.dat'
movies = readLines(movies_data_location)
movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies = data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) = c('MovieID', 'Title', 'Genres')
movies$MovieID = as.integer(movies$MovieID)
movies$Title = iconv(movies$Title, "latin1", "UTF-8")

small_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(small_image_url, x, '.jpg?raw=true'))

# Subset Genres column
genres <- as.data.frame(movies$Genres, stringsAsFactors=FALSE)
# Split text on pipe to get all genres for each movie
tmp = as.data.frame(tstrsplit(genres[,1], '[|]',
                              type.convert=TRUE),
                    stringsAsFactors=FALSE)
colnames(tmp) <- c(1:dim(tmp)[2])



genre_list = c("Action", "Adventure", "Animation", 
               "Children's", "Comedy", "Crime",
               "Documentary", "Drama", "Fantasy",
               "Film-Noir", "Horror", "Musical", 
               "Mystery", "Romance", "Sci-Fi", 
               "Thriller", "War", "Western")

genre_matrix = matrix(0, nrow(movies), length(genre_list))
# Loop over all movies
for(i in 1:nrow(tmp)){
  genre_matrix[i,genre_list %in% tmp[i,]]=1
}
colnames(genre_matrix) = genre_list


ratings = ratings[, -c(4)]
ratings_long <- dcast(ratings, MovieID~UserID, value.var = "Rating", na.rm=FALSE)
# for (i in 1:ncol(ratings_long)){
#   ratings_long[which(is.na(ratings_long[,i]) == TRUE),i] <- 0
# }
ratings_long <- ratings_long[,-1] #remove movieIds col. Rows are movieIds, cols are userIds
# Remove movies with no reviews
ratings_long <- ratings_long[rowSums(is.na(ratings_long)) != ncol(ratings_long), ]


get_recommendation_by_genre = function(genre){
  
  # List of movies of this genre
  movie_list <- which(genre_matrix[,c(genre)] == 1)
  movies_options <- ratings_long[movie_list, ]
  
  m = 50
  # Average movie review
  R <- rowMeans(movies_options, na.rm = TRUE)
  # Number of reviews received
  v <- rowSums(!is.na(movies_options))
  # Average rating for the movie in this genre
  C <- mean(R, na.rm = TRUE)
  # Compute Movie Weighted Rating
  movies_options['MWR'] = (v / (v + m)) * R + (m / (m +v)) * C
  movies_options['indx'] <- movie_list
  movies_options['ave_rating'] <- R
  movies_options['n_reviews'] <- v
  
  # Select the top-five "highly-rated" movies in the specified genre
  table <- movies_options[movies_options$n_reviews >=50, c('indx','n_reviews','MWR')]
  rows <- table[which.maxn(table$MWR, n=5) , 'indx']
  # Recommend movies
  selected_movies = movies[rows,]
  print(selected_movies)
  
  
  # user_results = (1:10)/10
  # user_predicted_ids = 1:10
  selected_movies$Rank = 1:5
  selected_movies
  # data.table(Rank = 1:5,
  #            MovieID = movies$MovieID[user_predicted_ids],
  #            Title = movies$Title[user_predicted_ids],
  #            Predicted_rating =  user_results)
}