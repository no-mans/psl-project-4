# system2


library(dplyr)
library(Matrix)
library(recommenderlab)
library(DT)
library(data.table)
library(reshape2)

library(proxy)
library(doBy) # to get top-n elements
library(knitr)



# read ratings data
myurl = "https://liangfgithub.github.io/MovieData/"
# ratings_data_location = paste0(myurl, 'ratings.dat?raw=true')C
ratings_data_location ='./ratings.dat'
ratings = read.csv(ratings_data_location,
                   sep = ':',
                   colClasses = c('integer', 'NULL'),
                   header = FALSE)
colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
ratings = subset(ratings, select = -c(Timestamp) )

# # read users data
# # users_data_location = paste0(myurl, 'users.dat?raw=true')
# users_data_location = './ratings.dat'
# users = read.csv(users_data_location,
#                  sep = ':', header = FALSE)
# users = users[, -c(2,4,6,8)] # skip columns
# colnames(users) = c('UserID', 'Gender', 'Age', 'Occupation', 'Zip-code')


# load the trained model
UBCF_model <- readRDS("UBCF_recommender.rds")
# IBCF_model <- readRDS("IBCF_recommender.rds")
num_movies_rated = length(UBCF_model@model$data@data@p) - 1

NEW_USER_ID=6041 # we have 6040 users in the db

get_colab_recommendation = function(movies, user_ratings){
  items_to_recommend = 10
  
  
  # ratings_vec = rep(NA, num_movies_rated)
  
  
  
  print("input")
  print(user_ratings)
  user_ratings$UserID=rep(NEW_USER_ID, nrow(user_ratings))

  
  newratings = rbind(ratings, user_ratings)
  print(tail(newratings))
  
  ratingmat <- dcast(newratings, UserID~MovieID, value.var = "Rating", na.rm=FALSE)
  # ratingmat <- dcast(ratings, UserID~MovieID, value.var = "Rating", na.rm=FALSE)
  
  ratingmat <- as.matrix(ratingmat[,-1]) #remove userIds
  # Convert rating matrix into a recommenderlab sparse matrix
  ratingmat <- as(ratingmat, "realRatingMatrix")
  
  
  
  
  
  # as.integer(rownames(movies %>% subset(MovieID = user_ratings$MovieID) ))
  # ratings_vec[user_ratings$MovieID] = user_ratings$Rating
  # print(user_ratings[1:30])
  # print(length(user_ratings))
  # my_user_ratings = ratingmat[UserID]
  
  # my_user_ratings = as(my_user_ratings, "matrix")
  # my_user_ratings = as.vector(my_user_ratings[1,])
  # my_user_ratings = matrix(ratings_vec, nrow=1)
  # print("my_user_ratings")
  # print(dim(my_user_ratings))
  # my_user_ratings = as(my_user_ratings, "realRatingMatrix")
  
  my_user_ratings = ratingmat[NEW_USER_ID]
  
  recom = predict(object = UBCF_model,
                                 newdata = my_user_ratings,
                                 n = items_to_recommend,
                                 type = "topNList")
  recom_list <- as(recom, "list")
  print("recom_list")
  print(as.integer(recom_list[[1]])) # [1:10]
  
  dt_recoms = movies[as.integer(recom_list[[1]]),]
  print("Movies")
  print(dt_recoms)
  

  
  
  dt_recoms$Rank = 1:items_to_recommend
  dt_recoms$Predicted_rating = 1:items_to_recommend
  
  print("Returning recoms:")
  print(dt_recoms)
  
  dt_recoms
  
  # user_results = (1:10)/10
  # user_predicted_ids = 1:10
  # data.table(Rank = 1:10,
  #            MovieID = movies$MovieID[user_predicted_ids],
  #            Title = movies$Title[user_predicted_ids],
  #            Predicted_rating =  user_results)
}