
library(vetiver)
library(pins)
library(dplyr)
library(googleCloudStorageR)
library(googleAuthR)

## fitani model
train_fit  <- readr::read_rds("titanic_model.rds")
### train podaci za prototip
train <- readr::read_rds("data/train.rds")

### vetiver model
vet_model <- vetiver_model(
  train_fit,
  model_name = "titanic_survived_predictor",
  save_prototype = train |>
	select(
  "passenger_id", "pclass", "sex", "age", "sib_sp", "parch", "fare", "embarked", "title"
	) |>
	head(1)
)

## google cloud storage

gcs_auth(json_file = "titanic-466214-95c689d94120.json")
gcs_list_buckets("titanic-466214")

### google cloud board
gcs_model_board <- board_gcs("titanic-model-1602")
gcs_model_board |> vetiver_pin_write(vet_model)

### lokalni board s modelom
local_model_board <- board_folder("board-local")
### zapiši vetiver model lokalno
local_model_board |> vetiver_pin_write(vet_model)


### plumber file
vetiver_write_plumber(
  board = local_model_board, ### lokalni board
  name = "titanic_survived_predictor"
)


### docker file, dodaj COPY board-local foldera ako je lokalni model
vetiver_write_docker(   
    vetiver_model = vet_model,
    base_image = glue::glue("FROM rocker/r-ver:{getRversion()}"),

)
