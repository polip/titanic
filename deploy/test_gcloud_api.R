library(httr2)
library(dplyr)
library(googleAuthR)

# Sample input data frame

titanic_tibble <- tibble(
  passenger_id=c(1,2,3),
  pclass=c("1st","1st","3rd"),
  sex=c("female","male","male"),
  age=c(23,76,45), sib_sp=c(1,4,7),
  parch=c(1,0,3),
  fare=c(8.23,4.67,8.45),
  embarked=c("C","Q","S"),
  title=c("Mr", "Mrs","Capt")
)

# Authenticate using the service account key
auth <- gar_auth_service(json_file = "~/Documents/titanic/titanic-466214-95c689d94120.json") # nolint

# Get the access token 
my_token <- gar_token()
access_token  <- my_token$auth_token$credentials$access_token

# URL of deployed Cloud Run service
base_url <- 'https://titanic-88146497745.europe-west1.run.app'

# Build and perform the POST request
response <- request(base_url) %>%
  req_url_path_append("predict") %>%
  req_auth_bearer_token(token = access_token) %>%
  req_body_json(data = titanic_tibble) %>%
  req_perform()

# Print the response status and the prediction result
print(resp_status(response))
print(resp_body_json(response))
