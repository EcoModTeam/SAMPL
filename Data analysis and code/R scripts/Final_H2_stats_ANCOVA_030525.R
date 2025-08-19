# The purpose of this document is to explore and assess the effect of spatial
# distribution and density of mussel populations on the accuracy,
# detection rate, and precision of sampling methods.This document accounts for
# decreased detectability of qualitative timed searches, which are known to
# detect fewer mussels than quantitative methods.

## Clear workspace
rm(list = ls()) ## remove stored files and objects
gc(T) ## garbage collection
graphics.off() ## Turn off graphics

# Load necessary libraries
library(dplyr) ## for data organization
library(tidyr) ## spread
library(ggplot2) ## graphing
library(ggpattern) ## graphing
library(ggdist) ## graphing
library(tidyquant) ## graphing
library(ggthemes) ## graphing
library(ggpubr) ## graphing
library(here) ## set working directory
library(boot) ## for bootstrap analysis

# Bring in data and split by density and quantitative versus qualitative
all = read.csv("data/H2_Final_Data_12225_figures.csv")

# Isolate quantitative data
quant=all[which(all$Sampling.Method!="QTS"),]

# Isolate qualitative data
qual=all[which(all$Sampling.Method=="QTS"),]

# Set spatial distribution, detectability, and sampling method as factors
qual$Spatial.Distribution=as.factor(qual$Spatial.Distribution)
qual$True.Mussel.Density=as.factor(qual$True.Mussel.Density)
qual$Detectability=as.factor(qual$Detectability)
quant$Spatial.Distribution=as.factor(quant$Spatial.Distribution)
quant$Sampling.Method=as.factor(quant$Sampling.Method)
quant$Detectability=as.factor(quant$Detectability)

# Calculate percent error in density for quantitative data
quant$perc_error=abs((quant$Density.Metric-quant$True.Mussel.Density)/quant$True.Mussel.Density)*100

# Split quantitative data by true mussel density
quant_0.01=quant[which(quant$True.Mussel.Density==0.01),] ## 0.01 mussels/m2
quant_0.1=quant[which(quant$True.Mussel.Density==0.1),] ## 0.1 mussels/m2
quant_1=quant[which(quant$True.Mussel.Density==1),] ## 1.0 mussels/m2
quant_7=quant[which(quant$True.Mussel.Density==7),] ## 7.0 mussels/m2

# Split qualitative data by true mussel density
qual_0.01=qual[which(qual$True.Mussel.Density==0.01),] ## 0.01 mussels/m2
qual_0.1=qual[which(qual$True.Mussel.Density==0.1),] ## 0.1 mussels/m2
qual_1=qual[which(qual$True.Mussel.Density==1),] ## 1.0 mussels/m2
qual_7=qual[which(qual$True.Mussel.Density==7),] ## 7.0 mussels/m2

################################################################################

# Check levels of effort for each sampling method to see if they are similar
# NEEDS TO ACCOUNT FOR DETECTABILITY

# Split data by true density
all_0.01 = all %>% filter(True.Mussel.Density == 0.01)
all_0.1 = all %>% filter(True.Mussel.Density == 0.1)
all_1 = all %>% filter(True.Mussel.Density == 1)
all_7 = all %>% filter(True.Mussel.Density == 7)

effort_0.01 = all_0.01 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

## 0.1 mussels per square meter
effort_0.1 = all_0.1 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

## 1.0 mussels per square meter
effort_1.0 = all_1 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

## 7.0 mussels per square meter
effort_7.0 = all_7 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

effort = ggarrange(effort_0.01, effort_0.1 , effort_1.0 , effort_7.0 ,nrow = 2, ncol = 2,
                              labels = c("0.01", "0.1", "1.0",
                                         "7.0"),font.label = list(size = 35), hjust = -2)

# ggsave("effort.jpg", effort, width=30, height=15, limitsize = F)

effort_summary = all %>% group_by(True.Mussel.Density, Sampling.Method) %>%
  summarise(mean = mean(Total.Quadrats.Sampled), var = var(Total.Quadrats.Sampled),
              sd = sd(Total.Quadrats.Sampled))

################################################################################

# Check that dataset is balanced
table(all$Sampling.Method,all$Spatial.Distribution,all$True.Mussel.Density)

all = all %>% filter((Sampling.Method != "QTS" & Detectability == 1) | (Sampling.Method == "QTS" & Detectability == 0.3))

################################################################################

# Pull out model runs with perfect detection for quantitative methods
# Also, remove ACS for 1.0 and 7.0
quant_0.01=quant_0.01[which(quant_0.01$Detectability == 1),]
quant_0.1=quant_0.1[which(quant_0.1$Detectability == 1),] ## 0.1 mussels/m2
quant_1=quant_1[which(quant_1$Detectability == 1 & quant_1$Sampling.Method != "ACS"),] ## 1.0 mussels/m2
quant_7=quant_7[which(quant_7$Detectability == 1 & quant_7$Sampling.Method != "ACS"),] ## 7.0 mussels/m2

# Check that dataset is balanced
table(quant_0.01$Sampling.Method,quant_0.01$Spatial.Distribution)
table(quant_0.1$Sampling.Method,quant_0.1$Spatial.Distribution)
table(quant_1$Sampling.Method,quant_1$Spatial.Distribution)
table(quant_7$Sampling.Method,quant_7$Spatial.Distribution)

# Pull out model runs with 0.3 detection for qualitative methods
qual_0.01=qual_0.01[which(qual_0.01$Detectability == 0.3),] ## 0.01 mussels/m2
qual_0.1=qual_0.1[which(qual_0.1$Detectability == 0.3),] ## 0.1 mussels/m2
qual_1=qual_1[which(qual_1$Detectability == 0.3),] ## 1.0 mussels/m2
qual_7=qual_7[which(qual_7$Detectability == 0.3),] ## 7.0 mussels/m2

# Check that dataset is balanced
table(qual_0.01$Spatial.Distribution)
table(qual_0.1$Spatial.Distribution)
table(qual_1$Spatial.Distribution)
table(qual_7$Spatial.Distribution)

################################################################################

# Run randomized ANCOVAs to test whether sampling method and/or spatial
# distribution influence percent error and CPUE when sampling effort is a covariate

set.seed(3) ## set seed for repeatable results

## Quantitative methods

### True mussel density: 0.01 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(perc_error~Total.Quadrats.Sampled+Sampling.Method,quant_0.01)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.method.F=summary(obs.aov)[[1]]$F[2]


## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.method.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_0.01$perc_error,length(quant_0.01$perc_error),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~quant_0.01$Total.Quadrats.Sampled+quant_0.01$Sampling.Method) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.method.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.effort.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.method=mean(perm.method.F>obs.method.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.method)



## True mussel density: 0.1 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(perc_error~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution,quant_0.1)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.samp.F=summary(obs.aov)[[1]]$F[2]
obs.spat.F=summary(obs.aov)[[1]]$F[3]
obs.int.F=summary(obs.aov)[[1]]$F[4]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_0.1$perc_error,length(quant_0.1$perc_error),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution,quant_0.1) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[4] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.samp)
print(p.spat)
print(p.int)


# The interaction is not significant in this model, which means that unbalanced sample sizes for the covariate are an issue
# To make sure our results are reliable, we will run bootstrapped linear regression instead, which avoids order of entry issues

# Re-level factors so that SRS and Random are the reference categories
quant_0.1$Sampling.Method = relevel(quant_0.1$Sampling.Method, ref = "SRS")
quant_0.1$Spatial.Distribution = relevel(quant_0.1$Spatial.Distribution, ref = "Random")

## Run parametric linear regression
perc_error_0.1 = lm(perc_error ~ Total.Quadrats.Sampled + Sampling.Method * Spatial.Distribution,quant_0.1)
summary(perc_error_0.1)

## Set up bootstrap function
beta = function(formula, data, indices) {
  d = data[indices,] ### allows boot to select sample
  fit = lm(formula, data = d) ### set up equation structure
  return(coef(fit))
}

## Run bootstrap analysis
results_pe_0.1 = boot(data = quant_0.1, statistic = beta, R = 10000,
    formula = perc_error ~ Total.Quadrats.Sampled + Sampling.Method * Spatial.Distribution)

results_pe_0.1

## Pull mean and confidence intervals

### Intercept
mean(results_pe_0.1$t[,1])
quantile(results_pe_0.1$t[,1], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### Search effort
mean(results_pe_0.1$t[,2])
quantile(results_pe_0.1$t[,2], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS sampling method
mean(results_pe_0.1$t[,3])
quantile(results_pe_0.1$t[,3], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method
mean(results_pe_0.1$t[,4])
quantile(results_pe_0.1$t[,4], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S spatial distribution
mean(results_pe_0.1$t[,5])
quantile(results_pe_0.1$t[,5], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M spatial distribution
mean(results_pe_0.1$t[,6])
quantile(results_pe_0.1$t[,6], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M+2 spatial distribution
mean(results_pe_0.1$t[,7])
quantile(results_pe_0.1$t[,7], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+2 spatial distribution
mean(results_pe_0.1$t[,8])
quantile(results_pe_0.1$t[,8], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM Ran spatial distribution
mean(results_pe_0.1$t[,9])
quantile(results_pe_0.1$t[,9], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### Poisson spatial distribution
mean(results_pe_0.1$t[,10])
quantile(results_pe_0.1$t[,10], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1S spatial distribution
mean(results_pe_0.1$t[,11])
quantile(results_pe_0.1$t[,11], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S spatial distribution
mean(results_pe_0.1$t[,12])
quantile(results_pe_0.1$t[,12], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1S+1M spatial distribution
mean(results_pe_0.1$t[,13])
quantile(results_pe_0.1$t[,13], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S+1M spatial distribution
mean(results_pe_0.1$t[,14])
quantile(results_pe_0.1$t[,14], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1S+1M+2 spatial distribution
mean(results_pe_0.1$t[,15])
quantile(results_pe_0.1$t[,15], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S+1M+2 spatial distribution
mean(results_pe_0.1$t[,16])
quantile(results_pe_0.1$t[,16], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1s+2 spatial distribution
mean(results_pe_0.1$t[,17])
quantile(results_pe_0.1$t[,17], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S+2 spatial distribution
mean(results_pe_0.1$t[,18])
quantile(results_pe_0.1$t[,18], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM Ran spatial distribution
mean(results_pe_0.1$t[,19])
quantile(results_pe_0.1$t[,19], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM Ran spatial distribution
mean(results_pe_0.1$t[,20])
quantile(results_pe_0.1$t[,20], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect


### ACS Sampling method Poisson spatial distribution
mean(results_pe_0.1$t[,21])
quantile(results_pe_0.1$t[,21], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method Poisson spatial distribution
mean(results_pe_0.1$t[,22])
quantile(results_pe_0.1$t[,22], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect


# Regular randomized ANOVA (since quadrats sampled are all the same)
## True mussel density: 1.0 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(perc_error~Sampling.Method*Spatial.Distribution,quant_1)
summary(obs.aov)

obs.samp.F=summary(obs.aov)[[1]]$F[1]
obs.spat.F=summary(obs.aov)[[1]]$F[2]
obs.int.F=summary(obs.aov)[[1]]$F[3]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_1$perc_error,length(quant_1$perc_error),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Sampling.Method*Spatial.Distribution,quant_1) ### run anova on randomly ordered data
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
}

## Step 4: compute p-values
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.samp)
print(p.spat)
print(p.int)



## True mussel density: 7.0 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(perc_error~Sampling.Method*Spatial.Distribution,quant_7)
summary(obs.aov)

obs.samp.F=summary(obs.aov)[[1]]$F[1]
obs.spat.F=summary(obs.aov)[[1]]$F[2]
obs.int.F=summary(obs.aov)[[1]]$F[3]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_7$perc_error,length(quant_7$perc_error),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Sampling.Method*Spatial.Distribution,quant_7) ### run anova on randomly ordered data
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
}

## Step 4: compute p-values
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.samp)
print(p.spat)
print(p.int)

# The interaction is not significant in this model, which means that unbalanced sample sizes for the covariate are an issue
# To make sure our results are reliable, we will run bootstrapped linear regression instead, which avoids order of entry issues

# Re-level factors so that SRS and Random are the reference categories
quant_7$Sampling.Method = relevel(quant_7$Sampling.Method, ref = "SRS")
quant_7$Spatial.Distribution = relevel(quant_7$Spatial.Distribution, ref = "Random")

## Run parametric linear regression
perc_error_7 = lm(perc_error ~ Sampling.Method * Spatial.Distribution,quant_7)
summary(perc_error_7)

## Set up bootstrap function
beta = function(formula, data, indices) {
  d = data[indices,] ### allows boot to select sample
  fit = lm(formula, data = d) ### set up equation structure
  return(coef(fit))
}

## Run bootstrap analysis
results_pe_7 = boot(data = quant_7, statistic = beta, R = 10000,
                      formula = perc_error ~ Sampling.Method * Spatial.Distribution)

results_pe_7

## Pull mean and confidence intervals

### Intercept
mean(results_pe_7$t[,1])
quantile(results_pe_7$t[,1], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method
mean(results_pe_7$t[,2])
quantile(results_pe_7$t[,2], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S spatial distribution
mean(results_pe_7$t[,3])
quantile(results_pe_7$t[,3], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M spatial distribution
mean(results_pe_7$t[,4])
quantile(results_pe_7$t[,4], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M+2 spatial distribution
mean(results_pe_7$t[,5])
quantile(results_pe_7$t[,5], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S + 2 spatial distribution
mean(results_pe_7$t[,6])
quantile(results_pe_7$t[,6], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM Ran spatial distribution
mean(results_pe_7$t[,7])
quantile(results_pe_7$t[,7], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### Poisson spatial distribution
mean(results_pe_7$t[,8])
quantile(results_pe_7$t[,8], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1S spatial distribution
mean(results_pe_7$t[,9])
quantile(results_pe_7$t[,9], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1s+1M spatial distribution
mean(results_pe_7$t[,10])
quantile(results_pe_7$t[,10], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1S+1M+2 spatial distribution
mean(results_pe_7$t[,11])
quantile(results_pe_7$t[,11], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1S+2 spatial distribution
mean(results_pe_7$t[,12])
quantile(results_pe_7$t[,12], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM Ran spatial distribution
mean(results_pe_7$t[,13])
quantile(results_pe_7$t[,13], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x Poisson spatial distribution
mean(results_pe_7$t[,14])
quantile(results_pe_7$t[,14], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect


## Qualitative methods (QTS)

### True mussel density: 0.1 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(Mussels.Per.Person.Hour~Total.Quadrats.Sampled+Spatial.Distribution,qual_0.1)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.spatial.F=summary(obs.aov)[[1]]$F[2]


## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spatial.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(qual_0.1$Mussels.Per.Person.Hour,length(qual_0.1$Mussels.Per.Person.Hour),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~qual_0.1$Total.Quadrats.Sampled+qual_0.1$Spatial.Distribution) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.spatial.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.effort.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spatial=mean(perm.spatial.F>obs.method.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.spatial)



### True mussel density: 1.0 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(Mussels.Per.Person.Hour~Total.Quadrats.Sampled+Spatial.Distribution,qual_1)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.spatial.F=summary(obs.aov)[[1]]$F[2]


## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spatial.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(qual_1$Mussels.Per.Person.Hour,length(qual_1$Mussels.Per.Person.Hour),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~qual_1$Total.Quadrats.Sampled+qual_1$Spatial.Distribution) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.spatial.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.effort.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spatial=mean(perm.spatial.F>obs.method.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.spatial)



### True mussel density: 7.0 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(Mussels.Per.Person.Hour~Total.Quadrats.Sampled+Spatial.Distribution,qual_7)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.spatial.F=summary(obs.aov)[[1]]$F[2]


## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spatial.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(qual_7$Mussels.Per.Person.Hour,length(qual_7$Mussels.Per.Person.Hour),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~qual_7$Total.Quadrats.Sampled+qual_7$Spatial.Distribution) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.spatial.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.effort.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spatial=mean(perm.spatial.F>obs.method.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.spatial)

# Summary statistics

## Statistics for each sampling method by density
perc_error_sum = quant %>% group_by(True.Mussel.Density,
        Sampling.Method) %>% summarise(min = min(perc_error),
        mean = mean(perc_error), max = max(perc_error), sd = sd(perc_error))

## Statistics for each spatial distribution with different methods and densities
perc_error_sum_spat = quant %>% group_by(True.Mussel.Density,
  Sampling.Method, Spatial.Distribution) %>% summarise(min = min(perc_error),
          mean = mean(perc_error), max = max(perc_error), sd = sd(perc_error))

cpue_summary = qual %>% group_by(True.Mussel.Density, Spatial.Distribution) %>% summarise(min = min(Mussels.Per.Person.Hour),
          mean = mean(Mussels.Per.Person.Hour), max = max(Mussels.Per.Person.Hour), sd = sd(Mussels.Per.Person.Hour))


################################################################################

## Examine pseudoabsence rates

## Calculate number of observations and number of obs that were zero
percent_abs = all %>% group_by(True.Mussel.Density, Spatial.Distribution,
          Sampling.Method) %>% summarise(obs=n(),
          zero = sum(Density.Metric == 0))

## Calculate pseudoabsence rate
percent_abs=percent_abs %>% mutate(perc_false_neg=(zero/obs)*100)

## Order results
percent_abs=percent_abs %>% arrange(perc_false_neg,.by_group=TRUE)

perc_abs_0.01 = percent_abs[which(percent_abs$True.Mussel.Density == 0.01),]
perc_abs_0.1 = percent_abs[which(percent_abs$True.Mussel.Density == 0.1),]
perc_abs_1 = percent_abs[which(percent_abs$True.Mussel.Density == 1 & percent_abs$Sampling.Method != "ACS"),]
perc_abs_7 = percent_abs[which(percent_abs$True.Mussel.Density == 7 & percent_abs$Sampling.Method != "ACS"),]

# Summary statistics
percent_abs_sum = all %>% group_by(True.Mussel.Density, Sampling.Method,
                                   Spatial.Distribution) %>% summarise(obs = n(),
                                    zero = sum(Density.Metric == 0))

percent_abs_sum = percent_abs_sum %>% mutate(perc_false_neg = (zero/obs)*100)

percent_abs_sum = percent_abs_sum %>% arrange(perc_false_neg,.by_group = TRUE)

perc_abs_density = percent_abs_sum %>% group_by(True.Mussel.Density,
          Sampling.Method) %>% summarise(min = min(perc_false_neg), mean =
          mean(perc_false_neg), max = max(perc_false_neg), sd = sd(perc_false_neg))

################################################################################

# Run randomized ANCOVAs to test whether sampling method and/or spatial
# distribution influence proportion detected when sampling effort is a covariate

all = all %>% mutate(prop_detected = Total.Mussels.Detected/Total.Mussels)

# Split data by true density
all_0.01 = all %>% filter(True.Mussel.Density == 0.01)
all_0.1 = all %>% filter(True.Mussel.Density == 0.1)
all_1 = all %>% filter(True.Mussel.Density == 1 & Sampling.Method != "ACS")
all_7 = all %>% filter(True.Mussel.Density == 7 & Sampling.Method != "ACS")

# Check that datasets are balanced
table(all_0.01$Sampling.Method, all_0.01$Spatial.Distribution)
table(all_0.1$Sampling.Method, all_0.1$Spatial.Distribution)
table(all_1$Sampling.Method, all_1$Spatial.Distribution)
table(all_7$Sampling.Method, all_7$Spatial.Distribution)

all %>% group_by(True.Mussel.Density) %>% summarise(NAs = sum(is.na(prop_detected)))

set.seed(3) ## set seed for repeatable results

### True mussel density: 0.01 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(prop_detected ~ Total.Quadrats.Sampled + Sampling.Method, all_0.01)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.method.F=summary(obs.aov)[[1]]$F[2]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.method.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(all_0.01$prop_detected, length(all_0.01$prop_detected),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~all_0.01$Total.Quadrats.Sampled + all_0.01$Sampling.Method) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.method.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.effort.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.method=mean(perm.method.F>obs.method.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.method)



## True mussel density: 0.1 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(prop_detected~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution, all_0.1)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.samp.F=summary(obs.aov)[[1]]$F[2]
obs.spat.F=summary(obs.aov)[[1]]$F[3]
obs.int.F=summary(obs.aov)[[1]]$F[4]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(all_0.1$prop_detected,length(all_0.1$prop_detected),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution, all_0.1) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[4] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.samp)
print(p.spat)
print(p.int)



## True mussel density: 1.0 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(prop_detected~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution, all_1)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.samp.F=summary(obs.aov)[[1]]$F[2]
obs.spat.F=summary(obs.aov)[[1]]$F[3]
obs.int.F=summary(obs.aov)[[1]]$F[4]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(all_1$prop_detected,length(all_1$prop_detected),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution, all_1) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[4] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.samp)
print(p.spat)
print(p.int)



## True mussel density: 7.0 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(prop_detected~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution, all_7)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.samp.F=summary(obs.aov)[[1]]$F[2]
obs.spat.F=summary(obs.aov)[[1]]$F[3]
obs.int.F=summary(obs.aov)[[1]]$F[4]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(all_7$prop_detected,length(all_7$prop_detected),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution, all_7) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[4] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.samp)
print(p.spat)
print(p.int)

## Summary statistics

prop_detected_sum = all %>% group_by(True.Mussel.Density,
        Sampling.Method) %>% summarise( min = min(prop_detected),
        mean = mean(prop_detected), max = max(prop_detected), sd = sd(prop_detected))


prop_detected_sum_spat = all %>% group_by(True.Mussel.Density,
        Sampling.Method, Spatial.Distribution) %>%  summarise( min = min(prop_detected),
            mean = mean(prop_detected), max = max(prop_detected), sd = sd(prop_detected))

################################################################################

# Run randomized ANCOVAs to test whether sampling method and/or spatial
# distribution influence CV when sampling effort is a covariate

# Check that datasets are balanced- they are not
balance_CV = quant %>% group_by(True.Mussel.Density, Sampling.Method, Spatial.Distribution) %>% summarise(num_NA = sum(!is.na(Sample.CV)))

set.seed(3) ## set seed for repeatable results

### True mussel density: 0.01 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(Sample.CV ~ Total.Quadrats.Sampled + Sampling.Method, quant_0.01)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.method.F=summary(obs.aov)[[1]]$F[2]


## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.method.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_0.01$Sample.CV, length(quant_0.01$Sample.CV),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~quant_0.01$Total.Quadrats.Sampled + quant_0.01$Sampling.Method) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.method.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
}

## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.effort.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.method=mean(perm.method.F>obs.method.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.method)



## True mussel density: 0.1 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(Sample.CV~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution,quant_0.1)
summary(obs.aov)

obs.effort.F=summary(obs.aov)[[1]]$F[1]
obs.samp.F=summary(obs.aov)[[1]]$F[2]
obs.spat.F=summary(obs.aov)[[1]]$F[3]
obs.int.F=summary(obs.aov)[[1]]$F[4]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.effort.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in


## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_0.1$Sample.CV,length(quant_0.1$Sample.CV),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Total.Quadrats.Sampled+Sampling.Method*Spatial.Distribution,quant_0.1) ### run anova on randomly ordered data
  perm.effort.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[4] ### store f value in empty file
}


## Step 4: compute p-values
p.effort=mean(perm.effort.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.effort)
print(p.samp)
print(p.spat)
print(p.int)



# The interaction is not significant in this model, which means that unbalanced sample sizes for the covariate are an issue
# To make sure our results are reliable, we will run bootstrapped linear regression instead, which avoids order of entry issues

## Run parametric linear regression
cv_0.1 = lm(Sample.CV ~ Total.Quadrats.Sampled + Sampling.Method * Spatial.Distribution,quant_0.1)
summary(cv_0.1)

## Set up bootstrap function
beta = function(formula, data, indices) {
  d = data[indices,] ### allows boot to select sample
  fit = lm(formula, data = d) ### set up equation structure
  return(coef(fit))
}

## Run bootstrap analysis
results_cv_0.1 = boot(data = quant_0.1, statistic = beta, R = 10000,
                      formula = Sample.CV ~ Total.Quadrats.Sampled + Sampling.Method * Spatial.Distribution)

results_cv_0.1

## Pull mean and confidence intervals

### Intercept
mean(results_cv_0.1$t[,1])
quantile(results_cv_0.1$t[,1], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### Search effort
mean(results_cv_0.1$t[,2])
quantile(results_cv_0.1$t[,2], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS sampling method
mean(results_cv_0.1$t[,3])
quantile(results_cv_0.1$t[,3], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method
mean(results_cv_0.1$t[,4])
quantile(results_cv_0.1$t[,4], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S spatial distribution
mean(results_cv_0.1$t[,5])
quantile(results_cv_0.1$t[,5], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M spatial distribution
mean(results_cv_0.1$t[,6])
quantile(results_cv_0.1$t[,6], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M+2 spatial distribution
mean(results_cv_0.1$t[,7])
quantile(results_cv_0.1$t[,7], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+2 spatial distribution
mean(results_cv_0.1$t[,8])
quantile(results_cv_0.1$t[,8], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM Ran spatial distribution
mean(results_cv_0.1$t[,9])
quantile(results_cv_0.1$t[,9], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### Poisson spatial distribution
mean(results_cv_0.1$t[,10])
quantile(results_cv_0.1$t[,10], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1S spatial distribution
mean(results_cv_0.1$t[,11])
quantile(results_cv_0.1$t[,11], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S spatial distribution
mean(results_cv_0.1$t[,12])
quantile(results_cv_0.1$t[,12], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1S+1M spatial distribution
mean(results_cv_0.1$t[,13])
quantile(results_cv_0.1$t[,13], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S+1M spatial distribution
mean(results_cv_0.1$t[,14])
quantile(results_cv_0.1$t[,14], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1S+1M+2 spatial distribution
mean(results_cv_0.1$t[,15])
quantile(results_cv_0.1$t[,15], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S+1M+2 spatial distribution
mean(results_cv_0.1$t[,16])
quantile(results_cv_0.1$t[,16], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM 1S+2 spatial distribution
mean(results_cv_0.1$t[,17])
quantile(results_cv_0.1$t[,17], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM 1S+2 spatial distribution
mean(results_cv_0.1$t[,18])
quantile(results_cv_0.1$t[,18], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### ACS Sampling method CM Ran spatial distribution
mean(results_cv_0.1$t[,19])
quantile(results_cv_0.1$t[,19], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method CM Ran spatial distribution
mean(results_cv_0.1$t[,20])
quantile(results_cv_0.1$t[,20], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect


### ACS Sampling method Poisson spatial distribution
mean(results_cv_0.1$t[,21])
quantile(results_cv_0.1$t[,21], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS Sampling method Poisson spatial distribution
mean(results_cv_0.1$t[,22])
quantile(results_cv_0.1$t[,22], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect





# Regular ANOVA because effort is equal

## True mussel density: 1.0 mussels/m2
## Step 1: get and store observed F values
obs.aov=aov(Sample.CV~Sampling.Method*Spatial.Distribution,quant_1)
summary(obs.aov)

obs.samp.F=summary(obs.aov)[[1]]$F[1]
obs.spat.F=summary(obs.aov)[[1]]$F[2]
obs.int.F=summary(obs.aov)[[1]]$F[3]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_1$Sample.CV,length(quant_1$Sample.CV),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Sampling.Method*Spatial.Distribution,quant_1) ### run anova on randomly ordered data
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
}

## Step 4: compute p-values
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.samp)
print(p.spat)
print(p.int)


# The interaction is not significant in this model, which means that unbalanced sample sizes for the covariate are an issue
# To make sure our results are reliable, we will run bootstrapped linear regression instead, which avoids order of entry issues

# Re-level factors so that SRS and Random are the reference categories
quant_1$Sampling.Method = relevel(quant_1$Sampling.Method, ref = "SRS")
quant_1$Spatial.Distribution = relevel(quant_1$Spatial.Distribution, ref = "Random")

## Run parametric linear regression
cv_1 = lm(Sample.CV ~ Sampling.Method * Spatial.Distribution,quant_1)
summary(cv_1)

## Set up bootstrap function
beta = function(formula, data, indices) {
  d = data[indices,] ### allows boot to select sample
  fit = lm(formula, data = d) ### set up equation structure
  return(coef(fit))
}

## Run bootstrap analysis
results_cv_1 = boot(data = quant_1, statistic = beta, R = 10000,
                    formula = Sample.CV ~ Sampling.Method * Spatial.Distribution)

results_cv_1

## Pull mean and confidence intervals

### Intercept
mean(results_cv_1$t[,1])
quantile(results_cv_1$t[,1], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method
mean(results_cv_1$t[,2])
quantile(results_cv_1$t[,2], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S spatial distribution
mean(results_cv_1$t[,3])
quantile(results_cv_1$t[,3], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M spatial distribution
mean(results_cv_1$t[,4])
quantile(results_cv_1$t[,4], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M+2 spatial distribution
mean(results_cv_1$t[,5])
quantile(results_cv_1$t[,5], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+2 spatial distribution
mean(results_cv_1$t[,6])
quantile(results_cv_1$t[,6], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM Ran spatial distribution
mean(results_cv_1$t[,7])
quantile(results_cv_1$t[,7], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### Poisson spatial distribution
mean(results_cv_1$t[,8])
quantile(results_cv_1$t[,8], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1S spatial distribution
mean(results_cv_1$t[,9])
quantile(results_cv_1$t[,9], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1s+1M spatial distribution
mean(results_cv_1$t[,10])
quantile(results_cv_1$t[,10], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1s+1M+2 spatial distribution
mean(results_cv_1$t[,11])
quantile(results_cv_1$t[,11], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1S+2 spatial distribution
mean(results_cv_1$t[,12])
quantile(results_cv_1$t[,12], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM Ran spatial distribution
mean(results_cv_1$t[,13])
quantile(results_cv_1$t[,13], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x Poisson spatial distribution
mean(results_cv_1$t[,14])
quantile(results_cv_1$t[,14], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect




## True mussel density: 7.0 mussels/m2
## Step 1: get and store observed F values

obs.aov=aov(Sample.CV~Sampling.Method*Spatial.Distribution,quant_7)
summary(obs.aov)

obs.samp.F=summary(obs.aov)[[1]]$F[1]
obs.spat.F=summary(obs.aov)[[1]]$F[2]
obs.int.F=summary(obs.aov)[[1]]$F[3]

## Step 2: set up variables for permutation loop
perms=10000 ### number of permutations
perm.samp.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.spat.F=rep(NA,perms) ### create empty file to place permuted F ratios in
perm.int.F=rep(NA,perms) ### create empty file to place permuted F ratios in

## Step 3: run permutation
for (i in 1:perms) {
  Randomized.Resp = sample(quant_7$Sample.CV,length(quant_7$Sample.CV),replace=FALSE) ### randomly reorder data
  perm.aov=aov(Randomized.Resp~Sampling.Method*Spatial.Distribution,quant_7) ### run anova on randomly ordered data
  perm.samp.F[i]=summary(perm.aov)[[1]]$F[1] ### store f value in empty file
  perm.spat.F[i]=summary(perm.aov)[[1]]$F[2] ### store f value in empty file
  perm.int.F[i]=summary(perm.aov)[[1]]$F[3] ### store f value in empty file
}

## Step 4: compute p-values
p.samp=mean(perm.samp.F>obs.samp.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.spat=mean(perm.spat.F>obs.spat.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data
p.int=mean(perm.int.F>obs.int.F) ### prob of obtaining F value as large or larger than observed F with randomly ordered data

## Step 5: print p-values
print(p.samp)
print(p.spat)
print(p.int)


# The interaction is not significant in this model, which means that unbalanced sample sizes for the covariate are an issue
# To make sure our results are reliable, we will run bootstrapped linear regression instead, which avoids order of entry issues

## Run parametric linear regression
cv_7 = lm(Sample.CV ~ Sampling.Method * Spatial.Distribution,quant_7)
summary(cv_7)

## Set up bootstrap function
beta = function(formula, data, indices) {
  d = data[indices,] ### allows boot to select sample
  fit = lm(formula, data = d) ### set up equation structure
  return(coef(fit))
}

## Run bootstrap analysis
results_cv_7 = boot(data = quant_7, statistic = beta, R = 10000,
                    formula = Sample.CV ~ Sampling.Method * Spatial.Distribution)

results_cv_7

## Pull mean and confidence intervals

### Intercept
mean(results_cv_7$t[,1])
quantile(results_cv_7$t[,1], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method
mean(results_cv_7$t[,2])
quantile(results_cv_7$t[,2], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S spatial distribution
mean(results_cv_7$t[,3])
quantile(results_cv_7$t[,3], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M spatial distribution
mean(results_cv_7$t[,4])
quantile(results_cv_1$t[,4], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+1M+2 spatial distribution
mean(results_cv_7$t[,5])
quantile(results_cv_7$t[,5], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM 1S+2 spatial distribution
mean(results_cv_7$t[,6])
quantile(results_cv_7$t[,6], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### CM Ran spatial distribution
mean(results_cv_7$t[,7])
quantile(results_cv_7$t[,7], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### Poisson spatial distribution
mean(results_cv_7$t[,8])
quantile(results_cv_7$t[,8], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1s spatial distribution
mean(results_cv_7$t[,9])
quantile(results_cv_7$t[,9], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1s+1M spatial distribution
mean(results_cv_7$t[,10])
quantile(results_cv_7$t[,10], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1s+1M+2 spatial distribution
mean(results_cv_7$t[,11])
quantile(results_cv_7$t[,11], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM 1S+2 spatial distribution
mean(results_cv_7$t[,12])
quantile(results_cv_7$t[,12], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x CM Ran spatial distribution
mean(results_cv_7$t[,13])
quantile(results_cv_7$t[,13], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect

### TRS sampling method x Poisson spatial distribution
mean(results_cv_7$t[,14])
quantile(results_cv_7$t[,14], c(0.025, 0.975)) ### if CI doesn't overlap zero, slope is sig. dif from zero and variable has an effect





## Summary statistics

cv_summary = quant %>% group_by(True.Mussel.Density, Sampling.Method) %>% summarise(min = min(Sample.CV, na.rm = T),
        mean = mean(Sample.CV, na.rm = T), max = max(Sample.CV, na.rm = T),
        sd = sd(Sample.CV, na.rm = T), total = n(), num_NA = sum(is.na(Sample.CV)))

cv_summary_spat = quant %>% group_by(True.Mussel.Density, Sampling.Method, Spatial.Distribution) %>% summarise(min = min(Sample.CV, na.rm = T),
            mean = mean(Sample.CV, na.rm = T), max = max(Sample.CV, na.rm = T),
            sd = sd(Sample.CV, na.rm = T), total = n(), num_NA = sum(is.na(Sample.CV)))

################################################################################

# Figures

# Load necessary libraries
library(ggplot2)### for graphs
library(ggpubr)### for arranging plots
library(scales)### for graph text
library(ggpattern) ## graphing
library(ggdist) ## graphing
library(tidyquant) ## graphing
library(ggthemes) ## graphing
library(ggbreak) ## axis breaks
library(ggrain) ## raincloud plots
library(dplyr) ## data filtering
library(ggforce) ## violin plots

# Set up colorblind friendly palette
cbPalette <- c( "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Bring in data with correct detectabilities and ACS at only low densities
all = read.csv("H2_Final_Data_12225_figures.csv")

# Isolate quantitative data
quant = all[which(all$Sampling.Method != "QTS"),]

# Calculate percent error in density for quantitative data
quant$perc_error = abs((quant$Density.Metric-quant$True.Mussel.Density)/quant$True.Mussel.Density)*100

# Set spatial distribution, detectability, and sampling method as factors
quant$True.Mussel.Density = as.factor(quant$True.Mussel.Density)
quant$Spatial.Distribution = as.factor(quant$Spatial.Distribution)
quant$Sampling.Method = as.factor(quant$Sampling.Method)
quant$Detectability = as.factor(quant$Detectability)

## Labeller for facet wrapping three higher densities
density_labeller=as_labeller(c("0.1"="Density:~0.1~mussels~m^{-2}", "1"="Density:~1.0~mussels~m^{-2}","7"="Density:~7.0~mussels~m^{-2}"),
                        default = label_parsed)


## Labeller for facet wrapping lowest density
density_labeller_low = as_labeller(c("0.01"="Density:~0.01~mussels~m^{-2}"),
                                   default = label_parsed)



################################################################################

# Sampling effort

effort_0.01 = all_0.01 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

## 0.1 mussels per square meter
effort_0.1 = all_0.1 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

## 1.0 mussels per square meter
effort_1.0 = all_1 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

## 7.0 mussels per square meter
effort_7.0 = all_7 %>% ggplot(aes(x = Sampling.Method, y = (Total.Quadrats.Sampled), fill = Sampling.Method)) +
  ### add half-violin from {ggdist} package
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, point_colour = NA, scale = 0.5
  ) + geom_boxplot(width = 0.12, outlier.color = NA, alpha = 0.5
  ) + stat_dots(side = "left", justification = 1.1, binwidth = NA
  ) + theme(text=element_text(color="black",size=30))

effort = ggarrange(effort_0.01, effort_0.1 , effort_1.0 , effort_7.0 ,nrow = 2, ncol = 2,
                   labels = c("0.01", "0.1", "1.0",
                              "7.0"),font.label = list(size = 35), hjust = -2)

ggsave("effort.jpg", effort, width=30, height=15, limitsize = F)

effort_summary = all %>% group_by(True.Mussel.Density, Sampling.Method) %>%
  summarise(mean = mean(Total.Quadrats.Sampled), var = var(Total.Quadrats.Sampled),
            sd = sd(Total.Quadrats.Sampled))

################################################################################

## Violin plots

# Reorder sampling method
quant$Spatial.Distribution <- factor(quant$Spatial.Distribution,
     levels = c("Random", "Clumped Poisson", "Clumped Matern 1S",
                "Clumped Matern 1S+1M", "Clumped Matern 1S+1M+2",
                "Clumped Matern 1S+2", "Clumped Matern Ran"))

# Percent error

pe_high_violin = quant %>% filter(True.Mussel.Density != 0.01 & Spatial.Distribution != "Clumped Matern Ran") %>% group_by(Spatial.Distribution,
     Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = perc_error, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2,
                  position = position_dodge(width=0.9), color = "black")+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + ylab("Percent error (%)"
        ) + xlab("Spatial distribution") + theme(text = element_text(color = "black",
           size = 27)) + theme(axis.text = element_text(color = "black"))+theme(
             axis.title.y = element_text(hjust=0.75)) + guides(color = 'none')


density_labeller_CMR = as_labeller(c("", "", ""),
                                   default = label_parsed)

pe_high_violin_CMR = quant %>% filter(True.Mussel.Density != 0.01 & Spatial.Distribution == "Clumped Matern Ran") %>% group_by(Spatial.Distribution,
     Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = perc_error, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller_CMR, scale = "free_y") + theme(
    legend.position="bottom") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2,
                  position = position_dodge(width=0.9), color = "black") + labs(fill="") + ylab(""
        ) + xlab("") + theme(text = element_text(color = "black",
           size = 27)) + theme(axis.text = element_text(color = "black"))+theme(
             axis.title.y = element_text(hjust=0.75)) + guides(color = 'none')

pe_fig_violin_high = ggarrange( pe_high_violin, pe_high_violin_CMR, nrow = 1, ncol = 2,
                                widths = c(0.75, 0.25), heights = c(1, 1))

pe_low_violin = quant %>% filter(True.Mussel.Density == 0.01 & Spatial.Distribution != "Clumped Matern Ran") %>% group_by(Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Sampling.Method,
     y = perc_error, fill = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = "black") + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller_low, scale = "free_y") + theme(
    legend.position="none") + guides(
    color = 'none', fill = 'none') + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9),)+ theme(
      legend.position="bottom") + labs(fill="") + guides(
        color = 'none') + ylab("") + xlab(
          "Sampling method") + theme(text = element_text(color = "black",
                                                         size = 27)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75))



## Combined graph
pe_fig_violin = ggarrange(pe_low_violin, pe_fig_violin_high, nrow = 2,ncol = 1,
                   heights = c(0.27, 0.73), widths = c(1, 1))

#ggsave("Percent error Violin.jpg", pe_fig_violin, width=20, height=10, limitsize = F)


# CPUE

cpue_high_violin = qual %>% filter(True.Mussel.Density != 0.01) %>% group_by(Spatial.Distribution, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = Mussels.Per.Person.Hour, fill = Spatial.Distribution, color = Spatial.Distribution)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9), color = "black")+ theme(
      legend.position="none") + ylab("CPUE (mussels per person hour)") + xlab("Spatial distribution") + theme(text = element_text(color = "black",
                                                         size = 27)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75)) + guides(
                                                           color = 'none')


#ggsave("CPUE Violin.jpg", cpue_high_violin, width=20, height=10, limitsize = F)

combo = ggarrange(pe_fig_violin, cpue_high_violin, ncol =1, nrow = 2,labels = c("A","B"), font.label = list(size = 35))

#ggsave("Violin_PE_CPUE.jpg", combo, width=20, height=20, limitsize = F)




## CV

cv_high_violin = quant %>% filter(True.Mussel.Density != 0.01 & Spatial.Distribution != "Clumped Matern Ran" & Spatial.Distribution != "Random") %>% group_by(Spatial.Distribution,
     Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = Sample.CV, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2,
                  position = position_dodge(width=0.9), color = "black")+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + ylab("Coefficient of variation"
        ) + xlab("Spatial distribution") + theme(text = element_text(color = "black",
           size = 27)) + theme(axis.text = element_text(color = "black"))+theme(
             axis.title.y = element_text(hjust=0.75)) + guides(color = 'none')


cv_high_violin_CMR = quant %>% filter(True.Mussel.Density != 0.01 & Spatial.Distribution == "Clumped Matern Ran") %>% group_by(Spatial.Distribution,
     Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = Sample.CV, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller_CMR, scale = "free_y") + theme(
    legend.position="bottom") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2,
                  position = position_dodge(width=0.9), color = "black") + labs(fill="") + ylab(""
        ) + xlab("") + theme(text = element_text(color = "black",
           size = 27)) + theme(axis.text = element_text(color = "black"))+theme(
             axis.title.y = element_text(hjust=0.75)) + guides(color = 'none')

cv_high_violin_ran = quant %>% filter(True.Mussel.Density != 0.01 & Spatial.Distribution == "Random") %>% group_by(Spatial.Distribution,
     Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = Sample.CV, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller_CMR, scale = "free_y") + theme(
    legend.position="bottom") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2,
                  position = position_dodge(width=0.9), color = "black") + labs(fill="") + ylab(""
        ) + xlab("") + theme(text = element_text(color = "black",
           size = 27)) + theme(axis.text = element_text(color = "black"))+theme(
             axis.title.y = element_text(hjust=0.75)) + guides(color = 'none')

cv_fig_violin_high = ggarrange(cv_high_violin, cv_high_violin_CMR, nrow = 1, ncol = 2,
                                widths = c(0.75, 0.25), heights = c(1, 1))

cv_low_violin = quant %>% filter(True.Mussel.Density == 0.01 & Spatial.Distribution != "Clumped Matern Ran") %>% group_by(Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Sampling.Method,
     y = Sample.CV, fill = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = "black") + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller_low, scale = "free_y") + theme(
    legend.position="none") + guides(
    color = 'none', fill = 'none') + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9),)+ theme(
      legend.position="bottom") + labs(fill="") + guides(
        color = 'none') + ylab("") + xlab(
          "Sampling method") + theme(text = element_text(color = "black",
                                                         size = 27)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75))



## Combined graph
cv_fig_violin = ggarrange(cv_low_violin, cv_fig_violin_high, nrow = 2,ncol = 1,
                   heights = c(0.27, 0.73), widths = c(1, 1))

#ggsave("CV Violin.jpg", cv_fig_violin, width=20, height=10, limitsize = F)





# CV

cv_high_violin = quant %>% filter(True.Mussel.Density != 0.01) %>% group_by(Spatial.Distribution,
     Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = Sample.CV, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9), color = "black")+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + ylab("Coefficient of variation (CV)") + xlab("Spatial distribution") + theme(text = element_text(color = "black",
                                                         size = 26.5)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75)) + guides(
                                                           color = 'none')


cv_low_violin = quant %>% filter(True.Mussel.Density == 0.01) %>% group_by(Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Sampling.Method,
     y = Sample.CV, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = "black") + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller_low, scale = "free_y") + theme(
    legend.position="none") + guides(
    color = 'none', fill = 'none') + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9),)+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + guides(
        color = 'none') + ylab("") + xlab(
          "Sampling method") + theme(text = element_text(color = "black",
                                                         size = 26.5)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75))

## Combined graph
cv_fig_violin = ggarrange(cv_low_violin, cv_high_violin, nrow = 2,ncol = 1,
                   heights = c(0.27, 0.73), widths = c(1, 1))

#ggsave("CV Violin.jpg", cv_fig_violin, width=20, height=10, limitsize = F)





# Proportion detected

## Reorder sampling method
all$Spatial.Distribution <- factor(all$Spatial.Distribution,
     levels = c("Random", "Clumped Poisson", "Clumped Matern 1S",
                "Clumped Matern 1S+1M", "Clumped Matern 1S+1M+2",
                "Clumped Matern 1S+2", "Clumped Matern Ran"))


pd_high_violin = all %>% filter(True.Mussel.Density != 0.01 & Spatial.Distribution != "Clumped Matern Ran") %>% group_by(Spatial.Distribution,
     Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = prop_detected, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9), color = "black")+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + ylab("Proportion detected") + xlab("Spatial distribution") + theme(text = element_text(color = "black",
                                                         size = 26.5)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75)) + guides(
                                                           color = 'none')

pd_high_violin_CMR = all %>% filter(True.Mussel.Density != 0.01 & Spatial.Distribution == "Clumped Matern Ran"
    ) %>% group_by(Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Spatial.Distribution,
     y = prop_detected, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9), color = "black")+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + ylab("Proportion detected") + xlab("Spatial distribution") + theme(text = element_text(color = "black",
                                                         size = 26.5)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75)) + guides(
                                                           color = 'none')


pd_fig_violin_high = ggarrange(pd_high_violin, pd_high_violin_CMR, nrow = 1, ncol = 2,
                               widths = c(0.75, 0.25), heights = c(1, 1))

pd_low_violin = all %>% filter(True.Mussel.Density == 0.01) %>% group_by(Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Sampling.Method,
     y = prop_detected, fill = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = "black") + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 3, labeller = density_labeller_low, scale = "free_y") + theme(
    legend.position="none") + guides(
    color = 'none', fill = 'none') + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9),)+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + guides(
        color = 'none') + ylab("") + xlab(
          "Sampling method") + theme(text = element_text(color = "black",
                                                         size = 26.5)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75))

## Combined graph
pd_fig_violin = ggarrange(pd_low_violin, pd_fig_violin_high, nrow = 2,ncol = 1,
                   heights = c(0.27, 0.73), widths = c(1, 1))

#ggsave("Proportion detected Violin.jpg", pd_fig_violin, width=20, height=10, limitsize = F)



# Pseudoabsence rate

density_labeller_all=as_labeller(c("0.01"="Density:~0.01~mussels~m^{-2}","0.1"="Density:~0.1~mussels~m^{-2}",
                               "1"="Density:~1.0~mussels~m^{-2}","7"="Density:~7.0~mussels~m^{-2}"),
                             default = label_parsed)


pa_quant_violin = pseudo_absence %>% filter(Sampling.Method != "QTS") %>% group_by(Sampling.Method, True.Mussel.Density) %>% ggplot(aes(x = Sampling.Method,
     y = perc_false_neg, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = cbPalette
    ) + scale_color_manual(values = cbPalette) + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 4, labeller = density_labeller_all, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9), color = "black")+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + ylab("Pseudoabsence rate (%)") + xlab("Sampling method") + theme(text = element_text(color = "black",
                                                         size = 26.5)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75)) + guides(
                                                           color = 'none')


pa_qual_violin = pseudo_absence %>% filter(Sampling.Method == "QTS") %>% group_by(True.Mussel.Density) %>% ggplot(aes(x = Sampling.Method,
     y = perc_false_neg, fill = Sampling.Method, color = Sampling.Method)) + geom_violin()+ theme_classic() + scale_fill_manual(values = "#F0E442"
    ) + scale_color_manual(values = "black") + facet_wrap(~ True.Mussel.Density,
    ncol = 1, nrow = 4, labeller = density_labeller_CMR, scale = "free_y") + theme(
    legend.position="none") + scale_x_discrete(labels = label_wrap(10))+ ylab("") + xlab(
    "Sampling method") + theme(text = element_text(color = "black", size =
    20)) + theme(axis.text = element_text(color = "black")) + geom_boxplot(width=0.2, position = position_dodge(width=0.9),)+ theme(
      legend.position="bottom") + labs(fill="Sampling method") + guides(
        color = 'none') + ylab("") + xlab(
          "Sampling method") + theme(text = element_text(color = "black",
                                                         size = 26.5)) + theme(axis.text = element_text(color = "black"))+theme(axis.title.y = element_text(hjust=0.75))

## Combined graph
pa_fig_violin = ggarrange(pa_quant_violin, pa_qual_violin, nrow = 1,ncol = 2,
                   heights = c(1, 1), widths = c(0.75, 0.25))

#ggsave("Pseudoabsence rate Violin.jpg", pa_fig_violin, width=20, height=10, limitsize = F)



################################################################################

# Bootstrap confidence interval graphs

# Load necessary libraries
library(ggplot2)### for graphs
library(ggpubr)### for arranging plots
library(scales)### for graph text
library(ggpattern) ## graphing
library(ggdist) ## graphing
library(tidyquant) ## graphing
library(ggthemes) ## graphing
library(ggbreak) ## axis breaks
library(ggrain) ## raincloud plots
library(dplyr) ## data filtering
library(forcats)

# Set up colorblind friendly palette
cbPalette <- c( "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette_reduced = c("#E69F00", "#56B4E9", "#F0E442")

## Three higher densities
density_labeller=as_labeller(c("0.1"="Density:~0.1~mussels~m^{-2}",
                               "1"="Density:~1.0~mussels~m^{-2}","7"="Density:~7.0~mussels~m^{-2}"),
                             default = label_parsed)

bs_results = read.csv("data/bootstrap_significance.csv")



# Percent error 0.1 mussels m-2
pe_0.1 = bs_results  %>% filter(response == "Percent error" & density == 0.1 & variable != "Intercept") %>% mutate(
  var_ordered = fct_reorder(variable, rev(order))) %>% group_by(density
            ) %>% ggplot(aes(x = var_ordered, y = value, fill = type, color = group
            )) + geom_line(aes(group = variable, size = 1.8, color = type)
            ) + geom_point(size = 3, shape = 16, color = "black") + theme_classic() + scale_fill_manual(values = cbPalette
            ) + scale_color_manual(values = cbPalette) + facet_wrap(~ density,
                ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y"
                ) + ylab("Estimate") + xlab("Effect") + theme(text = element_text(color = "black",
                    size = 22)) + geom_hline(yintercept = 0, linetype = "dashed", color = "black",
                     size = 1)  + theme(axis.text = element_text(color = "black")) + theme(
                       legend.position="none") + coord_flip()



pe_7 = bs_results  %>% filter(response == "Percent error" & density == 7 & variable != "Intercept") %>% mutate(
  var_ordered = fct_reorder(variable, rev(order))) %>% group_by(density
            ) %>% ggplot(aes(x = var_ordered, y = value, fill = type, color = group
            )) + geom_line(aes(group = variable, size = 1.8, color = type)
            ) + geom_point(size = 3, shape = 16, color = "black") + theme_classic() + scale_fill_manual(values = cbPalette_reduced
            ) + scale_color_manual(values = cbPalette_reduced) + facet_wrap(~ density,
                ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y"
                ) + ylab("Estimate") + xlab("Effect") + theme(text = element_text(color = "black",
                    size = 22)) + geom_hline(yintercept = 0, linetype = "dashed", color = "black",
                     size = 0.5)  + theme(axis.text = element_text(color = "black"))  + theme(
                       legend.position="bottom") + coord_flip() + labs(color="")  + guides(
                         fill = 'none')

# Percent error 7 mussels m-2
bs_pe = ggarrange(pe_0.1, pe_7, ncol = 1, nrow = 2)


#ggsave("Bootstrap percent error fig.jpg", bs_pe, width=15, height=12, limitsize = F)





# CV 0.1 mussels m-2
 cv_0.1 = bs_results  %>% filter(response == "CV" & density == 0.1 & variable != "Intercept") %>% mutate(
  var_ordered = fct_reorder(variable, rev(order)))  %>% group_by(density
            ) %>% ggplot(aes(x = var_ordered, y = value, fill = type, color = group
            )) + geom_line(aes(group = variable, size = 1.8, color = type)
            ) + geom_point(size = 3, shape = 16, color = "black") + theme_classic() + scale_fill_manual(values = cbPalette
            ) + scale_color_manual(values = cbPalette) + facet_wrap(~ density,
                ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y"
                ) + ylab("Estimate") + xlab("Effect") + theme(text = element_text(color = "black",
                    size = 25)) + geom_hline(yintercept = 0, linetype = "dashed", color = "black",
                     size = 1)  + theme(axis.text = element_text(color = "black")) + theme(
                       legend.position="none") + coord_flip()


# CV 1.0 mussels m-2
 cv_1 = bs_results  %>% filter(response == "CV" & density == 1 & variable != "Intercept") %>% mutate(
  var_ordered = fct_reorder(variable, rev(order)))  %>% group_by(density
            ) %>% ggplot(aes(x = var_ordered, y = value, fill = type, color = group
            )) + geom_line(aes(group = variable, size = 1.8, color = type)
            ) + geom_point(size = 3, shape = 16, color = "black") + theme_classic() + scale_fill_manual(values = cbPalette
            ) + scale_color_manual(values = cbPalette_reduced) + facet_wrap(~ density,
                ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y"
                ) + ylab("Estimate") + xlab("Effect") + theme(text = element_text(color = "black",
                    size = 25)) + geom_hline(yintercept = 0, linetype = "dashed", color = "black",
                     size = 1)  + theme(axis.text = element_text(color = "black")) + theme(
                       legend.position="none")  + coord_flip()


# CV 7.0 mussels m-2
 cv_7 = bs_results  %>% filter(response == "CV" & density == 7 & variable != "Intercept") %>% mutate(
  var_ordered = fct_reorder(variable, rev(order)))  %>% group_by(density
            ) %>% ggplot(aes(x = var_ordered, y = value, fill = type, color = group
            )) + geom_line(aes(group = variable, size = 1.8, color = type)
            ) + geom_point(size = 3, shape = 16, color = "black") + theme_classic() + scale_fill_manual(values = cbPalette
            ) + scale_color_manual(values = cbPalette_reduced) + facet_wrap(~ density,
                ncol = 1, nrow = 3, labeller = density_labeller, scale = "free_y"
                ) + ylab("Estimate") + xlab("Effect") + theme(text = element_text(color = "black",
                    size = 25)) + geom_hline(yintercept = 0, linetype = "dashed", color = "black",
                     size = 1)  + theme(axis.text = element_text(color = "black")) + theme(
                       legend.position="none") + coord_flip()

 bs_cv = ggarrange(cv_0.1, cv_1, cv_7, ncol = 1, nrow = 3)


 #ggsave("Bootstrap cv fig.jpg", bs_cv, width=10, height=20, limitsize = F)


