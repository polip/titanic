# write manifest using rsconnect for POSIT deployment


# Write manifest for the current directory
renv::status()
renv::install("googleCloudStorageR")

# Load rsconnect package
library(rsconnect)
writeManifest(appDir = "shiny_app", appFiles = "app.R", appPrimaryDoc = NULL)


