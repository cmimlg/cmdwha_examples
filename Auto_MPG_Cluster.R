.libPaths("/home/admin123/R/x86_64-pc-linux-gnu-library/3.2")
library(homals)
library(dplyr)
library(xtable)
library(datasets)
library(fpc)

data("mtcars")
df = as.data.frame(mtcars)
df$cyl = factor(df$cyl, ordered = TRUE)
df$vs = as.factor(df$vs)
df$am = as.factor(df$am)
df$gear = factor(df$gear, ordered = TRUE)
df$carb = factor(df$carb, ordered = TRUE)
car.names = row.names(df)

numeric.vars = c("mpg","disp", "hp", "drat", "wt", "qsec")
ordinal.vars = c("cyl", "gear", "carb")
nominal.vars = c("vs", "am")
df.numeric = as.data.frame(scale(df[, numeric.vars]))
df = cbind(df.numeric, df[,nominal.vars], df[, ordinal.vars])

# Run homals on the sample to obtain optimal scaling
#var levels - first seven numeric, next two nominal, next two ordinal
df.homals = df[, 7:11]

var.levels = c(rep("nominal",2 ), rep("ordinal", 3))
homals.fit = homals(df.homals, ndim = 5, level = var.levels)
plot(homals.fit, plot.type = "screeplot", main = "Auto MPG Dataset Scree Plot")
df.hm.ev1 = as.data.frame(homals.fit$scoremat[,,1])
names(df.hm.ev1) = paste(names(df.hm.ev1), "1", sep = "_")
df.hm.ev2 = as.data.frame(homals.fit$scoremat[,,2])
names(df.hm.ev2) = paste(names(df.hm.ev2), "2", sep = "_")
df.hm.ev3 = as.data.frame(homals.fit$scoremat[,,3])
names(df.hm.ev3) = paste(names(df.hm.ev3), "3", sep = "_")
df.hm.ev4 = as.data.frame(homals.fit$scoremat[,,4])
names(df.hm.ev4) = paste(names(df.hm.ev4), "4", sep = "_")
df.hm.cons = cbind(df.hm.ev1, df.hm.ev2, df.hm.ev3, df.hm.ev4)
df.homals = cbind(df.numeric, df.hm.cons)


pamk.homals = pamk(df.homals, krange=2:10, criterion="asw")
homals.labels.pamk = pamk.homals$pamobject$clustering


df.homals$Cluster = homals.labels.pamk
df.clus = as.data.frame(as.integer(df.homals[, "Cluster"]))
df.clus$car.names = car.names
df.clus$HP = mtcars$hp
df.clus$cyl = as.integer(mtcars$cyl)
names(df.clus) = c("Cluster", "Car", "HP", "Cylinders")
## Subset the clusters
df.clus = df.clus[order(df.clus$Cluster),]
df.clus.1 = filter(df.clus, Cluster == '1')
df.clus.2 = filter(df.clus, Cluster == '2')
#print(xtable(df.clus.1,caption = "mtcars Clusters"), include.rownames = FALSE)
#print(xtable(df.clus.2, caption = "mtcars Clusters"), include.rownames = FALSE)




