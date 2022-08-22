
library(shiny)
library(shinythemes)
library(googledrive)
library(gargle)
library(googlesheets4)
library(cli)
library(dplyr)

# Para info sobre como conectar shiny y google sheets https://www.jdtrat.com/blog/connect-shiny-google/
# y https://stackoverflow.com/questions/63535190/connect-to-googlesheets-via-shiny-in-r-with-googlesheets4
options(
  # whenever there is one account token found, use the cached token
  gargle_oauth_email = TRUE,
  # specify auth tokens should be stored in a hidden directory ".secrets"
  gargle_oauth_cache = ".secrets"
)

fields <- c("date", "happiness", "happiness_error", "things_done", "feelings")
sheet_id <- "1gUUh3OCLceWFTTBbZd12NFMLr8sjK8pPu9vUAPH8Pyw"

saveData <- function(data) {
  # The data must be a dataframe rather than a named vector
  data <- data %>% as.list() %>% data.frame() %>% 
    mutate(date = as.Date(as.POSIXct(as.numeric(as.character(date))*24*60*60, origin = '1970-01-01')))
  # Add the data as a new row
  sheet_append(ss = sheet_id, data = data)
}

ui <- fluidPage(
  
  theme = shinytheme("spacelab"),
  
  # Application title
  titlePanel("Daily Happiness"),
  
  dateInput(inputId = "date", label = "Selecciona una fecha:", format = "dd/mm/yyyy",
            weekstart = 1, language = "es"),
  
  sliderInput(inputId = 'happiness', label = "¿Repetirías día?", min = 0, max = 10, value = 5),
  
  sliderInput(inputId = 'happiness_error', label = "Margen de error", min = -1, max = 1, value = 0),
  
  textAreaInput(inputId = 'things_done', label = '¿Qué has hecho?', rows = 3),
  
  textAreaInput(inputId = "feelings", label = "¿Qué has sentido?", rows = 8),
  
  actionButton(inputId = "submitInput", label = "Submit")
  
)

server = function(input, output, session) {
  
  # Whenever a field is filled, aggregate all form data
  formData <- reactive({
    print(input)
    data <- sapply(fields, function(x) input[[x]])
    data
  })
  
  # When the Submit button is clicked, save the form data
  observeEvent(input$submitInput, {
    saveData(formData())
  })
  
}


shinyApp(ui = ui, server = server)

