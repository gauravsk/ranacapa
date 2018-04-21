library(shiny)
library(ggplot2)
library(reshape2)
library(vegan)
library(dplyr)
library(phyloseq)
library(gridBase)
library(broom)
library(gridExtra)
library(plotly)
library(tibble)
library(ranacapa)
library(scales)
library(heatmaply)

options(digits = 5, shiny.maxRequestSize=10*1024^2)

server <- function(input, output)({

  # Read in data files and make the physeq object

  anacapa_output <- reactive({
    if(input$mode == "Custom") {
      read.table(input$in_biom$datapath, header = 1, sep = "\t", stringsAsFactors = F)
    } else {
      readRDS("data/demo_biomdata.Rds")
    }
  })

  mapping_file <- reactive({
    if(input$mode == "Custom") {
      read.table(input$in_metadata$datapath, header = 1, sep = "\t", stringsAsFactors = F)
    } else {
      readRDS("data/demo_metadata.Rds")
    }
  })
  # Make physeq object ----------
  physeq <- reactive({
    convert_anacapa_to_phyloseq(ana_out = anacapa_output(), mapping_file = mapping_file())
  })

  heads <- reactive({
    base::colnames(mapping_file())
  })

  # BiomTable to print ---------
  output$print_biom <- renderDataTable({
    anacapa_output() %>% select(sum.taxonomy, everything())
  })

  # UI inputs ------
  output$biomSelect <- renderUI({
    req(input$mode)
    if(input$mode == "Custom"){
      fileInput("in_biom", "Select biom table")
    }
  })
  output$metaSelect <- renderUI({
    req(input$mode)
    if(input$mode == "Custom"){
      fileInput("in_metadata", "Select metadata")
    }
  })

  output$which_variable_r <- renderUI({
    selectInput("var", "Select the variable", choices = heads())
  })

  output$which_divtype <- renderUI({
    radioButtons("divtype", label = "Observed or Shannon diversity?",
                 choices = c("Observed", "Shannon"))
  })
  output$which_dissim <- renderUI({
    radioButtons("dissimMethod", "Which type of distance metric would you like?",
                 choices = c("bray", "jaccard"))
  })
  output$which_taxon_level <- renderUI({
    radioButtons("taxon_level", "Pick the taxonomic level for making the plot",
                 choices = c("Phylum", "Class", "Order", "Family", "Genus", "Species"))

  })
  output$rare_depth <- renderUI({
    if (input$rare_method == "custom") {
      sliderInput("rarefaction_depth", label = "Select a depth of rarefaction", min = 2000, max = 100000, step = 1000,
                  value = 2000)
    } else {
      radioButtons("rarefaction_depth", label = "Rarefy all samples to the minimum number of seqs in any single sample",
                   choices = c(colSums(anacapa_output() %>% select_if(is.numeric)) %>% min))
    }
  })

  output$rare_reps <- renderUI({
    sliderInput("rarefaction_reps", label = "Select the number of times to rarefy", min = 2, max = 20, value = 2)
  })

  # Time to make some graphs -----------
  output$tax_bar <- renderPlotly({
    plot_bar(physeq(), fill = input$taxon_level)
    ggplotly()
  })

  data_subset_unrare <- reactive({
    p2 <- physeq()
    sample_data(p2) <- physeq() %>% sample_data %>% subset(., !is.na(get(input$var)))
    p2
  })

  data_subset <- reactive({
    custom_rarefaction(data_subset_unrare(), sample_size = input$rarefaction_depth, replicates = input$rarefaction_reps)
  })

  # Rarefaction curve before and after rarefaction -----------
  output$rarefaction_ur <- renderPlotly({
    p <- ggrare(data_subset_unrare(), step = 1000, se=FALSE, color = input$var)
    q <- p + # facet_wrap(as.formula(paste("~", input$var))) +
      theme_bw() + theme_ranacapa()
    ggplotly(q)
  })

  output$rarefaction_r <- renderPlotly({
    p <- ggrare(data_subset(), step = 1000, se=FALSE, color = input$var)
    q <- p + # facet_wrap(as.formula(paste("~", input$var))) +
      theme_bw() + theme_ranacapa()
    ggplotly(tooltip = c("Sample", input$var))
  })

  # Alpha diverstity boxplots ----------
  output$alpharichness <- renderPlotly({
    p <- plot_richness(data_subset(), x = input$var,  measures= input$divtype)
    q <- p + geom_boxplot(aes_string(fill = input$var, alpha=0.2, show.legend = F)) + theme_bw() +
      xlab(paste(input$divtype, "Diversity")) +
      theme(panel.grid.minor.y = element_blank(), panel.grid.minor.x = element_blank(),
            panel.grid.major.y = element_blank(), panel.grid.major.x = element_blank())
    ggplotly(tooltip = c("x", "value"))
  })

  # Alpha diversity aov generation
  physeq.alpha.anova <- reactive({
    alpha.diversity <- estimate_richness(data_subset(), measures = c("Observed", "Shannon"))
    data <- cbind(sample_data(data_subset()), alpha.diversity)
    aov(as.formula(paste(input$divtype, "~" , input$var)), data)
  })

  # Alpha diversity AOV print --------
  output$alphaDivAOV <- renderTable({
    broom::tidy(physeq.alpha.anova())
  }, digits = 4)

  # Alpha Diversity tukey --------
  output$alphaDivTukey <- renderTable({
    broom::tidy(TukeyHSD(physeq.alpha.anova()))
  }, digits = 4)

  # NMDS plotly -----------
  output$betanmdsplotly <- renderPlotly({
    d <- distance(data_subset(), method=input$dissimMethod)
    ord <- ordinate(data_subset(), method = "MDS", distance = d)
    nmdsplot <- plot_ordination(data_subset(), ord, input$var, color = input$var) +
      theme_bw() +  # stat_ellipse(type = "t", geom = "polygon", alpha = 0.2) +
      ggtitle(paste(input$var, "NMDS; dissimilarity method:",
                    tools::toTitleCase(input$dissimMethod))) + theme(plot.title = element_text(hjust = 0.5)) +
      theme_ranacapa()
    ggplotly(tooltip = c(input$var, "x", "y")) %>% layout(hovermode = 'closest')
  })



  # Other beta diversity plots --------
  output$dissimMap <- renderPlot({
    d <- distance(data_subset(), method=input$dissimMethod)

    # Network map ---------
    ig <- make_network(data_subset(),
                       distance=function(x){vegan::vegdist(x, input$dissimMethod)}, max.dist=0.9)

    igp <-  plot_network(ig, data_subset(), color=input$var, line_weight=0.9, label=NULL) +
      theme_bw(base_size = 18)

    # Ward linkage map --------
    wcluster <- as.dendrogram(hclust(d, method = "ward.D2"))
    envtype <- get_variable(data_subset(), input$var)
    tipColor <- col_factor(rainbow(10), levels = levels(envtype))(envtype)
    wl <- ggdendro::ggdendrogram(wcluster, theme_dendro = FALSE, color = "red")  +
      theme_bw(base_size = 18) + theme(axis.text.x = element_text(angle = 45, hjust = 1))

    # Big old heat map -----------
    heat <- ggplot(data = melt(as.matrix(d)), aes(x=Var1, y=Var2, fill=value)) +
      geom_tile() + theme_bw(base_size = 18) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))


    # Plot them all out ------
    gridExtra::grid.arrange(igp, wl, heat, ncol = 1, heights = c(3,3,3,4))


  }, height = 2000, width = 1000 )

  output$adonisTable <- renderTable ({
    sampledf <- data.frame(sample_data(data_subset()))
    dist_obj <- phyloseq::distance(data_subset(), method = input$dissimMethod)
    broom::tidy(adonis(as.formula(paste("dist_obj~", input$var)), data = sampledf)$aov.tab)

  }, digits = 5)

  output$permTestTable <- renderPrint({
    sdf <- as(sample_data(data_subset()), "data.frame")
    dist_obj <- phyloseq::distance(data_subset(), method = input$dissimMethod)
    betadisper(dist_obj, getElement(sdf, input$var))
  })

  output$betaTukey <- renderTable({
    sdf <- as(sample_data(data_subset()), "data.frame")
    dist_obj <- phyloseq::distance(data_subset(), method = input$dissimMethod)
    broom::tidy(TukeyHSD(betadisper(dist_obj, getElement(sdf, input$var))))
  }, digits = 5)

  output$pairwiseAdonis <- renderPrint({
    sdf <- as(sample_data(data_subset()), "data.frame")
    veganComm <- vegan_otu(data_subset())
    pairwise.adonis(veganComm,getElement(sdf, input$var),sim.method = 'jaccard')
  })



  ## Heatmap of taxonomy by site ---------
  output$tax_heat <- renderPlotly({
    biom <- anacapa_output() %>% mutate(sum.taxonomy = as.character(sum.taxonomy)) %>%
      mutate(sum.taxonomy = ifelse(sum.taxonomy == "", "NA;NA;NA;NA;NA;NA", sum.taxonomy))

    for_hm <- cbind(biom, colsplit(anacapa_output()$sum.taxonomy, ";",
                                               names = c("Phylum", "Class", "Order", "Family", "Genus", "Species")))
    for_hm <- for_hm %>%
      mutate(Phylum = ifelse(is.na(Phylum) | Phylum == "", "unknown", Phylum)) %>%
      mutate(Class = ifelse(is.na(Class) | Class == "", "unknown", Class)) %>%
      mutate(Order = ifelse(is.na(Order) | Order == "", "unknown", Order)) %>%
      mutate(Family = ifelse(is.na(Family) | Family == "", "unknown", Family)) %>%
      mutate(Genus = ifelse(is.na(Genus) | Genus == "", "unknown", Genus)) %>%
      mutate(Species = ifelse(is.na(Species)| Species == "", "unknown", Species))

    for_hm <- for_hm %>% group_by(get(input$taxon_level)) %>% summarize_if(is.numeric, sum) %>%
      data.frame %>% column_to_rownames("get.input.taxon_level.")
    for_hm[for_hm == 0] <- NA

    heatmaply(for_hm, Rowv = F, Colv = F, hide_colorbar = T, grid_gap = 1, na.value = "white")
  })


})
