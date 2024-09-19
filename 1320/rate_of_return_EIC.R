

library(ggplot2)
library(dplyr)
library(tidyr)

data<-data.frame(Time=0:10)
data<-data %>%
  mutate(
    `1. Gov. Bonds`=100*(1.04)^Time,
    `2. Real Estate`=100*(1.05)^Time,
    `3. S&P 500`=100*(1.1)^Time,
    `4. EIC`=100*(1.35)^Time
  ) %>% 
  pivot_longer(`1. Gov. Bonds`:`4. EIC`, names_to = "Avg. Rate of Return", values_to="Value")


data %>%
  filter(`Avg. Rate of Return`!="4. EIC") %>%
  ggplot(aes(x=Time, y=Value, group=`Avg. Rate of Return`, color=`Avg. Rate of Return`))+
  geom_line()

data %>%
  ggplot(aes(x=Time, y=Value, group=`Avg. Rate of Return`, color=`Avg. Rate of Return`))+
  geom_line()

``