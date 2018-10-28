## read results from Bayesiaon modeling
# 0.95 one-tail strong evidence; 0.975, two-tail
# 1.645 one-tail strong evidence; 1.96, two-tail

setwd("/Users/yq/Documents/UMD/CMNT/analysis_R")

setwd("~/Dropbox/research/CMNT")
aa <- c("region_","region_pairs_")
vars <- c("age","social","mental","social-age","mental-age","social-mental","social-mental-age")

networks <- "networks_all"
networks <- "mental_reward"

aa <- "regions_"
for(i in 1:length(vars)) {
  tmp <- read.table(paste0("Bayesian modeling/",networks,"/",aa,vars[i],".txt"),header = T)
  tmp$region <- as.character(tmp$region)
  ab <- tmp[tmp$P. > 0.95,"region"] 
  print(ab)
}
i <- 4
tmp <- read.table(paste0("Bayesian modeling/",networks,"/",aa,vars[i],".txt"),header = T)
tmp[tmp$P. > 0.975,] 


# region pairs
networks <- "networks_all"
networks <- "mental_reward"
aa <- "region_pairs_"
for(i in 1:length(vars)) {
  tmp <- read.table(paste0("Bayesian modeling/",networks,"/",aa,vars[i],".txt"),header = T)
  tmp_low <- tmp[lower.tri(tmp)]
  ac <- tmp_low[ abs(tmp_low)>1.65]
#  ac <- which(abs(tmp) > 1.65)
  print(ac)
}

i <- 4

ab = matrix_index(14)
ab = matrix_index(27)

 kk <- which(tmp > 1.95)
 which(ab==k[i],arr.ind = T) 
