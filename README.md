# MovieRocommender

Authors: 

  - Tatiana Sokolinski, University Of Illinois Urbana Champaign
  - Noam Mansovsky, University Of Illinois Urbana Champaign


Webapp code is based on https://github.com/pspachtholz/BookRecommender

The app is deployed in shinyapps.io, and you can visit it at https://no-man.shinyapps.io/psl-project-4/



## Using the App Locally

This is a R Shiny app.

### Install the required packages for Shiny

```r
install.packages("devtools")
install.packages("shinydashboard")
install.packages("recommenderlab")
install.packages("irlba")
install.packages("shinyjs")
```
### Run the APP

In RStudio, open either `server.R` ro `ui.R` and press `Run App`

### Develop / Invoke the models without the app

run with either of these helpers:

- `source("driver_system1.R")` 
- `source("driver_system2.R")`

The models themselves are implemented in:

- `functions/system1.R`
- `functions/system2.R`


### Evaluate & Continue our work

Open `Project-4-Summary-Report.Rmd` to review our work process and improve on it!
