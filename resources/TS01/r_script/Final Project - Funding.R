# Two packages needed for this modelling are ggplot2 and forecast, make sure you install them before running this script.
# Below is code for ACF and PACF of time series model
library(forecast)
Residualm3=scan("residual_model_3.txt",skip=1)
tsdisplay(Residualm3)


Residualm1lag1=scan("residual_model_5.txt",skip=1)
tsdisplay(Residualm1lag5)

######################################################
# Arima Model R script
# Import data
y=read.csv("AverageFund.csv")
head(y)
tail(y)

# create a time series object
y.ts=ts(y,start=c(2006,2),frequency = 4)
y.ts

# upload library forecast(models and time series visualization functions)
library(forecast)
library(ggplot2)

# create a seasonal graph for subset of data
ggseasonplot(window(y.ts,start=c(2006,2)),main="Seasonal Plot")+geom_point()

# Divide data into training and testing sets
train.start=c(2006,2)
train.end=c(2014,4)
test.start=c(2015,1)
test.end=c(2015,4)

train.ts=window(y.ts,start=train.start,end=train.end)
test.ts=window(y.ts,start=test.start,end=test.end)

# size of training and testing sets
nTrain=length(train.ts)
nTest=length(test.ts)



# Build ARIMA model
M1=auto.arima(train.ts,lambda="auto")

# Generate future forecast
M1F=forecast(M1,h=nTest,level=95)

# predicted values on testing set
M1F

# Fitted values
fitted(M1)

# plot data and prediction
autoplot(M1F)+ autolayer(test.ts)+autolayer(fitted(M1))

# accuracy metrics
accuracy(M1F,test.ts)[,c("RMSE","MAPE")]

# residual diagnistics
checkresiduals(M1)
