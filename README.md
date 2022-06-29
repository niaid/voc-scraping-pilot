**Web scraping pilot study for SARS-CoV-2 variants of concern dashboards** <br>
Lisa M. Mayer, MPH<sup>1</sup>, Wiriya Rutvisuttinunt, PhD<sup>2</sup>, Steve Tsang, PhD<sup>1</sup>, Jane Lockmuller, MS<sup>1</sup>, Liliana Brown, PhD<sup>2</sup> <br>

Affiliations
1.	Office of Data Science and Emerging Technologies, Office of Science Management and Operations, National Institute of Allergy and Infectious Diseases (NIAID), National Institutes of Health (NIH), Rockville, MD, USA
2.	Office of Genomic and Advanced Technologies, Division of Microbiology and Infectious Diseases, National Institute of Allergy and Infectious Diseases (NIAID), National Institutes of Health (NIH), Rockville, MD, USA

Federal Lead: Dr. Wiriya Rutvisuttinunt (wiriya.rutvisuttinunt@nih.gov) <br>
Released: May 13, 2022 <br>
Version: 1.0 <br>
License: public <br>

<br>

This is a repository to complement the poster presentation "Web scraping pilot study for SARS-CoV-2 variants of concern dashboards" given by Lisa M. Mayer at ISMB 2022. It contains scripts from the study period July 1 through September 9, 2021, which are not still maintained and may not work as originally intended. These could be updated or modified for future similar use.

<br>
<br>

**Background**
<p>As SARS-CoV-2 circulates, it accumulates mutations that sometimes affect virus behavior and thus human health. These can go on to form genetically distinct groups, called variants or lineages. Organizations throughout the world track these variants using systems that assess the threats each poses and how this changes over time. They publish these assessments online or in other formats, generating data that other sites share directly or use for additional analyses.</p>
<p>This variation in classification and reporting systems makes it challenging to uncover the "true" threat level of any variant. A proposed mechanism to address this is twofold: 1) evaluating aspects of these websites to ensure they are reliable sources and 2) collating and summarizing findings across multiple websites to learn about threat levels. This repo contains setup information and scripts for a small-scale project addressing part 2 of that mechanism.</p>

**Overview**
<p> This writeup focuses on the second part of this project pertaining to tracking and summarizing data across multiple websites. It will follow the process from prerequisite software requirements through Jupyter notebook Python scripts for collecting information from websites, R scripts for collating those data, and finally R scripts for summarizing data as a graphic. The goal is that these can be downloaded and used as-is, but web scraping scripts will need to be updated as websites change.</p>


![workflow](/scraping_wf.jpg)
*Image 1: workflow for web scraping data collection through visualization*


**Software Requirements**
- Python interpreter - recommend [Anaconda](https://www.anaconda.com/products/individual) which will include Jupyter notebooks  
- R interpreter - recommend [R Studio](https://www.rstudio.com/products/rstudio/download/)  
- [Selenium webdriver](https://selenium-python.readthedocs.io/getting-started.html) that matches your web browser
- Administrator access (required for webdriver)

**Overall Walkthrough**
1. Install required software.
2. Download scripts.
3. Collect variant threat level data with [web scraping scripts](https://github.niaid.nih.gov/mayerlm/variant-trackers/tree/master/scraping_scripts).  
    * Each website has its own script and outputs its own .csv with variant threat levels.
    * Open each script using Jupyter notebooks and execute code one chunk at a time. Scripts include instructions and comments for each step. 
    * Because code depends on website structure and often changes, validate output against website each time it's collected.
    * Modify code as needed to ensure accuracy.
4. Open [R script](https://github.niaid.nih.gov/mayerlm/variant-trackers/blob/master/combine_make_indicator.R) to harmonize data and make summary variables.
    * Input: separate .csv data from web scraping
    * Output: combined .csv with summary and indicator variables
    * Execute each line according to commented instructions.
    * As long as scraping output retains the same structure, this code will not need modification.
    * Harmonized data produced by this script makes sense to human readers and is the input for visualization step.
5. Open [R script](https://github.niaid.nih.gov/mayerlm/variant-trackers/blob/master/make_heatmap.R) to generate heatmap visualizing data.
    * Input: harmonized data .csv from previous step
    * Output: heatmap graphic of website findings and summary statistics
    * Execute each line according to commented instructions.    
    * As long as input retains the same structure, this code will not need modification.
