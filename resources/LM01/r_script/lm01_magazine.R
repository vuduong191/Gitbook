mag_data <- read.csv("MagazineAds.csv")
sum(is.na(mag_data))
#import data
head(mag_data)
str(mag_data)
domestic <- as.numeric(as.numeric(mag_data$Market)==1)
#create a new dummy variable to describe Market variable
mag_data1 <- mag_data[,c(-1,-6)]
#remove the col with magazine name and the Market columns
mag_data1$domestic <- domestic
#add the dummy varible into the data frame

newdata<-data.frame(circ=1800,percmale = 60,medianincome = 80000,domestic = 0)
#create the data for Dr. Sam's magazine. Popular Statistics,  for prediction
for (i in 1:5){
  histi <- hist(mag_data1[,i], plot=FALSE)
  histi$density <-histi$counts/sum(histi$counts)*100
  plot(histi, freq = FALSE,main = paste("Histogram of" , colnames(mag_data1)[i]), xlab = colnames(mag_data1)[i])
}
#a loop that generates five histogram for 5 variables

summary(mag_data1)
#get the descriptive statistics for the variables 

plot(mag_data1)
#scatter plot
round(cor(mag_data1),2)
#correlation table with 2 decimal rounding
M1 = lm(pagecost~.,data = mag_data1)
summary(M1)
#install.packages("car") for vif testing
library(car)
vif(M1)

res_data1 <- residuals(M1)
plot(res_data1, type = "l")
abline(h=0,col="red")
qqnorm(res_data1)
qqline(res_data1, col = "red")
predicted_data1 <-predict(M1)
plot(predicted_data1,res_data1)
abline(h=0,col="red")
install.packages("lmtest")
library(lmtest)
dwtest(M1)
acf(res_data1)
shapiro.test(res_data1)
#Evaluate the required conditions: linearity, Homoscedasticity, Independence and normality only  
predict(M1,newdata = newdata, se.fit = TRUE, interval = "confidence")
#Preidict the pagecost and the prediction interval
mag_data2 <- mag_data1
mag_data2$pagecost <-log(mag_data2$pagecost)
colnames(mag_data2)[1] <-"ln.pagecost"
head(mag_data2)
#create another data and transform the pagecost

for (i in 2:5) {
  plot(mag_data2[,i],mag_data2[,1], xlab = colnames(mag_data2)[i], ylab = "ln.pagecost")}
M2<-lm(ln.pagecost~.,data = mag_data2)
summary(M2)
#plot ln.pagecost against all predictor variables

res_data2 <- residuals(M2)
plot(res_data2, type = "l")
abline(h=0,col="red")

qqnorm(res_data2)
qqline(res_data2, col = "red")
predicted_data2 <-predict(M2)
plot(predicted_data2,res_data2)
abline(h=0,col="red")
dwtest(M2)
acf(res_data2)
shapiro.test(res_data2)
#data normally distributed

#Evaluate the required conditions: linearity, Homoscedasticity, Independence and normality only  
mag_data3 <- mag_data2
mag_data3$circ <-log(mag_data3$circ)
head(mag_data3)
colnames(mag_data3)[2] <- "ln.circ"
#Transform log of circ
M3<-lm(ln.pagecost~., data = mag_data3)
summary(M3)

res_data3 <- residuals(M3)
plot(res_data3, type = "l")
abline(h=0,col="red")
qqnorm(res_data3)
qqline(res_data3,col="red")
predicted_data3 <-predict(M3)
plot(predicted_data3,res_data3)
abline(h=0,col="red")
dwtest(M3)
acf(res_data3)
shapiro.test(res_data3)
vif(M3)
for (i in 2:5) {
  plot(mag_data3[,i],res_data3,xlab = colnames(mag_data3)[i], ylab = "residuals")}
#Plot the residuals against all predictor variables
newdata2 <-newdata
newdata2$circ = log(newdata2$circ)
colnames(newdata2)[1] = "ln.circ"
#transform the newdata to feed the predict method
predict(M3,newdata = newdata2, se.fit = TRUE, interval = "confidence")

removeoutlier <-function(sampledata) {
  model<-lm( as.formula(paste(colnames(sampledata)[1], "~",
                              paste(colnames(sampledata)[c(2:length(sampledata))], collapse = "+"),
                              sep = "")),data=sampledata)
  paste(colnames(sampledata)[1], "~",
        paste(colnames(sampledata)[c(2:length(sampledata))], collapse = "+"),
        sep = "")
 
  cook.distance <- cooks.distance(model)
  outlier.index <- cook.distance>(4/44)
  nonoutlier.index <-!outlier.index
  mag_data_outlier_remove <-sampledata[nonoutlier.index,]
  MX<-lm( as.formula(paste(colnames(mag_data_outlier_remove)[1], "~",
                     paste(colnames(mag_data_outlier_remove)[c(2: ncol(mag_data_outlier_remove))], collapse = "+"),
                     sep = ""
    )),
    data=mag_data_outlier_remove
  )
  summary(MX)
}
#defining a function to remove outlier using Cook's Distance and show summary of the model after removing outliers 
removeoutlier(mag_data3)

# res_dataX <- residuals(MX)
# plot(res_dataX, type = "l")
# abline(h=0,col="red")
# qqnorm(res_dataX)
# predicted_dataX <-predict(MX)
# plot(predicted_dataX,res_dataX)
# abline(h=0,col="red")
# dwtest(MX)
# vif(MX)


mag_data4<-mag_data3
mag_data4$dom.ln.circ <-mag_data4$domestic*mag_data4$ln.circ
mag_data4$dom.percmale <-mag_data4$domestic*mag_data4$percmale
mag_data4$dom.medianincome <-mag_data4$domestic*mag_data4$medianincome
#add interaction terms
M4<-lm(ln.pagecost~.,data = mag_data4)
summary(M4)

removeoutlier(mag_data4)
#check what the r-square would be after removing outliers

mag_data5<-mag_data4
mag_data5$sqr.permale <-mag_data5$percmale*mag_data5$percmale 
removeoutlier(mag_data5)
#check what the r-square would be after removing outliers
mag_data6<-mag_data5[,-c(6,7)]
#removing insignificant variables
head(mag_data6)
removeoutlier(mag_data6)
M6<-lm(ln.pagecost~.,data=mag_data6)
#check what the r-square would be after removing outliers
plot(resid(M6))
abline(h=0,col="red")

newdata3<-newdata2
newdata3$dom.medianincome <-newdata3$domestic*newdata3$medianincome
newdata3$sqr.permale <-newdata3$percmale*newdata3$percmale
colnames(newdata3)==colnames(mag_data6)[-1]
#transform the newdata to feed the predict method
predict(M6,newdata = newdata3, se.fit = TRUE, interval = "confidence")

