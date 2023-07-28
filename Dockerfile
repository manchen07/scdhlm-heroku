# change here is you want to pin R version
FROM rocker/r-base:4.2.2

# change maintainer here
LABEL maintainer="Man Chen <manchen9005@gmail.com>"

# add system dependencies for packages as needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    && rm -rf /var/lib/apt/lists/*

# install packages
RUN install2.r -e remotes renv stats utils readxl rlang dplyr tidyselect magrittr \
    lmeInfo nlme knitr markdown rmarkdown ggplot2 plyr boot parallel shiny \
    shinytest glue janitor rclipboard rvest brms scdhlm

RUN R -e 'install.packages("StanHeaders", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))'
RUN R -e 'install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))'

# create non root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

# switch over to the app user home
WORKDIR /home/app

COPY ./renv.lock .
RUN Rscript -e "options(renv.consent = TRUE);renv::restore(lockfile = '/home/app/renv.lock', repos = c(CRAN = 'https://cloud.r-project.org'), library = '/usr/local/lib/R/site-library', prompt = FALSE)"
RUN rm -f renv.lock

# copy everything inside the app folder
COPY app .

# permissions
RUN chown app:app -R /home/app

# change user
USER app

# EXPOSE can be used for local testing, not supported in Heroku's container runtime
EXPOSE 8080

# web process/code should get the $PORT environment variable
ENV PORT=8080

# command we want to run
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"]
