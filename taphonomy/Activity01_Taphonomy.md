# Activity 1—Constructing the Fossil Record: Living Communities, Dead Shells, and Time-Averaging

The fossil record allows us to reconstruct the biology of Earth’s ancient past. However, the fossil record does not perfectly record every aspect of living communities: some information is missing, while other biological aspets may be over-represented. Paleontologists often want to know what species were present and in what abundance at a particular location and during a specific interval of geological time. In many cases we are fortunate enough to have fossil samples to help us answer that question. However, properly interpreting fossil assemblages reqires knowing how the fossil record was constructed. This exercise will allow you to explore some aspects of how living communities become fossil assemblages.

As you learned in the online lectures, time-averaging is the mixing of individuals in a fossil or death assemblage that did not actually live at the same time. Time averaging  typically increases species richness (the number of species present) in a death assemblage relative to the corresponding life assemblage from that location. Time-averaging also makes death assemblages from different locations look more similar to each other than the life assemblages actually are.

This exercise will be based upon a ‘shiny app’, which is a dynamic website built using the statistical programming language R. For this exercise you will use the *Taphonomy* shiny app, which you will need to launch using R or RStudo by running the following two lines\*:

```` r
library(shiny)
runGitHub("shinypaleo", "naheim", subdir="taphonomy")

````

\* *If you don't have the shiny package already installed, you will first need to run:* ``install.packages("shiny")``*. You will only need to run this command once.*

Executing the above code in the R console or RStudio will open a browser window. The app web page has three tabs, which will correspond to Parts 1, 2, and 3 below.


## Part 1: Live-Dead Data

This tab displays what is typically called 'live-dead' data. They are called this because the data are composed of samples containing both living and dead individuals. Of course, the only species that accumulate dead individuals with any abunace are those with hard skeletons. For this exercise, we are focusing on bivalve (clam) and gastropod (snail) mollusks from coastal waters off of Southern California.

The data presented in the 'Live-Dead Data' tab were compiled by John Warme in the 1960s for his PhD dissertation. The samples were collected in Mugu Lagoon, which is a small back-barrier lagoon in Ventura County California (between Santa Barbara and Los Angeles). Warme collected 45 samples within Mugu lagoon (see map at bottom of app page). For each sample all of the living bivalve and gastropod species were identified and individuals counted. He also identified and counted all dead individuals (empty shells) from the same samples. There are two major environments withing Mugu Lagoon: subtidal eel grass beds and intertidal sand flats. 

The table at the top of the page (labeled 1) shows the numbers of sites containing living and dead individuals, the numbers of living and dead species at each size, and the total numbers of living and dead individuals sampled.

The first set of plots (labeled 2) compares the numbers of species and individuals in the living and death assemblages for each sample site. The dashed line on each plot is the 1-to-1 line: samples that fall exactly on this line have the same value in the living and death assemblage. Examine the two plots and make sure you understand what is being displayed. Note that both axes are shown on a log<sub>10</sub> scale. This means that each change of one unit on the axis represents a factor-of-ten change in the data. (e.g., the distane between 10 and 100 is the same as between 100 and 1000.) We ofetn plot data on a log-scale when the data span a large range in values and most are small.

_Answer the following questions_

1. Which environment do you think is more diverse?
2. Which taon do you think is more diverse?
3. In general, which assemblage, the living or death, has more species and individuals? Why do you think this is?
4. Is your answer above true for all samples? How do you know?
5. Based on the data presented in section 1 and 2 of the app, do you think the death assemblage is a good representation of the living assemblage? Why or why not?

So far you've explored how the number of individuals and species might differe between corresponding living and death assemblages. There are, however, other ways of comparing the biological diversity of two samples. One of those is called *similarity*. As the name suggests, similarity measures how similar or different two samples are and there are many different metrics we could use. Here we will look at two versions of the Jaccard similarity metric. The first version of the Jaccard similarity is simply the percentage of species that are shared between two samples. In our case, the two samples are the living and death assemblages from a site. 





Matthew's questions
Answer the following questions:

How does the variability in species composition differ between the low and high immigration probability simulations? Describe and compare (A) the magnitude of the changes away from zero and (B) the length of trends in community composition.
Why does immigration probability have this effect in the simulations? Hint: think about the implications of filling a vacancy from the infinitely-large metacommunity vs. the limited local community.
These results are for the life assemblage communities. The death assemblage will be an average of those life assemblages over a few hundred to maybe thousand timesteps. How will a typical death assemblage compare to the metacommunity (zero is average) – will it be more similar to the metacommunity than any single life assemblage chosen at random, less similar, or about the same?
Given that result, how and why will time-averaging affect the observed similarity of species composition between death assemblages at different locations?

Answer these questions:

How does the duration of time-averaging affect inflation of richness in death assemblages? What mechanism causes this effect in the simulation?
How does the immigration probability affect inflation of richness? What mechanism is responsible? Hint: think back to the similarity results from part 2.


When you are done, reflect on your answers and write a short paragraph explaining how and why time-averaging affects species richness and similarity among fossil assemblages.


If you finish with those questions, you can consider these additional issues:

How would changes in sediment accumulation rate change the magnitude of diversity inflation between life and death assemblages? Explain why.
What other factors (related to the organisms themselves or the environment) could lead to inflation of species richness in death assemblages?


