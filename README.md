# SWO

MSE for Indian Ocean swordfish

## INSTALL

```{r}
install.packages(c("FLCore", "FLFishery"), repos="http://flr-project.org/R")
devtools::install_github(c("flr/FLCore", "flr/FLFishery"))
devtools::install_github("iagomosqueira/ss3om")
devtools::install_github("iotcwpm/ALB", subdir="ioswomse")
```

## CONDITIONING

- Open `ioswomse/exec/condition.R`

```{r}
edit(file=system.file("exec/condition.R", package="ioswomse"))
```

1. CREATES list of scenarios.
2. LOAD `data(cpue)`.
3. SETUP grid of runs, `setioswogrid()`.
4. RUN grid, use doParallel if multiple cores are available, `runss3grid`.
5. LOAD results as follows
    - `res` *data.frame*, containing reference points, grid values and results.
    - `omf` *FLStock*
    - `fqsfull` summary `metrics` of `omf`: `ssb`, `catch`, `fbar` and `rec`.
6. TRIM `omf` according to
    - Convergence level > 0.001
    - BO > 1.5 Mt
7. SIMPLIFY `om` by
    - Merging `area` and `unit`.
    - `setPlusGroup` to age 20.
8. CREATE `refpts` *FLPar*
9. EXTRACT SR residuals, `loadquants`.
10. CREATE `osr` *predictModel* using `bevholtss3`.
11. SAVE `om.RData` object, containing `om`, `osr`, and `refpts`.
