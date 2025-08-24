
library(vetiver)
library(pins)
library(dplyr)
library(googleCloudStorageR)
library(googleAuthR)


### google cloud storage autentifikacija
options(googleAuthR.client_id = Sys.getenv("GOOGLE_AUTH_CLIENT_ID"))
options(googleAuthR.client_secret = Sys.getenv("GOOGLE_AUTH_CLIENT_SECRET"))
options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/devstorage.read_write")
googleAuthR::gar_auth()
gcs_model_board <- board_gcs(bucket = 'titanic-model-1602')

### lokalni board s modelom
local_model_board <- board_folder('board-local')

### fitani model
train_fit  <- readr::read_rds('titanic_model.rds') 
### train podaci za prototip
train <- readr::read_rds('data/train.rds') 

### vetiver model
vet_model <- vetiver_model(train_fit, model_name = "titanic_survived_predictor", save_prototype = train |> select("passenger_id","pclass", "sex", "age", "sib_sp", "parch", "fare", "embarked","title") |> head(1))
#### lokalno
local_model_board |> vetiver_pin_write(vet_model)
### google cloud
gcs_model_board |> vetiver_pin_write(vet_model)

pin_list(board = local_model_board)
pin_list(board = gcs_model_board)


### plumber file
vetiver_write_plumber(board = gcs_model_board, name = 'titanic_survived_predictor')

### docker file, dodaj COPY board-local foldera
vetiver_write_docker(vetiver_model = vet_model,base_image = glue::glue("FROM rocker/r-ver:{getRversion()}"))
 
