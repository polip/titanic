library(dplyr)

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

titanic_tibble |> 
write_csv("data/titanic.csv")

titanic_input_json <- titanic_tibble |> 
  jsonlite::toJSON()

titanic_tibble <- titanic_tibble |> 
  mutate(across(where(is.character), factor)) 
