##################################################################
### IOTC SWO MSE - Figures for options in Biol and CPUE params ###
##################################################################
# prepared by R.Coelho: rpcoelho@ipma.pt


###########################
#### M - Natural Mortality

#define vars
library(reshape)
library(ggplot2)
Low <- rep(0.2, 31)
High <- rep(0.4, 31)
Lorenzen.F <- c(0.5660322,	0.4382228,	0.368445,	0.3248203,	0.295235,	0.2740602,	0.2583189,	0.2462855,	0.23689,
                0.2294327,	0.2234366,	0.2185649,	0.2145735,	0.2112806,	0.2085487,	0.2062716,	0.204366,	0.2027662,
                0.2014195,	0.2002831,	0.1993224,	0.1985089,	0.1978191,	0.1972334,	0.1967357,	0.1963124,	0.1959521,
                0.1956453,	0.1953838,	0.1951609,	0.1949708)
Lorenzen.M <- c(0.4588258,	0.3631227,	0.3124604,	0.2817323,	0.2615569,	0.2476183,	0.2376487,	0.2303405,	0.2248866,
                0.220762,	0.2176113,	0.2151861,	0.2133084,0.2118481,	0.2107082,	0.2098161,	0.2091164,	0.2085667,
                0.2081342,	0.2077936,	0.2075252,	0.2073135,	0.2071465,	0.2070146,	0.2069105,	0.2068282,	0.2067633,
                0.2067119,	0.2066714,	0.2066393,	0.206614)
M.schedules.data <- data.frame(Low=Low, High=High, Lorenzen.F=Lorenzen.F, Lorenzen.M=Lorenzen.M)
M.schedules.data.melt <- melt(M.schedules.data)
M.schedules.data.melt$Age <- seq(0,30) # Add ages vector
summary(M.schedules.data.melt)

M.schedules.plot <-ggplot(data=M.schedules.data.melt)+
  geom_line(aes(x=Age, y=value, group=variable, color=variable), size=1)+
  geom_point(aes(x=Age, y=value, group=variable, color=variable), size=2)+
  labs(title = "Natural Mortality", x = "Age", y = "M")+
  guides(color=guide_legend("M option"))+ 
  theme_bw()

png(file="Natural-Mortality.png", bg = "white",
     width = 18, height = 12, units = "cm", res = 300) 
print(M.schedules.plot)
dev.off()


######################
####  VB Growth Curves
library(reshape)
library(ggplot2)
Farley.2016.oto.F <- c(83.70591021,	111.6181888,	135.4749267,	155.8653773,	173.2931783,	188.1887905,	200.9201307,	211.8016588,
                       221.1021451,	229.0513084,	235.8454906,	241.6525057,	246.6157851,	250.8579201,	254.4836901,	257.5826505,
                       260.2313445,	262.495194,	264.4301154,	266.0839005,	267.4973974,	268.7055189,	269.7381053,	270.620661,
                       271.374985,	272.0197088,	272.5707568,	273.0417398,	273.4442908,	273.7883529,	274.0824241)
Farley.2016.oto.M <- c(87.79367093,	114.1762607,	135.0335671,	151.5227456,	164.5586094,	174.8643833,	183.0118278,	189.4529599,
                       194.5451311,	198.5708533,	201.7534719,	204.2695574,	206.2587012,	207.8312603,	209.0744797,	210.0573328,
                       210.8343477,	211.4486331,	211.9342692,	212.3181989,	212.6217226,	212.8616796,	213.0513826,	213.2013562,
                       213.319921,	213.4136549,	213.4877581,	213.546342,	213.5926567,	213.6292718,	213.6582186)
Wang.2010.spines.F <- c(66.23390044,	93.1254331,	116.550612,	136.9562547,	154.7315834,	170.215649,	183.7037982,	195.4533074,
                        205.6882894,	214.6039689,	222.3704056,	229.1357385,	235.0290111,	240.1626332,	244.6345247,
                        248.5299835,	251.9233125,	254.8792371,	257.454139,	259.6971328,	261.6510017,	263.3530143,
                        264.8356353,	266.1271446,	267.2521765,	268.2321904,	269.0858793,	269.8295265,	270.4773166,
                        271.0416057,	271.5331572)
Wang.2010.spines.M <- c(72.14055972,	97.30857257,	118.5631835,	136.5128917,	151.67158,	164.4732273,	175.2843324,	184.4144069,
                        192.1248362,	198.6363623,	204.1354041,	208.7793938,	212.7012845,	216.0133561,	218.8104301,	221.172584,
                        223.1674439,	224.8521209,	226.2748457,	227.4763494,	228.4910299,	229.3479367,	230.0716021,	230.682744,
                        231.1988588,	231.6347223,	232.0028129,	232.3136687,	232.5761892,	232.7978901,	232.9851184)

Age.data <- data.frame(Farley.2016.oto.F=Farley.2016.oto.F, Farley.2016.oto.M=Farley.2016.oto.M, Wang.2010.spines.F=Wang.2010.spines.F,
                       Wang.2010.spines.M=Wang.2010.spines.M)
Age.data.melt <- melt(Age.data)
Age.data.melt$Age <- seq(0,30) # Add ages vector
summary(Age.data.melt)
Age.plot <-ggplot(data=Age.data.melt)+
  geom_line(aes(x=Age, y=value, group=variable, color=variable), size=1)+
  geom_point(aes(x=Age, y=value, group=variable, color=variable), size=2)+
  xlim(0, 30)+ 
  labs(title = "Growth", x = "Age", y = "Size (LJFL, cm)")+
  guides(color=guide_legend("Growth curve"))+ 
  theme_bw()

png(file="Growth.png", bg = "white", width = 18, height = 10, units = "cm", res = 300) 
print(Age.plot)
dev.off()


#####################
####  Maturity Curves
library(reshape)
library(ggplot2)
Farley.2016.otolith <- c(0.001, 0.006, 0.027, 0.109, 0.354, 0.711, 0.917, 0.98, 0.996, 0.999,   1, 1, 1, 1, 1, 1, 1, 1, 1,
                         1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
Wang.2010 <- c(0, 0, 0, 0, 0.02, 0.1, 0.5, 0.9, 0.98, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
Mat.data <- data.frame(Farley.2016.otolith=Farley.2016.otolith, Wang.2010=Wang.2010)
Mat.data.melt <- melt(Mat.data)
Mat.data.melt$Age <- seq(0,30) # Add ages vector
summary(Mat.data.melt)
Mat.plot <-ggplot(data=Mat.data.melt)+
  geom_line(aes(x=Age, y=value, group=variable, color=variable), size=1)+
  geom_point(aes(x=Age, y=value, group=variable, color=variable), size=2)+
  xlim(0, 15)+ 
  labs(title = "Age-at-Maturity", x = "Age", y = "Proportion mature")+
  guides(color=guide_legend("Maturity curve"))+ 
  theme_bw()

png(file="Maturity.png", bg = "white", width = 18, height = 10, units = "cm", res = 300) 
print(Mat.plot)
dev.off()


#################
####  CPUEs
library(ioswomse)
data(cpues)
head(cpues)
summary(cpues)
table(cpues$name)
#subset CPUES used
cpues.scenario1 <- subset(cpues, cpues$name=="UJPLL_NE"|cpues$name=="UJPLL_NW"|
                            cpues$name=="UJPLL_SE"|cpues$name=="UPOR_SW")
cpues.scenario1$option <- "CPUE.option1"
cpues.scenario2 <- subset(cpues, cpues$name=="UJPLL_NE"|cpues$name=="UJPLL_NW"|
                           cpues$name=="UJPLL_SE"|cpues$name=="UJPLL_SW")
cpues.scenario2$option <- "CPUE.option2"
cpues.scenario3 <- subset(cpues, cpues$name=="UTWLL_NE"|cpues$name=="UTWLL_NW"|
                            cpues$name=="UTWLL_SE"|cpues$name=="UPOR_SW")
cpues.scenario3$option <- "CPUE.option3"
cpues.grid <- rbind(cpues.scenario1, cpues.scenario2, cpues.scenario3)

#extract areas
library(stringr)
cpues.grid$area <- str_sub(cpues.grid$name,-2,-1)
#extract fleets
cpues.grid$fleet <- str_sub(cpues.grid$name, 1,5)


### sCPUE plots
plot.cpues <- ggplot(cpues.grid)+
  geom_line(aes(x=year, y=obs, col=fleet), size=0.5)+
  labs(y = "Scaled index")+
  ggtitle("CPUE Series") +
  scale_x_continuous(breaks = seq(1990, 2015, by = 5))+
  theme_bw()+
  theme(legend.position="right")+
  guides(color=guide_legend("CPUEs"))+
  facet_wrap(~option+area, scales="free_y")
plot.cpues

png(file="CPUEs.png", bg = "white",
     width = 24, height = 14, units = "cm", res = 300) 
print(plot.cpues)
dev.off()

