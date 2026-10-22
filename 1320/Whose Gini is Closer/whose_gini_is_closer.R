

############## LIBRARIES ##############
library(DescTools)
library(ggplot2)
library(gridExtra)


####### HELPER FUNCTIONS ##############

# Define a function to plot the Lorenz curve
plot_lorenz_curve <- function(x) {
  
  # Sort the data in ascending order
  sorted_x <- sort(x)
  
  # Calculate cumulative proportions
  cum_prop <- cumsum(sorted_x) / sum(sorted_x)
  
  # Create a data frame for plotting
  lorenz_data <- data.frame(
    Percentile = seq(0, 1, length.out = length(x)),
    CumulativeProportion = cum_prop
  )
  
  # Create the ggplot figure
  lorenz_plot <- ggplot(lorenz_data, aes(x = Percentile, y = CumulativeProportion)) +
    geom_line() +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    labs(
      x = "Cumulative Population",
      y = "Cumulative Income",
      title = "Lorenz Curve"
    )
  
  return(lorenz_plot)
}

# Function to create the ggplot barplot
plot_group_barplot <- function(x, target) {
  
  # Sort the input vector in decreasing order
  sorted_x <- sort(x, decreasing = FALSE)
  
  # Create a data frame for plotting
  df <- data.frame(
    Value = sorted_x,
    Rank = 1:length(sorted_x)
  )
  
  # Create the ggplot barplot
  p <- ggplot(df, aes(x = Rank, y = Value)) +
    geom_bar(stat = "identity") +
    labs(
      title = paste("Gini Coefficient:", round(Gini(x), 3)),
      subtitle = paste(" Penalty=", round(abs(Gini(x)-target),3), "   (Target: ",target,")", sep = ""),
      x = "Population",
      y = ""
    ) + theme(axis.text.x = element_blank(),
              axis.text.y= element_blank(),
              plot.subtitle = element_text(color = "red")
    )
  return(p)
}




#######################################
# Each group should allocate candy to #
# the 10 representative citizens to   #
# try and best approximate the income #
# distribution for the round!         #
#######################################

#%#%#%#%#%#%#%#%#%#%#%#%#%#%#
                            #
#TARGET GINI VALUE:         #
Target<-0.51                #
                            #
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#


#TEAM 1
x<-c(1,1,2,4,5,7,8,11,12,16)
grid.arrange(plot_lorenz_curve(x),plot_group_barplot(x,Target), nrow=1, top="Team 1")
print(abs(Gini(x)-Target))

#TEAM 2
x<-c(0,1,2,3,4,5,5,10,12,16)
grid.arrange(plot_lorenz_curve(x),plot_group_barplot(x,Target), nrow=1, top="Team 2")
print(abs(Gini(x)-Target))


#TEAM 3
x<-c(1,1,2,3,4,5,8,11,14,17)
grid.arrange(plot_lorenz_curve(x),plot_group_barplot(x,Target), nrow=1, top="Team 3")
print(abs(Gini(x)-Target))


#TEAM 4
x<-c(0,1,1,3,5,7,10,11,14,16)
grid.arrange(plot_lorenz_curve(x),plot_group_barplot(x,Target), nrow=1, top="Team 4")
print(abs(Gini(x)-Target))


#TEAM 5
x<-c(0,1,3,5,7,8,9,11,13,16)
grid.arrange(plot_lorenz_curve(x),plot_group_barplot(x,Target), nrow=1, top="Team 5")
print(abs(Gini(x)-Target))

