library(tidymodels)
library(readr)
library(forcats)
library(DataExplorer)
library(stringr)

train <- read_csv("data/train.csv") |> 
  janitor::clean_names()

train |> count(survived)
train |> glimpse()
train |> count(pclass)
train |> count(embarked)

train <- train %>% 
  janitor::clean_names() %>% 
  mutate(survived=factor(survived), survived=fct_relevel(survived,"0",after=1))  %>% 
  mutate(pclass=factor(pclass,labels = c("1st","2nd","3rd"))) %>% 
  mutate(sex = factor(sex)) |> 
  mutate(embarked= factor(embarked)) |> 
  mutate(title=str_extract(name,"\\,\\s*(.*?)\\s*\\."), title=str_remove(title,", "), title=str_remove(title,"\\."), title=factor(title)) 

train |> glimpse()

train <- train |> 
  select(-name, -ticket,-cabin)

train |> write_rds("data/train.rds")


### recipe
recipe <- recipe(survived~., train) %>% 
  update_role(passenger_id, new_role = "id variable") %>% 
  step_impute_knn(c(age,fare)) %>% 
  step_novel(all_nominal_predictors()) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_other(all_nominal_predictors(),threshold = 10) %>% 
  step_nzv(all_predictors())  %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_zv(all_predictors())  %>% 
  step_normalize(all_numeric_predictors())


train_baked <-recipe |> 
  prep() |> 
  bake(new_data = NULL)

train_baked  |> write_rds("data/train_baked.rds") 
  

rf_model <- rand_forest(mode = "classification") |> 
    set_engine(engine = "ranger",importance = "impurity")

rf_wf <- workflow() |> 
  add_model(rf_model) |> 
  add_recipe(recipe)



### resampling

#set.seed(121)
#train_folds <- 

#fit_resamples <- 
  #rf_wf |> 
  #fit_resamples(resamples = bootstraps(times = 10, data=train, strata = survived), control = control_resamples(save_pred = TRUE, save_workflow = TRUE))

#collect_metrics(fit_resamples,summarize = T) 

#fit_resamples |> 
  #collect_predictions() 

#conf_mat_resampled(fit_resamples)

train_fit <- fit(rf_wf, train)

##library(butcher)
###butchered_workflow <- butcher::butcher(train_fit)
train_fit |> write_rds(
  "titanic_model.rds")

library(vip)
vip(train_fit)


#### test data

test <- read_csv("data/test.csv") %>% 
  janitor::clean_names() %>% 
  #mutate(pclass=factor(pclass,labels = c("1st","2nd","3rd"))) %>% 
  mutate(title=str_extract(name,"\\,\\s*(.*?)\\s*\\."), title=str_remove(title,", "), title=str_remove(title,"\\.")) %>% 
  mutate(across(where(is.character),factor))  

test %>% count(title)
plot_missing(test)

test_pred <- predict(train_fit,test,type = "prob")
test_pred_class <- predict(train_fit,test,type = "class")

test_predictions <- test_pred |> 
  bind_cols(test_pred_class)

sample_submission <- bind_cols(test %>% select(passenger_id),test_pred_class %>% select(.pred_class) )

sample_submission <- sample_submission %>% 
  rename("PassengerID"=passenger_id,"Survived"=.pred_class)
sample_submission %>% write_csv("data/sample_submission_v2.csv")
