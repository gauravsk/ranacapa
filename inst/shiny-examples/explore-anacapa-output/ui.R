library(plotly)
library(shiny)
library(shinythemes)
shinyUI(bootstrapPage(theme = shinytheme("sandstone"),

  headerPanel("Exploring output from Anacapa pipeline"),
  sidebarPanel(

    ## conditionalPanel() functions for selected tab

    # For Panel 1, have an input option
    conditionalPanel(condition="input.tabselected==1",
                     radioButtons("mode", label = "Run with demo data or custom dataset?",
                                 choices = c("Demo", "Custom"), selected = "Demo"),
                     uiOutput("biomSelect"),
                     uiOutput("metaSelect")),

    # For panels 3, 4, 5, 6, ask user which varible they would like to visualize on
    conditionalPanel(condition="input.tabselected == 3 | input.tabselected == 4 |
                     input.tabselected == 5 | input.tabselected == 6",
                     uiOutput("which_variable_r")),

    # On panel 3 (rarefaction), ask what depth they want to rarefy to
    conditionalPanel(condition="input.tabselected == 3",
                     radioButtons("rare_method", "Choose whether you would like to pick a custom rarefaction depth,
                                  or whether samples should be rarefied to the minimum number of sequences in any single sample",
                                  choices = c("custom", "minimum", "none")),
                     uiOutput("rare_depth")),
     # On panel 3, also ask how many replicate rarefactions should be done
    conditionalPanel(condition="input.tabselected == 3", uiOutput("rare_reps")),

    # On panel 4 (alpha diversity), ask whether users want observed or Shannon div stats
    conditionalPanel(condition="input.tabselected == 4", uiOutput("which_divtype")),

    # On panel 4 (alpha diversity), ask whether users want x-axis labels rotated
    conditionalPanel(condition="input.tabselected == 4",
                     checkboxInput("rotate_x", label = "Select to rotate x-axis labels", value = F)),

    # On panel 5 (beta diersity),  ask whether users want to use NMDS or Bray disslimilarity
    conditionalPanel(condition="input.tabselected == 5 | input.tabselected == 6", uiOutput("which_dissim")),

    # On panels 7 and 8 (barplot and heatmap), ask which taxonomic level they want to visualize to
    conditionalPanel(condition="input.tabselected == 7 | input.tabselected == 8", uiOutput("which_taxon_level")),
    conditionalPanel(condition="input.tabselected == 7 | input.tabselected == 8",
                     radioButtons("rared_taxplots", "Choose whether you would like to view the taxonomy barplot and heatmap for the
                                  rarefied or unrarefied datasets",
                                  choices = c("unrarefied", "rarefied")))

  ),

  mainPanel(
    tabsetPanel(
      tabPanel("About", value=1,
               helpText("Select a biom table and a metadata file"),
               textOutput("fileStatus")),
      tabPanel("View OTU table", value=2,
               h3("Please verify your input biom table (unrarefied)"),
               dataTableOutput("print_biom")),
      tabPanel("Rarefaction curve", value = 3,
               h3("Background on rarefaction"),
               p("You might notice a great deal of variation in the number of sequences generated per sample-
                 this can happen for a variety of reasons- e.g. the sequencer may have worked less efficiently
                 on certain samples than others. This makes comparison between samples difficult- e.g. you might find more species
                 in one sample than another simply because it has been sequenced more deeply than others."),
               p("One approach in this scenario is to 'rarefy' your samples by subsampling a defined number of sequences
                 from each sample. You can choose a specific depth to rarefy to, or can choose to rarefy down to the minimum
                 number of reads sequenced in any single sample (e.g. if you have 50000 reads in the least well-sequenced
                 sample, all samples will be subsampled down to 50000 reads. Replicating this subsampling many times
                 allows us to have better estimates of the diversity in the rarefied samples."),
               p("We note that there has been considerable discussion regarding the best way of dealing with unequal sampling,
                 and we refer users to", a("Weiss et al. 2017, Microbiome",
                                           href ="https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-017-0237-y"), " and",
                 a("McMurdie & Holmes 2014, PLoS Comp. Biol", href = "http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003531"),
                 ", although we have not yet implemented alternative options in ranacapa."),
               h3("Unrarefied samples - taxon accumulation curve"),
               plotlyOutput("rarefaction_ur"),
               h3("Rarefied samples"),
               plotlyOutput("rarefaction_r")),


      tabPanel("Alpha Diversity", value = 4,
               h3("Background on alpha diversity"),
               p("In ecology, the term", a("alpha diversity", href = "https://en.wikipedia.org/wiki/Alpha_diversity"), "refers
                 simply to the diversity observed in a single sample. Although this may seem like a very simple concept,
                 it turns out that there's many ways to consider diversity. The most obvious metric, of course, is simply
                 to count the number of species found in a sample. This is the metric calculated with the 'Observed' option on the left."),
               p("Beyond this obvious choice of just counting up the number of species, there's a variety of related metrics
                 that can be used to calculate alpha diversity. Most of these metric address the following situation:"),
               p("Consider you are comparing two communities. The observed species richness is 3. But in the first community,
                 each species is represented by 100 individuals each; in the other, there are 290 individuals of Sp A, 9 of Sp B,
                 and just 1 of Sp C. Clearly, there is something different about the diversity of these two communities even though
                 they house the same number of species."),
               p("This is the type of diversity captured by a metric known as", a("Shannon diversity", href = "https://en.wikipedia.org/wiki/Diversity_index#Shannon_index"),
                 ". We present this option on the left, and encourage readers to explore the many other ways of measuring alpha
                 diversity at a varity of resources listed at the bottom of this page"),

               p("In addition to inspecting alpha diversity per sample, you also have the option to view the alpha diversity summarized
                 by one of the characteristics of the plots. You can choose the characteristic from the dropdown list on the left."),

               plotlyOutput("alpharichness"),
               br(), br(),
               h4("Alpha Diversity AOV"),
               tableOutput("alphaDivAOV"),
               br(),
               h4("Alpha Diversity Tukey Tests"),
               tableOutput("alphaDivTukey"),
               h3("More resources on alpha diversity"),
               p(a("Measurements of Biodiversity", href="http://www.marinespecies.org/introduced/wiki/Measurements_of_biodiversity"))),

      # beta Diversity panels - first, just plots
      tabPanel("Beta Diversity exploration", value = 5,
               h3("Background on Beta Diversity"),
               p("Alpha diversity lets us consider the diveristy within any given sample.
A second way to consider the diversity among samples is to consider how", strong("dissimilar"), "samples are from each other.
                 For example, two sites could hold ten species each- and it might be the same ten in both cases. A different pair of
                 sites might hold ten species each, but it may be a completely different list of ten between the two sites. Quantifying
                 differences between sites (i.e. low difference between the first pair of sites, which hold the same ten species; higher difference
                 between the second pair) is at the crux of",
                 a("Beta Diversity.",href = "https://methodsblog.wordpress.com/2015/05/27/beta_diversity/")),
               p("Although it may seem simple at first, the calculation of Beta Diversity is still quite an unresolved
topic in ecology- there's many ways for samples to be different from each other! Some of the many ways Beta diversity can be calculated are reviewed in the following
                 references: ", a("What is Beta Diversity?", href = "https://methodsblog.wordpress.com/2015/05/27/beta_diversity/"), "; ",
               a("Navigating the multiple meanings of Beta Diversity",
                 href = "https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1461-0248.2010.01552.x")),

               br(),

               p("Here we present one way of considering the beta diversity between plots "),

               br(),
               br(),
               h4("PCoA plot"),
               plotlyOutput("betanmdsplotly"),
               plotOutput("dissimMap")),

      # beta Diversity panels- second, just stats
      tabPanel("Beta Diversity stats", value = 6,
               h3("Adonis table"),
               tableOutput("adonisTable"),
               h4("Pairwise adonis"),
               verbatimTextOutput("pairwiseAdonis"),
               h3("Multivariate homogeneity of groups dispersions"),
               verbatimTextOutput("permTestTable"),
               h4("Multivariate homogeneity of groups dispersions - Post-hoc Tukey"),
               tableOutput("betaTukey")),
      tabPanel("Taxonomy Barplot", value = 7,
               plotlyOutput("tax_bar")),
      tabPanel("Taxonomy Heatmap", value = 8,
               plotlyOutput("tax_heat", height = "750px", width = "750px")),

      id = "tabselected"
    )
  )
))
