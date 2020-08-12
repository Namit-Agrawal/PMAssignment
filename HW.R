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


####################################################

library(quantmod)
mystocks <- c("GLD","USO","VNQ","BNO","SLV")
getSymbols(mystocks,from = "2014-01-01")

###

GLDa <- adjustOHLC(GLD)
USOa <- adjustOHLC(USO)
VNQa <- adjustOHLC(VNQ)
BNOa <- adjustOHLC(BNO)
SLVa <- adjustOHLC(SLV)

###

returns <- cbind(ClCl(GLDa),ClCl(USOa),ClCl(VNQa),ClCl(BNOa),ClCl(SLVa))
all.r <- as.matrix(na.omit(returns))
n <- nrow(all.r)

#wealth <- c()
boot.portfolio1 <- c()
set.seed(1)
for (i in 1:5000){
  total <- 100000
  weights <- rep(0.2,5)
  holdings <- total * weights
  for (i in 1:20){
    return.day <- resample(all.r,1,orig.ids = FALSE)
    holdings <- holdings*(1+return.day)
    #wealth <- c(wealth,holdings)
  }
  boot.portfolio1 <- c(boot.portfolio1,sum(holdings))
}

#wealth <- c()
boot.portfolio2 <- c()
set.seed(1)
for (i in 1:5000){
  total <- 100000
  weights <- c(0.96,0.01,0.01,0.01,0.01)
  holdings <- total * weights
  for (i in 1:20){
    return.day <- resample(all.r,1,orig.ids = FALSE)
    holdings <- holdings*(1+return.day)
    #wealth <- c(wealth,holdings)
  }
  boot.portfolio2 <- c(boot.portfolio2,sum(holdings))
}

#wealth <- c()
boot.portfolio3 <- c()
set.seed(1)
for (i in 1:5000){
  total <- 100000
  weights <- c(0.1,0.1,0.6,0.1,0.1)
  holdings <- total * weights
  for (i in 1:20){
    return.day <- resample(all.r,1,orig.ids = FALSE)
    holdings <- holdings*(1+return.day)
    #wealth <- c(wealth,holdings)
  }
  boot.portfolio3 <- c(boot.portfolio3,sum(holdings))
}

hist(boot.portfolio1)
hist(boot.portfolio2)
hist(boot.portfolio3)

summary(boot.portfolio1)
summary(boot.portfolio2)
summary(boot.portfolio3)

abs(quantile(boot.portfolio1 - 100000,prob = 0.05))
abs(quantile(boot.portfolio2 - 100000,prob = 0.05))
abs(quantile(boot.portfolio3 - 100000,prob = 0.05))







