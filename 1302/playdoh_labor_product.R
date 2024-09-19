
library(DescTools)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggplot2)
#######################################
# Each group will produce play-doh dice over a 1 minute period.
# Each round, the group will add more labor to the production process 
#######################################

labor<-c(2,3,4,5)
group1<-c(3,5,6,7)
group2<-c(1,5,7,11)
group3<-c(3,6,8,12)
group4<-c(3,10,7,9)

output<-data.frame(labor,group1, group2, group3, group4)

output %>%
  pivot_longer(., group1:group4, names_to="group", values_to = "output") %>%
  ggplot()+
  geom_line(aes(x=labor, y=output, group=group, color=group))
