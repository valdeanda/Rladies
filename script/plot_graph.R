#Name:     plot_graph.R
#Purpose:  Visualize a NetAn network 
#@uthor:  Valerie de Anda -vdeanda@ciencias.unam.mx - valdeanda@utexas.edu
#Created:    September  2017
#Modified: August 12, 2020 
#Modified by: Ian Rambo - ian.rambo@utexas.edu - shrimpngrits44@gmail.com

#install.packages("visNetwork")
#devtools::install_github("datastorm-open/visNetwork") #for development version

library(visNetwork)
library(tidyverse)
library(RColorBrewer)

create.network <- function(n, e, tmain, tsub, select_by, h = "700px", w = "100%") { 
  ### Visualize a network using visNetwork
  visNetwork(n, e, height = h, width = w,
             main = tmain,
             submain = tsub) %>%
    visEdges(arrows="to") %>%
    visOptions(selectedBy = select_by, 
               highlightNearest = TRUE, 
               nodesIdSelection = TRUE,
               manipulation = TRUE) %>%
    visPhysics(stabilization = FALSE) %>%
    visConfigure(enabled = TRUE) }

id.color.shape.df <- function(idv, idv_name) {
  ### Dataframe of shapes and qualitative palette colors
  ### This vector can be used in a dplyr::left_join()
  ### The shapes and colors are used in VisNetwork
  
  node_shapes = c("square", "triangle", "box",
                  "dot", "star", "ellipse", "diamond")

  qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
  
  qual_col_vec = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
  
  node_col_shape = data.frame(qual_col_vec, rep(node_shapes, length.out = length(qual_col_vec)))
  colnames(node_col_shape) = c("color", "shape")
  
  idv = unique(idv)
  incs = data.frame(idv,
                    node_col_shape$color[1:length(idv)],
                    node_col_shape$shape[1:length(idv)])
  
  colnames(incs) = c(idv_name, "color", "shape")
  
  return(incs)
}
#=============================================================================
#Tu directorio 
#Directory with node and edge files

data_dir <- "../data/"
#Output directory
output_dir <- "~/data/"

#Necesitas cambiar los nombres de los archivos
nodes <- read.table(file.path(data_dir, "nodes2addColors.tab"), sep = "\t", header = TRUE)
edges <- read.table(file.path(data_dir, "edges2addTax.tab"), header = TRUE, sep="\t")

edges$color <- vector(mode = "character", length = nrow(edges))

#Añadir colores  
edges$color[which(edges$Strength > 0)] <- "#FF7F00"
edges$color[which(edges$Strength < 0)] <- "#386CB0"

#Dataframe que agrega difrentes formas y colores a columna de datos unicos 
tax_col_shape <- id.color.shape.df(nodes$Domain, "Domain")

nodes_colshape <- nodes %>% left_join(tax_col_shape)

create.network(nodes_colshape, edges,
              tmain = "Red de interaccion con VisNetwork", tsub = "RLadies Workshop",
              select_by = "Phylum")%>%
visEdges(arrows="to")%>%
  visOptions(selectedBy = "Domain", 
             highlightNearest = TRUE, 
             nodesIdSelection = TRUE,
             manipulation=TRUE) %>%
  visPhysics(stabilization =FALSE)%>%
  visConfigure(enabled=TRUE)


#vis_network <- create.network(nodes_colshape, edges,
#                              tmain = "Only 0.05% of the total interactions", tsub = "Mi red chido",
#                              select_by = "Phylum")
#network_name <- paste("visNetwork_", Sys.Date(), ".html", sep = '')
#network_html <- file.path(output_dir, network_name)

#visSave(vis_network, file = network_html)

