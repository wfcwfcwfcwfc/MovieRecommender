# MovieRecommender
## Introduction
This is a Shiny app for movie recommender. It has two systems - genre based and UBCF. Pre-trained UBCF model is loaded at run time.

## How to Run
Install required R libraries.  

(recommenderlab)
(Matrix)
(tidyverse)
(dplyr)

Run command: R -e "shiny::runApp('.')". 
Follow the provided URL in the print logs, and open in browser.

## Core Files
[ui.R](ui.R) - The view.  
[server.R](server.R) - Model and controller.  
[r1.rds](r1.rds) - Pre-trained UBCF model.  
[top_by_genre.csv](top_by_genre.csv) - Static genre ranking.  

