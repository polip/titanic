
library(vetiver)
library(dplyr)
library(glue)
library(pins)
library(googleCloudStorageR)
library(googleAuthR)

#### generate function for readinf csv file

## fitani model
train_fit  <- readr::read_rds("shiny_app/titanic_model.rds")
### train podaci za prototip
train <- readr::read_rds("data/train.rds")

### vetiver model
vet_model <- vetiver_model(
  train_fit,
  model_name = "titanic_survived_predictor",
  save_prototype = train |>
	select(
  "passenger_id", "pclass", "sex", "age", "sib_sp", "parch", "fare", "embarked", "title") |>
	head(1)
)

## google cloud storage
gcs_auth(json_file = "deploy/titanic-466214-95c689d94120.json")
gcs_list_buckets("titanic-466214")

### google cloud board
gcs_model_board <- board_gcs("titanic-model-1602")
gcs_model_board |> vetiver_pin_write(vet_model)

### lokalni board s modelom
local_model_board <- board_folder("board-local")
### zapiši vetiver model lokalno
local_model_board |> vetiver_pin_write(vet_model)

### plumber file za API
vetiver_write_plumber(file = "deploy/plumber.R",  
  board = gcs_model_board, ### gcs board
  name = "titanic_survived_predictor"
)

### docker file za API 
### dodaj COPY board-local foldera ako je lokalni model
vetiver_write_docker(path="deploy",
plumber_file = "deploy/plumber.R",
    vetiver_model = vet_model,
    base_image = glue::glue("FROM rocker/r-ver:{getRversion()}"),

)

renv::init( project="deploy"  
  
)

renv::snapshot( 
  lockfile = "deploy/renv.lock",
  prompt = FALSE
)

renv::restore(
  lockfile = "deploy/renv.lock",
  prompt = FALSE
)

