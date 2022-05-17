#this script is written to combine webscraping data for SARS-CoV-2 variants
# (variant lineage names + VOI/VOC/VUM status) exported as .csv by associated
# scraping scripts and create a summary variable 

library(dplyr)
library(modeest)
library(purrr)

#format=MMDDYY
dataDate = as.character(format(Sys.Date(), format="%m%d%y"))

#read in data
#replace <data_filepath> with the location of your data
#cdc scraping data
cdc = read.csv(paste0("<data_filepath>/cdc_all", dataDate, ".csv"))

#who scraping data
who = read.csv(paste0("<data_filepath>/who_all", dataDate, ".csv"))

#outbreak.info scraping data
oi = read.csv(paste0("<data_filepath>/outbreak_all", dataDate, ".csv"))

#make function to clean data columns
fix_cols = function(df){
  df = df%>%
    select(-c("X"))%>%
    rename("Variant"="X0",
           "Level"="X1")
}

#fix columns
cdc = fix_cols(cdc)
who = fix_cols(who)
oi = fix_cols(oi)


#join into one dataframe
#new data sources would just be added to list
# ex list(cdc, who, oi, bb)
all = lst(cdc, who, oi) %>%
  imap(function(cdc, who) cdc %>% 
    rename_with(~paste(., who, sep = '_'), -Variant)) %>%
  reduce(full_join, by = 'Variant')


#make indicators for sources
#tot_sources=total number of sources in df
#nmiss=number of missing designations (counts how many times variant NOT mentioned)
#num_sources= number of times mentioned (will be denom for avg)
sources = all%>%
  mutate(tot_sources = ncol(all[,-1]),
         nmiss=apply(all[,-1], MARGIN = 1, function(x) sum(is.na(x))),
         num_sources=tot_sources-nmiss
         )

#calculate threat level indicators
#convert to integers: VOC=3, VOI=2, VFM=1, missing=0
#if variants of high concern identified (CDC level), add as level 4
level_df = all%>%
  mutate_at(
    vars(starts_with("Level")),
    list(~case_when(. == "VOC"~3,
                   . == "VOI"~2,
                   . == "VFM"~1,
                   TRUE~NA_real_)))
#get summary statistics

#apply across rows excluding variant name
level_df2 = level_df%>%
  mutate(lvl_sum = apply(level_df[, -1], MARGIN = 1, function(x) sum(x, na.rm=T)))
#use these to get average threat level
#denom from sources = num_sources (num non-missing sites)
level_df3 = level_df2%>%
  mutate(lvl_avg = round(lvl_sum/sources$num_sources, digits = 2))


#make final dataset
#summary stats from level_df3 plus number of nonmissing sources

final_vars = level_df3%>%
    mutate(num_sources = sources$num_sources)

#save as .csv
#note this name includes date - for automation update with paste0()+today's date
#replace <output_data_filepath> with desired location of output data
write.csv(final_vars, file = paste0("<output_data_filepath>/processed", dataDate, ".csv"))