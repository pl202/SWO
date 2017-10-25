# cpues.R - DESC
# /cpues.R

# Copyright European Union, 2017
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

cpues <- read.table("cpues.dat", header=T)

save(cpues, file="../data/cpues.RData", compress="xz")

# ggplot(cpues, aes(x=year, y=obs)) + geom_line() + facet_wrap(~name)
