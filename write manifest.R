# write manifest using rsconnect
# Load rsconnect package
library(rsconnect)
install.packages("ranger")

# Write manifest for the current directory
writeManifest(appDir = ".", appFiles = "app.R", appPrimaryDoc = NULL)
renv::snapshot()

