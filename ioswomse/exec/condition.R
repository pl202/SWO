# condition.R - DESC
# ioalbmse/exec/condition.R

# Copyright European Union, 2016
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

library(ioswomse)

library(doParallel)
registerDoParallel(225)

# --- SCENARIOS

scenarios <- list(
  # Natural mortality, M
  M=c(0.2, 0.4),
  # SR steepness
  steepness=c(0.6, 0.75, 0.9),
  # 
  sigmaR=c(0.2, 0.6),
  #
  ess=c(2, 20),
  #
  llq=c(1, 1.01),
  #
  growmat=c("farley", "wang"),
  #
  cpue=c("jappt", "jap", "twnpt"),
  #
  scaling=c("area", "catch", "biomass"))

# --- DATA

data(cpues)

# -- SETUP grid/SS3 folders

dir <- "grid_20171108"

grid <- setioswogrid(scenarios, cpues=cpues, dir=dir, write=FALSE)
load(paste0(dir, "/grid.RData"))

# -- RUN SS3 grid

runss3grid(grid, options="", dir=dir)

# -- LOAD results

# res
res <- loadres(dir=dir, grid=grid, repfile = "Report.sso.gz",
  covarfile = "covar.sso.gz")

# omfull
omf <- loadom(dir=dir, repfile = "Report.sso.gz", covarfile = "covar.sso.gz",
  compfile="CompReport.sso.gz")

omf <- loadomFLStocks(dir=dir, repfile = "Report.sso.gz", covarfile = "covar.sso.gz",
  compfile="CompReport.sso.gz")
omf <- Reduce(combine, om)

omf <- loadomDT(dir=dir, repfile = "Report.sso.gz", covarfile = "covar.sso.gz",
  compfile="CompReport.sso.gz")

# BUG units in m.spwn & harvest.spwn

range(omf, c("minfbar", "maxfbar")) <- c(2,8)
name(omf) <- "SWO"
desc(omf) <- "IOTC SWO SS3 grid 20171117"



save(omf, res, file="out/omfull.RData", compress="xz")

# fqsfull
fqs <- metrics(omf)

save(fqs, res, file="out/fqsfull.RData", compress="xz")

# om

# TRIM if BO > 1.5 Mt
idb0 <- res$TotBio_Unfished < 1.5e6

# TRIM if Convergence level > 0.001
idcl <- res$Convergence_Level <= 0.001

idx <- idcl & idb0

# SUBSET by idx
om <- FLCore::iter(omf, idx)

# MERGE areas
om <- simplify(om, c("area", "unit"))

# DROP iters in slots with var=0
om <- slim(om)
# BUG slim if all NAs
discards(om) <- discards(om)[,,,,,1]
discards.n(om) <- discards.n(om)[,,,,,1]
discards.wt(om) <- discards.wt(om)[,,,,,1]

# BUG Should readFLSss3 take care of this?
landings.wt(om)[1,] <- stock.wt(om)[1,]
discards.wt(om) <- landings.wt(om)
discards.n(om) <- 0

# MERGE ages 21-31 in plusgroup
om <- setPlusGroup(om, 20)

# rpts: MSY, SB_MSY, F_MSY, SB0
refpts <- with(res[idx,], FLPar(MSY=TotYield_MSY, SBMSY=2 * SSB_MSY, FMSY=Fstd_MSY,
  SB0=2 * SPB_1950, Ftarget=Fstd_MSY, SBlim=2 * 0.40 * SSB_MSY))

# sr
resid <- loadquants(dir=dir, object="resid", repfile = "Report.sso.gz",
  covarfile = "covar.sso.gz", compfile="CompReport.sso.gz")

osr <- predictModel(model="bevholtss3",
  params=with(res[idx,], FLPar(s=steepness, R0=exp(`SR_LN(R0)`), v=SPB_1950,
    units=c("", "1000", "t"))),
  FLQuants(residuals=resid[, ac(1975:2013),,,,idx]))

save(om, refpts, osr, file='out/om.RData', compress='xz')


# --- TEST
library(ioswomse)
library(FLasher)

data(om)

tt <- fwd(om, sr=list(model=geomean()$model, params=FLPar(a=10000)),
  control=fwdControl(year=2010:2015, value=6000, quant="catch"))




system.time(tt <- fwd(om, sr=osr, catch=catch(om)[,ac(2013:2015)],
  residuals=window(osr$residuals, start=1950)))

tt <- fwd(om, sr=osr, catch=catch(om)[,ac(2013:2015)],
  residuals=window(osr$residuals, start=1950))

tt <- fwd(om, sr=osr,
  control=fwdControl(year=2010:2012, value=6000, quant="catch"),
  residuals=window(osr$residuals, start=1950, end=2015))

tt <- fwd(om, sr=list(model=model(osr), params=params(osr)),
  control=fwdControl(year=2010:2012, value=6000, quant="catch"),
  residuals=window(osr$residuals, start=1950, end=2015))

tt <- fwd(om, sr=list(model=model(osr), params=params(osr)),
  control=fwdControl(year=2010:2012, value=6000, quant="catch"),
  residuals=window(osr$residuals, start=1950, end=2015))

tt <- fwd(om, sr=list(model=model(osr), params=params(osr)),
  control=fwdControl(year=2010:2015, value=6000, quant="catch"))



    res <- fwd(ple4, control=control, sr=list(model=geomean()$model, 
      params=FLPar(a=yearMeans(rec(ple4)[, ac(2006:2008)]))))

# discards
# landings.wt['0',]


# index: cpue, sd, b
cpue <- foreach(i=seq(length(grid$id))) %dopar% {
  print(i)
readFLIBss3(dir=grid$id[i], fleets=c(LLCPUE3=3))
}

index <- cpue[[1]]@index
sel.pattern <- Reduce('combine', lapply(cpue, function(x) x@sel.pattern))
index.res <- Reduce('combine', lapply(cpue, function(x) x@index.var))
index.q <- Reduce('combine', lapply(cpue, function(x) x@index.q))

save(cpue, index, sel.pattern, index.res, index.q, file='cpue.RData', compress='xz')

# cpue list
# TODO REVIEW deSeason, deGender
ocpue <- list(index=seasonMeans(index),
  sel.pattern=seasonMeans(unitMeans(sel.pattern)),
  index.q=seasonMeans(index.q),
  index.res=seasonMeans(index.res)
) 



# --- OMS - For TESTING

set.seed(99)
idx <- sample(dimnames(m(om))$iter, 200)

om <- FLCore::iter(om, idx)
  desc(om) <- "IO ALB MSE SS3 grid of 20170117, 200 randomly selected runs"
orp <- FLBRP(om)
omp <- FLBRP::fwdWindow(om, orp, end=2040)
res <- res[idx, ]
rpts <- FLPar(MSY=res$TotYield_MSY, SBMSY=2 * res$SSB_MSY, FMSY=res$Fstd_MSY,
  SB0=2 * res$SPB_1950, Ftarget=res$Fstd_MSY, SBlim=2 * 0.40 * res$SSB_MSY)
osr <- predictModel(residuals=FLCore::iter(resid,idx)[, ac(1975:2012)],
  params=FLPar(s=res$steepness, R0=exp(res$`SR_LN(R0)`), v=res$SPB_1950, iter=dim(res)[1]),
  model=rec ~ (4 * s * R0 * ssb) / (v * (1 - s) + ssb * (5 * s - 1)))
ocpue <- list(index=ocpue$index,
  sel.pattern=ocpue$sel.pattern[,,,,,idx],
  index.q=ocpue$index.q[,,,,,idx],
  index.res=ocpue$index.res[,,,,,idx]
) 

save(om, omp, res, rpts, osr, ocpue, file='oms.RData', compress='xz')

