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
               includeMarkdown("docs/rarefaction-overview.md"),
               h3("Unrarefied samples - taxon accumulation curve"),
               plotlyOutput("rarefaction_ur"),
               h3("Rarefied samples"),
               plotlyOutput("rarefaction_r")),

      tabPanel("Alpha Diversity", value = 4,
               includeMarkdown("docs/alpha-div-overview.md"),
               plotlyOutput("alpharichness"),
               h4("Alpha Diversity AOV"),
               tableOutput("alphaDivAOV"),
               br(),
               h4("Alpha Diversity Tukey Tests"),
               tableOutput("alphaDivTukey"),
               h3("More resources on alpha diversity"),
               p(a("Measurements of Biodiversity", href="http://www.marinespecies.org/introduced/wiki/Measurements_of_biodiversity"))),

      # beta Diversity panels - first, just plots
      tabPanel("Beta Diversity exploration", value = 5,
               includeMarkdown("docs/beta-div-overview.md"),
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
