/*  
  Aggregate tick data into 1-minute bins.  
  Each bin contains timestamps strictly *earlier than* the bucket label, except for last bucket.
  So first bucket, 09:31, contains timestamps 09:30:00 through 09:30:59, inclusive.
  Use subquery to define "tminute" as the appropriate 1-minute bin for each trade.
  Use CASE statement in order to provide special handling for the final bucket, #390, which has one extra second.
  Use DECLARE/SET to define query parameters with SQL variables rather than using literal values down below.
  [11/23/2016 pfm, revised 11/30/2018 yb]
*/


-- Declare and initialize SQL variables for parameters of interest

declare @date_first date
declare @date_last date
declare @start_of_day time(0)
declare @end_of_day time(0)
declare @last_minute int

declare @ticker_list table(ticker char(6))

set @date_first   = '05/05/2010'
set @date_last    = '05/06/2010'
set @start_of_day = '09:30:00'
set @end_of_day   = '16:00:00'
set @last_minute  = datediff(minute,@start_of_day,@end_of_day)

insert into @ticker_list values ('DIA'),('AIG'),('KO'),('PG')

select
  symbol,
  [date],
  dateadd(minute,tminute,@start_of_day) as [time],
  min([time]) as tmin,
  max([time]) as tmax,
  tminute,
  count(size) as numtrades,
  avg(price) as pavg,
  sum(price*size)/sum(size) as vwap,
  min(price) as pmin,
  max(price) as pmax,
  stdev(price) as pstd,
  sum(size) as q,
  avg(size) as qavg
from
(
select
  symbol,
  [date],
  [time],
  case when ([time] < @end_of_day) 
    then (datediff(minute,@start_of_day,[time])+1) 
    else @last_minute
  end as tminute,
  price,
  size
from taq.dbo.trade T
where
  ([date] between @date_first and @date_last)
  and (symbol in (select ticker from @ticker_list))
) as X
group by symbol, [date], tminute
order by symbol, [date], tminute
