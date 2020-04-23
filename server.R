source("global.R")

shinyServer(function(input, output, session) {
  
  usersCashAccounts <- reactiveValues(Names = NULL, Balance = NULL)
  usersTopUps <- reactiveValues(Names = NULL, Balance = NULL)
  
  thePot <- reactiveValues(Pot = NULL)
  
  players <- reactive({
    data <- read.csv('data/players.csv', stringsAsFactors = FALSE)
    return(data)
  })
  
  observe({
    usersCashAccounts$Data <- data.frame(
      Names = players()$Name,
      Balance = 0,
      stringsAsFactors = FALSE
    )  
  })
  
  observe({
    usersTopUps$Data <- data.frame(
      Names = players()$Name,
      Added = 0,
      stringsAsFactors = FALSE
    )  
  })
  
  output$showSelectNames <- renderUI({
    names <- players()$Name
    selectInput(
      inputId = 'selectNames', 
      label = 'Select Player(s)', 
      choices = c("All", names),
      selected = NULL,
      multiple = TRUE,
      width = 300
    )
  })
  
  observeEvent(input$clearNameSelector, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = NULL,
    )
  })
  
  observeEvent(input$addMoney, {
    cash <- input$moneyToAdd
    
    if(is.null(input$selectNames)){return(NULL)}
    
    if(head(input$selectNames, 1) == 'All'){
      peopleWantingCash <-  players()$Name
    } else {
      peopleWantingCash <- input$selectNames
    }
    
    newCash <- data.frame(
      Names = peopleWantingCash,
      Add = cash,
      stringsAsFactors = FALSE
    )
    data <- left_join(usersCashAccounts$Data, newCash, by = 'Names') 
    data[is.na(data)] <- 0
    
    data <- data %>%
      mutate(Balance = Balance + Add) %>%
      select(-Add)
    
    usersCashAccounts$Data <- data
    
    topUp <- left_join(usersTopUps$Data, newCash, by = 'Names') 
    topUp[is.na(topUp)] <- 0
    
    topUp <- topUp %>%
      mutate(Added = Added + Add) %>%
      select(-Add)
    
    usersTopUps$Data <- topUp
    
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = NULL,
    )
    
  })
  
  output$accountTable <- reactable::renderReactable({
    data <- usersCashAccounts$Data %>% 
      left_join(usersTopUps$Data, by = 'Names') %>%
      mutate(Status = Balance - Added) %>%
      select(Names, Added, Status, Balance) %>%
      arrange(desc(Status, Names))
    
    lightTextCol <- "#C1C1C1"
    
    reactable(
      data,
      #defaultSorted = list(Balance = "desc"),
      #searchable = TRUE,
      defaultPageSize = 20,
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 20, 50, 100),
      onClick = "expand",
      resizable = TRUE,
      bordered = TRUE,
      highlight = TRUE,
      wrap = FALSE,
      class = "react-table",
      rowStyle = list(cursor = "pointer"),
      fullWidth = FALSE,
      defaultColDef = colDef(headerStyle = list(background = "#f7f7f8")),
      columns = list(
        Names = colDef(
          minWidth = 145
        ),
        Status = colDef(
          name = 'Win | Loss',
          style = function(value) {
            if (value == 0) {
              color <- lightTextCol
            } else {
              color <- "#333"
            }
            list(color = color)
          }
        ),
        Balance = colDef(
          style = function(value) {
            if (value == 0) {
              color <- lightTextCol
            } else {
              color <- "#333"
            }
            list(color = color)
          }
        ),
        Added = colDef(
          style = function(value) {
            if (value == 0) {
              color <- lightTextCol
            } else {
              color <- "#333"
            }
            list(color = color)
          }
        )
      )
    )
  })
  
  output$topUpTable <- reactable::renderReactable({
    data <- usersTopUps$Data %>% 
      arrange(desc(Added, Names))
    reactable(
      data,
      #defaultSorted = list(Balance = "desc"),
      #searchable = TRUE,
      defaultPageSize = 20,
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 20, 50, 100),
      onClick = "expand",
      resizable = TRUE,
      bordered = TRUE,
      highlight = TRUE,
      wrap = FALSE,
      class = "react-table",
      rowStyle = list(cursor = "pointer"),
      fullWidth = FALSE,
      defaultColDef = colDef(headerStyle = list(background = "#f7f7f8"))
      # columns = list(
      #   Task = colDef(
      #     minWidth = 350,
      #     name = "Digital & Technology Indirect Hours"
      #   ),
      #   Hours = colDef(
      #     format = colFormat(separators = TRUE)
      #   )
      # )
    )
  })
  
  observeEvent(input$placeBet, {
    cash <- input$moneyToAdd
    
    if(is.null(input$selectNames)){return(NULL)}
    
    if(head(input$selectNames, 1) == 'All'){
      peopleWantingCash <-  players()$Name
    } else {
      peopleWantingCash <- input$selectNames
    }
    
    newCash <- data.frame(
      Names = peopleWantingCash,
      Add = -1 * cash,
      stringsAsFactors = FALSE
    )

    data <- left_join(usersCashAccounts$Data, newCash, by = 'Names') 
    data[is.na(data)] <- 0
   
    data <- data %>%
      mutate(Balance = Balance + Add) %>%
      select(-Add)
    
    usersCashAccounts$Data <- data
    
    if(head(input$selectNames, 1) == 'All'){
      multiplier <- length(players()$Name)
    } else {
      multiplier <- length(input$selectNames)
    }
    
    if(is.null(thePot$Pot)){
      data <- cash * multiplier
    } else {
      data <- (cash * multiplier) + thePot$Pot  
    }
    
    thePot$Pot <- data
    
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = NULL,
    )
  })
  
  output$thePot <- renderUI({
    div(thePot$Pot)
  })
  
  observeEvent(input$cashOut, {
    cash <- input$moneyToAdd
    
    if(cash > thePot$Pot){
      return(NULL)
    }
    
    if(is.null(input$selectNames)){
      return(NULL)
    } else if (head(input$selectNames, 1) == 'All') {
      return(NULL)
    } else if (length(input$selectNames) != 1){
      return(NULL)
    } else {
      newCash <- data.frame(
        Names = input$selectNames,
        Add = cash,
        stringsAsFactors = FALSE
      )
      
      data <- left_join(usersCashAccounts$Data, newCash, by = 'Names') 
      data[is.na(data)] <- 0
  
      data <- data %>%
        mutate(Balance = Balance + Add) %>%
        select(-Add)
      
      usersCashAccounts$Data <- data
      
      if(is.null(thePot$Pot)){
        pot <- cash * -1
      } else {
        pot <- thePot$Pot - cash 
      }
      
      thePot$Pot <- pot

    }
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = NULL,
    )
  })
  
  observeEvent(input$allPeople, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name,
    )
  })
  
  observeEvent(input$billy, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name[players()$Name == 'Billy'],
    )
  })
  
  observeEvent(input$brian, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name[players()$Name == 'Brian'],
    )
  })
  
  observeEvent(input$browno, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name[players()$Name == 'Browno'],
    )
  })
  
  observeEvent(input$doc, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name[players()$Name == 'Doc'],
    )
  })
  
  observeEvent(input$jason, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name[players()$Name == 'Jason'],
    )
  })
  
  observeEvent(input$matthew, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name[players()$Name == 'Matthew'],
    )
  })
  
  observeEvent(input$mossy, {
    updateSelectInput(
      session,
      inputId = 'selectNames', 
      choices = c("All", players()$Name),
      selected = players()$Name[players()$Name == 'Mossy'],
    )
  })
  
  output$potLabel <- renderUI({
    if (is.null(thePot$Pot)) {
      outputValue <- "---"
    } else {
      outputValue <- thePot$Pot
    }
    labelIcon <- tags$i(class = "fa fa-money fa-fw")
    labelText = "What's in the pot?"
    div(createInfoBox(outputValue, labelIcon, labelText), class = "combo-box combo-dark")
  })
  
  output$leaderLabel <- renderUI({
    data <- usersCashAccounts$Data %>%
      arrange(desc(Balance))
    print(data)
    if (is.null(data)) {
      outputValue <- "---"
      leader <- ""
    } else {
      outputValue <- head(data$Balance, 1)
      leader <- head(data$Names, 1)
    }
    labelIcon <- tags$i(class = "fa fa-trophy fa-fw")
    labelText <- leader
    div(createInfoBox(outputValue, labelIcon, labelText), class = "combo-box combo-light")
  })
  
  observeEvent(input$oneIn, {
    updateNumericInput(
      session,
      inputId = 'moneyToAdd', 
      label = 'How Much?', 
      value = 1
    )
  })
  
  observeEvent(input$twoIn, {
    updateNumericInput(
      session,
      inputId = 'moneyToAdd', 
      label = 'How Much?', 
      value = 2
    )
  })
  
  observeEvent(input$fiveIn, {
    updateNumericInput(
      session,
      inputId = 'moneyToAdd', 
      label = 'How Much?', 
      value = 5
    )
  })
  
  observeEvent(input$tenIn, {
    updateNumericInput(
      session,
      inputId = 'moneyToAdd', 
      label = 'How Much?', 
      value = 10
    )
  })
  
})
