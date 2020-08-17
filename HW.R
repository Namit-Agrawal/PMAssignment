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

plot(ClCl(GLDa),main = "GLD Price since 2014",
     xlab = "Amount in Dollars")
plot(ClCl(USOa),main = "USO Price since 2014",
     xlab = "Amount in Dollars")
plot(ClCl(VNQa),main = "VNQ Price since 2014",
     xlab = "Amount in Dollars")
plot(ClCl(BNOa),main = "BNO Price since 2014",
     xlab = "Amount in Dollars")
plot(ClCl(SLVa),main = "SLV Price since 2014",
     xlab = "Amount in Dollars")

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

hist(boot.portfolio1,main = "Portfolio 1 Returns",
     xlab = "Amount in Dollars")
hist(boot.portfolio2,main = "Portfolio 2 Returns",
     xlab = "Amount in Dollars")
hist(boot.portfolio3,main = "Portfolio 3 Returns",
     xlab = "Amount in Dollars")

summary(boot.portfolio1)
summary(boot.portfolio2)
summary(boot.portfolio3)

hist(boot.portfolio1 - 100000, breaks = 30,main = "Portfolio 1 profit/loss",
     xlab = "Amount in Dollars")
hist(boot.portfolio2 - 100000, breaks = 30,main = "Portfolio 2 profit/loss",
     xlab = "Amount in Dollars")
hist(boot.portfolio3 - 100000, breaks = 30,main = "Portfolio 3 profit/loss",
     xlab = "Amount in Dollars")

abs(quantile(boot.portfolio1 - 100000,prob = 0.05))
abs(quantile(boot.portfolio2 - 100000,prob = 0.05))
abs(quantile(boot.portfolio3 - 100000,prob = 0.05))


####################################################################


social <- read.csv("social_marketing.csv",header = T)


library(ggplot2)
library(tidyverse)

scaled <- as.data.frame(scale(social[,-c(1)],center = T,scale = T))
mu <- attr(scale(social[,-c(1)]), "scaled:center")
sigma <- attr(scale(social[,-c(1)]),"scaled:scale")


#####
ID <- as.data.frame(social[,1])

pca.social <- prcomp(scaled)
plot(pca.social)
plot(summary(pca.social)$importance[3,])

scaled.pca <- pca.social$x[,1:15]
head(round(pca.social$rotation[,1:3],2))


loadings.summary <- pca.social$rotation %>%
  as.data.frame() %>%
  rownames_to_column("Category")
# spam
spam <- loadings.summary %>%
  select(Category,PC1) %>%
  arrange(desc(PC1))

# young
young <- loadings.summary %>%
  select(Category,PC2) %>%
  arrange(desc(PC2))

# fit
fit <- loadings.summary %>%
  select(Category,PC3) %>%
  arrange(desc(PC3))

# college gamer
game <- loadings.summary %>%
  select(Category,PC4) %>%
  arrange(desc(PC4))

# college gamer
loadings.summary %>%
  select(Category,PC5) %>%
  arrange(desc(PC5))

# blogger
loadings.summary %>%
  select(Category,PC6) %>%
  arrange(desc(PC6))

# artist/travel enthusiast
art <- loadings.summary %>%
  select(Category,PC7) %>%
  arrange(desc(PC7))

# singles
loadings.summary %>%
  select(Category,PC10) %>%
  arrange(desc(PC10))



followers <- as.data.frame(pca.social$x)
rownames(followers) <- ID$social[, 1]

ggplot(young, aes(x=reorder(Category,PC2), y=PC2)) +
  geom_bar(stat='identity') + coord_flip()

ggplot(fit, aes(x=reorder(Category,PC3), y=PC3)) +
  geom_bar(stat='identity') + coord_flip()

ggplot(game, aes(x=reorder(Category,PC4), y=PC4)) +
  geom_bar(stat='identity') + coord_flip()



scaled <- as.data.frame(scale(social[,-c(1)],center = T,scale = T))
mu <- attr(scale(social[,-c(1)]), "scaled:center")
sigma <- attr(scale(social[,-c(1)]),"scaled:scale")


clust <- kmeanspp(scaled,k = 5,nstart = 25)
colors <- clust$cluster

subset <- pca.social$x[,c(3,4)]
plot(subset, col = colors, pch = 16)

###################################################


# ReadPlain function 

setwd("C:/Users/timot/Documents/GitHub/PMAssignment/")
library(tidyverse)
library(tm)
library(slam)
library(proxy)

readerPlain = function(fname){
  readPlain(elem=list(content=readLines(fname)), 
            id=fname, language='en') }


file_list <- Sys.glob("ReutersC50/C50train/*")

total <- c()
author <- c()

for (i in 1:length(file_list)){
  articles <- Sys.glob(as.character(paste(file_list[i],"/*.txt", sep = "")))
  author <- c(author,rep(strsplit(file_list[i],"/")[[1]][3],length(articles)))
  total <- c(total,articles)
}

data <- cbind(author,total)
data <- cbind(data,lapply(data[,2],readerPlain))


documents_raw <- Corpus(VectorSource(data[,3]))

my_documents <- documents_raw %>%
  tm_map(content_transformer(tolower))  %>%             
  tm_map(content_transformer(removeNumbers)) %>%        
  tm_map(content_transformer(removePunctuation)) %>%    
  tm_map(content_transformer(stripWhitespace))          

my_documents <- tm_map(my_documents, content_transformer(removeWords), stopwords("en"))

DTM_train <- DocumentTermMatrix(my_documents)
inspect(DTM_train[1:10,1:20])

DTM_train <- removeSparseTerms(DTM_train, 0.98)
tfidf_train = weightTfIdf(DTM_train)

# TEST SET

file_list2 <- Sys.glob("ReutersC50/C50test/*")

total2 <- c()
author2 <- c()

for (i in 1:length(file_list2)){
  articles2 <- Sys.glob(as.character(paste(file_list2[i],"/*.txt", sep = "")))
  author2 <- c(author2,rep(strsplit(file_list2[i],"/")[[1]][3],length(articles2)))
  total2 <- c(total2,articles2)
}

data2 <- cbind(author2,total2)
data2 <- cbind(data2,lapply(data2[,2],readerPlain))


documents_raw2 <- Corpus(VectorSource(data2[,3]))

my_documents2 <- documents_raw2 %>%
  tm_map(content_transformer(tolower))  %>%             
  tm_map(content_transformer(removeNumbers)) %>%        
  tm_map(content_transformer(removePunctuation)) %>%    
  tm_map(content_transformer(stripWhitespace))          

my_documents2 <- tm_map(my_documents2, content_transformer(removeWords), stopwords("en"))

DTM_test <- DocumentTermMatrix(my_documents2)
inspect(DTM_test[1:10,1:20])

DTM_test <- removeSparseTerms(DTM_test, 0.98)
tfidf_test <- weightTfIdf(DTM_test)

# FILTER

X_train <- as.matrix(tfidf_train)
scrub <- which(colSums(X_train) == 0)
X_train <- X_train[,-scrub]

X_test <- as.matrix(tfidf_test)
scrub2 <- which(colSums(X_test) == 0)
X_test <- X_test[,-scrub2]


# MATCH

train.cols <- colnames(X_train)
test.cols <- colnames(X_test)

match <- intersect(train.cols,test.cols)
X_test <- X_test[,match]
X_train <- X_train[,match]


# DIMENSION REDUCTION

pca.x <- prcomp(X_train,scale=T)
plot(summary(pca.x)$importance[3,])

train <- pca.x$x[,1:500]
test <- predict(pca.x,newdata = X_test)[,1:500]

# PREDICTION

train <- as.data.frame(cbind(author,train))
test <- as.data.frame(cbind(author2,test))

# Random forest

library(randomForest)

set.seed(1)
rf <- randomForest(as.factor(author)~.,data = train,importance = T,mtry = 20,ntree =500)

preds <- predict(rf,newdata = test)
tab <- table(preds,as.factor(test$author))
accuracy <- mean(preds==as.factor(author))
accuracy




# KNN

library(class)


knn <- knn(train[,-c(1)],test[,-c(1)],cl = factor(train$author), k = 1)

tab <- table(knn,factor(test$author2))
mean(knn == factor(test$author2))


#############################################################

library(arules)
library(arulesViz)
grocery <- read.delim("groceries.txt",sep = "\n",header = F)

baskets <- c()
for (i in 1:length(rownames(grocery))){
  current <- strsplit(grocery[i,],split = ",")
  baskets <- c(baskets,current)
}

length(baskets)

baskets.trans <- as(baskets,"transactions")
summary(baskets.trans)

# we want to ensure that there is at least 50% confidence that the rule is correct

# Baseline
basket.rules3 <- apriori(baskets.trans, parameter=list(support=.001, confidence=.1, maxlen=3))
arules::inspect(subset(basket.rules3, subset=lift > 1))

# 1
basket.rules <- apriori(baskets.trans, parameter=list(support=.05, confidence=.3, maxlen=3))
arules::inspect(subset(basket.rules, subset=lift > 1))

# 2
basket.rules <- apriori(baskets.trans, parameter=list(support=.02, confidence=.3, maxlen=3))
arules::inspect(subset(basket.rules, subset=lift > 1)[1:10])

# 3
basket.rules <- apriori(baskets.trans, parameter=list(support=.02, confidence=.3, maxlen=3))
arules::inspect(subset(basket.rules, subset=lift > 2))

# 4
basket.rules <- apriori(baskets.trans, parameter=list(support=.01, confidence=.3, maxlen=4))
arules::inspect(subset(basket.rules, subset=lift > 2))

# 5
basket.rules <- apriori(baskets.trans, parameter=list(support=.005, confidence=.01, maxlen=3))
arules::inspect(subset(basket.rules, subset=lift < 1)[76:77])



# choose #4

data <- subset(basket.rules, subset=lift > 2)



