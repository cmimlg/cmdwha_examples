.libPaths("/home/admin123/R/x86_64-pc-linux-gnu-library/3.2")
library(homals)
library(dplyr)
library(xtable)
library(datasets)

fp = "/home/admin123/Clustering_MD/Paper/clustering.experiments/heart_uci.csv"
df = read.table(fp, sep = "\t", header = TRUE)
diagnosis = df[,"Dis"]
req.cols = setdiff(names(df), "Dis")
df = df[,req.cols]
all.vars = names(df)
nom.vars = c("RECG", "CP", "Thal","Sex", "FBS", "EIA")
ord.vars = "SST"
cat.vars = c(nom.vars, ord.vars)
numeric.vars = setdiff(all.vars, cat.vars)

df.num.vars = as.data.frame(scale(df[, numeric.vars]))
df.nom.vars = df[, nom.vars]
df.nom.vars = apply(df.nom.vars,2, as.factor)
df.ord.vars = as.data.frame(factor(df$SST, ordered = TRUE))
names(df.ord.vars) = "SST"
df.col.ordered = cbind(df.num.vars, df.nom.vars, df.ord.vars)
# Run homals on the sample to obtain optimal scaling
var.levels = c(rep("nominal",6 ), "ordinal")
df.cat.vars = df.col.ordered[,cat.vars]
homals.fit = homals(df.cat.vars, ndim = 7, level = var.levels)
plot(homals.fit, plot.type = "screeplot", main = "Heart Disease Dataset Scree Plot")
df.hm.ev1 = as.data.frame(homals.fit$scoremat[,,1])
names(df.hm.ev1) = paste(names(df.hm.ev1), "1", sep = "_")
df.hm.ev2 = as.data.frame(homals.fit$scoremat[,,2])
names(df.hm.ev2) = paste(names(df.hm.ev2), "2", sep = "_")
df.hm.ev3 = as.data.frame(homals.fit$scoremat[,,3])
names(df.hm.ev3) = paste(names(df.hm.ev3), "3", sep = "_")
df.hm.ev4 = as.data.frame(homals.fit$scoremat[,,4])
names(df.hm.ev4) = paste(names(df.hm.ev4), "4", sep = "_")
df.hm.ev5 = as.data.frame(homals.fit$scoremat[,,5])
names(df.hm.ev5) = paste(names(df.hm.ev5), "5", sep = "_")
df.hm.ev6 = as.data.frame(homals.fit$scoremat[,,6])
names(df.hm.ev6) = paste(names(df.hm.ev6), "6", sep = "_")

df.hm.cons = cbind(df.hm.ev1, df.hm.ev2, df.hm.ev3, df.hm.ev4, df.hm.ev5, df.hm.ev6)

df.homals = cbind(df.num.vars, df.hm.cons)

pamk.homals = pamk(df.homals, krange=2:10, criterion = "asw")
homals.labels.pamk = pamk.homals$pamobject$clustering

df.col.ordered$Cluster = homals.labels.pamk
df.col.ordered$Dis = diagnosis
df.gb = group_by(df.col.ordered, Cluster, Dis)
df.summary = dplyr::summarize(df.gb, count = n())

df.clus1 = filter(df.col.ordered, Cluster == '1')
df.clus1.gb = group_by(df.clus1, Thal)
df.clus1.summary = dplyr::summarize(df.clus1.gb, count = n())
names(df.summary) = c("Cluster", "Disease_Code", "Count")
df.summary$Disease_Code = as.factor(df.summary$Disease_Code)
#recode Disease_Status
df.summary$Disease_Status = ifelse(df.summary$Disease_Code == '1', "Absent", "Present")
req.cols = setdiff(names(df.summary), "Disease_Code")
df.summary = df.summary[,req.cols]
print(xtable(df.summary,caption = "mtcars Clusters"), include.rownames = FALSE)



# The following segment was used to generate the tables for the tex document
df.var.types = data.frame(names(df))
df.var.types$Description = c("Age", "Sex", "Chest Pain Type", "Resting Blood Pressure",
                             "Serum Cholesterol", "Is fasting blood Sugar over 120",
                             "Resting electrocardiographic results (values 0,1,2) ",
                             "Maximum heart rate achieved",
                             " Exercise induced angina ",
                             "Oldpeak = ST depression induced by exercise relative to rest ",
                             "The slope of the peak exercise ST segment",
                             "Number of major vessels (0-3) colored by flourosopy ",
                             "Thal: 3 = normal; 6 = fixed defect; 7 = reversable defect ")
df.var.types$Type = c("Continuous", "Nominal", "Nominal", "Continuous", "Continuous",
                      "Nominal", "Nominal", "Continuous", "Nominal", "Continuous",
                      "Ordinal", "Continuous", "Nominal")
names(df.var.types) = c("Variable", "Description", "Type")
print(xtable(df.var.types, caption = "Heart Disease Data Types"), include.rownames = FALSE)
