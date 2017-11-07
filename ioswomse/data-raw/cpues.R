# cpues.R - DESC
# /cpues.R

# Copyright European Union, 2017
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

library(r4ss)
library(data.table)

# LOAD CSV file
# <http://iotc.org/meetings/15th-working-party-billfish-wpb15>
cpues <- data.table(read.csv("cpues.csv", header=T, stringsAsFactors=FALSE))

# RESCALE UPOR_SW
cpues[index == 21, obs := obs / mean(obs)]

# CREATE area from name
cpues[, area := tstrsplit(name, "_", keep=2)]

# --- NO SCALING

cpues_orig <- cpues[,.(year, seas=1, index, obs, se_log=0.1)]

# --- SCALE by area

# CREATE areas data.table
# 
areas <- c(NW=0.2478, NE=0.2577, SW=0.1638, SE=0.3307)
surface <- data.table(surface=areas/mean(areas), area=names(areas),
  stringsAsFactors=FALSE)

# INDEX data.tables for merge
setkey(cpues, area)
setkey(surface, area)

# MERGE, adds 'surface' to cpues by 'area'
cpues_area <- cpues[surface]

# RESCALE by surface
cpues_area[, obs := obs * surface]

cpues_area <- cpues_area[,.(year, seas=1, index, obs, se_log=0.1)]


# --- SCALE by catch

# LOAD SS3 dat & ctl
dat <- SS_readdat("../inst/ext-data/sa/swo.dat", verbose=FALSE)
catch <- data.table(dat$catch)

# MELT to long
catch <- melt(catch, id.vars=c("year"), measure.vars=names(catch)[1:12],
  variable.name = "fleet", value.name = "catch")

# CREATE area code
catch[, area := tstrsplit(fleet, "_", keep=2)][,fleet := NULL]

# SUM mean catch by area & year, 1994-2015
catch <- catch[year >= 1994, .(catch=mean(catch)), by=.(area)]

# CALCULATE proportions by area
# catch[, prop := prop.table(catch), by=year]
catch[, catch := catch / mean(catch)]

# INDEX data.table for merge
setkey(catch, area)
setkey(cpues, area)

# MERGE, adds 'prop' to cpues by 'area'
cpues_catch <- cpues[catch]

# SCALE each index by its mean
cpues_catch[, obs := obs / mean(obs), by=index]

# RESCALE by catch
cpues_catch[, obs := obs * catch]

cpues_catch <- cpues_catch[,.(year, seas=1, index, obs, se_log=0.1)]


# --- SCALE by biomass

biomass <- c(NW=36413.7, NE=47425, SW=31389, SE=24431.3)
biomass <- biomass / mean(biomass)

abundance <- data.table(abundance=biomass, area=names(biomass),
  stringsAsFactors=FALSE)

# INDEX data.tables for merge
setkey(cpues, area)
setkey(abundance, area)

# MERGE, adds 'surface' to cpues by 'area'
cpues_biomass <- cpues[abundance]

# SCALE each index by its mean
cpues_biomass[, obs := obs / mean(obs), by=index]

# RESCALE by surface
cpues_biomass[, obs := obs * abundance]

cpues_biomass <- cpues_biomass[,.(year, seas=1, index, obs, se_log=0.1)]


# --- SAVE as data

save(cpues_orig, cpues_area, cpues_catch, cpues_biomass,
  file="../data/cpues.RData", compress="xz")


# --- INSPECT

library(ggplot2)

allcpues <- cbind(cpues, byarea=cpues_area$obs, catch=cpues_catch$obs,
  biomass=cpues_biomass$obs)
allcpues <- melt(allcpues, id.vars=c("year", "name", "index", "area"),
  measure.vars=c("obs", "catch", "biomass", "byarea"),
  variable.name = "cpue", value.name = "obs")

ggplot(allcpues, aes(x=year, y=obs, group=cpue)) + geom_line(aes(colour=cpue)) +
  facet_wrap(~name, scales='free_y')
