## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/helpers.R')

sidebar <- dashboardSidebar(sidebarMenu(
  menuItem("System I", tabName = "S1", icon = icon("dashboard")),
  menuItem(
    "System II",
    icon = icon("th"),
    tabName = "S2",
    badgeLabel = "new",
    badgeColor = "green"
  )
))


shinyUI(dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Movie Recommender"),
  
  sidebar,
  
  dashboardBody(includeCSS("css/books.css"),
                tabItems(
                  tabItem(tabName = "S2",
                          fluidRow(
                            box(
                              width = 12,
                              title = "Step 1: Rate as many books as possible",
                              status = "info",
                              solidHeader = TRUE,
                              collapsible = TRUE,
                              div(class = "rateitems",
                                  uiOutput('ratings'))
                            )
                          ),
                          fluidRow(
                            useShinyjs(),
                            box(
                              width = 12,
                              status = "info",
                              solidHeader = TRUE,
                              title = "Step 2: Discover books you might like",
                              br(),
                              withBusyIndicatorUI(
                                actionButton("btn", "Click here to get your recommendations", class = "btn-warning")
                              ),
                              br(),
                              tableOutput("results")
                            )
                          )),
                  tabItem(tabName = "S1",
                          selectInput("genre_selector", "Select a genre:",
                c("Animation" =  "Animation",
                 "Children's" =  "Children's",
                  "Comedy" = "Comedy",
                  "Adventure" = "Adventure",
                  "Fantasy" = "Fantasy",
                  "Romance" = "Romance",
                  "Drama" = "Drama",
                  "Action" = "Action",
                  "Crime" = "Crime",
                  "Thriller" = "Thriller",
                  "Horror" = "Horror",
                  "Sci-Fi" = "Sci-Fi",    
                  "Documentary" = "Documentary",
                  "War" = "War",
                  "Musical" = "Musical",
                  "Mystery" = "Mystery",
                  "Film-Noir" = "Film-Noir",
                  "Western" = "Western")),
                  fluidRow(
                            useShinyjs(),
                            box(
                              width = 12,
                              status = "info",
                              solidHeader = TRUE,
                              title = "Movies you might like",
                              br(),
                              br(),
                              tableOutput("results2")
                            )
                          )
                          ) # tabItem
                ))
  
)) 