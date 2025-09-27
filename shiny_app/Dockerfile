# Docker file to run Shiny app

# Use the Rocker r 4.4 image
FROM rocker/shiny-verse:4.4
ENV RENV_CONFIG_REPOS_OVERRIDE https://packagemanager.rstudio.com/cran/latest

RUN apt-get update -qq && apt-get install -y --no-install-recommends libxml2-dev \
  libcurl4-openssl-dev \
  # Add pandoc as it is not in the base image but required by rmarkdown (a vetiver dependency)
  pandoc \
  fontconfig \
  libfreetype6-dev \
  libfribidi-dev \
  libharfbuzz-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libglpk-dev \
  libicu-dev \
  libsodium-dev \
  libssl-dev \
  libx11-dev \
  make \
  unzip \
  zip \
  zlib1g-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
  

# Install required R packages
RUN R -e "install.packages(c('bslib', 'DT', 'shiny','tidymodels', 'ranger','vetiver','pins'), dependencies = TRUE)"

# Create app directory and copy files
WORKDIR /app
COPY shiny_app/app.R app.R

# Create non-root user and change ownership
RUN useradd --create-home --shell /bin/bash shiny-user && \
    chown -R shiny-user:shiny-user /app

# Switch to non-root user
USER shiny-user

# Expose the app port
EXPOSE 3838

# Run the app directly with R 
CMD ["R", "-e", "shiny::runApp('app.R', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT',8080)))"]