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

    conditionalPanel(condition="input.tabselected == 3 | input.tabselected == 4 | input.tabselected == 5 | input.tabselected == 6", uiOutput("which_variable_r")),
    conditionalPanel(condition="input.tabselected == 4", uiOutput("which_divtype")),
    conditionalPanel(condition="input.tabselected == 5 | input.tabselected == 6", uiOutput("which_dissim")),
    conditionalPanel(condition="input.tabselected == 3", uiOutput("rare_depth")),
    conditionalPanel(condition="input.tabselected == 3", uiOutput("rare_reps")),
    conditionalPanel(condition="input.tabselected == 7 | input.tabselected == 8", uiOutput("which_taxon_level"))

  ),

  mainPanel(
    tabsetPanel(
      tabPanel("About", value=1, helpText("Select a biom table and a metadata file")),
      tabPanel("View OTU table", value=2, helpText("Here's the OTU table (taxon name not displayed)"), dataTableOutput("print_biom")),
      tabPanel("Rarefaction curve", value = 3,
               plotlyOutput("rarefaction_ur"),
               plotlyOutput("rarefaction_r")),
      tabPanel("Alpha Diversity exploration", value = 4, plotlyOutput("alpharichness"),
               tableOutput("alphaDivAOV"), tableOutput("alphaDivTukey")),
      tabPanel("Beta Diversity exploration", value = 5, plotlyOutput("betanmdsplotly"), plotOutput("dissimMap")),
      tabPanel("Beta Diversity stats", value = 6,
               h3("Adonis table"),
               tableOutput("adonisTable"),
               h4("Pairwise adonis"),
               verbatimTextOutput("pairwiseAdonis"),
               h3("Multivariate homogeneity of groups dispersions"),
               verbatimTextOutput("permTestTable"),
               h4("Multivariate homogeneity of groups dispersions - Post-hoc Tukey"),
               tableOutput("betaTukey")),
      tabPanel("Taxonomy Barplot", value = 7, plotlyOutput("tax_bar")),
      tabPanel("Taxonomy Heatmap", value = 8, plotlyOutput("tax_heat", height = "750px", width = "750px")),


      id = "tabselected"
    )
  )
))
