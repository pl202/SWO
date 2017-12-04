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

