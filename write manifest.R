# write manifest using rsconnect
# Load rsconnect package
library(rsconnect)


# Write manifest for the current directory
writeManifest(appDir = ".", appFiles = "app.R", appPrimaryDoc = NULL)
