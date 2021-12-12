## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/helpers.R')

genres = readLines('data/genres.dat')


system_1_tab <- tabItem(tabName = "system1",
                        fluidRow(
                          useShinyjs(),
                          box(
                            # width = 8,
                            width = 12,
                            height = 4,
                            status = "info", solidHeader = TRUE,
                            title = "Discover movies with your favourite genre",
                            
                            # div("Select your favourite Movie Genre:"),
                            selectInput(inputId='genre_selection', 
                                        label='Choose a move genre:', 
                                        choices=genres),

                            
                            br(),
                            withBusyIndicatorUI(
                              actionButton(inputId = "genre_btn", "Click here to get your recommendations", class = "btn-warning")
                            ),
                            br(),
                            tableOutput("results_genre")
                          )
                        )

)

system_2_tab <- tabItem(tabName = "system2",
                       fluidRow(
                         box(width = 12, title = "Step 1: Rate as many movies as possible", status = "info", solidHeader = TRUE, collapsible = TRUE,
                             div(class = "rateitems",
                                 uiOutput('ratings')
                             )
                         )
                       ),
                       fluidRow(
                         useShinyjs(),
                         box(
                           width = 12, status = "info", solidHeader = TRUE,
                           title = "Step 2: Discover movies you might like",
                           br(),
                           withBusyIndicatorUI(
                             actionButton("colab_btn", "Click here to get your recommendations", class = "btn-warning")
                           ),
                           br(),
                           tableOutput("results_colab")
                         )
                       )
)

shinyUI(
    dashboardPage(
      
          skin = "blue",
          dashboardHeader(title = "Movie Recommender"),
          
          dashboardSidebar(
            sidebarMenu(
              menuItem("System II - Collaborative Recommendation", tabName = "system2", icon = icon("th")),
              menuItem("System I - Recommendation by Genre", tabName = "system1", icon = icon("th"))
            )
          ),

          dashboardBody(includeCSS("css/movies.css"),
                        tabItems(
                          # First tab content
                          system_2_tab
                          ,
                          
                          # Second tab content
                          system_1_tab
                        )
              
          )
    )
) 