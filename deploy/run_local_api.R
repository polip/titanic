library(plumber)

pr <- plumber::plumb("deploy/plumber.R")
pr$run(host = "0.0.0.0", port = 8000)
