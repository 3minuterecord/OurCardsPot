library(shinydashboard)
source('global.R')

header <- dashboardHeader(title = "www.ORB10X.com", titleWidth = 220)
sidebar <- dashboardSidebar(disable = TRUE)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$link(href="https://fonts.googleapis.com/css?family=Archivo+Black&display=swap"),
    tags$link(href="https://fonts.googleapis.com/css?family=Archivo&display=swap")
  ),
  tags$style(rel = "stylesheet", type = "text/css", href = "custom.css"),
  div(
    div(
      numericInput(
        inputId = 'moneyToAdd', 
        label = 'How Much?', 
        value = 20, 
        min = 1,
        max = 100,
        step = 1,
        width = 300
        )
      ),
      div(uiOutput('showSelectNames'), style = 'margin-right:20px;'),
    class = 'sliderPanel'
  ),
  div(
    div(uiOutput("potLabel"), class = "sliderPanel"),
    #div(uiOutput("leaderLabel"), class = "sliderPanel"),
    class = 'sliderPanel'
  ),  
  div(
    actionButton(
      inputId = 'allPeople', 
      label = 'All', 
      icon = icon("users fa-fw"),
      width = 100
    ),
    actionButton(
      inputId = 'billy', 
      label = 'Billy', 
      icon = icon("user-o fa-fw"),
      width = 100
    ),
    actionButton(
      inputId = 'brian', 
      label = 'Brian', 
      icon = icon("user-o fa-fw"),
      width = 100
    ),
    actionButton(
      inputId = 'browno', 
      label = 'Browno', 
      icon = icon("user-o fa-fw"),
      width = 100
    )
  ),
  div(
    actionButton(
      inputId = 'doc', 
      label = 'Doc', 
      icon = icon("user-o fa-fw"),
      width = 100
    ),
    actionButton(
      inputId = 'jason', 
      label = 'Jason', 
      icon = icon("user-o fa-fw"),
      width = 100
    ),
    actionButton(
      inputId = 'matthew', 
      label = 'Matthew', 
      icon = icon("user-o fa-fw"),
      width = 100
    ),
    actionButton(
      inputId = 'mossy', 
      label = 'Mossy', 
      icon = icon("user-o fa-fw"),
      width = 100
    )
  ), br(),
  div(
    actionButton(
      inputId = 'oneIn', 
      label = '€1', 
      width = 100
    ),
    actionButton(
      inputId = 'twoIn', 
      label = '€2', 
      width = 100
    ),
    actionButton(
      inputId = 'fiveIn', 
      label = '€5', 
      width = 100
    ),
    actionButton(
      inputId = 'tenIn', 
      label = '€10', 
      width = 100
    )
  ),
  div(
    actionButton(
      inputId = 'addMoney', 
      label = 'Top Up', 
      width = 100
    ),
    actionButton(
      inputId = 'clearNameSelector', 
      label = 'Clear', 
      width = 100
    ),
    actionButton(
      inputId = 'placeBet', 
      label = 'Put In', 
      icon = icon("plus fa-fw"),
      width = 100
    ),
    actionButton(
      inputId = 'cashOut', 
      label = 'Take Out', 
      icon = icon("minus fa-fw"),
      width = 100
    ),
    br(), br(), br(),
  reactableOutput('accountTable'),
  br(),
  #reactableOutput('topUpTable'),
  br()
  )
)

dashboardPage(title = "ORB10X", header, sidebar, body, skin = "green")

