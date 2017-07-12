library(dplyr)
library(homals)
library(sampling)
library(gdata)

set.seed(4314)
setwd("/home/admin123/Clustering_MD/Paper/clustering.experiments/")
fp = "clean_jan_2016_data.csv"
df = read.csv(fp, strip.white = TRUE)
req.cols = setdiff(names(df), c("X", "CANCELLED", "DIVERTED", "FL_NUM"))
df = df[, req.cols]
df = na.omit(df)
df = filter(df, ARR_DELAY <= 155)
# do the time preprocessing
df = mutate (df,
             CADT  = ifelse ( nchar(CRS_DEP_TIME) < 4,
                              paste(substr(CRS_DEP_TIME,1,1),
                                    substr(CRS_DEP_TIME,2,nchar(CRS_DEP_TIME)), "00", sep = ":"),
                              paste(substr(CRS_DEP_TIME,1,2),
                                    substr(CRS_DEP_TIME,3,nchar(CRS_DEP_TIME)),"00", sep = ":")),
             DDT = paste("2016", "1", df[,"DAY_OF_MONTH"], sep = "-"),
             LADT = paste(DDT, CADT, sep = " "))


df$FDDT = strptime(df$LADT, format =  "%Y-%m-%d %H:%M:%S")
ref.time = strptime("2016-1-1 12:00:00", format =  "%Y-%m-%d %H:%M:%S")
df$NDDT = as.numeric(difftime(df[,"FDDT"], ref.time), units = "mins")

req.cols = setdiff(names(df), c("FDDT", "CADT", "DDT", "LADT", "CRS_DEP_TIME"))
df = df[,req.cols]
df = na.omit(df)



#set the day of week and day of month as factors
df$DAY_OF_MONTH = as.factor(df$DAY_OF_MONTH)
df$DAY_OF_WEEK = as.factor(df$DAY_OF_WEEK)


# Obtain the strata for these variables in the data
delay.gb = group_by(df, ORIGIN, DEST)
df.strata.summary = dplyr::summarize(delay.gb, operation_count = n(),
                                     avg_delay = mean(ARR_DELAY))
df.strata.summary = filter(df.strata.summary, operation_count >= 10)
df.strata.summary = mutate(df.strata.summary, sample.frac = ceiling(0.02*operation_count))
df.strata.summary = as.data.frame(arrange(df.strata.summary, ORIGIN, DEST))
# free some memory
delay.gb = NULL
df = inner_join(df, df.strata.summary, by = c("ORIGIN", "DEST"))
req.cols = setdiff(names(df), c("operation_count", "sample.frac", "avg_delay"))
df = df[, req.cols]
df = as.data.frame(arrange(df, ORIGIN, DEST))

#write out the cleaned original datafile for use in cluster analysis
fp.unscaled = "jan_2016_unscaled_clean_for_clus_anal.csv"
write.csv(df, fp.unscaled, row.names = FALSE)

# Now scale the numeric variables in the dataset for analysis going forward
df = cbind(df[, 1:5], scale(df[,6:11]))

strata.size = df.strata.summary$sample.frac
the.strata = c("ORIGIN", "DEST")
s = strata(df, the.strata, size = strata.size, method = "srswor")
df.sample = getdata(df, s)
req.cols = names(df)
df.sample = df.sample[, req.cols]





# Run homals on the sample to obtain optimal scaling
var.levels = c(rep("ordinal",2), rep("nominal", 3))
df.homals = df.sample[,1:5]
homals.fit.sample = homals(df.homals, ndim = 4, level = var.levels)
plot(homals.fit.sample, plot.type = "screeplot", main = "Airline 2016 Jan Delays Dataset Scree Plot")


recoderFunc <- function(data, oldvalue, newvalue) {
  
  # convert any factors to characters
  
  if (is.factor(data))     data     <- as.character(data)
  if (is.factor(oldvalue)) oldvalue <- as.character(oldvalue)
  newvalue <- as.numeric(newvalue)
  
  # create the return vector
  
  newvec <- data
  
  # put recoded values into the correct position in the return vector
  
  for (i in unique(oldvalue)) newvec[data == i] <- newvalue[oldvalue == i]
  
  newvec
  
}

cat.vars = names(df)[sapply(df, is.factor)]
df = drop.levels(df)
num.eigen.values = 3

for(var in cat.vars)  {
  old.var.levels = as.factor(levels(df[,var]))
  cat("Processing ", var, "...", "\n")
  for (e in 1:num.eigen.values)  {
    cat("processing eigen value", e, "...", "\n")
    temp.var.name = paste("homals.fit.sample$catscores$", var, "[,", e, "]", sep = "")
    new.var.scores = eval(parse(text = temp.var.name))
    old.var.name =  paste("df$", var, sep ="")
    old.var.values = as.factor(eval(parse(text = old.var.name)))
    recoded.values = recoderFunc(old.var.values, old.var.levels, new.var.scores)
    new.recodev.var.name = paste(var, ".R.", e, sep ="")
    df[, new.recodev.var.name] = recoded.values
  }
  
}


# drop the old month, DOW, DOM columns and use the new recoded ones
req.cols = setdiff(names(df), c("DAY_OF_WEEK", "DAY_OF_MONTH","CARRIER", "ORIGIN", "DEST"))
df = df[, req.cols]
# Write the recoded file out to disk for clustering by mini batch K means
fp = "/home/admin123/Clustering_MD/Paper/clustering.experiments/Jan_2016_Delays_Recoded.csv"
write.csv(df, fp, row.names = FALSE)

