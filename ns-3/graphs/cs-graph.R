#!/usr/bin/env Rscript
# Copyright (c) 2012-2013  Alexander Afanasyev <alexander.afanasyev@ucla.edu>


# install.packages ('ggplot2')
library (ggplot2)
## # install.packages ('scales')
## library (scales)

library (doBy)

#########################
# Rate trace processing #
#########################
data = read.table ("cs-trace.txt", header=T)
data$Node = factor (data$Node)
data$Type = factor (data$Type)

## data.rtr = data[grep("Rtr", data$Node),]
#data.combined = summaryBy (. ~ Time + Node + Type, data=data, FUN=sum)

# graph rates on all nodes in Kilobits
g.all <- ggplot (data, aes (x=Time, y=Packets, color=Type)) +
  geom_point (size=2) +
  geom_line () +
  ylab ("Packets") +
  facet_wrap (~ Node) +
  theme_bw ()

png ("cs-trace-all-nodes.png", width=800, height=500)
print (g.all)
x = dev.off ()
