# grid.R - DESC
# ioalbmse/R/grid.R

# Copyright European Union, 2015-2016
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@jrc.ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

#' Sets a grid of SS3 runs for the IOTC SWO OM
#'
#' @name setioswogrid
#' @examples
#' base <- '../inst/ext-data/sa/'
#' name <- 'swo'
#' from <- 1
#' write <- TRUE
#'
# setioswogrid {{{
setioswogrid <- function(scenarios, cpues,
  dir=paste0("grid_", format(Sys.time(), "%Y%m%d")),
  base=system.file("ext-data/sa", package="ioswomse"), name='swo', from=1,
  write=TRUE) {
	
  # EXPAND grid from sce
	grid <- nameGrid(expand.grid(scenarios, stringsAsFactors=FALSE), from=from)

  if(!write)
    return(grid)

  # SET ctl, dat full paths
  ctlf <- paste0(base, "/", name, ".ctl")
  datf <- paste0(base, "/", name, ".dat")
 	
  # READ source files
  dats <- r4ss::SS_readdat(datf, verbose=FALSE)
  ctls <- r4ss::SS_readctl_3.24(file=ctlf, use_datlist=T, datlist=dats, verbose=FALSE)

  # NAMES in grid
  pars <- names(scenarios)

  # CREATE dir
  if(dir.exists(dir))
    stop(paste("folder", dir, "already exists. Delete first."))
	
  dir.create(dir)

	# SETUP grid
  foreach (i=grid$number, .errorhandling = "remove") %dopar% {

    dat <- dats
    ctl <- ctls

    row <- which(grid$number == i)
 
    # llsel TODO
    if("llsel" %in% pars) {
      if(grid[row, 'llsel'] == "DoNorm") {
        # CHANGE fleet 3 (S) 
        ctl$size_selex_parms[7:12, "INIT"] <- c(90, -0.50, 5.00, 6.00, -999, 0)
      } else if(grid[row, 'llsel'] == "Logistic") {
        ctl$size_selex_parms[7:12, "INIT"] <- c(90, -0.50, 5.00, 6.00, -999, 0)
      }
    }

		# steepness
    if("steepness" %in% pars) {
      ctl$SRparm["SR_BH_steep", c("INIT", "PRIOR")] <- grid[row, "steepness"]
    }

    # M
    if("M" %in% pars) {
      if(ctl$natM_type == 0) {
        ctl$MG_parms[1, c("INIT", "PRIOR")] <- grid[row, "M"]
      }
    }

    # Growth + maturity
    if("growmat" %in% pars) {
      if(grid[row, 'growmat'] == "farley") {

        ctl$MG_parms[2:4,] <- rbind(
          # Farley Ray L_at_Amin_Fem_GP_1_
          c(70, 90, 83.22, 83.22, 0, 0.1, -2, 0, 0, 0, 0, 0, 0, 0),
          # Farley Ray Ray L_at_Amax_Fem_GP_1_
          c(300, 340, 308.0713, 308.0713, 0, 0.1, -2, 0, 0, 0, 0, 0, 0, 0),
          # Farley Ray Ray VonBert_K_Fem_GP_1_
          c(0.05, 0.2, 0.123, 0.123, 0, 0.1, -3, 0, 0, 0, 0, 0, 0, 0))

        # Farley 2016 Otolith
        ctl$Age_Maturity[] <- c(0.001, 0.006, 0.027, 0.109, 0.354, 0.711, 0.917,
          0.98, 0.996, 0.999, rep(1, 21))

      } else if(grid[row, 'growmat'] == "wang") {
        ctl$MG_parms[2:4,] <- rbind(
          # Wang IO L_at_Amin_Fem_GP_1
          c(70, 90, 66.2, 66.2, 0, 0.1, -2, 0, 0, 0, 0, 0.5, 0, 0),
          # Wang IO L_at_Amax_Fem_GP_1
          c(310, 340, 274.9, 274.9, 0, 0.1, -2, 0, 0, 0, 0, 0.5, 0, 0),
          # Wang IO VonBert_K_Fem_GP_1
          c(0.05, 0.26, 0.138, 0.138, 0, 0.1, -3, 0, 0, 0, 0, 0.5, 0, 0))

        # TWN/Hawai'i Maturity 50% age 4
        ctl$Age_Maturity[] <- c(0, 0, 0, 0, 0.02, 0.1, 0.5, 0.9, 0.98,
            rep(1, 22))
      }
    }

    # ESS obs
    if("ess" %in% pars) {
      dat$lencomp$Nsamp <- grid[row, "ess"]
    }
	
    # CPUE scaling schemes
    if("scaling" %in% pars) {

      # GET object by name (flaky)
      cpue <- get(paste0("cpues_", grid[row, "scaling"]))

      # data.table of dat$CPUE
      # datcpue <- data.table(dat$CPUE)

      # set keys for merge
      # setkey(datcpue, year, seas, index)
      # setkey(cpue, year, seas, index)

      # MERGE
      # datcpue[cpue, obs:=cpue$obs]

      # dat$CPUE <- datcpue
    }

    # CPUEs
    if("cpue" %in% pars) {
    # JAP late + PT in SW
      if(grid[row, "cpue"] == "jappt") {
        # 15 - UJPLL_SW
        dat$CPUE <- subset(cpue , index != 15 | year < 2000)[, 1:5]
        # SET lambdas$value = 0.001 for all but c(13:16,21)
        ctl$lambdas[, "value"] <- 0.001
        ctl$lambdas[ctl$lambdas[,"fleet/survey"] %in% c(13:16,21), "value"] <- 1.000
      }

    # JAP late
      else if(grid[row, "cpue"] == "jap") {
        dat$CPUE <- cpue[, 1:5]
        # SET lambdas$value = 0.001 for all but c(13:16)
        ctl$lambdas[, "value"] <- 0.001
        ctl$lambdas[ctl$lambdas[,"fleet/survey"] %in% c(13:16), "value"] <- 1.000
      }

    # TWN late + PT in SW
      else if(grid[row, "cpue"] == "twnpt") {
        dat$CPUE <- subset(cpue , name != 19 | year < 2000)[, 1:5]
        # SET lambdas$value = 0.001 for all but c(17:21)
        ctl$lambdas[, "value"] <- 0.001
        ctl$lambdas[ctl$lambdas[,"fleet/survey"] %in% c(17:21), "value"] <- 1.000
      }

      dat$N_cpue <- nrow(dat$CPUE)
    
    }

    # CPUE Q increases
    if("llq" %in% pars) {
      cpue <- data.table(dat$CPUE)
      dat$CPUE <- cpue[, obs:=obs / as.numeric(grid[row, "llq"]) ^ seq(0,
        length(obs) - 1), by=index]
    }

    # sigmaR, #_SRparm3
    if("sigmaR" %in% pars) {
      ctl$SRparm["SR_sigmaR", c("INIT", "PRIOR")] <- grid[row, "sigmaR"]
    }

		# CREATE dir
		dirname <- paste(dir, grid[row, "id"], sep='/')
		dir.create(dirname)

		# COPY unaltered files
		# starter.ss
		file.copy(paste(base, "starter.ss", sep="/"),
			paste(dirname, "starter.ss", sep="/"))
		
		# forecast.ss
		file.copy(paste(base, "forecast.ss", sep="/"),
			paste(dirname, "forecast.ss", sep="/"))

		# WRITE modified files
		# ctl
    r4ss::SS_writectl_3.24(ctl, paste0(dirname, "/", name, ".ctl"), nseas=ctl$nseas)
		
    # dat
    r4ss::SS_writedat(dat, outfile=paste0(dirname, "/", name, ".dat"))
	}

	invisible(grid)
} # }}}
