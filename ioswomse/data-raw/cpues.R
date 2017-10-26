# cpues.R - DESC
# /cpues.R

# Copyright European Union, 2017
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

library(data.table)

cpues <- data.table(read.csv("cpues.csv", header=T, stringsAsFactors=FALSE))

# RESCALE by mean

cpues[, obs := obs / mean(obs), by=name]

# SCALE by area
cpues[, area := tstrsplit(name, "_", keep=2)]

areas <- c(NW=0.26, NE=0.27, SW=0.16, SE=0.33) 

# COMPLETE data.frame

save(cpues, file="../data/cpues.RData", compress="xz")

# 
ggplot(cpues, aes(x=year, y=obs)) + geom_line() + facet_wrap(~name, scales='free_y')
