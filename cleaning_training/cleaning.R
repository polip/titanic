### Cleaning and preparation, change of data types

library(tidyverse)

train <- read_csv('data/train.csv' ) 

train_clean <- train %>% 
  janitor::clean_names() %>% 
  mutate(survived=factor(survived), survived=fct_relevel(survived,"0",after=1))  %>% 
  mutate(pclass=factor(pclass,labels = c("1st","2nd","3rd"))) %>% 
  mutate(sex = factor(sex)) |> 
  mutate(embarked= factor(embarked)) |> 
  mutate(title=str_extract(name,"\\,\\s*(.*?)\\s*\\."), title=str_remove(title,", "), title=str_remove(title,"\\."), title=factor(title)) 


train_clean <- train_clean |> 
  select(-name, -ticket,-cabin)

train_clean |> write_rds("data/train_clean.rds")
