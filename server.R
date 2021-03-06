source("functions/system1.R")
source("functions/system2.R")
get_system_1_recommendations = function(movies, genre){
  get_recommendation_by_genre(genre)
}


get_system_2_recommendations = function(movies, user_ratings){
  get_colab_recommendation(movies, user_ratings)
  
}


get_user_ratings = function(value_list) {
  # print("value_list:")
  # print(head(value_list))
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                   Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat = na.omit(dat)
  # print("value_list:")
  # print(dat[order(MovieID),])
  dat = dat[Rating > 0]
  dat = na.omit(dat)
  dat
}

# read in data
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

movie_genres = readLines('data/genres.dat')

small_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(small_image_url, x, '.jpg?raw=true'))

shinyServer(function(input, output, session) {
  
  # show the movies to be rated
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    
    # random sample movies to rate
    random_movie_rows <- sample(nrow(movies), num_rows * num_movies)
    display_movies <- movies[random_movie_rows, ]
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        list(box(width = 2,
                 div(style = "text-align:center", img(src = display_movies$image_url[(i - 1) * num_movies + j], height = 150)),
                 #div(style = "text-align:center; color: #999999; font-size: 80%", books$authors[(i - 1) * num_books + j]),
                 div(style = "text-align:center", strong(display_movies$Title[(i - 1) * num_movies + j])),
                 div(style = "text-align:center; font-size: 150%; color: #f0ad4e;", ratingInput(paste0("select_", display_movies$MovieID[(i - 1) * num_movies + j]), label = "", dataStop = 5)))) #00c0ef
      })))
    })
  })
  
  
  # df <- 
  #   withBusyIndicatorServer("colab_btn", { # showing the busy indicator
  #     # hide the rating container
  #     useShinyjs()
  #     jsCode <- "document.querySelector('[data-widget=collapse]').click();"
  #     runjs(jsCode)
  #     
  #     # get the user's rating data
  #     value_list <- reactiveValuesToList(input)
  #     user_ratings <- get_user_ratings(value_list)
  #     
  #     user_results = (1:10)/10
  #     user_predicted_ids = 1:10
  #     recom_results <- data.table(Rank = 1:10, 
  #                                 MovieID = movies$MovieID[user_predicted_ids], 
  #                                 Title = movies$Title[user_predicted_ids], 
  #                                 Predicted_rating =  user_results) %>% 
  #   bindEvent(input$colab_btn)
   
  df_genre <- eventReactive(input$genre_btn, {
    withBusyIndicatorServer("genre_btn", { # showing the busy indicator
      # hide the rating container
      useShinyjs()
      jsCode <- "document.querySelector('[data-widget=collapse]').click();"
      runjs(jsCode)
      
      selected_genre = input$genre_selection
      # print(selected_genre)
      
      get_system_1_recommendations(movies, selected_genre)
      
     
      
    }) # still busy
    
  }) # clicked on genre button
  
  # Calculate recommendations when the sbumbutton is clicked
  df <- eventReactive(input$colab_btn, {
    withBusyIndicatorServer("colab_btn", { # showing the busy indicator
      # hide the rating container
      useShinyjs()
      jsCode <- "document.querySelector('[data-widget=collapse]').click();"
      runjs(jsCode)

      # get the user's rating data
      value_list <- reactiveValuesToList(input)
      user_ratings <- get_user_ratings(value_list)

      get_system_2_recommendations(movies, user_ratings)
      
    }) # still busy
    
  }) # clicked on button
  
  # display the recommendations of genre (system I)
  output$results_genre <- renderUI({
    num_rows <- 1
    num_movies <- 5
    recom_result <- df_genre()
    # print(recom_result)
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
            
            div(style = "text-align:center", 
                a(img(src = recom_result$image_url[(i - 1) * num_movies + j], height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(recom_result$Title[(i - 1) * num_movies + j])
            )
            
        )        
      }))) # columns
    }) # rows
    
  }) # renderUI function
  
  
  # display the recommendations of colaborative
  output$results_colab <- renderUI({
    num_rows <- 2
    num_movies <- 5
    recom_result <- df()
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
            
            div(style = "text-align:center", 
                a(img(src = recom_result$image_url[(i - 1) * num_movies + j], height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(recom_result$Title[(i - 1) * num_movies + j])
            )
            
        )        
      }))) # columns
    }) # rows
    
  }) # renderUI function
  
}) # server function