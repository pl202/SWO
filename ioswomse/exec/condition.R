# condition.R - DESC
# ioswomse/exec/condition.R

# Copyright European Union, 2018
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

library(ioswomse)

library(doParallel)
registerDoParallel(4)
registerDoParallel(200)

# --- SCENARIOS

scenarios <- list(
  # Natural mortality, M
  M=c(0.2, 0.4, 999),
  # SR steepness
  steepness=c(0.6, 0.75, 0.9),
  # Rec variance
  sigmaR=c(0.2, 0.6),
  # Weight of length samples
  ess=c(2, 20),
  # Trends in LL catchability
  llq=c(1, 1.01),
  # Growth + maturity
  growmat=c("farley", "wang"),
  # CPUEs
  cpue=c("jappt", "jap", "twnpt"),
  # Area CPUE scaling factor
  scaling=c("area", "catch", "biomass"))

# --- DATA

data(cpues)
data(lorenzen)

# -- SETUP grid/SS3 folders

dir <- "grid"

grid <- setioswogrid(scenarios, cpues=cpues, dir=dir, base='./sa/', write=FALSE)

# -- RUN SS3 grid
# $ parallel --jobs 200 --progress 'cd {} && ss3' ::: *
runss3grid(grid, options="", dir=dir, pack=TRUE)

# -- LOAD results

# res
res <- loadres(dir=dir, repfile = "Report.sso",
  covarfile = "covar.sso", grid=grid)

# omfull
omf <- loadomDT(dir=dir, repfile = "Report.sso", covarfile = "covar.sso",
  compfile="CompReport.sso")

# SET range of ages fully selected
range(omf, c("minfbar", "maxfbar")) <- c(2,8)

# SET name and desc(ription)
name(omf) <- "SWO"
desc(omf) <- paste("IOTC SWO SS3", dir)

save(omf, res, file="out/omfull.RData", compress="xz")

# fqsfull
fqs <- metrics(omf)

save(fqs, res, file="out/fqsfull.RData", compress="xz")


# INSPECT results

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

# BUG Should readFLSss3 take care of this?
landings.wt(om)[1,] <- stock.wt(om)[1,]
discards.wt(om) <- landings.wt(om)[,,,,,1]

# MERGE ages 21-31 in plusgroup
om <- setPlusGroup(om, 20)

# rpts: MSY, SB_MSY, F_MSY, SB0
refpts <- with(res[idx,], FLPar(MSY=TotYield_MSY, SBMSY=2 * SSB_MSY, FMSY=Fstd_MSY,
  SB0=2 * SPB_1950, Ftarget=Fstd_MSY, SBlim=2 * 0.40 * SSB_MSY))

# sr
resid <- loadquants(subdirs=file.path("grid", grid$id[idx]), object="resid",
  repfile = "Report.sso", covarfile = "covar.sso", compfile="CompReport.sso")

osr <- predictModel(model="bevholtss3",
  params=with(res[idx,], FLPar(s=steepness, R0=exp(`SR_LN(R0)`), v=SPB_1950,
    units=c("", "1000", "t"))), FLQuants(residuals=resid[, ac(1975:2013)]))

units(harvest.spwn(om)) <- ""
units(m.spwn(om)) <- ""

res <- res[idx,]

save(om, refpts, osr, res, file='out/om.RData', compress='xz')

# fqs
fqs <- metrics(om)

save(fqs, file="out/fqs.RData", compress="xz")
