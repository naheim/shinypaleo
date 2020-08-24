# Activity 1—Constructing the Fossil Record: Living Communities, Dead Shells, and Time Averaging

The fossil record allows us to reconstruct the biology of Earth’s ancient past. However, the fossil record does not perfectly record every aspect of living communities: some information is missing entirely, while other information may be over-represented. Paleontologists often want to know species were present, and in what abundance, at a particular location and during a specific interval of geological time. In many cases we are fortunate enough to have fossil samples to help us answer that question. However, because fossil assemblages are not perfect representations of past living assemblages, it’s important to know how the fossil record. is constructed. This exercise will allow you to explore some aspects of how living communities become fossil assemblages.

As you learned in the video lectures, time-averaging typically increases species richness (the number of species present) in a death assemblage relative to any given life assemblage from that location. Time-averaging also makes death assemblages from different locations look more similar to each other than the life assemblages actually are. The purpose of this exercise is to use explore real datasets as well as simulations generate possible explanations for those phenomena.

This exercise will be based upon a ‘shiny app’, which is a dynamic website built using the statistical programming language R. For this exercise you will use the Taphonomy shiny app, which you will need to launch using R or RStudo by running the following two lines*:

```` r
library(shiny)
runGitHub("shinypaleo", "naheim", subdir="taphonomy")

````

\* *If you don't have the shiny package already installed, you will first need to run:* ``install.packages("shiny")``*. You will only need to run this command once.*

Executing the above code in the R console or RStudio will open a browser window. The app web page has three tabs, which will correspond to Parts 1, 2, and 3 below.


## Part 1: Live-Dead Data

This tab displays what is typically called 'live-dead' data. It's called this because sediment samples are collected that contain both living and dead individuals. Of course, the only species that accumulate dead individuals with any abunace are those with hard skeletons. For this exercise, we are focusing on bivalve (clam) and gastropod (snail) mollusks from coastal waters off of Southern California.

The data presented in the 'Live-Dead Data' tab were compiled by John Warme in the 1960s for his PhD dissertation. The samples were collected in Mugu Lagoon, which is a small back-barier lagoon in Ventura County California (between Santa Barbara and Los Angeles). Warme collected 45 samples within Mugu lagoon (see map at bottom of app page). For each sample all of the living bivalve and gastropod species were identified and counted as were all of the dead individuals (empty shells).

There are two major environments withing Mugu Lagoon: subtidal eel grass beds and intertidal sand flats. The table at the top of the page (labeled 1) shows the 


Imagine that you choose a small square of coastline, say 5 m by 5 m, on Monterey Bay and identify the organisms. We can call this the local community and it will probably contain some mussels, sea stars, and some less common species. The entirety of Monterey Bay includes many more species than found in your local community, however. We can call the entire group of organisms living in Monterey Bay the metacommunity and treat it as an infinitely large (relative to the local community) potential source of species.

For simplicity we will ignore environmental preferences and biological interactions and construct a neutral model of the metacommunity and local community. In this model we will populate the local community with organisms drawn randomly from the metacommunity. The probability of drawing an organism from the metacommunity is proportional to that organism’s abundance in the metacommunity.

When an organism in the local community dies, that vacancy can be replaced either by a species taken from the metacommunity (immigration) or by an organism “born” from the local community (local “birth”). The model has only one parameter, the probability of immigration, which varies between 0 and 1 and determines whether a vacancy is filled by immigration or by local birth. Values close to 1 mean that vacancies are most likely filled by drawing a species from the metacommunity, whereas values close to 0 means that vacancies are most likely filled by drawing a species from the local community.

Part 2: Effects of immigration probability

The goals of this part are 1) to visualize changes in the local community over time and 2) to explore how and why immigration probability influences those changes.

The next command runs a larger version of the neutral model that you already investigated. But first, some background. There are 125 species with a more realistic distribution of abundances (not all equally abundant) and the simulation runs for 18000 time steps. The output will be a graph showing how the species composition of the local community changes through time in the simulation. The difference in species composition is quantified by something called the “Bray-Curtis dissimilarity” – but that isn’t important now (we will discuss these measures later). Basically, a value of zero means the community composition is the same as the average and values either higher or lower than zero indicate increasing dissimilarity from the average.
Answer the following questions:

How does the variability in species composition differ between the low and high immigration probability simulations? Describe and compare (A) the magnitude of the changes away from zero and (B) the length of trends in community composition.
Why does immigration probability have this effect in the simulations? Hint: think about the implications of filling a vacancy from the infinitely-large metacommunity vs. the limited local community.
These results are for the life assemblage communities. The death assemblage will be an average of those life assemblages over a few hundred to maybe thousand timesteps. How will a typical death assemblage compare to the metacommunity (zero is average) – will it be more similar to the metacommunity than any single life assemblage chosen at random, less similar, or about the same?
Given that result, how and why will time-averaging affect the observed similarity of species composition between death assemblages at different locations?

Part 3: Effects on species richness

The final step is to investigate how immigration probability and the duration of time-averaging affect recorded species richness in the death assemblage. The code runs the same simulation used in part 2, but additionally places the organisms into a death assemblage once they “die” in the local community. At the end, it calculates the ratio of species richness in the death assemblage to species richness in the life assemblage (both are estimated from 100 individuals). It does this many times and plots the results as a box-and-whisker plot, which shows the median (the middle value) with the thick line, the interquartile range (the range between 25% and 75% of the data) with the box, and the total range of data with the whiskers (some outliers are shown as isolated dots). The median is the important value and is reported as the average richness inflation at the top of the plot.

Answer these questions:

How does the duration of time-averaging affect inflation of richness in death assemblages? What mechanism causes this effect in the simulation?
How does the immigration probability affect inflation of richness? What mechanism is responsible? Hint: think back to the similarity results from part 2.


When you are done, reflect on your answers and write a short paragraph explaining how and why time-averaging affects species richness and similarity among fossil assemblages.


If you finish with those questions, you can consider these additional issues:

How would changes in sediment accumulation rate change the magnitude of diversity inflation between life and death assemblages? Explain why.
What other factors (related to the organisms themselves or the environment) could lead to inflation of species richness in death assemblages?

read in dataset

calculate total number of species and individuals at each site (live and dead)
calculate all pairwise similarity coefficients among all sites (live and dead)
calculate similarity coefficients for all live - dead pairs
calculate rank-order-correlation between live and dead at each site

pool sites within life and death assemblages


questions
Why does the death assemblage have more 
Which assemblages are  assemblages more similar to each other or are
What are the factors that go 

We don’t know over how many years the death assemblage accumulated, how might the
