library(recommenderlab)
library(Matrix)
library(tidyverse)
library(dplyr)

get_user_ratings = function(value_list) {
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                    Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat = dat[Rating > 0]
}

# read in data
myurl = "https://liangfgithub.github.io/MovieData/"
movies = readLines(paste0(myurl, 'movies.dat?raw=true'))
movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies = data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) = c('MovieID', 'Title', 'Genres')
movies$MovieID = as.integer(movies$MovieID)
movies$Title = iconv(movies$Title, "latin1", "UTF-8")

small_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(small_image_url, x, '.jpg?raw=true'))

r1 <- readRDS("r1.rds")

# New stuff
s1_movie_genre = read.table("top_by_genre.csv")
ratings = read.csv('ratings.dat', 
                   sep = ':',
                   colClasses = c('integer', 'NULL'), 
                   header = FALSE)
colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
train = ratings

i = paste0('u', train$UserID)
j = paste0('m', train$MovieID)
x = train$Rating
tmp = data.frame(i, j, x, stringsAsFactors = T)
Rmat = sparseMatrix(as.integer(tmp$i), as.integer(tmp$j), x = tmp$x)
rownames(Rmat) = levels(tmp$i)
colnames(Rmat) = levels(tmp$j)
Rmat = new('realRatingMatrix', data = Rmat)

movieIDs = colnames(Rmat)
n.item = ncol(Rmat) 

# print(movieIDs)


shinyServer(function(input, output, session) {
  
  # show the books to be rated
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        list(box(width = 2,
                 div(style = "text-align:center", img(src = movies$image_url[(i - 1) * num_movies + j], height = 150)),
                 #div(style = "text-align:center; color: #999999; font-size: 80%", books$authors[(i - 1) * num_books + j]),
                 div(style = "text-align:center", strong(movies$Title[(i - 1) * num_movies + j])),
                 div(style = "text-align:center; font-size: 150%; color: #f0ad4e;", ratingInput(paste0("select_", movies$MovieID[(i - 1) * num_movies + j]), label = "", dataStop = 5)))) #00c0ef
      })))
    })
  })
  
  # System II, Calculate recommendations when the sbumbutton is clicked
  df <- eventReactive(input$btn, {
    withBusyIndicatorServer("btn", { # showing the busy indicator
        # hide the rating container
        useShinyjs()
        jsCode <- "document.querySelector('[data-widget=collapse]').click();"
        runjs(jsCode)
        
        # get the user's rating data
        value_list <- reactiveValuesToList(input)
        user_ratings <- get_user_ratings(value_list)
        # print(user_ratings)

        # https://campuswire.com/c/G497EEF81/feed/1333
        default_user_ratings = data.frame(MovieID = c(1), Rating =c(5))
        if(nrow(user_ratings) == 0) {
          user_ratings = default_user_ratings;
        }
        
        print(user_ratings)
        new.ratings = rep(NA, n.item)
        
        for(i in 1:nrow(user_ratings) ){
          new.ratings[which(movieIDs == paste0('m', user_ratings$MovieID[i]))] = user_ratings$Rating[i]
        }
        
        # print(new.ratings)
        new.user = matrix(new.ratings, 
                  nrow=1, ncol=n.item,
                  dimnames = list(
                    user=paste('feng'),
                    item=movieIDs
                  ))
        new.Rmat = as(new.user, 'realRatingMatrix')

        recom = predict(r1, new.Rmat, type = 'topN')
        

        user_results = recom@ratings[[1]]
        user_predicted_ids = recom@items[[1]]
        recom_results <- data.table(Rank = 1:10, 
                                    MovieID = movies$MovieID[user_predicted_ids], 
                                    Title = movies$Title[user_predicted_ids], 
                                    Predicted_rating =  user_results)
        print(recom_results)
        
        
    }) # still busy
    
  }) # clicked on button
  
  # System I DAO
    # Calculate recommendations when the sbumbutton is clicked
  df_genre <- eventReactive(input$genre_selector, {
    withBusyIndicatorServer("genre_selector", { # showing the busy indicator

        # get the user's rating data
        value_list <- reactiveValuesToList(input)
        
        # print(s1_movie_genre)
        genre_movie = s1_movie_genre[s1_movie_genre$Genres == value_list$genre_selector,]

        # print(s1_movie_genre)

        user_results = genre_movie$adjusted_rating
        user_predicted_ids = genre_movie$MovieID
        recom_results <- data.table(Rank = 1:5, 
                                    MovieID = movies$MovieID[user_predicted_ids], 
                                    Title = movies$Title[user_predicted_ids], 
                                    Predicted_rating =  user_results)

        print(recom_results)
        
    }) # still busy
    
  }) # clicked on button




  # System II display the recommendations
  output$results <- renderUI({
    num_rows <- 2
    num_movies <- 5
    recom_result <- df()
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
            
          div(style = "text-align:center", 
              a(img(src = movies$image_url[recom_result$MovieID[(i - 1) * num_movies + j]], height = 150))
             ),
          div(style="text-align:center; font-size: 100%", 
              strong(movies$Title[recom_result$MovieID[(i - 1) * num_movies + j]])
             )
          
        )        
      }))) # columns
    }) # rows
    
  }) # renderUI function



  # System I Controller
  output$results2 <- renderUI({
    num_rows <- 1
    num_movies <- 5
    recom_result <- df_genre()
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
            
          div(style = "text-align:center", 
              a(img(src = movies$image_url[recom_result$MovieID[(i - 1) * num_movies + j]], height = 150))
             ),
          div(style="text-align:center; font-size: 100%", 
              strong(movies$Title[recom_result$MovieID[(i - 1) * num_movies + j]])
             )
          
        )        
      }))) # columns
    }) # rows
    
  }) # renderUI function
  
}) # server function