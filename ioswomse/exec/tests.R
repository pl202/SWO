# tests.R - DESC
# /tests.R

# Copyright European Union, 2017
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

library(ioswomse)
library(FLasher)

data(om)

tt <- fwd(om, sr=list(model=geomean()$model, params=FLPar(a=10000)),
  control=fwdControl(year=2010:2015, value=6000, quant="catch"))


# stk <- readFLSss3(dir=dir, repfile = "Report.sso.gz", covarfile = "covar.sso.gz",
#   compfile="CompReport.sso.gz")



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

