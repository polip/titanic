library(httr2)
library(dplyr)
library(googleAuthR)

# Authenticate using the service account key
auth <- gar_auth_service(json_file = "titanic-466214-dd0b8f1ad195.json")

# Get the access token 
my_token <- gar_token()
access_token  <- my_token$auth_token$credentials$access_token 

googleAuthR::gar_has_token()
# URL of deployed Cloud Run service
base_url <- 'https://titanic-88146497745.europe-west1.run.app'


# Build and perform the POST request
response <- request(base_url) %>%
  req_url_path_append("predict") %>%
  req_auth_bearer_token(token = access_token) %>%
  req_body_json(data = titanic_tibble) %>%
  req_perform()

# Print the response status and the prediction result
resp_body_json(response)
resp_status(response)
