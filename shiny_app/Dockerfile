# Use the Rocker r 4.4 image
FROM rocker/shiny-verse:4.4

# Install required R packages
RUN R -e "install.packages(c('bslib', 'DT', 'shiny','tidymodels', 'ranger'), repos='https://cran.rstudio.com/')"

# Create app directory and copy files
WORKDIR /app
COPY app.R .
COPY titanic_model.rds .

# Create non-root user and change ownership
RUN useradd --create-home --shell /bin/bash shiny-user && \
    chown -R shiny-user:shiny-user /app

# Switch to non-root user
USER shiny-user

# Expose port 3838
EXPOSE 3838

# Run the app directly with R instead of shiny-server
CMD ["R", "-e", "shiny::runApp('app.R', host='0.0.0.0', port=3838)"]