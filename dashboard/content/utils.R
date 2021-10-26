warning('Have you updated the packages.R file with the above packages?')



## Globals
## Get the username from the shinyproxy environment
Sys.setenv(TZ = "Europe/London")






## Set up logger
if(log_app_useractivity){
  logger <- peakshinytemplate::Logger$new(con = con,
                                          log_level = 'DEBUG',
                                          log_table_name = paste0(log_table_name, '_log'),
                                          flag = flag,
                                          session_id = TRUE)

  logger$log(log_level = 'INFO',
             object = 'USER',
             action = 'LOGGED_IN',
             description = 'User has logged in',
             meta=as.character(username),
             status = 'SUCCESS')
}




configure_body_tags <- function() {
  tags$head(

    # Peak Theme / skin:
    # Pulls from remotely hosted theme
    # Deployed App will automatically update when Engineering updates the theme
    # tags$link(rel = "stylesheet", type = "text/css",
    #           href = "https://shinytheme.dev.peak.ai/dashboard/dist/css/AdminLTE.min.css"),
    # tags$link(rel = "stylesheet", type = "text/css",
    #           href = "https://shinytheme.dev.peak.ai/dashboard/dist/css/skins/_all-skins.min.css"),
    # tags$link(rel = "stylesheet", type = "text/css",
    #           href = "https://shinytheme.dev.peak.ai/assets/css/bootstrap.min.css")

    # Use static css file for now
    tags$link(rel = "stylesheet", type = "text/css", href = "_all-skins.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "AdminLTE.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.min.css"),


    tags$style(HTML('.box { font-family: montserrat; } ')),
    tags$style(type = "text/css", HTML("th { text-align: center; }")),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/qtip2/3.0.3/jquery.qtip.js"),

    HTML(
      "
					<script>
					var socket_timeout_interval
					var n = 0
					$(document).on('shiny:connected', function(event) {
					socket_timeout_interval = setInterval(function(){
					Shiny.onInputChange('count', n++)
					}, 15000)
					});
					$(document).on('shiny:disconnected', function(event) {
					clearInterval(socket_timeout_interval)
					});
					</script>
					"
    )
  )
}

# textWrapColNames <- function(colNames){
#
#   colNames = gsub(x = colNames, pattern = '_', replacement = ' ')
#   colNames = gsub(pattern = "(\\\w)([A-Z])", replacement = "\\\1 \\\2", colNames)
#   colNames = gsub('(.{1,12})(\\\s|$)', '\\\1\n', colNames)
#
#   return(colNames)
#
# }



