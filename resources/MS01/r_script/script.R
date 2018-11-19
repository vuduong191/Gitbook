college <-read.csv("college.csv")
head(college)
rownames(college) <- college[,1]
college <- college[,-1]
head(college)
str(college)
summary(college)
pairs(college[,1:10])
# Can we use plot instead?
# plot(college[,1:10])
plot(Outstate~Private, college)
college$Elite=rep("No",nrow(college))
college$Elite[college$Top10perc >50]=" Yes"
college$Elite=as.factor(college$Elite)


summary(college$Elite)
plot(Outstate~Elite,college)

# Change the Private and Elite into dummy variables
college$Elite = as.numeric(as.numeric(college$Elite)==1)
college$Private= as.numeric(as.numeric(college$Private)==2)
# Divide data into training and testing sets
set.seed(1)
test_id<-sample(dim(college)[1],200)
y.train=college[-(test_id),2]
x.train=college[-(test_id),-2]

y.test=college[(test_id),2]
x.test=college[(test_id),-2]

test=college[test_id,]
train=college[-(test_id),]

# To evaluate models predictive accuracy, we create functions for RMSE and MAPE. But we just use RMSE in this example.

RMSE=function(y,y.hat) sqrt(mean((y-y.hat)^2))
MAPE=function(y,y.hat) mean(abs((y-y.hat)/y))

# Upload leaps packages that has regsubsets function
library(leaps)

# Make the time consumtion report table
time_consumed <-data.frame(NA,NA,NA,NA,NA,NA,NA,NA,NA)
colnames(time_consumed) <- c("Sub_Ex", "Sub_For", "Sub_Back","Linear Reg","Ridge","Lasso","PCR","PLS","Elastic Net")
# Make the RMSE report table
rmse_comparison <-data.frame(NA,NA,NA,NA,NA,NA,NA,NA,NA)
colnames(rmse_comparison) <- c("Sub_Ex", "Sub_For", "Sub_Back","Linear Reg","Ridge","Lasso","PCR","PLS","Elastic Net")


# regsubset with exhaustive method
starting.time=Sys.time()
M.ex=regsubsets(Apps~.,data=train,nvmax=18,really.big=T)
finishing.time=Sys.time()
time_consumed[1,1]=round(finishing.time-starting.time,4)

which.max(summary(M.ex)$adjr2)
plot(summary(M.ex)$adjr2, xlab = "Number of Variables", ylab = "Adjusted R Square")
points(14, summary(M.ex)$adjr2[14], pch = 20, col = "red")
# plot(M.ex, scale = "adjr2")
# 14 variables, but this is just based on training set

# Model Selection Using a Validation Set. Make prediction on testing set, and record the erros for each model. There're 18 models.
M.ex.accuracy <- data.frame(rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18), stringsAsFactors = FALSE)
colnames(M.ex.accuracy)=c("Train.RMSE","","Test.RMSE","","Train.MAPE","","Test.MAPE","","Train.Corr","","Test.Corr","")
for (i in 1:18) {
  M.ex.y.hat<-t(coef(M.ex,id=i)) %*% t(cbind(1,x.test[,names(coef(M.ex,id=i))[-1]]));
  M.ex.fitted<-t(coef(M.ex,id=i)) %*% t(cbind(1,x.train[,names(coef(M.ex,id=i))[-1]]));  
  M.ex.accuracy$Train.RMSE[i] = RMSE(y=y.train,y.hat=M.ex.fitted);
  M.ex.accuracy$Test.RMSE[i] = RMSE(y=y.test,y.hat=M.ex.y.hat);
  M.ex.accuracy$Train.MAPE[i] = MAPE(y=y.train,y.hat=M.ex.fitted);
  M.ex.accuracy$Test.MAPE[i] = MAPE(y=y.test,y.hat=M.ex.y.hat);
  M.ex.accuracy$Train.Corr[i] = cor(as.vector(M.ex.fitted),y.train);
  M.ex.accuracy$Test.Corr[i] = cor(as.vector(M.ex.y.hat),y.test)
}

for (i in 1:3){
  M.ex.accuracy[match(sort(M.ex.accuracy$Train.RMSE)[i],M.ex.accuracy$Train.RMSE),2]=paste(replicate(4-i, '*'), collapse = "");
  M.ex.accuracy[match(sort(M.ex.accuracy$Test.RMSE)[i],M.ex.accuracy$Test.RMSE),4]=paste(replicate(4-i, '*'), collapse = "");
  M.ex.accuracy[match(sort(M.ex.accuracy$Train.MAPE)[i],M.ex.accuracy$Train.MAPE),6]=paste(replicate(4-i, '*'), collapse = "");
  M.ex.accuracy[match(sort(M.ex.accuracy$Test.MAPE)[i],M.ex.accuracy$Test.MAPE),8]=paste(replicate(4-i, '*'), collapse = "");
  M.ex.accuracy[match(sort(M.ex.accuracy$Train.Corr)[19-i],M.ex.accuracy$Train.Corr),10]=paste(replicate(4-i, '*'), collapse = "");
  M.ex.accuracy[match(sort(M.ex.accuracy$Test.Corr)[19-i],M.ex.accuracy$Test.Corr),12]=paste(replicate(4-i, '*'), collapse = "");  
}
M.ex.accuracy

# Plot RMSE for training set and testing set
par(mfrow=c(1,2))
plot(M.ex.accuracy$Test.RMSE, ylab = "RMSE", ylim = c(950, 1500),pch = 19, type = "b")
points(M.ex.accuracy$Train.RMSE, col = "blue", pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = c("Training", "Validation"), col = c("blue", "black"), 
       pch = 19)

plot(M.ex.accuracy$Test.RMSE, ylab = "RMSE",ylim = c(1300, 1370), pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = "Validation", col = "black", pch = 19)

which.min(M.ex.accuracy$Test.RMSE)
# 15
rmse_comparison[1]<-M.ex.accuracy$Test.RMSE[which.min(M.ex.accuracy$Test.RMSE)]
# 1302.273
# based on the testing set, 15 variable model is also optimal

# We can write our own predict method
# predict.regsubsets = function(object, newdata, id, ...) {
#   form = as.formula(object$call[[2]])
#   mat = model.matrix(form, newdata)
#   coefi = coef(object, id = id)
#   t(cbind(1,mat[, names(coefi)[-1]])) %*% t(coefi)
# }


# regsubset with forward method
starting.time=Sys.time()
M.for=regsubsets(Apps~.,data=train,nvmax=18,method="forward")
finishing.time=Sys.time()
time_consumed[1,2]=round(finishing.time-starting.time,4)

which.max(summary(M.for)$adjr2)
plot(summary(M.for)$adjr2, xlab = "Number of Variables", ylab = "Adjusted R Square")
points(14, summary(M.for)$adjr2[14], pch = 20, col = "red")
# 14 variable, based on training set

# Model Selection Using a Validation Set. Make prediction on testing set, and record the erros for each model. There're 18 models.
M.for.accuracy <- data.frame(rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18), stringsAsFactors = FALSE)
colnames(M.for.accuracy)=c("Train.RMSE","","Test.RMSE","","Train.MAPE","","Test.MAPE","","Train.Corr","","Test.Corr","")
for (i in 1:18) {
  M.for.y.hat<-t(coef(M.for,id=i)) %*% t(cbind(1,x.test[,names(coef(M.for,id=i))[-1]]));
  M.for.fitted<-t(coef(M.for,id=i)) %*% t(cbind(1,x.train[,names(coef(M.for,id=i))[-1]]));  
  M.for.accuracy$Train.RMSE[i] = RMSE(y=y.train,y.hat=M.for.fitted);
  M.for.accuracy$Test.RMSE[i] = RMSE(y=y.test,y.hat=M.for.y.hat);
  M.for.accuracy$Train.MAPE[i] = MAPE(y=y.train,y.hat=M.for.fitted);
  M.for.accuracy$Test.MAPE[i] = MAPE(y=y.test,y.hat=M.for.y.hat);
  M.for.accuracy$Train.Corr[i] = cor(as.vector(M.for.fitted),y.train);
  M.for.accuracy$Test.Corr[i] = cor(as.vector(M.for.y.hat),y.test)
}
for (i in 1:3){
  M.for.accuracy[match(sort(M.for.accuracy$Train.RMSE)[i],M.for.accuracy$Train.RMSE),2]=paste(replicate(4-i, '*'), collapse = "");
  M.for.accuracy[match(sort(M.for.accuracy$Test.RMSE)[i],M.for.accuracy$Test.RMSE),4]=paste(replicate(4-i, '*'), collapse = "");
  M.for.accuracy[match(sort(M.for.accuracy$Train.MAPE)[i],M.for.accuracy$Train.MAPE),6]=paste(replicate(4-i, '*'), collapse = "");
  M.for.accuracy[match(sort(M.for.accuracy$Test.MAPE)[i],M.for.accuracy$Test.MAPE),8]=paste(replicate(4-i, '*'), collapse = "");
  M.for.accuracy[match(sort(M.for.accuracy$Train.Corr)[19-i],M.for.accuracy$Train.Corr),10]=paste(replicate(4-i, '*'), collapse = "");
  M.for.accuracy[match(sort(M.for.accuracy$Test.Corr)[19-i],M.for.accuracy$Test.Corr),12]=paste(replicate(4-i, '*'), collapse = "");  
}

M.for.accuracy

# Plot RMSE for training set and testing set
par(mfrow=c(1,2))
plot(M.for.accuracy$Test.RMSE, ylab = "RMSE", ylim = c(950, 1500),pch = 19, type = "b")
points(M.for.accuracy$Train.RMSE, col = "blue", pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = c("Training", "Validation"), col = c("blue", "black"), 
       pch = 19)

plot(M.for.accuracy$Test.RMSE, ylab = "RMSE",ylim = c(1280, 1400), pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = "Validation", col = "black", pch = 19)

which.min(M.for.accuracy$Test.RMSE)
# 12
rmse_comparison[2]<-M.for.accuracy$Test.RMSE[which.min(M.for.accuracy$Test.RMSE)]
# 1283.129
# based on the testing set, 12 variable model is optimal


# regsubset with backward method
starting.time=Sys.time()
M.back=regsubsets(Apps~.,data=train,nvmax=18,method="backward")
finishing.time=Sys.time()
time_consumed[1,3]=round(finishing.time-starting.time,4)
which.max(summary(M.back)$adjr2)
plot(summary(M.back)$adjr2, xlab = "Number of Variables", ylab = "Adjusted R Square")
points(14, summary(M.back)$adjr2[14], pch = 20, col = "red")
# 14 variable mode, based on training set

# Model Selection Using a Validation Set. Make prediction on testing set, and record the erros for each model. There're 18 models.
M.back.accuracy <- data.frame(rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18),rep(NA,18),rep("",18), stringsAsFactors = FALSE)
colnames(M.back.accuracy)=c("Train.RMSE","","Test.RMSE","","Train.MAPE","","Test.MAPE","","Train.Corr","","Test.Corr","")
for (i in 1:18) {
  M.back.y.hat<-t(coef(M.back,id=i)) %*% t(cbind(1,x.test[,names(coef(M.back,id=i))[-1]]));
  M.back.fitted<-t(coef(M.back,id=i)) %*% t(cbind(1,x.train[,names(coef(M.back,id=i))[-1]]));  
  M.back.accuracy$Train.RMSE[i] = RMSE(y=y.train,y.hat=M.back.fitted);
  M.back.accuracy$Test.RMSE[i] = RMSE(y=y.test,y.hat=M.back.y.hat);
  M.back.accuracy$Train.MAPE[i] = MAPE(y=y.train,y.hat=M.back.fitted);
  M.back.accuracy$Test.MAPE[i] = MAPE(y=y.test,y.hat=M.back.y.hat);
  M.back.accuracy$Train.Corr[i] = cor(as.vector(M.back.fitted),y.train);
  M.back.accuracy$Test.Corr[i] = cor(as.vector(M.back.y.hat),y.test)
}

for (i in 1:3){
  M.back.accuracy[match(sort(M.back.accuracy$Train.RMSE)[i],M.back.accuracy$Train.RMSE),2]=paste(replicate(4-i, '*'), collapse = "");
  M.back.accuracy[match(sort(M.back.accuracy$Test.RMSE)[i],M.back.accuracy$Test.RMSE),4]=paste(replicate(4-i, '*'), collapse = "");
  M.back.accuracy[match(sort(M.back.accuracy$Train.MAPE)[i],M.back.accuracy$Train.MAPE),6]=paste(replicate(4-i, '*'), collapse = "");
  M.back.accuracy[match(sort(M.back.accuracy$Test.MAPE)[i],M.back.accuracy$Test.MAPE),8]=paste(replicate(4-i, '*'), collapse = "");
  M.back.accuracy[match(sort(M.back.accuracy$Train.Corr)[19-i],M.back.accuracy$Train.Corr),10]=paste(replicate(4-i, '*'), collapse = "");
  M.back.accuracy[match(sort(M.back.accuracy$Test.Corr)[19-i],M.back.accuracy$Test.Corr),12]=paste(replicate(4-i, '*'), collapse = "");  
}
M.back.accuracy

# Plot RMSE for training set and testing set
par(mfrow=c(1,2))
plot(M.back.accuracy$Test.RMSE, ylab = "RMSE", ylim = c(950, 1500),pch = 19, type = "b")
points(M.back.accuracy$Train.RMSE, col = "blue", pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = c("Training", "Validation"), col = c("blue", "black"), 
       pch = 19)

plot(M.back.accuracy$Test.RMSE, ylab = "RMSE",ylim = c(1300, 1390), pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = "Validation", col = "black", pch = 19)

which.min(M.back.accuracy$Test.RMSE)
# 15
rmse_comparison[3]<-M.back.accuracy$Test.RMSE[which.min(M.back.accuracy$Test.RMSE)]
# 1302.273
# based on the testing set, 15 variable model is optimal

# Comparing three model, the one with the lowest RMSE is M.for with 12 variable model

# Fit a linear model using least squares 

library(boot)
starting.time=Sys.time()
M.linear=glm(Apps~.,data=college)
finishing.time=Sys.time()
time_consumed[1,4]=round(finishing.time-starting.time,4)

cv.error=cv.glm(college,M.linear,K=10)$delta[1]
summary(M.linear)
cv.error  # = 1262112
cv.error^.5 # = 1123.438
M.linear.y.hat=predict(M.linear,x.test)
rmse_comparison[4]<-RMSE(y=y.test,y.hat=M.linear.y.hat)

# Ridge regression model
library(glmnet)

set.seed(1)
cv.out=cv.glmnet(as.matrix(x.train),y.train,alpha=0)
cv.out$cvsd
min(cv.out$cvsd) # = 230181.5
min(cv.out$cvsd)^.5 # = 479.7724
par(mfrow=c(1,1))
plot(cv.out)

best.lambda=cv.out$lambda.min
best.lambda # = 351.804

starting.time=Sys.time()
M.ridge=glmnet(as.matrix(x.train),y.train,alpha=0,lambda=best.lambda)
finishing.time=Sys.time()
time_consumed[1,5]=round(finishing.time-starting.time,4)

coef(M.ridge)
M.ridge.y.hat=predict(M.ridge,s=best.lambda, newx = as.matrix(x.test))
rmse_comparison[5]<-RMSE(y=y.test,y.hat=M.ridge.y.hat)


# Fit a lasso model with lambda chosen by cross-validation
set.seed(1)
lambdarange <- (exp(1))^seq(6, -2, length = 100)
cv.out=cv.glmnet(as.matrix(x.train), y.train,alpha=1, lambda = lambdarange)
cv.out$cvsd
min(cv.out$cvsd) # = 229225.6
min(cv.out$cvsd)^.5 # = 478.7751
par(mfrow=c(1,1))
plot(cv.out)

best.lambda=cv.out$lambda.min
best.lambda # = 9.043264


starting.time=Sys.time()
M.lasso=glmnet(as.matrix(x.train),y.train,alpha=1,lambda=best.lambda)
finishing.time=Sys.time()
time_consumed[1,6]=round(finishing.time-starting.time,4)

coef(M.lasso)

M.lasso.y.hat=predict(M.lasso,s=best.lambda,newx = as.matrix(x.test))
rmse_comparison[6]<-RMSE(y=y.test,y.hat=M.lasso.y.hat)



#Create visualization(s) to illustrate the shrinkage effects. 
par(mfrow=c(1,1))
plot(coef(M.linear),type="b", col="black")
lines(predict(M.ridge,type="coefficients",s=best.lambda)[1:18,],type="b", col="red")
lines(predict(M.lasso,type="coefficients",s=best.lambda)[1:18,],type="b", col="blue")

# Fit elastic net, with lambda chosen by cross-validation

set.seed(1)
lambdarange <- (exp(1))^seq(6, -2, length = 100)
cv.out= cv.glmnet(as.matrix(x.train),y.train,alpha=.5, lambda = lambdarange)
cv.out$cvsd
min(cv.out$cvsd) #229001.9
min(cv.out$cvsd)^.5 #478.5414
plot(cv.out)

best.lambda=cv.out$lambda.min 
best.lambda # = 4.030697

starting.time=Sys.time()
M.elastic=glmnet(as.matrix(x.train),y.train,alpha = .5,lambda=best.lambda)
finishing.time=Sys.time()
time_consumed[1,9]=round(finishing.time-starting.time,4)

coef(M.elastic)
M.elastic.y.hat=predict(M.elastic,s=best.lambda,newx=as.matrix(x.test))
rmse_comparison[9]<-RMSE(y=y.test,y.hat=M.elastic.y.hat)

#	Fit a PCR  model, with number of PC chosen by cross-validation

library (pls)
set.seed(1)
starting.time=Sys.time()
M.pcr=pcr(Apps~.,data=train, scale=TRUE,validation="CV")
finishing.time=Sys.time()
time_consumed[1,7]=round(finishing.time-starting.time,4)


summary(M.pcr)
validationplot(M.pcr,val.type=c("MSEP"))

sqrt(min(M.pcr$validation$PRESS))
# 24396.33

M.pcr.y.hat = predict(M.pcr,x.test,ncomp = 5) 
rmse_comparison[7]<-RMSE(y=y.test,y.hat=M.pcr.y.hat)

#	Fit a PLS  model, with number of PC chosen by cross-validation.

starting.time=Sys.time()
M.pls=plsr(Apps~.,data=train, scale=TRUE,validation="CV")
finishing.time=Sys.time()
time_consumed[1,8]=round(finishing.time-starting.time,4)

summary (M.pls)
validationplot(M.pls,val.type=c("MSEP")) 

sqrt(min(M.pls$validation$PRESS)) #24481.34

M.pls.y.hat= predict(M.pls,x.test,ncomp = 5) 
rmse_comparison[8]<-RMSE(y=y.test,y.hat=M.pls.y.hat)

rmse_comparison
