library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(shinyjs) # for disabling buttons
library(shinycssloaders) # for loading spinners
library(shinyWidgets) # for toggle switch
library(shinyalert)
library(httr)
library(rjson)
library(stringr)
library(bsplus)
library(shinyBS)
library(reactable)
library(dplyr)

# Create a custom value / info box
createInfoBox <- function(value, iconName, text) {
  return(
    div(div(div(value, class = "label-big"), span(iconName, class = "label-icon"), class = "label-box"), div(text, class = "label-box-explainer"))
  )
}