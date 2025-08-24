
library(shiny)
library(bslib)
library(DT)
library(tidyverse)
library(tidymodels)
library(ranger)

# UI
ui <- page_sidebar(theme = bs_theme(bootswatch = "minty"),
  title = "Titanic Survivor Prediction",
  sidebar = sidebar(
    width = 350,
    h4("Input Method"),
    radioButtons(
      "input_method",
      "Choose input method:",
      choices = list(
        "Manual Input" = "manual",
        "Upload CSV File" = "upload"
      ),
      selected = "manual"
    ),
    
    # Manual input controls
    conditionalPanel(
      condition = "input.input_method == 'manual'",
      h5("Passenger Information"),
      selectInput(
        "pclass",
        "Passenger Class:",
        choices = list("1st", "2nd" , "3rd" ),
        selected = "1st"
      ),
      selectInput(
        "sex",
        "Sex:",
        choices = list("Male" = "male", "Female" = "female"),
        selected = "male"
      ),
      numericInput(
        "age",
        "Age:",
        value = 30,
        min = 0,
        max = 100,
        step = 1
      ),
      numericInput(
        "sib_sp",
        "Number of Siblings/Spouses:",
        value = 0,
        min = 0,
        max = 10,
        step = 1
      ),
      numericInput(
        "parch",
        "Number of Parents/Children:",
        value = 0,
        min = 0,
        max = 10,
        step = 1
      ),
      numericInput(
        "fare",
        "Fare:",
        value = 32.0,
        min = 0,
        step = 1
      ),
      selectInput(
        "embarked",
        "Port of Embarkation:",
        choices = list(
          "Southampton" = "S",
          "Cherbourg" = "C",
          "Queenstown" = "Q"
        ),
        selected = "S"
      ),
      selectInput(
        "title",
        "Title:",
        choices = list(
          "Miss",
          "Mr",
          "Mrs",
          "Other",
          "Master"
        ),
        selected = "Mr"
      ),
      actionButton(
        "predict_single",
        "Predict Survival",
        class = "btn-primary",
        width = "100%"
      )
    ),
    
    # File upload controls
    conditionalPanel(
      condition = "input.input_method == 'upload'",
      h5("Upload CSV File"),
      fileInput(
        "file",
        "Choose CSV File:",
        accept = ".csv"
      ),
      p("CSV should contain columns: pclass, sex, age, sib_sp, parch, fare, embarked, title"),
      actionButton(
        "predict_batch",
        "Predict All",
        class = "btn-primary",
        width = "100%"
      )
    )
  ),
  
  # Main panel with results
  card(
    card_header("Prediction Results"),
    conditionalPanel(
      condition = "input.input_method == 'manual'",
      h4("Single Prediction"),
      htmlOutput("single_prediction")
    ),
    conditionalPanel(
      condition = "input.input_method == 'upload'",
      h4("Batch Predictions"),
      DTOutput("batch_predictions")
    )
  ),
  
  # Data preview card (for uploaded files)
  conditionalPanel(
    condition = "input.input_method == 'upload'",
    card(
      card_header("Data Preview"),
      DTOutput("data_preview")
    )
  )
)

# Server
server <- function(input, output, session) {
  # Load the pre-trained model (assuming it exists)
  # In a real scenario, you would load your actual model here
  
  titanic_model <- read_rds('titanic_model.rds')  
 
# Reactive value for uploaded data
  uploaded_data <- reactive({
    req(input$file)
    
    tryCatch({
      data <- read_csv(input$file$datapath)
      
      # Validate required columns
      required_cols <- c("passenger_id","pclass", "sex", "age", "sib_sp", "parch", "fare", "embarked","title")
      missing_cols <- setdiff(required_cols, names(data))
      
      if (length(missing_cols) > 0) {
        showNotification(
          paste("Missing columns:", paste(missing_cols, collapse = ", ")),
          type = "error"
        )
        return(NULL)
      }
      
      return(data)
    }, error = function(e) {
      showNotification(
        paste("Error reading file:", e$message),
        type = "error"
      )
      return(NULL)
    })
  })
  

# Single prediction
  single_result <- eventReactive(input$predict_single, {
    
# Create data frame from manual inputs
    input_data <- data.frame(
      passenger_id=NA,
      pclass=factor(input$pclass, levels =  c('1st','2nd','3rd')),
      sex = factor(input$sex),
      age = input$age,
      sib_sp = input$sib_sp,
      parch = input$parch,
      fare = input$fare,
      embarked = factor(input$embarked),
      title=factor(input$title)
    )
    

# Make prediction
    result <- input_data |> 
      bind_cols(predict(titanic_model,input_data,type = 'class')) |> 
      bind_cols(predict(titanic_model,input_data,type = 'prob')) 
    
    return(result)
  })
  
  
  
# Batch predictions
  batch_results <- eventReactive(input$predict_batch, {
    req(uploaded_data())
    
    # Make predictions for all rows
    results <- uploaded_data() |> 
      bind_cols(predict(titanic_model, uploaded_data(), type = 'class')) |> 
      bind_cols(predict(titanic_model, uploaded_data(), type = 'prob'))
    
    return(results)
  })
  
  # Output single prediction
  output$single_prediction <- renderUI({
    req(single_result())
    
    result <- single_result()

  
    # Create HTML formatted output
    tagList(
      div(
        style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; font-family: monospace;",
        h5(paste("Prediction:", result$.pred_class), 
           style = if(result$.pred_class == "Survived") "color: green;" else "color: red;"),
        p(paste("Probability:", paste0(round(result$.pred_1, 3) * 100, "%"))),
        hr(),
        h6("Passenger Details:"),
        p(paste("Class:", result$pclass)),
        p(paste("Sex:", tools::toTitleCase(as.character(result$sex)))),
        p(paste("Age:", result$age)),
        p(paste("Title:", result$title)),
        p(paste("Siblings/Spouses:", result$sib_sp)),
        p(paste("Parents/Children:", result$parch)),
        p(paste("Fare: $", result$fare)),
        p(paste("Embarked:", result$embarked))
      )
    )
  })
  
  # Output data preview
  output$data_preview <- renderDT({
    req(uploaded_data())
    
    datatable(
      uploaded_data(),
      options = list(
        scrollX = TRUE,
        pageLength = 10,
        searching = TRUE
      ),
      caption = paste("Data preview:", nrow(uploaded_data()), "rows")
    )
  })
  
  # Output batch predictions
  output$batch_predictions <- renderDT({
    req(batch_results())
    
    results <- batch_results() %>%
      select(
        pclass, sex, age, sib_sp, parch, fare, embarked,title,
        `Predicted Survival` = .pred_class,
        `Survival Probability (%)` = .pred_1
      ) %>%
      mutate(
        `Survival Probability (%)` = round(`Survival Probability (%)` * 100, 1)
      )
    
    datatable(
      results,
      options = list(
        scrollX = TRUE,
        pageLength = 10,
        searching = TRUE
      ),
      caption = paste("Predictions for", nrow(results), "passengers")
    ) %>%
      formatStyle(
        "Predicted Survival",
        backgroundColor = styleEqual(
          c("Survived", "Did not survive"),
          c("#d4edda", "#f8d7da")
        )
      )
  })
}

# Run the app
shinyApp(ui = ui, server = server)
