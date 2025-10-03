# Docker file to run Shiny app - Multi-stage build

# Build stage
FROM rocker/shiny-verse:4.4 AS builder
ENV RENV_CONFIG_REPOS_OVERRIDE https://packagemanager.rstudio.com/cran/latest

# Install build dependencies and development tools
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libxml2-dev \
  libcurl4-openssl-dev \
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

# Install R packages
RUN R -e "install.packages(c('bslib', 'DT', 'shiny','tidymodels', 'ranger','vetiver','pins'), dependencies = TRUE)"

# Runtime stage
FROM rocker/shiny-verse:4.4 AS runtime

# Install only runtime dependencies (same as build stage but without build tools)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libxml2-dev \
  libcurl4-openssl-dev \
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
  zlib1g-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy R packages from builder stage
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

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