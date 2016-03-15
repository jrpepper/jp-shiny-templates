library(zipcode)
data(zipcode)
library(rgdal)
library(plyr)
library(ggplot2)
library(lubridate)


ca.zip <- zipcode[zipcode$state=="CA",]
ca.zip$value1 <- runif(dim(ca.zip)[1], 100, 1000)
ca.zip$value2 <- runif(dim(ca.zip)[1], 1, 10)
ca.zip$date <- ymd("20150101") + ddays(runif(dim(ca.zip)[1], 0, 365))
ca.zip$date <- ca.zip$date %>% as.Date()

zip.shape <- readOGR("./data/", layer="californiaZIP")

zip.shape@data = data.frame(zip.shape@data, ca.zip[match(zip.shape@data[,"ZCTA5CE10"], ca.zip[,"zip"]),])
