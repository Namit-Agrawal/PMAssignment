library(mosaic)
library(ggplot2)
library(reshape)
greenBuild = read.csv("greenbuildings.csv", stringsAsFactors = FALSE)
greenBuild$green_rating = as.factor(greenBuild$green_rating)
abia = read.csv("abia.csv", stringsAsFactors = FALSE)
abia$Month = as.factor(abia$Month)
abia$DayOfWeek = as.factor(abia$DayOfWeek)


abia$DepHour=sapply(abia$DepTime, function(x) x%/%100)
abia$ArrHour=sapply(abia$ArrTime, function(x) x%/%100)

abia_austin_Dep = subset(abia, Origin == 'AUS')
abia_austin_Arr = subset(abia, Dest == 'AUS')

attach(abia)
#Distance Flown by each carrier
ggplot(abia, aes(x=Month, y=Distance)) + 
  geom_bar(stat='identity') +geom_bar(stat='identity') +
  facet_wrap(~ UniqueCarrier, nrow = 4)

delay_dep_sum = abia_austin_Dep %>%
  group_by(DayOfWeek)  %>%  
  summarize(ToDepDelay = sum(DepDelay, na.rm = TRUE)) 

delay_arr_sum = abia_austin_Arr %>%
  group_by(DayOfWeek)  %>%  
  summarize(ToArrDelay = sum(ArrDelay, na.rm = TRUE)) 
delay_sum = merge(delay_dep_sum, delay_arr_sum, by="DayOfWeek")
delay_sum <- melt(delay_sum, id.vars = 'DayOfWeek')

#Compare depDelays and ArrDelays for each day of week
ggplot(delay_sum, aes(x=DayOfWeek, y=value, fill=variable )) + 
  geom_bar(stat='identity', position='dodge') 
  

num_dep_delay_by_carrier = abia_austin_Dep %>%
  group_by(UniqueCarrier)  %>%  
  summarize(AvgDepDelay = mean(DepDelay, na.rm = TRUE)) 

num_arr_delay_by_carrier = abia_austin_Arr %>%
  group_by(UniqueCarrier)  %>%  
  summarize(AvgArrDelay = mean(ArrDelay, na.rm = TRUE)) 

num_delay_by_carrier = merge(num_dep_delay_by_carrier, num_arr_delay_by_carrier, by="UniqueCarrier")
num_delay_by_carrier = as.data.frame(num_delay_by_carrier)
num_delay_by_carrier <- melt(num_delay_by_carrier, id.vars = 'UniqueCarrier')

#Compare which airline has the most avg delays for departure and arrival
ggplot(num_delay_by_carrier, aes(x=UniqueCarrier, y=value, fill=variable )) + 
  geom_bar(stat='identity', position='dodge') 


num_cancelled_by_carrier = abia %>%
  group_by(UniqueCarrier, CancellationCode)  %>%  
  summarize(Cancelprob = sum(Cancelled, na.rm = TRUE))

num_cancelled_dummy = abia %>%
  group_by(UniqueCarrier)  %>%  
  summarize(Total = length(Cancelled))
Cancellation_probs=merge(num_cancelled_by_carrier, num_cancelled_dummy, by="UniqueCarrier")
Cancellation_probs$True_prob = Cancellation_probs$Cancelprob/Cancellation_probs$Total
Cancellation_probs = subset(Cancellation_probs, CancellationCode=='A' | CancellationCode=='B' | CancellationCode=='C' )
Cancellation_probs$CancellationCode = ifelse(Cancellation_probs$CancellationCode=='A', "Carrier", ifelse(Cancellation_probs$CancellationCode =="B", "Weather", "NAS"))
#Compare which airline has the highest possiblity for cancellation
ggplot(Cancellation_probs, aes(x=UniqueCarrier, y=True_prob, fill=CancellationCode )) + 
  geom_bar(stat='identity', position='dodge') 

num_flights_dep_per_hour = abia_austin_Dep %>%
  group_by(DepHour)  %>%  
  summarize(TotalDep = length(DepHour))

num_flights_arr_per_hour = abia_austin_Arr %>%
  group_by(ArrHour)  %>%  
  summarize(TotalArr = length(ArrHour))

num_flights_arr_per_hour=subset(num_flights_arr_per_hour, !is.na(ArrHour))
num_flights_dep_per_hour=subset(num_flights_dep_per_hour, !is.na(DepHour))
colnames(num_flights_arr_per_hour)[1] <- "Hour"
colnames(num_flights_dep_per_hour)[1] <- "Hour"

num_flights_per_hours = merge(num_flights_arr_per_hour, num_flights_dep_per_hour, by="Hour")
num_flights_per_hours <- melt(num_flights_per_hours, id.vars = 'Hour')

ggplot(num_flights_per_hours, aes(x=Hour, y=value, fill=variable )) + 
  geom_bar(stat='identity', position='dodge') 

cor(greenBuild)

ggplot(data=greenBuild) + 
  geom_point(mapping=aes(x=cluster_rent, y=Rent, colour=green_rating)) +
  labs(x="Cluster Rent", y='Rent', title = 'Green buildings: Cluster rent VS Rent',
       color='Green building')

ggplot(data=greenBuild) + 
  geom_point(mapping=aes(x=stories, y=Rent, colour=green_rating)) +
  labs(x="Electricity", y='Rent', title = 'Green buildings: Cluster rent VS Rent',
       color='Green building')

ggplot(data=greenBuild) + 
  geom_point(mapping=aes(x=leasing_rate, y=Rent, colour=green_rating)) +
  labs(x="Leasing Rate", y='Rent', title = 'Green buildings: Cluster rent VS Rent',
       color='Green building')

ggplot(data=greenBuild) + 
  geom_point(mapping=aes(x=size, y=Rent, colour=green_rating)) +
  labs(x="Size", y='Rent', title = 'Green buildings: Cluster rent VS Rent',
       color='Green building')
