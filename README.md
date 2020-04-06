# COVID-19-SouthDakota
## Provides historical testing/case counts by date for COVID-19 (coronavirus) from the South Dakota Department of Public Health and updates data automatically

### About this Program:

This program was developed in response to the COVID-19 global pandemic.  The South Dakota (USA) Department of
Public Health Publishes updated COVID-19 around noon.  However, the agency does not publish a historical record 
of testing and case counts by date.  Without this historical data, it's impossible to develop predictive statistical 
models, make forecastst of disease spread, or develop longitudinal statistical analyses. This
program has loaded all historical data from the South Dakota Deaprtment of Public Health using the search results from the
Internet archive service "Wayback Machine - Internet Archive" (www.archive.org) and then updates this at 7 pm daily by 
scraping data from the South Dakota Department of Public Health's website.  After reading this data, data is updated and stored 
in both RDS and CSV formats.

### Frequency of Update & Uses:

This program will execute twice daily at 7pm EDT and output files will be updated accordingly.
Users may use this program directly or simply use the output data that has been compiled so long as attribution is made as
follows:  
> Lamias, Mark J., The Stochastic Group, Inc. 2020.  COVID-19 Historical Data for South Dakota.

### Features:

This program uses Hadley Wickham's rvest package to navigate to and "screen scrape" web data from the South Dakota Department of
Public Health's (SDDPH) website.  In addition, since much of the demographic data provided by the SDDPH is 
in images of graphics (i.e. pie charts of the percentage of certain populations to be classified as COVID-19 positive cases),
this program uses the tesseract package to virtually "scan" the image, and then to use optical character recognition (OCR)
to extract the relevant text containing the statistical figures.

### Inputs/Global Variables Set by User:
* **DATA_DIRECTORY**:  A valid R pathname to the directory where this program and the existing data reside
* **COVID_19_SOUTH_DAKOTA_DATA.Rds**:  The R RDS file that contains the most recent South Dakota COVID-19 data
* **COVID_19_SOUTH_DAKOTA_COUNTIES_DATA**:  The R RDS file that contains the most recent South Dakota COVID-19 data by county
* **URL**:  The Uniform Resource Locator to the South Dakota Department of Public Health's COVID-19 daily report page

### Outputs:
This program outputs 4 files:
1. An Updated COVID_19_SOUTH_DAKOTA_DATA RDS file;
1. An Updated COVID_19_SOUTH_DAKOTA_DATA CSV file;
1. An Updated COVID_19_SOUTH_DAKOTA_COUNTIES_DATA RDS file;
1. An Updated COVID_19_SOUTH_DAKOTA_COUNTIES_DATA CSV file;
All output is sent to the DATA_DIRECTORY and files are overwritten.

Note that the COVID_19_SOUTH_DAKOTA_COUNTIES_DATA data files may be joined to the COVID_19_SOUTH_DAKOTA_DATA data file on Instance ID to obtain additional details associated with each county case counts.

The CSV files are comma separated values datasets.  They can be opened in any text editor or in MS Excel.  The RDS files such as COVID_19_SOUTH_DAKOTA_DATA.Rds can be read into R using synatx such as:
> readRDS(file = "COVID_19_SOUTH_DAKOTA_DATA.Rds")

Assuming the COVID_19_SOUTH_DAKOTA_DATA.Rds is in the R working directory.  Otherwise, you can specify the full path to the file in the file argument of the readRDS function.


### Dataset Variables
#### COVID_19_SD_COUNTIES_DATA

| Variable Name  | Variable Description |
| ------------- | ------------- |
| instance_id   | The report instance.  Each separate report from SDDPH corresponds to a unique (but not necessarily sequential) Instance ID.  |
| report_datetime  | The date and time that appears at the top of each SDDPH report.  Currently reports are produced twice at day at noon and 7 pm.  |
| test_result_positive   | The number of confirmed COVID-19 positive cases.  |
| test_result_negative   | The number of negative COVID-19 cases of those tested.  |
| test_result_pending    | The number of pending COVID-19 results of those tested.  |
| cases_number_of_cases  | The number of COVID-19 cases of those tested.  |
| cases_ever_hospitalized   | The number of confirmed COVID-19 hospitalizations.  |
| cases_deaths   | The number of confirmed COVID-19 related deaths.  |
| cases_recovered   | The number of recovered COVID-19 cases of those previously testing positive.  |
| age_0_to_19_years | 	The number (not percentage) of those 0-19 years testing positive for COVID-19.
| age_20_to_29_years | 	The number (not percentage) of those 20-29 years testing positive for COVID-19.
| age_30_to_39_years | 	The number (not percentage) of those 30-39 years testing positive for COVID-19.
| age_40_to_49_years | 	The number (not percentage) of those 40-49 years testing positive for COVID-19.
| age_50_to_59_years | 	The number (not percentage) of those 50-59 years testing positive for COVID-19.
| age_60_to_69_years | 	The number (not percentage) of those 60-69 years testing positive for COVID-19.
| age_70_to_79_years | 	The number (not percentage) of those 70-79 years testing positive for COVID-19.
| age_80+_years	 | The number (not percentage) of those 80+ years testing positive for COVID-19.
| gender_male	 | The number (not percentage) of males testing positive for COVID-19.
| gender_female	 | The number (not percentage) of females testing positive for COVID-19.


#### COVID_19_SOUTH_DAKOTA_COUNTIES_DATA

| Variable Name  | Variable Description |
| ------------- | ------------- |
| instance_id   | The report instance.  Each separate report from SDDPH corresponds to a unique (but not necessarily sequential) Instance ID.  |
| county  | County Name |
| total_positive_cases | The number of COVID-19 positive cases in the given South Dakota county.  |
| no_recovered | The number of recovereds of those having previously tested positive for COVID-19 in the given South Dakota county.  |


#### MISCELLANEOUS NOTES

