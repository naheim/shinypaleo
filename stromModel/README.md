# Growth Model for Stromatoporoids
This web widget stochastically models the growth of stromatoporoids an other accreting organisms. It follows the model presented by Swan & Kershaw (1994) and is modified from Matlab code written by Tom Olszewski ([https://serc.carleton.edu/NAGTWorkshops/paleo/activities/32376.html]).

## Run the App
To run the app in R, you need to have the *shiny*, *raster*, and *spatstat.utils* R libraries installed. Once installed, run the following code:

````r
library('shiny')
library('raster')
library('spatstat.utils')
runGitHub("shinypaleo", "naheim", subdir="stromModel")
````

Running this code will open a new window/tab in your default browser and load the shiny app. 

**When you're done using the app, return to the R console and hit 'esc'.**

## Citations
Swan, A. R. H. & Kershaw, S. 1994. A computer model for skeletal growth of stromatoporoids. *Palaeontology* 37:397–408. [URL: https://www.palass.org/publications/palaeontology-journal/archive/37/2/article_pp409-423](https://www.palass.org/publications/palaeontology-journal/archive/37/2/article_pp409-423)