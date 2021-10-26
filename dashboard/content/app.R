
# ------------------------------------------------------------------------
## Using a single paged dashboard with sidebar

# example: https://github.com/PeakBI/ds-fagroup-merchandising-dashboard/blob/master/dashboard/content/app.R

## Variables to be set:
# dir_name: The directory name the dashbaord folder sits within
#           ie would be "test_shiny" for "/home/kirstyparsons/test_shiny/dashboard/content"
# con:      The Redshift connection

# ------------------------------------------------------------------------


library(shiny)
library(aws.s3)
library(aws.ec2metadata)
library(aws.signature)
library(dplyr)
library(DBI)
library(odbc)
library(ggplot2)
library(shiny)
library(shinydashboard)

###########
# Globals #
###########

session_id     <<- gsub("-| |:", "", as.character(Sys.time()))
username       <<- Sys.getenv("SHINYPROXY_USERNAME")
dir_name       <<- '/ds-newstarter/'                          ## The directory name the dashbaord folder sits within ie would be "test_shiny" for "/home/kirstyparsons/test_shiny/dashboard/content"
con            <<- DBI::dbConnect(odbc::odbc(),
                                  "newstarter-prod",     ## Fill in the database name to connect to redshift
                                  bigint = "integer")
log_app_useractivity <<- FALSE                          ## Log user activity?
if(log_app_useractivity){
  log_table_name <<- dir_name                           ## Name of the table to log all user activity to
  flag           <<- 'BETA'
  # flag           <<- 'PROD'
}




###########
# Source #
###########

if (username != "") {
  root = '/root/content/'
} else {
  root = paste0('~/', dir_name, '/dashboard/content/')
}

## Source all dependent scripts here:
source(paste0(root, 'utils.R'))
## source(paste0(root, '....'.R))



####################################
#           User Interface        #
####################################

################
# Dashboard UI #
################

## Fill in the dashboard title
header <- dashboardHeader(title = "Emma Randerson Test Dashboard")


############
#   Body   #
############

body <- dashboardBody(
  configure_body_tags(),

  # Main body of the page
  # Page layout and UI items go here

  ## Fill in the body
  # use fluidRow() to create a new row
  # use column(width, ..., ), to create a new column
  fluidRow(
    column(8, plotOutput("firstPlot")),
    column(4, h2('first row, second column'))
  ),
  h2('Second row')
)

ui <- dashboardPage(header, sidebar = dashboardSidebar(disable = TRUE), body)






####################################
#         Dashboard Server         #
####################################


server <- function(input, output, session) {

  ## Fill in the server
  # reactiveValues() creates variables which are reactive / update when changed
  # Use observeEvent() to run code when the use changes an input
  # Use output$... to display in the UI
  # Use input$... to call UI elements named in the dashboardSidebar() or dashboardBody()
  # Use render..({}) to create plots and tables

  output$firstPlot <- renderPlot({
    mtcars %>%
      ggplot() +
      geom_point(aes(carb, hp))
  })

}

####################################
#           Launch App             #
####################################

shinyApp(ui, server)
