################################################################################
# This script makes a heatmap to visualize severity of SARS-CoV-2 variants
#   indicated by several variant-tracking websites. Data  produced in script
#   combine_make_indicator.R.
# 
################################################################################

#############################
# Setup
#############################

#libraries for data processing and making graph
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(stringr)
library(cowplot)

#set date corresponding to data
#format=MMDDYY
#dataDate=as.character(format(Sys.Date(),format="%m%d%y"))
dataDate ='081821'

#read in data
#replace <output_data_filepath> with the location of summary data from combine_make_indicator.R
heat_df = read.csv(paste0("<output_data_filepath>/processed", dataDate, ".csv"))
heat_df = heat_df[, -1] #remove index column


#############################
# Data processing
#############################
    
#sort so the highest total AND highest average are at the top
sorted = heat_df%>%
  arrange(-lvl_avg, -num_sources)
#add index to sort by
sorted$index = 1:nrow(sorted)

#lengthen for both
#by site
heat_long = pivot_longer(data = sorted,
               cols = starts_with("Level"),
               names_to = "Website",
               values_to = "Level")
#convert Level to factor for graphing
heat_long = heat_long%>%
  mutate(lvl_fact = as.factor(Level))

#for sum
sum_long = pivot_longer(data = sorted,
                      cols = "lvl_sum",
                      names_to = "Total Threat",
                      values_to = "Level")
#convert Level to factor for graphing
sum_long = sum_long%>%
  mutate(lvl_fact = as.factor(Level))


#############################
# Make heat map pieces
#############################

#x-axis label (websites)
x_lab = "Source Website Name"

#y-axis label (variants)
y_lab = "Variant Name (Pango lineage)"

#legend
key_lab = "      Individual \n   Threat Level"

key_lvls = c("Variant under Monitoring = 1",
           "Variant of Interest = 2",
           "Variant of Concern = 3",
           "Not Specified = 0")

#website names (x-axis)
site_labs=c("Level_averge" = "Average Level",
         "Level_cdc" = "US CDC",
         "Level_who" = "WHO",
         "Level_oi" = "outbreak.info"
         )


#############################
# Make graphs
#############################

######
# by site
heat_graph = ggplot(heat_long, aes(Website, y=reorder(Variant,-index, na.rm = TRUE), fill= lvl_fact)) + 
  geom_tile(color = "white")+
  labs(x = x_lab,
       y = y_lab)+
  theme(panel.background =  element_blank(),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 12, hjust = 0),
        plot.caption.position = "plot")+
  scale_fill_brewer(palette = "Oranges", 
                    na.value = "grey",
                    labels = key_lvls,
                    name = key_lab)+
  scale_x_discrete(labels = site_labs)
  
heat_graph

###
# for sum

#use if we add numbers to heatmap
sum_labs = c("1" = "1",
            "2" = "2",
            "3" = "3",
            "4" = "4",
            "5" = "5",
            "6" = "6",
            "7" = "7",
            "8" = "8",
            "9" = "9")

sum_graph = ggplot(sum_long, aes("Total Threat", y=reorder(Variant, -index, na.rm = TRUE), fill= lvl_fact)) + 
  geom_tile(color = "white") +
  theme(panel.background = element_blank(),
        plot.title = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank())+
  scale_fill_brewer(palette = "Reds", 
                    na.value = "grey",
                    name = "    Total\nthreat level",
                    labels = sum_labs)+
  scale_x_discrete(labels = site_labs)+ 
  geom_text(aes(label = Level),size = 3, colour="#4D4D4D", show.legend = F)
sum_graph


#############################
# Combine into grid
#############################

###
# make grid pieces
#make big title for grid
#change format of date to include in title
title_dt = as.Date(dataDate,format = "%m%d%y")
title_dt = format(title_dt,"%B %d, %Y")

big_title = ggdraw() +
  draw_label(paste("SARS-Cov-2 Variant Threat Level by Website \n                     as of ", title_dt),
             fontface = "bold",
             x = 0,
             hjust = 0
  ) +
  theme(
    # add margin on the left of the drawing canvas,
    # so title is aligned with left edge of first plot
    plot.margin = margin(0, 170, 0, 200)
  )

#make caption
grid_capt = ggdraw() +
  draw_label("A. Variant threat levels as presented by each website. Higher threats correspond to larger numbers.\nB. This shows the sum of all reported threat levels in graph A (n=3).",
             x = 0,
             hjust = 0
  ) +
  theme(
    # add margin on the left of the drawing canvas,
    # so title is aligned with left edge of first plot
    plot.margin = margin(0, 0, 0, 7)
  )


#line up axes
aligned = align_plots(heat_graph,sum_graph, align = 'h', axis = 'l')
#combine into grid
grid = plot_grid(aligned[[1]], aligned[[2]], ncol = 2, rel_widths = c(1, 0.5), labels = c('A.', 'B.'))


#add title
gridWtitle= plot_grid(
  big_title, grid,
  ncol = 1,
  # rel_heights values control vertical title margins
  rel_heights = c(0.1, 1)
)

#add caption
addcapt = plot_grid(
  gridWtitle,grid_capt,
  ncol = 1,
  # rel_heights values control vertical title margins
  rel_heights = c(1, 0.08)
)
addcapt



#save graph
#double check dataDate corresponds to desired date
#replace <heatmap_filepath> with desired location to save heatmap
ggsave(plot = addcapt,file = paste0("<heatmap_filepath>/heatmap_", dataDate, "new_colors.png"), dpi=300)