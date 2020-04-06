###################################################################################################################################
#Program Copyright, 2020, Mark J. Lamias, The Stochastic Group, Inc.
#Version 1.0 - Initial Update
#Version 2.0 - Modified code to account for site changes implemented by GDPH on 3/28/2020 (evening) which 
#              included new table of death by age, county, gender, and presence of underlying medical condition.
#Version 2.1 - Made efficiency improvements and improved code to accomodate minor changes to GDPH daily report
#Version 2.2 - Added code to save copy of GDPH website to local drive.
#Version 2.3 - Changed 1st comparison operator in get_demographic_stats to %in% from == to account for typos on
#              GDPH's website.
#Last Updated:  03/31/2020 04:08 AM EDT
#
#Terms of Service
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
#
#BACKGROUND NOTE:  This program was created after the GDPH COVID-19 report format change was implemented on 
#March 27, 2020.  Previous to this change, the script Update_covid_figures_from_gdph.R was used.  
#
#About this Program:  This program was developed in response to the COVID-19 global pandemic.  The SD (USA) Department of
#Public Health Publishes updated COVID-19 testing and case counts twice daily at noon and 7 pm Eastern time.  However, the
#agtency does not publish a historical record of testing and case counts by date.  Without this historical data, it's impossible
#to develop predictive statistical models, make forecastst of disease spread, or develop longitudinal statistical analyses. This
#program has loaded all historical data from the SD Deaprtment of Public Health using the search results from the
#Internet archive service "Wayback Machine - Internet Archive" (www.archive.org) and then updates this data twice a day
#(for the noon and 7 pm figures) by scraping data from the SD Department of Public Health's website.  After reading this
#data, data is updated and stored in both RDS and CSV formats.
#
#Frequency of Update & Uses:
#This program will execute twice daily at 1 pm and 8 pm EDT and output files will be updated accordingly.
#Users may use this program directly or simply use the output data that has been compiled so long as attribution is made as
#follows:  Lamias, Mark J., The Stochastic Group, Inc. 2020.  COVID-19 Historical Data for SD.
#
#Inputs/Global Variables Set by User:
#DATA_DIRECTORY:  A valid R pathname to the directory where this program and the existing data reside
#COVID_19_SD_DATA.Rds:  The R RDS file that contains the most recent GA COVID-19 data
#COVID_19_SD_COUNTIES_DATA:  The R RDS file that contains the most recent GA COVID-19 data by county
#URL:  The Uniform Resource Locator to the SD Department of Public Health's COVID-19 daily report page
#
#Outputs:
#This program outputs 4 files:
#(1) An Updated COVID_19_SD_DATA RDS file;
#(2) An Updated COVID_19_SD_DATA CSV file;
#(3) An Updated COVID_19_SD_COUNTIES_DATA RDS file;
#(4) An Updated COVID_19_SD_COUNTIES_DATA CSV file;
#All output is sent to the DATA_DIRECTORY and files are overwritten.

###################################################################################################################################

library(rvest)
library(httr)
library(tidyverse)
library(stringr)
library(readxl)
library(git2r)

#Set data directory
DATA_DIRECTORY <- "D:/Code/Github/COVID-19-SouthDakota"

#COVID_19_SD_DATA <- read.csv(file = paste0(DATA_DIRECTORY, "/COVID_19_SD_DATA.csv"), stringsAsFactors = FALSE)
#COVID_19_SD_COUNTIES_DATA <- read.csv(file = paste0(DATA_DIRECTORY, "/COVID_19_SD_COUNTIES_DATA.csv"), stringsAsFactors = FALSE)

#Import historical GDPH COVID-19 Data and Import historical GDPH COVID-19 Data for counties
COVID_19_SD_DATA <- readRDS(file = paste0(DATA_DIRECTORY, "/COVID_19_SD_DATA.Rds"))
COVID_19_SD_COUNTIES_DATA <- readRDS(file = paste0(DATA_DIRECTORY, "/COVID_19_SD_COUNTIES_DATA.Rds"))


#Create a report instance ID to differentiate reports from one another
#new_instance_id <- get0("COVID_19_SD_DATA", max(COVID_19_SD_DATA$Instance_ID), ifnotfound = 0) + 1
new_instance_id <- max(COVID_19_SD_DATA$instance_id)+1



#Connect to SDDPH website and read web page
URL <- "https://doh.sd.gov/news/coronavirus.aspx"
session <- html_session(URL)
html <- read_html(session)

#Download & Save A Copy of GDPH Website
save_url_name<-paste0("D:\\covid\\covid_SouthDakota_", str_replace_all(as.character(Sys.time()), ":", "_"), ".html")
download.file(URL, save_url_name, quiet = FALSE, mode = "w", cacheOK = FALSE)

#Get report date and time from page header
report_date_parts <-
  html %>% html_nodes(xpath = '//*[@id="content_block"]/p[5]/text()[2]') %>% simplify() %>% as.character() %>% 
  strsplit(split = "Last updated: ", fixed=TRUE) %>%
  simplify() %>% 
  magrittr::extract(-1) %>% 
  strsplit(split = "; ")  %>% simplify() 

#Create datetime variable from date and time parts
report_date <- report_date_parts[2] %>% as.Date(format = "%B %d, %Y")
report_time <- report_date_parts[1] %>% str_replace_all("\\.", "") %>% toupper()
report_datetime_str <- paste(report_date, report_time)
report_datetime <-
  strptime(report_datetime_str, "%Y-%m-%d %I:%M %p")

#Read in first and second table which define test/case counts by lab type
testing_table <-
  html %>%  html_nodes(xpath = '//*[@id="content_block"]/div[2]/div[1]/table')  %>%  
  simplify() %>%  
  pluck(1) %>% 
  html_table(header=TRUE) %>% 
  magrittr::extract(-4,) 
testing_table[,1] %>%   str_replace_all("\\*", "")->testing_table[,1]
paste0("test_result_", testing_table[,1])->testing_table[,1]

cases_table <-
  html %>%  html_nodes(xpath = '//*[@id="content_block"]/div[2]/div[2]/table') %>%  
  simplify() %>%  
  pluck(1) %>% 
  html_table(header=FALSE) %>% 
  magrittr::extract(-5,)
cases_table[,1] %>%   str_replace_all("\\*", "")->cases_table[,1]
names(cases_table)<-c("Description", "Count")
paste0("cases_", cases_table[,1])->cases_table[,1]

counties <-
  html %>%  html_nodes(xpath = '//*[@id="content_block"]/div[3]/div[1]/table') %>%  
  simplify() %>%  
  pluck(1) %>% 
  html_table(header=TRUE)

age_name_vec <-
  html %>%  html_nodes(xpath = '//*[@id="content_block"]/div[3]/div[2]/table[1]') %>%  
  simplify() %>%  
  pluck(1) %>% 
  html_table(header=TRUE)
paste("age", age_name_vec[,1])->age_name_vec[,1]


gender_name_vec <-
  html %>%  html_nodes(xpath = '//*[@id="content_block"]/div[3]/div[2]/table[2]') %>%  
  simplify() %>%  
  pluck(1) %>% 
  html_table(header=TRUE)
paste("gender", gender_name_vec[,1])->gender_name_vec[,1]

#Store total cases and total deaths
#total_cases <- cases_table[cases_table$Description=="Number of Cases",]
#total_hospitalized <- cases_table[cases_table$Description=="Ever Hospitalized",]
#total_deaths <- cases_table[cases_table$Description=="Deaths",]
#total_recovered <- cases_table[cases_table$Description=="Recovered",]

#Create update record from newly imported statistics referencing the instance ID obtained above
SD_data<-data.frame(cbind(instance_id=new_instance_id, report_datetime=report_datetime_str, t(testing_table), t(cases_table), t(age_name_vec), t(gender_name_vec)))
names(SD_data)<-names(COVID_19_SD_DATA)

#SD_data[1,] %>% str_replace_all(" ", "_") %>% tolower() ->SD_data_varnames




#names(counties) %>% str_replace_all(" ", "_") %>% str_replace_all("#", "No") %>% tolower() ->names(counties)
#SD_data_varnames[1:2]<-c("instance_id", "report_datetime")




COVID_19_SD_DATA


#Convert factors to strings

SD_data[]<-lapply(SD_data, as.character)
row.names(SD_data) <- NULL

counties<-data.frame(instance_id=new_instance_id, counties)



COVID_19_SD_DATA_CURRENT <-
  rbind(if(exists("COVID_19_SD_DATA")) COVID_19_SD_DATA, SD_data)
str(COVID_19_SD_DATA)
str(SD_data)
    
COVID_19_SD_COUNTIES_DATA_CURRENT <-
  rbind(if(exists("COVID_19_SD_COUNTIES_DATA")) COVID_19_SD_COUNTIES_DATA, counties)



#Save updated data.
saveRDS(
  COVID_19_SD_DATA_CURRENT,
  file = paste0(DATA_DIRECTORY, "/COVID_19_SD_DATA.Rds")
)

saveRDS(
  COVID_19_SD_COUNTIES_DATA_CURRENT,
  file = paste0(DATA_DIRECTORY, "/COVID_19_SD_COUNTIES_DATA.Rds")
)

#Save updated data in alternative CSV format
write.csv(
  COVID_19_SD_DATA_CURRENT,
  file = paste0(DATA_DIRECTORY, "/COVID_19_SD_DATA.csv"),
  row.names = FALSE
)
write.csv(
  COVID_19_SD_COUNTIES_DATA_CURRENT,
  file = paste0(DATA_DIRECTORY, "/COVID_19_SD_COUNTIES_DATA.csv"),
  row.names = FALSE
)


#Upload revised data to public github repository
source(paste0(DATA_DIRECTORY, "/Commit_to_public_github_repo.R"))
git_upload(DATA_DIRECTORY, paste0("Update for ", report_datetime))
