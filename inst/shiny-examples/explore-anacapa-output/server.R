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

  # RenderUIs for Panel 1
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

  # RenderUI for which_variable_r, gets used in Panels 3,4,5,6
  output$which_variable_r <- renderUI({
    selectInput("var", "Select the variable", choices = heads())
  })

  # RenderUI for which_divtype, for Alpha Diversity Panel 4
  output$which_divtype <- renderUI({
    radioButtons("divtype", label = "Observed or Shannon diversity?",
                 choices = c("Observed", "Shannon"))
  })

  # RenderUI for which_dissim, used for Beta Diversity Panel 5,6
  output$which_dissim <- renderUI({
    radioButtons("dissimMethod", "Which type of distance metric would you like?",
                 choices = c("bray", "jaccard"))
  })

  # RenderUI for which_taxon_level, used for barplot and heatmap in Panels 7,8
  output$which_taxon_level <- renderUI({
    radioButtons("taxon_level", "Pick the taxonomic level for making the plot",
                 choices = c("Phylum", "Class", "Order", "Family", "Genus", "Species"))

  })

  # Render UIs for Panel 3 (Rarefaction)
  output$rare_depth <- renderUI({
    if(input$rare_method == "custom"){
      sliderInput("rarefaction_depth", label = "Select a depth of rarefaction", min = 2000, max = 100000, step = 1000,
                  value = 2000)} else if (input$rare_method == "minimum") {
                    radioButtons("rarefaction_depth", label = "The minimum number of reads in any single plot will be selected:",
                                 choices = anacapa_output() %>% select_if(is.numeric) %>% colSums() %>% min())
                  } else {}
  })
  output$rare_reps <- renderUI({
    if(!(input$rare_method == "none")){
        sliderInput("rarefaction_reps", label = "Select the number of times to rarefy", min = 2, max = 20, value = 2)
    } else {

      }
  })

  ########################################################
  # Read in data files, validate and make the physeq object --------
  ########################################################
  anacapa_output <- reactive({
    if(input$mode == "Custom") {
      read.table(input$in_biom$datapath, header = 1,
                 sep = "\t", stringsAsFactors = F) %>%
        scrub_seqNum_column() %>%
        group_anacapa_by_taxonomy()
    } else {
      readRDS("data/demo_biomdata.Rds") %>%
        scrub_seqNum_column() %>%
        group_anacapa_by_taxonomy()
    }
  })

  mapping_file <- reactive({
    if(input$mode == "Custom") {
      read.table(input$in_metadata$datapath, header = 1, sep = "\t", stringsAsFactors = F)
    } else {
      readRDS("data/demo_metadata.Rds")
    }
  })


  output$fileStatus <- renderText({
    validate_input_files(anacapa_output(), mapping_file())
  })
  # Make physeq object ----
  physeq <- reactive({
    convert_anacapa_to_phyloseq(ana_taxon_table = anacapa_output(), metadata_file = mapping_file())
  })

  # Make the object heads, that has the column names in the metadata file
  heads <- reactive({
    base::colnames(mapping_file())
  })

  # Panel 2:  Print OTU table ---------

  output$print_biom <- renderDataTable({
    anacapa_output() %>% select(sum.taxonomy, everything())
  })



  # Panel 3: Rarefaction and associated plots ----------
  # Check if all samples have a non-NA value for the selected variable to plot by
  # If a sample has an NA for the selected variable, get rid of it from the
  # sample data and from the metadata and from the taxon table (the subset function does both)
  data_subset_unrare <- reactive({
    p2 <- physeq()
    sample_data(p2) <- physeq() %>% sample_data %>% subset(., !is.na(get(input$var)))
    p2
  })

  # rarefy the subsetted dataset
  data_subset <- reactive({
    if(!(input$rare_method == "none")){

    custom_rarefaction(data_subset_unrare(),
                       sample_size = input$rarefaction_depth,
                       replicates = input$rarefaction_reps)
    } else {
      data_subset_unrare()
    }
  })

  # Rarefaction curve before and after rarefaction
  output$rarefaction_ur <- renderPlotly({
    p <- ggrare(data_subset_unrare(), step = 1000, se=FALSE, color = input$var)
    q <- p + theme_ranacapa() + theme(axis.title = element_blank())
    gp <- ggplotly(tooltip = c("Sample", input$var)) %>%
      layout(yaxis = list(title = "Species Richness", titlefont = list(size = 16)), xaxis = list(title = "Sequence Sample Size", titlefont = list(size = 16)), margin = list(l = 100, b = 60))
    gp
  })

  output$rarefaction_r <- renderPlotly({
    p <- ggrare(data_subset(), step = 1000, se=FALSE, color = input$var)
    q <- p +  facet_wrap(as.formula(paste("~", input$var))) +
      theme_ranacapa() + theme(axis.text.x = element_text(angle = 45))
    gp <- ggplotly(tooltip = c("Sample", input$var))
    gp[['x']][['layout']][['annotations']][[2]][['x']] <- -0.07  # adjust y axis title (actually an annotation)
    gp[['x']][['layout']][['annotations']][[1]][['y']] <- -0.15  # adjust x axis title (actually an annotation)
    # this doesn't work right now, but still need to figure out how to not cut off legend title
    # gp[['x']][['layout']][['annotations']][[3]][['x']] <- 0.23  # adjust legend title (actually an annotation)
    gp %>% layout(margin = list(l = 70, b = 100, r = 20))
  })



  # Panel 4: Alpha diversity ------------
  # Alpha diversity boxplots
  output$alpharichness <- renderPlotly({
    color <- "black"; shape <- "circle"
    colorvecname = "color"; shapevecname = "shape"
    p <- plot_richness(data_subset(), x = input$var,  measures= input$divtype, color = colorvecname, shape = shapevecname)

    if(!input$rotate_x){
      q <- p + geom_boxplot(aes_string(fill = input$var, alpha=0.2, show.legend = F)) +
        theme_ranacapa() + theme(legend.position = "none") + theme(axis.title = element_blank())
      gp <- ggplotly(tooltip = c("x", "value")) %>%
        layout(yaxis = list(title = paste(input$divtype, "Diversity"), titlefont = list(size = 16)),
               xaxis = list(title = input$var, titlefont = list(size = 16)),
               margin = list(l = 60, b = 60))
    } else {

      q <- p + geom_boxplot(aes_string(fill = input$var, alpha=0.2, show.legend = F)) +
        theme_ranacapa() + theme(legend.position = "none") + theme(axis.title = element_blank()) +
        theme(axis.text.x = element_text(angle = 45))
      gp <- ggplotly(tooltip = c("x", "value")) %>%
        layout(yaxis = list(title = paste(input$divtype, "Diversity"), titlefont = list(size = 16)),
               xaxis = list(title = input$var, titlefont = list(size = 16)),
               margin = list(l = 60, b = 70))
    }

  })


  # Alpha diversity aov generation
  physeq.alpha.anova <- reactive({
    alpha.diversity <- estimate_richness(data_subset(), measures = c("Observed", "Shannon"))
    data <- cbind(sample_data(data_subset()), alpha.diversity)
    aov(as.formula(paste(input$divtype, "~" , input$var)), data)
  })

  # Alpha diversity AOV print
  output$alphaDivAOV <- renderTable({
    broom::tidy(physeq.alpha.anova())
  }, digits = 4)

  # Alpha Diversity tukey
  output$alphaDivTukey <- renderTable({
    broom::tidy(TukeyHSD(physeq.alpha.anova()))
  }, digits = 4)

  # Panel 5: Beta Diversity exploration plots ------------
  # NMDS plotly
  output$betanmdsplotly <- renderPlotly({
    d <- distance(data_subset(), method=input$dissimMethod)
    ord <- ordinate(data_subset(), method = "MDS", distance = d)
    nmdsplot <- plot_ordination(data_subset(), ord, input$var, color = input$var) +
      # stat_ellipse(type = "t", geom = "polygon", alpha = 0.2) +
      ggtitle(paste(input$var, "NMDS; dissimilarity method:",
                    tools::toTitleCase(input$dissimMethod))) +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme_ranacapa()
    ggplotly(tooltip = c(input$var, "x", "y")) %>% layout(hovermode = 'closest')
  })



  # Other beta diversity plot
  output$dissimMap <- renderPlot({
    d <- distance(data_subset(), method=input$dissimMethod)

    # Ward linkage map
    wcluster <- as.dendrogram(hclust(d, method = "ward.D2"))
    envtype <- get_variable(data_subset(), input$var)
    tipColor <- col_factor(rainbow(10), levels = levels(envtype))(envtype)
    wl <- ggdendro::ggdendrogram(wcluster, theme_dendro = FALSE, color = "red")  +
      theme_bw(base_size = 18) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
    # Plot it
    wl

  }, height = 2000, width = 1000 )

  # Panel 6: Beta diversity statistics ----------
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
    pairwise_adonis(veganComm,getElement(sdf, input$var),
                    sim_method = input$dissimMethod)
  })



  # Panel 7: Taxonomy-by-site interactive barplot -------
  output$tax_bar <- renderPlotly({

    ## NOTE!
    # Think more about whether we should use physeq() or data_subset_unrare() here
    if(input$rared_taxplots == "unrarefied"){
      plot_bar(physeq(), fill = input$taxon_level) + theme_ranacapa() +
        theme(axis.text.x = element_text(angle = 45)) + theme(axis.title = element_blank())
      gp <- ggplotly() %>%
        layout(yaxis = list(title = "Abundance", titlefont = list(size = 16)),
               xaxis = list(title = "Sample", titlefont = list(size = 16)),
               margin = list(l = 70, b = 100))
      gp
    } else{
      plot_bar(data_subset(), fill = input$taxon_level) + theme_ranacapa() +
        theme(axis.text.x = element_text(angle = 45)) + theme(axis.title = element_blank())
      gp <- ggplotly() %>% layout(yaxis = list(title = "Abundance"), xaxis = list(title = "Sample"),
                   margin = list(l = 100, b = 100))
      gp
    }
  })

  ## Panel 8: Heatmap of taxonomy by site ---------
  output$tax_heat <- renderPlotly({

    if(input$rared_taxplots == "unrarefied"){
      biom <- anacapa_output() %>% mutate(sum.taxonomy = as.character(sum.taxonomy)) %>%
        mutate(sum.taxonomy = ifelse(sum.taxonomy == "", "NA;NA;NA;NA;NA;NA", sum.taxonomy))

      for_hm <- cbind(biom, colsplit(biom$sum.taxonomy, ";",
                                     names = c("Phylum", "Class", "Order", "Family", "Genus", "Species")))
    } else {
      biom <- data.frame(otu_table(data_subset()))

      for_hm <- cbind(biom, colsplit(rownames(biom), ";",
                                     names = c("Phylum", "Class", "Order", "Family", "Genus", "Species")))
    }

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
    heatmaply(for_hm, Rowv = F, Colv = F, hide_colorbar = F, grid_gap = 1, na.value = "white")

  })


})
