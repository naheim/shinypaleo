# Activity 1—Constructing the Fossil Record: Living Communities, Dead Shells, and Time-Averaging

The fossil record allows us to reconstruct life of Earth’s ancient past. However, the fossil is not a perfect biological archive: some information is missing, while other biological aspects may be over-represented. Nevertheless, the aspiring paleontologist should not be daunted. We actually know quite a lot about how living organisms become fossils--this subfield of paleontology is called **_taphonomy_**. With an understanding of taphonomy, paleontologists can properly interpret the biology of fossil assemblages.

This exercise will have you to explore some aspects of how living communities become fossil assemblages. One of the questions paleontologist want to know is what species were present and in what abundance at a particular location and during a specific interval of geological time. You will learn some basic taphonomic principles here to allow you to answer one of these most basic of paleontological questions.

As you learned in the online lectures, time-averaging is the mixing of individuals in a fossil or death assemblage that did not actually live at the same time. Time averaging  typically increases species richness (the number of species present) in a death assemblage relative to the corresponding life assemblage from that location. Time-averaging also makes death assemblages from different locations look more similar to each other than the life assemblages actually are.

This exercise will be based upon a ‘shiny app’, which is a dynamic website built using the statistical programming language [R](http://r-project.org). For this exercise you will use the *Taphonomy* shiny app, which you will need to launch using R or RStudio by running the following two lines\*:

```` r
library(shiny)
runGitHub("shinypaleo", "naheim", subdir="taphonomy")

````

\* *If you don't have the shiny package already installed, you will first need to run:* ``install.packages("shiny")``*. You will only need to run this command once.*

Executing the above code in the R console or RStudio will open a browser window. The app web page has three tabs, which will correspond to Parts 1, 2, and 3 below.


## Part 1: Live-Dead Data

This tab displays what is typically called 'live-dead' data. They are called this because they are composed of samples containing both living and dead individuals. Of course, the only species that accumulate dead individuals with any abundance are those with hard skeletons. For this exercise, we are focusing on bivalve and gastropod mollusks (clams & snails, respectively) from coastal waters of Southern California.

The data presented in the 'Live-Dead Data' tab were compiled by John Warme in the 1960s for his PhD dissertation. The samples were collected in Mugu Lagoon, which is a small back-barrier lagoon in Ventura County California (between Santa Barbara and Los Angeles). Warme collected 45 samples within Mugu lagoon (see map at bottom of app page). For each sample all of the living bivalve and gastropod species were identified and individuals counted. He also identified and counted all dead individuals (empty shells) from the same samples. There are two major environments within Mugu Lagoon: subtidal eel grass beds and intertidal sand flats. 

The table at the top of the page (labeled 1) shows the numbers of sites containing living and dead individuals, the numbers of living and dead species at each site, and the total numbers of living and dead individuals sampled.

The first set of plots (labeled 2) compares the numbers of species and individuals in the living and death assemblages for each site. Examine the two plots, read the caption, and make sure you understand what is being displayed. 

_Answer the following questions_

1. Which environment do has more species? More individuals?
2. Which taxon has more species? More individuals?
3. Which assemblage, the living or death, tends to have more species? More individuals? Why do you think this is?
4. Is your answer above true for all samples? How do you know?
5. Based on the data presented in section 1 and 2, do you think the death assemblage is a good representation of the living assemblage? Why or why not?

So far you've explored how the number of individuals and species might differ between corresponding living and death assemblages. There are, however, other ways of comparing the biological diversity of two samples. A common one is called *similarity*. As the name suggests, similarity measures how similar or different two samples are, and there are several different metrics we could use. Here we will use the Chao-Jaccard similarity index. This index has the advantages of using abundance data (instead of just the presence or absence of species) and being relatively insensitive to differences in sample size. The mathematics behind the index are not important now, we will come back to them later. Chao-Jaccard similarity varies between zero and one, where zero means the two samples are totally different and a value of 1 means they are identical. 

The table in section 3 shows similarity between the pooled living and death assemblages. Pooled means we've combined the 45 individual living samples into a single assemblage (while maintaining the living and death components, of course). The plot in section 4, is a frequency distribution, or histograms, for the live-dead Jaccard similarities of individual sites. The height of each bar sows the number sites with live-dead similarity corresponding to the range of values indicated on the x-axis.

Section 5 allows you to see the raw data and live-dead similarities for individual pairs of sites. Explore the with select 

_Answer the following questions_

6. When comparing the living samples to the dead samples, do bivalves or gastropods show more similarity?
7. Which environment tends to have higher live-dead similarity? 

Finally, section 6 shows the Chao-Jaccard similarity for all pairs of living samples (left) and all pairs dead samples (right).

_Answer the following questions_

8. Are living assemblages of bivalves or gastropods more similar to each other?
9. Thinking about the whole ecosystem, what does is mean for the live-live similarity to be high or low?
10. Is there more similarity among samples in the living assemblage or among samples in the death assemblage? Why do you think this is?

## Part 2: Time-Averaging Data

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


