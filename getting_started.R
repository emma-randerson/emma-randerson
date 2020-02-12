#### Clone Github Repo
# 1. Open a terminal (Tools > Terminal > New Terminal)
# 2. Enter: git clone https://github.com/PeakBI/ds-newstarter
# (You will need to have set up your github personal access token before doing this. If you haven't
# already done so then go to slide 12 on https://docs.google.com/presentation/d/1nnI47V0mOMCU3Qfrr4vW0j0J2vSywk3HoHEV_2Re62w/edit#slide=id.g7de3dd328b_0_257
# for instructions)
# 3. Open this R script
# 4. Set up a branch to work on - git checkout -b <your_name>

#### Read Data in from S3
# 1. Install S3R package: put your personal access token here
devtools::install_github('PeakBI/S3R', auth_token = '<personal_access_token>')

# 2. Go to S3:
#       i. Open a new tab
#       ii. Click on the 9 dots near the top right hand corner
#       iii. Scroll down to Amazon Web Services and click
#       iv. Click on the buttom with your name/email address near the top right hand corner
#       v. Switch role to peak-prod (more details on this at slide 14 https://docs.google.com/presentation/d/1nnI47V0mOMCU3Qfrr4vW0j0J2vSywk3HoHEV_2Re62w/edit#slide=id.g7de3dd328b_0_257)
# 3. Search S3 in Find Services (if you get access denied, there is a problem with your role)
# 4. Go into the kilimanjaro-prod-datalake bucket (easily found by searching "datalake")
# 5. Click on the newstarter folder
# 6. Look in the uploads folder
# 7. Load the data from airlines into R
airlines <- S3R::s3.read_using(FUN = read.csv, bucket = 'kilimanjaro-prod-datalake', object_path = 'newstarter/uploads/airlines/1581525103214_Peak_airlines.csv')

# 8. Load weather, planes, flights, airports data into R as well. Clicking on the file and using 
# "Copy Path" can help with long paths.

# copy data from S3 to Redshift

# setup redshift connection

# query data from redshift

# create a peak themed plot

# write to S3

# write to redshift

# save in downloads section of AIS