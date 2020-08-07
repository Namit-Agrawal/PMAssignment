green <- read.csv("C:/Users/timot/Documents/GitHub/STA380/data/greenbuildings.csv",header=T)

edit <- green[green$leasing_rate > 20,]


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

###########################################################


abia <- read.csv("C:/Users/timot/Documents/GitHub/STA380/data/ABIA.csv", header = T)

attach(abia)
#mask <- complete.cases(abia)
#abia <- abia[mask,]

library(ggplot2)


#ggplot(data = abia) + geom_point(mapping = aes(x = abia$DayOfWeek, y = abia$))
NotCancelled <- ifelse(abia$Cancelled == 0, 1, 0)
edit <- abia
edit$NotCancelled <- NotCancelled

subset <- edit[,c(4,22,23,30)]
sub <- table(subset$DayOfWeek,subset$NotCancelled)
sub <- as.data.frame(matrix(sub,nrow = 7,ncol = 2))

sub$sum <- sub[,1] + sub[,2]
sub$prop <- sub$V2/sub$sum

sub$Days <- c("M","T","W","Th","F","Sat","Sun")
sub <- sub[,c(4,5)]


ggplot(data = sub,aes(x = Days,y=prop)) + geom_bar(stat = "identity",fill = 1:7)


new <- subset[subset$Cancelled == 1,]