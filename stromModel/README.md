# Growth Model for Stromatoporoids
This web widget stochastically models the growth of stromatoporoids an other accreting organisms. It follows the model presented by 


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