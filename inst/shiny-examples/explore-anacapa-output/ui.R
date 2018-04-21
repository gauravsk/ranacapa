library(plotly)
library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("Exploring output from Anacapa pipeline"),
  sidebarPanel(

    ## conditionalPanel() functions for selected tab
    conditionalPanel(condition="input.tabselected==1",
                     radioButtons("mode", label = "Run with demo data or custom dataset?",
                                 choices = c("Demo", "Custom"), selected = "Demo"),
                     uiOutput("biomSelect"),
                     uiOutput("metaSelect")),

    conditionalPanel(condition="input.tabselected == 3 | input.tabselected == 4 |
                     input.tabselected == 5 | input.tabselected == 6", uiOutput("which_variable_r")),
    conditionalPanel(condition="input.tabselected == 4", uiOutput("which_divtype")),
    conditionalPanel(condition="input.tabselected == 5 | input.tabselected == 6", uiOutput("which_dissim")),
    conditionalPanel(condition="input.tabselected == 3",
                     radioButtons("rare_method", "Choose whether you would like to pick a custom rarefaction depth,
                                  or whether samples should be rarefied to the minimum number of sequences in any single sample",
                                  choices = c("custom", "minimum")),
                     uiOutput("rare_depth")),
    conditionalPanel(condition="input.tabselected == 3", uiOutput("rare_reps")),
    conditionalPanel(condition="input.tabselected == 7 | input.tabselected == 8", uiOutput("which_taxon_level"))

  ),

  mainPanel(
    tabsetPanel(
      tabPanel("About", value=1, helpText("Select a biom table and a metadata file")),
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


      tabPanel("Alpha Diversity exploration", value = 4,
               h3("Explore the variation in alpha diversity among samples or across groups of samples"),
               p(),
               plotlyOutput("alpharichness"),
               tableOutput("alphaDivAOV"),
               tableOutput("alphaDivTukey")),
      tabPanel("Beta Diversity exploration", value = 5,
               plotlyOutput("betanmdsplotly")), # ,
               # plotOutput("dissimMap")),
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
