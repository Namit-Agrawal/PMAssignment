library(mosaic)
library(ggplot2)
library(reshape)
library(chron)
greenBuild = read.csv("greenbuildings.csv", stringsAsFactors = FALSE)
greenBuild$green_rating = as.factor(greenBuild$green_rating)
abia = read.csv("abia.csv", stringsAsFactors = FALSE)
abia$Month = as.factor(abia$Month)
abia$DayOfWeek = as.factor(abia$DayOfWeek)


abia$DepHour=sapply(abia$DepTime, function(x) x%/%100)
abia$ArrHour=sapply(abia$ArrTime, function(x) x%/%100)

abia$Diff_DepTime=difftime(as.POSIXct((times=sub("(\\d+)(\\d{2})", "\\1:\\2", abia$DepTime)),
           format='%H:%M'),  as.POSIXct((times=sub("(\\d+)(\\d{2})", "\\1:\\2", abia$CRSDepTime)),
                                        format='%H:%M'), units="mins")
abia$Diff_DepTime=as.numeric(abia$Diff_DepTime)
abia_austin_Dep = subset(abia, Origin == 'AUS')
abia_austin_Arr = subset(abia, Dest == 'AUS')

attach(abia)
#Distance Flown by each carrier
ggplot(abia, aes(x=Month, y=Distance)) + 
  geom_bar(stat='identity') +geom_bar(stat='identity') +
  facet_wrap(~ UniqueCarrier, nrow = 4)+
  labs(title="Distance traveled by different airlines each month", 
       y="Distance",
       x = "Month")+
  theme(plot.title = element_text(hjust = 0.5))

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
  geom_bar(stat='identity', position='dodge') +
  labs(title="Cumlative departure and arrival delay for each day of week", 
       y="Total Delay Time",
       x = "Day Of the Week (1-Monday)",
       fill="Delay")+
  theme(plot.title = element_text(hjust = 0.5))
  

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
  geom_bar(stat='identity', position='dodge') +
  labs(title="Average departure and arrival delay for each airline", 
       y="Average Delay Time",
       x = "Airline Carrier Code",
       fill="Delay")+
  theme(plot.title = element_text(hjust = 0.5))


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
  geom_bar(stat='identity', position='dodge')+
  labs(title="Probabilty of delay for each airline by type of delay", 
       y="Total Delay Time",
       x = "Day Of the Week (1-Monday)",
       fill="Type of Delay")+
  theme(plot.title = element_text(hjust = 0.5))

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
  geom_bar(stat='identity', position='dodge') +
  labs(title="Number of flights at ABIA for each hour by departure and arrival", 
       y="Number of Flights",
       x = "Hour",
       fill="Departure-Arrival")+
  theme(plot.title = element_text(hjust = 0.5))

num_flights_going_from_Aus = abia_austin_Dep %>%
  group_by(Dest)  %>%  
  summarize(DestinationCity = length(Dest))

num_flights_going_To_Aus = abia_austin_Arr %>%
  group_by(Origin)  %>%  
  summarize(OriginCity = length(Origin))

num_flights_going_from_Aus=as.data.frame(num_flights_going_from_Aus)
num_flights_going_To_Aus = as.data.frame(num_flights_going_To_Aus)

top_ten_dest=num_flights_going_from_Aus[order(-num_flights_going_from_Aus$DestinationCity),][1:10,]
top_ten_ori =  num_flights_going_To_Aus[order(-num_flights_going_To_Aus$OriginCity),][1:10,]
colnames(top_ten_dest)[1] <- "City"
colnames(top_ten_ori)[1] <- "City"
top_ten_city = merge(top_ten_dest, top_ten_ori, by="City")
top_ten_city <- melt(top_ten_city, id.vars = 'City')


ggplot(top_ten_city, aes(x=City, y=value, fill=variable )) + 
  geom_bar(stat='identity', position='dodge') +
  labs(title="Top 10 cities for incoming and outgoing flights", 
       y="Number of Flights",
       x = "City",
       fill="Type")+
  theme(plot.title = element_text(hjust = 0.5))

Avg_Time_By_Carrier = abia_austin_Dep %>%
  group_by(UniqueCarrier)  %>%  
  summarize(Avg_Time = mean(ActualElapsedTime, na.rm = TRUE))

ggplot(Avg_Time_By_Carrier, aes(x=UniqueCarrier, y=Avg_Time)) + 
  geom_bar(stat='identity') +
  labs(title="Average Air Time for each airline", 
       y="Avg Time",
       x = "Airline Carrier Code")+
  theme(plot.title = element_text(hjust = 0.5))

Avg_Time_By_Carrier = abia_austin_Dep %>%
  group_by(UniqueCarrier)  %>%  
  summarize(Avg_Time = mean(ActualElapsedTime, na.rm = TRUE))
abia_austin_Dep=transform(abia_austin_Dep, Diff_Category=ifelse(Diff_DepTime>=0 & Diff_DepTime<10, "0-10", 
                                         ifelse(Diff_DepTime>=10 & Diff_DepTime<20, "10-20",
                                                ifelse(Diff_DepTime>=20 & Diff_DepTime<30, "20-30",
                                                       ifelse(Diff_DepTime>=30, "30+",
                                                              ifelse(Diff_DepTime<0 & Diff_DepTime>=-10, "-10-0",
                                                                     ifelse(Diff_DepTime<-10, "-10+")))))))

Diff_Dep_Time = abia_austin_Dep %>%
  group_by(Diff_Category)  %>%  
  summarize(Times = length(Diff_Category))
Diff_Dep_Time=subset(Diff_Dep_Time, !is.na(Diff_Category))
temp=Diff_Dep_Time
temp[1,]=Diff_Dep_Time[2,]
temp[2,]=Diff_Dep_Time[1,]
Diff_Dep_Time=temp
ggplot(Diff_Dep_Time, aes(x=reorder(Diff_Category, -Times), y=Times)) + 
  geom_bar(stat='identity')+
  labs(title="Difference between Actual and Scheduled Departure Time", 
       y="Number of Flights",
       x = "Time Difference (Minutes)")+
  theme(plot.title = element_text(hjust = 0.5))

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
