green <- read.csv("C:/Users/timot/Documents/GitHub/STA380/data/greenbuildings.csv",header=T)

edit <- green[green$leasing_rate > 10,]


non <- edit[edit$green_rating == 0,]
yes <- edit[edit$green_rating == 1,]

g <- as.factor(edit$green_rating)
edit$g <- g

for (i in 1:23){
  print(colnames(edit)[i])
  print(summary(lm(Rent~g*edit[,i],data = edit)))
}


#renovated, size, precipitation, total_dd_07, age, stories
attach(edit)
table(renovated,g)

boxplot(size~g)
summary(aov(size~g))

# sample bias
boxplot(Precipitation~g)

boxplot(total_dd_07~g)

boxplot(age~g)


boxplot(stories~g)
cor(stories,as.numeric(g))

mean(non$Rent)
mean(yes$Rent)
