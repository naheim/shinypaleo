# Stratigraphic Range Chart
This web widget will take a list of taxonomic names, retrieve their times of first and last appearance from the [Paleobiology Database](http://paleobiodb.org), and plots those ranges. 

Unfortunately, this app is a little buggy--the main problem arises when a misspelled taxon name is submitted. I think the solution will be to request JSON from the PBDB API rather than a .tsv file. 

## Run the App
To run the app in R, you need to have the *shiny* R library installed and run the following code:

````r
library(shiny)
runGitHub("shinypaleo", "naheim", subdir="stratRange")
````

Running this code will open a new window/tab in your default browser and load the shiny app. 

**When you're done using the app, return to the R console and hit 'esc'.**