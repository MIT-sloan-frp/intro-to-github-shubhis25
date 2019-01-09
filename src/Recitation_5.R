###                                             ###
### 15.459 Financial Data Science and Computing ###
###             Youssef Berrada                 ###
###             yberrada@mit.edu                ###
###                Fall 2018                    ###

library('dplyr')
library(data.table)
library('ggplot2')
library('xtable')

# Data Acquisition
df = fread('projF.csv')
#colnames(df)<-c('symbol','date','time','tmin','tmax','tminute','numtrades','pavg','vwap','pmin','pmax','pstd','q','qavg')

# Data Pre-processing
summary(df)
str(df)
# ...

# Data Analysis
Q<-df %>% group_by(date,symbol) %>% summarise(HIGH = max(pmax),OPEN = first(pavg))
xtable(Q)
Q$date = as.Date(Q$date)

Q_xts = as.xts(Q$HIGH,Q$date)


df_bis = fread('/Users/youssefberrada/Desktop/AAPL.csv')
#colnames(df_bis)<-c('sym_root','date','time_m','tmin','tmax','tsecond','numtrades','pavg','vwap','pmin','pmax','pstd','q','qavg')

Q_bis<-df_bis %>%
  group_by(date)%>%
  separate(time_m,c('h','m','s')) %>%
  group_by(date,h,m)%>% 
  summarise(price=sum(vwap*q)/sum(q))%>%
  unite('time',c('h','m'),sep = ":")


Q_bis$date = as.POSIXct(paste(Q_bis$date, Q_bis$time), format="%Y-%m-%d %H:%M")
Q_bis_xts = as.xts(Q_bis$price,Q_bis$date)

# Data Presentation
plot.xts(Q_xts)
plot.xts(Q_bis_xts)


A2 = df[df$symbol=='AIG' & df$date=='2010-05-06']
D2 = df[df$symbol=='DIA' & df$date=='2010-05-06']
K2 = df[df$symbol=='KO' & df$date=='2010-05-06']
P2 = df[df$symbol=='PG' & df$date=='2010-05-06']

dat1 = data.frame('time'=A1$time,'AIG'=A1$vwap,'DIA'=D1$vwap,'KO'=K1$vwap,'PG'=P1$vwap)
ggplot(data = dat1, aes(x=time,y=AIG))

dat1 = rbind(A1[,c('symbol','time','vwap')],D1[,c('symbol','time','vwap')],K1[,c('symbol','time','vwap')],P1[,c('symbol','time','vwap')])
ggplot(data = dat1, aes(x=time,y=vwap,colour=symbol,group=symbol))+geom_line()
ggplot(data = P2,aes(x=a,y=vwap,group=1))+geom_line()+xlab('Time')+ylab('Price')
qplot(x=A1$time,y=A1$vwap,group=1)+geom_line()+scale_x_continuous(breaks = pretty(dat$x, n = 10))

A1$date=as.Date(A1$date)
a=strptime(A1$time,format = "%H:%M:%S")
#A1_xts = as.xts(A1$vwap,order.by = A1$time)
#plot.xts(A1_xts)

ticker = c('AIG','DIA','KO','PG')
ind1 = which(A1$vwap==min(A1$vwap))
ind2 = which(D1$vwap==min(D1$vwap))
ind3 = which(K1$vwap==min(K1$vwap))
ind4 = which(P1$vwap==min(P1$vwap))
A1[ind1,]
min = matrix(c('AIG',A1[ind1,'time'],A1[ind1,'vwap']),nrow=1)


min = df %>%
  group_by(symbol)%>%
  select(time,vwap)

final1 = data.frame('time'=A1$time,'AIG1'=A1$vwap,'DIA1'=D1$vwap,'KO1'=K1$vwap,'PG1'=P1$vwap,'AIG2'=A2$vwap,'DIA2'=D2$vwap,'KO2'=K2$vwap,'PG2'=P2$vwap)
minprice = apply(final1, 2, min)
minprice=minprice[-1]
minindex = apply(final1, 2, function(x) which.min(x))
a=as.vector(minindex)
mintime=0
for (i in 1:length(a)) {
  p=final1$time[a[[i]]]
  print(p)
  mintime = c(mintime,p)
}

a=rbind(minprice,mintime)
xtable(a[,1:4])
xtable(a[,5:8])

which.min(final1$AIG2)
