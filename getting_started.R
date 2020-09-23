#### Clone Github Repo
# * Open a terminal (Tools > Terminal > New Terminal)
# * Enter: git clone https://github.com/PeakBI/ds-newstarter
# (You will need to have set up your github personal access token before doing this. If you haven't
# already done so then go to slide 12 on https://docs.google.com/presentation/d/1nnI47V0mOMCU3Qfrr4vW0j0J2vSywk3HoHEV_2Re62w/edit#slide=id.g7de3dd328b_0_257
# for instructions)
# * Open this R script
# * Set up a branch to work on - git checkout -b <your_name>

#### Read Data in from S3
# * Install S3R package: put your personal access token here
devtools::install_github('PeakBI/S3R', auth_token = '<personal_access_token>')

# * Go to S3:
#       - Open a new tab
#       - Click on the 9 dots near the top right hand corner
#       - Scroll down to Amazon Web Services and click
#       - Click on the buttom with your name/email address near the top right hand corner
#       - Switch role to peak-prod (more details on this at slide 14 https://docs.google.com/presentation/d/1nnI47V0mOMCU3Qfrr4vW0j0J2vSywk3HoHEV_2Re62w/edit#slide=id.g7de3dd328b_0_257)
# * Search S3 in Find Services (if you get access denied, there is a problem with your role)
# * Go into the kilimanjaro-prod-datalake bucket (easily found by searching "datalake")
# * Click on the newstarter folder
# * Look in the uploads folder
# * Load the data from airlines into R
library(S3R); library(odbc); library(readr)

flights <- S3R::s3.read_using(FUN = readr::read_csv,
                              bucket = 'kilimanjaro-prod-datalake',
                              object_path = 'newstarter/uploads/flights/1581525083144_Peak_flights.csv')

# * Load weather, planes, airlines, airports data into R as well. Clicking on the file and using 
# "Copy Path" can help with long paths.


#### Write data up to S3. 
# Data Scientists are only allowed to write into the datascience subfolder for each customer
# within S3. We can write to S3 in a really similar way to how we read from S3.
S3R::s3.write_using(flights, 
                    FUN = readr::write_csv,
                    bucket = 'kilimanjaro-prod-datalake',
                    object_path = 'newstarter/datascience/file_upload/flights.csv')

# Write weather, planes, airlines and airports data up to S3 as well.


# * Setup Redshift connection. Within workspaces, you can connect to Redshift using the
# odbc package. You can use the 'Connections' tab to the right.
# New connection > newstarter-prod < Ok or connect directly using the code below
con <- DBI::dbConnect(odbc::odbc(), "newstarter-prod", timeout = 10)

# After running the above, a connections tab will appear on the right of this screen. You can look
# at the different schemas and tables that already exist.

# * Copy data from S3 to Redshift
# S3 is used for short term data storage, but we often move data to Redshift if it is large
# (making it difficult to read in all at once) or if we plan to use it in production / on a
# long term basis. You can run the COPY command to move S3 files into Redshift.

# First create a table in redshift that you want to load into by sending a SQL query to the 
# redshift database. We will copy over some of the raw flights data into the schema 'stage'. 
# Create an empty table with the appropriate schema. You can find out about the types of the 
# columns in the dataframe by running str(<dataframe>)
DBI::dbSendQuery(con, "create table if not exists sandpit.flights (
                       year int,
                       month int,
                       day int,
                       dep_time int,
                       sched_dep_time int,
                       dep_delay int,
                       arr_time int,
                       sched_arr_time int,
                       arr_delay int,
                       carrier varchar,
                       flight int,
                       tailnum varchar,
                       origin varchar,
                       dest varchar,
                       air_time int,
                       distance int,
                       hour int,
                       minute int,
                       time_hour varchar
                 )")

# Use the redshift copy command to populate the table. More info on this command can be found at:
# https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html.

DBI::dbSendQuery(con, "copy sandpit.flights
                  from 's3://kilimanjaro-prod-datalake/newstarter/datascience/file_upload/flights.csv'
                  iam_role 'arn:aws:iam::794236216820:role/RedshiftS3Access'
                  delimiter ','
                  NULL as 'NA'
                  EMPTYASNULL
                  ignoreheader 1;")

# Copy the rest of the files over to redshift using the same method.


# * Query data from Redshift. You can query the database in Redshift. Now you have data in 
# redshift, you can query it using dbplyr which allows you to look at the data without loading
# it all into memory. First we load in the packages we'll need
library(dplyr); library(dbplyr); library(DBI)

flights_redshift <-
  con %>%
  tbl(in_schema('sandpit','flights'))

# Have a play around with the flights data which is stored locally and the flights_redshift data
# which is pulled from redshift. E.g.

monthly_distance <- 
  flights %>%
  group_by(year, month) %>%
  summarise(total_dist = sum(distance))

# We can have a look at this in an easier to read format by running

monthly_distance %>% View()

# If we try to do the same with flights_redshift it won't work as the data is still held in
# redshift. To view it, we need to use collect():

monthly_distance <-
  flights_redshift %>%
  group_by(year,month) %>%
  summarise(ttotal_dist = sum(distance)) %>%
  collect()

monthly_distance %>% View()

# Create a peak themed plot. When we generate plots for customers, we use the package peak-theme
# to make the plots look consistent with our branding on the website and elsewhere.
# If it's not already installed, install the peak-theme package from github. At the moment, we 
# are working off a branch called v2-brand-updates (you may need to check with Sorcha/Amy/Jason 
# if this is still the case). Remember to use collect() if you are trying to plot using flights_redshift
devtools::install_github('PeakBI/peak-theme', auth_token = '<personal_access_token>', ref = 'v2-brand-updates')

# Say we want to plot the distance travelled by each carrier
library(ggplot2); library(peaktheme)

flights %>%
  group_by(carrier) %>%
  summarise(dist=sum(distance)) %>%
  ggplot(aes(x = reorder(carrier,dist), y = dist)) +
  geom_col(fill = peaktheme:::peak_fa[1])+ 
  theme_peak() +
  coord_flip() +
  labs(x = 'Carrier', y = 'Distance travelled') +
  geom_text(aes(label = paste0(round(dist/10^3,1),'k')), family = 'nhaasgrotesk55rg', size = 3, hjust=-0.1)+
  scale_y_continuous(limits = c(0,100000000))

# save in downloads section of AIS
# We usually use a 