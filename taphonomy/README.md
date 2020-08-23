# Time Averaging
This web widget will use a recent dataset to demonstrate time averaging in a modern death assemblage off the coast of southern California. Understanding how dead shells accumulate in the sedimentary record over time is important for understanding how the fossil record is constructed and what types of information is transferred from living communities to the fossil record. 

## Run the App
To run the app in R, you need to have the *shiny* R library installed and run the following code:

````r
library(shiny)
runGitHub("shinypaleo", "naheim", subdir="taphonomy")
````

Running this code will open a new window/tab in your default browser and load the shiny app. 

**When you're done using the app, return to the R console and hit 'esc'.**

## Citations
Warme, J. (1971). Paleoecological aspects of a modern coastal lagoon. *University of California Publications in Geological Sciences* 87:1-131.

Tomasovych, A., Kidwell, S., Barber, R. (2016). Inferring skeletal production from time-averaged assemblages: skeletal loss pulls the timing of production pulses towards the modern period. *Paleobiology* 42(01):54-76. [DOI: 10.1017/pab.2015.30](https://doi.org/10.1017/pab.2015.30)