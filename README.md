# MovieRocommender

Webapp code is based on https://github.com/pspachtholz/BookRecommender

### installation

```r
install.packages("devtools")
install.packages("shinydashboard")
install.packages("recommenderlab")
install.packages("irlba")
install.packages("shinyjs")
```

### Run the APP

open either `server.R` ro `ui.R` and press `Run App`

### Develop / Invoke the models without the app

run with either of these helpers:

- `source("driver_system1.R")` 
- `source("driver_system2.R")`

The models themselves are implemented in:

- `functions/system1.R`
- `functions/system2.R`
