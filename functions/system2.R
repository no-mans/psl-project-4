# system2

get_colab_recommendation = function(movies, user_ratings){
  user_results = (1:10)/10
  user_predicted_ids = 1:10
  data.table(Rank = 1:10,
             MovieID = movies$MovieID[user_predicted_ids],
             Title = movies$Title[user_predicted_ids],
             Predicted_rating =  user_results)
}