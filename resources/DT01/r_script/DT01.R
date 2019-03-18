
cust_data = read.csv("Profitable Customers DATA.csv")
#Create a copy of the data
cust_data2<-cust_data
names(cust_data2)
str(cust_data)
#Convert money string into numeric value. Ex. "$2020" to 2020
currency.col = c(1, 12, 13, 15, 16, 44, 45, 55, 56, 57)
for (i in currency.col){
  cust_data2[,i] <- as.numeric(gsub(",", "", substr(cust_data2[,i], 2, length(cust_data2[,i]))))
}
str(cust_data2)

#Categorical variables with too many level, We store data of the variables for later use (if ever)
SIC.code <- cust_data$SIC.Code
Industry.Category <-cust_data$Industry.Category
Industry.Subcategory <- cust_data$Industry.Subcategory
Industry.State <- cust_data$State
Metropolitan.Statistical.Area <- cust_data$Metropolitan.Statistical.Area
Division <- cust_data$Division
TimeZone <- cust_data$TimeZone

# Get the main industry categories
Industry.Main.Cat = substring(Industry.Category,1,3)


#Create cust_data3 data set, with these categorical variables removed. We also add back the Industry.Main.Cat
removed.cols<- c(7,8,9,49,50,51,53)
names(cust_data2[,removed.cols])
cust_data3 <- cust_data2[,-removed.cols]
cust_data3 <- data.frame(cust_data3,Industry.Main.Cat)
str(cust_data3)

#Remove Manufacturer (4 observations) and Wholesales (31 observations)
cust_data3 <- cust_data3[cust_data3$Industry.Main.Cat!="Man" & cust_data3$Industry.Main.Cat!="Who",]
cust_data3$Industry.Main.Cat<-droplevels(cust_data3$Industry.Main.Cat)
summary(cust_data3)

# Remove ambiguous variables, which do not have descriptions on project file. We also remove the Num.of.Child.Supports variables, because all values are 0.
removed.cols.amb <- c("Amt.Past.Judgments", "X1.Years", "Num.of.Child.Supports")
cust_data3 <- cust_data3[,!(colnames(cust_data3) %in% removed.cols.amb)]

# Convert categorical variables to dummy variables

#Install fastdummies package if missing.
if (!require("fastDummies")) install.packages("fastDummies")
cust_data4 <- dummy_cols(cust_data3, select_columns = c("Originator", "Property.Ownership","Ever.Bankrupt.","Region", "Industry.Main.Cat"))
str(cust_data4)


# Remove redundant variables: the original categorical varibles, and one base dummy variabled among those created by the function right above
removed.cols2.dummies <- c("Originator", "Property.Ownership","Ever.Bankrupt.","Region", "Industry.Main.Cat", "Originator_B", "Property.Ownership_Mortgage", "Region_South","Ever.Bankrupt._no", "Female.Population", "Industry.Main.Cat_Ret")
cust_data4 <- cust_data4[,!(colnames(cust_data4) %in% removed.cols2.dummies)]
names(cust_data4)

# Variables with NA values. The NA values cannot be converted to 0 in these cases because zero value has a different meaning, so we temporarily remove these variables.
# Time.Since.Bankruptcy
# Past.Due.of.Charge.Offs
# Credit.Bal.of.Charge.Offs
removed.cols.na <- c("Time.Since.Bankruptcy", "Past.Due.of.Charge.Offs", "Credit.Bal.of.Charge.Offs")
cust_data5 <- cust_data4[,!(colnames(cust_data4) %in% removed.cols.na)]
str(cust_data5)
sum(is.na(cust_data5))
#28 NA cells left
na.search <- apply(is.na(cust_data5),2, sum)
#variables that have NA values
names(na.search)[na.search>0]
#"Active.Percent.Revolving"  

#With Active.Percent.Revolving, let's take a look at those observations
cust_data5[is.na(cust_data5$Active.Percent.Revolving),]
which(is.na(cust_data5$Active.Percent.Revolving))
cust_data_na <- cust_data5[which(is.na(cust_data5$Active.Percent.Revolving)),]
summary(cust_data_na)
summary(cust_data5)
dim(cust_data5)

# After comparing the the descriptive statistic of the set of observations that have NA values and the whole data, we don't recognize any pattern. We assump that NA is error, so we remove these observations.
cust_data6<-cust_data5[-which(is.na(cust_data5$Active.Percent.Revolving)),]
summary(cust_data6)
dim(cust_data6)

data_ready <- cust_data6

#############Finding outliers

#Analyzing box plots
par(mfrow=c(1,3))
for (i in 1:48) boxplot(data_ready[,i], main = colnames(data_ready)[i])

#Collect indexes of extreme values for variables

head(sort(data_ready$Credit.score,decreasing = FALSE))
rows.removed<-which(data_ready$Credit.score==1)

head(sort(data_ready$Active.Credit.Available,decreasing = TRUE))
rows.removed<-c(rows.removed,which(data_ready$Active.Credit.Available==2626200))
rows.removed

head(sort(data_ready$Active.Credit.Balance,decreasing = TRUE))
rows.removed<-c(rows.removed,which(data_ready$Active.Credit.Balance==8388930))
rows.removed

head(sort(data_ready$Num.Charged.Off,decreasing = TRUE))
rows.removed<-c(rows.removed,which(data_ready$Num.Charged.Off>40))
rows.removed

head(sort(data_ready$Num.of.Closed.Tax.Liens,decreasing = TRUE))
rows.removed<-c(rows.removed,which(data_ready$Num.of.Closed.Tax.Liens==21))
rows.removed

head(sort(data_ready$Persons.Per.Household,decreasing = FALSE), n=50)
rows.removed<-c(rows.removed,which(data_ready$Persons.Per.Household==0))
rows.removed

head(sort(data_ready$Income.Per.Household,decreasing = FALSE), n=50)
which(data_ready$Income.Per.Household==0)

#take a holistic look at these observations, we notice the data for them are incomplete with 0 population.
data_ready[which(data_ready$Income.Per.Household==0),]
rows.removed<-c(rows.removed,which(data_ready$Income.Per.Household==0))
rows.removed

head(sort(data_ready$Median.Age,decreasing = FALSE), n=50)
rows.removed<-c(rows.removed,which(data_ready$Median.Age<5))
rows.removed

#These are likely to be overlapped with those above, but we add them anyway.
head(sort(data_ready$Median.Age.Male,decreasing = FALSE), n=50)
rows.removed<-c(rows.removed,which(data_ready$Median.Age.Male<5))
rows.removed

head(sort(data_ready$Median.Age.Female,decreasing = FALSE), n=50)
rows.removed<-c(rows.removed,which(data_ready$Median.Age.Female<5))
rows.removed

head(sort(data_ready$Annual.Payroll..000.,decreasing = TRUE), n=10)
rows.removed<-c(rows.removed,which(data_ready$Annual.Payroll..000.>9000000))
rows.removed

#get the unique values out of rows.removed
rows.removed<-unique(rows.removed)
rows.removed
length(rows.removed)

data_ready <- cust_data6[-rows.removed,]
dim(data_ready)
#[1] 3153   48
summary(data_ready)

#Recheck the box plots
par(mfrow=c(1,3))
for (i in 1:48) boxplot(data_ready[,i], main = colnames(data_ready)[i])

####################################
#Assessing management's assumptions

par(mfrow=c(1,1))
plot(data_ready$Active.Credit.Lines, data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Active.Credit.Lines, data_ready$Annual.Fees),2), sep=""), xlab="Active.Credit.Lines", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Active.Credit.Lines, data_ready), col="red") # regression line (y~x) 

plot(data_ready$Utilitization.Percent, data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Utilitization.Percent, data_ready$Annual.Fees),2), sep=""), xlab="Utilitization.Percent", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Utilitization.Percent, data_ready), col="red") # regression line (y~x) 

plot(data_ready$Credit.score, data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Credit.score, data_ready$Annual.Fees),2), sep=""), xlab="Credit.score", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Credit.score, data_ready), col="red") # regression line (y~x) 

par(mfrow=c(1,2))
plot(data_ready$Originator_A , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Originator_A , data_ready$Annual.Fees),2), sep=""), xlab="Originator_A ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Originator_A , data_ready), col="red") # regression line (y~x) 

plot(data_ready$Originator_C , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Originator_C , data_ready$Annual.Fees),2), sep=""), xlab="Originator_C ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Originator_C , data_ready), col="red") # regression line (y~x) 

par(mfrow=c(1,1))
plot(data_ready$Industry.Main.Cat_Ser , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Industry.Main.Cat_Ser , data_ready$Annual.Fees),2), sep=""), xlab="Industry.Main.Cat_Ser ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Industry.Main.Cat_Ser , data_ready), col="red") # regression line (y~x) 

plot(data_ready$Num.Charged.Off , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Num.Charged.Off , data_ready$Annual.Fees),2), sep=""), xlab="Num.Charged.Off ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Num.Charged.Off , data_ready), col="red") # regression line (y~x) 

plot(data_ready$Years.in.Business , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Years.in.Business , data_ready$Annual.Fees),2), sep=""), xlab="Years.in.Business ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Years.in.Business , data_ready), col="red") # regression line (y~x) 

par(mfrow=c(1,2))
plot(data_ready$Property.Ownership_Lease , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Property.Ownership_Lease , data_ready$Annual.Fees),2), sep=""), xlab="Property.Ownership_Lease ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Property.Ownership_Lease , data_ready), col="red") # regression line (y~x) 

plot(data_ready$Property.Ownership_Own , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Property.Ownership_Own , data_ready$Annual.Fees),2), sep=""), xlab="Property.Ownership__Own ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Property.Ownership_Own , data_ready), col="red") # regression line (y~x)

par(mfrow=c(1,2))
plot(data_ready$Average.House.Value , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Average.House.Value , data_ready$Annual.Fees),2), sep=""), xlab="Average.House.Value ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Average.House.Value , data_ready), col="red") # regression line (y~x) 

plot(data_ready$Income.Per.Household , data_ready$Annual.Fees, main=paste("Cor= ",round(cor(data_ready$Income.Per.Household , data_ready$Annual.Fees),2), sep=""), xlab="Income.Per.Household ", ylab="Annual.Fees ", pch=19)
abline(lm(Annual.Fees~Income.Per.Household , data_ready), col="red") # regression line (y~x) 

###########################################################

#Best Subset Selection
# Divide data into training and testing sets
set.seed(1)
train_ID=sample(1:nrow(data_ready), 2000)
train=data_ready[train_ID,]
test=data_ready[-train_ID,]

y.train=train[,1]
x.train=train[,-1]

y.test=test[,1]
x.test=test[,-1]
# To evaluate models predictive accuracy, we create functions for RMSE and MAPE. But we just use RMSE in this example.

RMSE=function(y,y.hat) sqrt(mean((y-y.hat)^2))
MAPE=function(y,y.hat) mean(abs((y-y.hat)/y))

# Upload leaps packages that has regsubsets function
library(leaps)

# regsubset with exhaustive method
M.ex=regsubsets(Annual.Fees~.,data=train,nvmax=47,really.big=T)

which.max(summary(M.ex)$adjr2)
#30
plot(summary(M.ex)$adjr2, xlab = "Number of Variables", ylab = "Adjusted R Square")
points(30, summary(M.ex)$adjr2[30], pch = 20, col = "red")

# Model Selection Using a Validation Set. Make prediction on testing set, and record the erros for each model. There're 18 models.
M.ex.accuracy<- data.frame(rep(NA,47),rep("",47),rep(NA,47),rep("",47),rep(NA,47),rep("",47),rep(NA,47),rep("",47),rep(NA,47),rep("",47),rep(NA,47),rep("",47), stringsAsFactors = FALSE)
colnames(M.ex.accuracy)=c("Train.RMSE","","Test.RMSE","","Train.MAPE","","Test.MAPE","","Train.Corr","","Test.Corr","")
for (i in 1:47) {
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
  M.ex.accuracy[match(sort(M.ex.accuracy$Train.Corr)[48-i],M.ex.accuracy$Train.Corr),10]=paste(replicate(4-i, '*'), collapse = "");
  M.ex.accuracy[match(sort(M.ex.accuracy$Test.Corr)[48-i],M.ex.accuracy$Test.Corr),12]=paste(replicate(4-i, '*'), collapse = "");  
}
M.ex.accuracy
# Train.RMSE     Test.RMSE     Train.MAPE     Test.MAPE     Train.Corr     Test.Corr    
# 1    721.4117      742.8137      0.1911004     0.1883117      0.3493874     0.3131580    
# 2    666.4447      707.7468      0.1795857     0.1816457      0.5007593     0.4265397    
# 3    634.6883      676.0299      0.1668668     0.1706180      0.5660935     0.5027058    
# 4    606.3308      656.1156      0.1588785     0.1625608      0.6163020     0.5484201    
# 5    587.2279      639.2589      0.1540947     0.1584896      0.6467538     0.5788554    
# 6    568.1637      619.4314      0.1533400     0.1577279      0.6748685     0.6134524    
# 7    554.2486      609.3626      0.1506964     0.1553701      0.6941143     0.6292644    
# 8    547.8627      606.6644      0.1483171     0.1528194      0.7026144     0.6342027    
# 9    542.4419      595.1417      0.1489349     0.1534057      0.7096740     0.6503290    
# 10   538.3878      592.2832      0.1476254     0.1519987      0.7148628     0.6548963    
# 11   536.1445      593.8085      0.1474871     0.1522437      0.7177013     0.6528383    
# 12   534.4884      593.0310      0.1470118     0.1519784      0.7197820     0.6537525    
# 13   533.1219      591.5274      0.1466066     0.1513111      0.7214896     0.6561182    
# 14   532.1960      589.6873      0.1462784     0.1510248      0.7226417     0.6584615    
# 15   531.4728      589.3718      0.1459290     0.1511715      0.7235391     0.6585279    
# 16   530.7948      589.8179      0.1457133     0.1513209      0.7243782     0.6579584    
# 17   530.1922      589.0783      0.1454407     0.1510628      0.7251223     0.6589496    
# 18   529.7080      585.3970      0.1456823     0.1504785      0.7257189     0.6639464    
# 19   529.3674      583.9710   *  0.1455357     0.1499270   *  0.7261380     0.6658994   *
# 20   529.1214      584.1074      0.1455305     0.1499204  **  0.7264404     0.6657824    
# 21   528.7795      585.0963      0.1453984     0.1504383      0.7268603     0.6645329    
# 22   528.4289      583.6589 ***  0.1453194     0.1499022 ***  0.7272903     0.6664968 ***
# 23   528.1883      583.9339  **  0.1453533     0.1499291      0.7275851     0.6661588  **
# 24   527.9696      584.7479      0.1452189     0.1503263      0.7278528     0.6650039    
# 25   527.7930      585.4745      0.1451494     0.1504809      0.7280688     0.6640026    
# 26   527.6444      585.1994      0.1451304     0.1504088      0.7282505     0.6644207    
# 27   527.5030      585.4332      0.1449160     0.1503255      0.7284233     0.6640745    
# 28   527.4249      586.0384      0.1450064     0.1505633      0.7285187     0.6632509    
# 29   527.2195      585.6898      0.1447873     0.1505620      0.7287694     0.6637158    
# 30   527.0214      585.8464      0.1448312     0.1505729      0.7290111     0.6635338    
# 31   526.9058      586.0466      0.1446574     0.1505162      0.7291521     0.6632301    
# 32   526.8173      586.7033      0.1447334     0.1507678      0.7292599     0.6623361    
# 33   526.7502      586.2142      0.1446958     0.1506529      0.7293417     0.6630382    
# 34   526.7134      586.5683      0.1447183     0.1507794      0.7293865     0.6625206    
# 35   526.6713      585.9575      0.1446904     0.1505901      0.7294378     0.6633628    
# 36   526.6480      586.0083      0.1446870     0.1505943      0.7294662     0.6632901    
# 37   526.6294      586.0708      0.1446479     0.1506038      0.7294889     0.6631828    
# 38   526.6081      586.0077      0.1447054     0.1506364      0.7295147     0.6632002    
# 39   526.5884      585.9664      0.1446812     0.1506215      0.7295388     0.6632546    
# 40   526.5692      586.0169      0.1446779     0.1506281      0.7295621     0.6631847    
# 41   526.5547      585.9767      0.1446717     0.1506128      0.7295797     0.6632478    
# 42   526.5462      585.9726      0.1446423     0.1506140      0.7295901     0.6632444    
# 43   526.5380      585.7427      0.1446318     0.1505514      0.7296001     0.6635464    
# 44   526.5332      585.7406      0.1446202     0.1505625      0.7296059     0.6635394    
# 45   526.5312   *  585.7614      0.1446060   * 0.1505540      0.7296084   * 0.6635119    
# 46   526.5308  **  585.7740      0.1446022  ** 0.1505642      0.7296088  ** 0.6634918    
# 47   526.5305 ***  585.7871      0.1445989 *** 0.1505693      0.7296092 *** 0.6634696  

# Plot RMSE for training set and testing set
par(mfrow=c(1,2))
plot(M.ex.accuracy$Test.RMSE, ylab = "RMSE", ylim = c(520, 750),pch = 19, type = "b")
points(M.ex.accuracy$Train.RMSE, col = "blue", pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = c("Training", "Validation"), col = c("blue", "black"), 
       pch = 19)

plot(M.ex.accuracy$Test.RMSE, ylab = "RMSE",ylim = c(580, 600), pch = 19, type = "b")
grid(nx = 3, ny = 6, col = "lightgray", lty = "solid")
legend("topright", legend = "Validation", col = "black", pch = 19)

which.min(M.ex.accuracy$Test.RMSE)
#Best model: 22 variables model.

bestsubset.coef <-names(coef(M.ex,id=which.min(M.ex.accuracy$Test.RMSE)))[-1]
bestsubset.coef
# [1] "Years.in.Business"      
# [2] "Credit.score"           
# [3] "Active.Credit.Lines"    
# [4] "Active.Credit.Available"
# [5] "Utilitization.Percent"  
# [6] "Past.Due.Total.Balance" 
# [7] "Avg.Monthly.Payment"    
# [8] "Active..30Days"         
# [9] "Active..60Days"         
# [10] "Active..90Days"         
# [11] "Num.Charged.Off"        
# [12] "Num.of.Bankruptcies"    
# [13] "Num.of.Closed.Judgments"
# [14] "Median.Age"             
# [15] "Median.Age.Male"        
# [16] "Median.Age.Female"      
# [17] "Avg.Annual.Salary"      
# [18] "Originator_A"           
# [19] "Originator_C"           
# [20] "Property.Ownership_Own" 
# [21] "Ever.Bankrupt._yes"     
# [22] "Industry.Main.Cat_Ser"


allvars<-c(c("Annual.Fees", "Average.House.Value", "Income.Per.Household"),bestsubset.coef)
#List of all variables to consider (adding two varibles that mangement considers important)

####################################################################

# OLS
data_ready.1 <- data_ready[,allvars]
summary(data_ready.1)
dim(data_ready.1)

#Recreate the training and testing sets
set.seed(2)
train_ID=sample(1:nrow(data_ready.1), 2000)
train=data_ready.1[train_ID,]
test=data_ready.1[-train_ID,]

y.train=train[,1]
x.train=train[,-1]

y.test=test[,1]
x.test=test[,-1]

head(train)
mlr=lm(Annual.Fees~., train)
summary(mlr)
# Adj R-Squared 0.4924, p-value: < 2.2e-16

# We try taking natural log to y
Ln=lm(log(train$Annual.Fees)~., data=train)
summary(Ln)
# Adjusted R-Square is 0.4723

# We try taking SQRT of y
mlr.sqrt=lm(sqrt(train$Annual.Fees)~., data=train)
summary(mlr.sqrt)
# Adjusted R-squared:  0.4913 
# Transforming y does not improve the model


# Residual plots
par(mfrow=c(1,2))
for (i in 2:25) {
  plot(train[,i],mlr$residuals, xlab = colnames(train)[i])
}

## after examining plots above, we further transform some x variables, and rerun OLS model
train.1<-train
train.1$ln.pastdue <- sqrt(train.1$Past.Due.Total.Balance)
train.1$util.perc <- sqrt(train.1$Utilitization.Percent)
summary(lm(Annual.Fees~., train.1))
#Adjusted R-squared:  0.4926, slightly higher than the original model

# Also, we try to test interactions between Ever Bankrupt and Credit Score, and rerun OLS model
mlr.9=lm(Annual.Fees~Ever.Bankrupt._yes:Credit.score+., train)
summary(mlr.9) # Adjusted R-squared:  0.5068
# interaction between (Ever.Bankrupt._yes:Credit.score) helps R-squre by a little
# but doing so with so many variables is like shooting in the dark -> should try decision tree, where important variables can interact with all other variables 

#########################################################################

### KNN

library(FNN)
set.seed(1)
train_ID=sample(1:nrow(data_ready), 2000)
train=data_ready.1[train_ID,]
test=data_ready.1[-train_ID,]

y.train=train[,1]
x.train=train[,-1]

y.test=test[,1]
x.test=test[,-1]

## Find the optimal k to use for the model
MSE_KNN.2 = NULL
MSE_KNN_table = NULL
k_seq = seq(from = 1, to = 20, by = 1)

for (i in k_seq){
  set.seed(1)
  knn_model.2 = knn.reg(train=x.train, test=x.test, y=y.train, k=i)
  y_hat_knn.2=knn_model.2$pred
  MSE_KNN.2=mean((y.test-y_hat_knn.2)^2)
  MSE_KNN_table = c(MSE_KNN_table,MSE_KNN.2)
}
MSE_KNN_table
plot(MSE_KNN_table) # the higher k is the lower MSE is. We should also not overfit our model
# We can potentitally select a lowest k that only degrade MSE by 5% from MSE of k=20
# for now, just to compare modeling method, let's choose k=20
best_k = which.min(MSE_KNN_table)
best_k 
MSE_KNN.2 #605383.4 (will compare KNN with OLS at the end)

### After trying interactions and transformation, we don't see much improvement in OLS model,
# thus, we decide to use the originalOLS modleto compare with KNN

y_hat_mlr=predict(mlr, x.test)
MSE_mlr=mean((y.test-y_hat_mlr)^2)

MSE_mlr #333477.3
MSE_KNN.2 #605383.4
## OLS's MSE is smaller than kNN model, thus, we think OLS is a better model for this case.


#######################################################
# Decision Tree
library(tree)

set.seed(1)
train_ID=sample(1:nrow(data_ready), 2000)
train=data_ready[train_ID,]
test=data_ready[-train_ID,]

y.train=train[,1]
x.train=train[,-1]

y.test=test[,1]
x.test=test[,-1]

tree=tree(Annual.Fees~.,train) 
summary(tree)
par(mfrow=c(1,1))
plot(tree)
text(tree,pretty=0)

# make prediction
y.hat=predict (tree, newdata=test)
plot(y.hat ,y.test)
abline (0,1)
mean((y.hat-y.test)^2)		# MSE = 439125.2

# prune the tree
cv_tree=cv.tree(tree)
names(cv_tree)
plot(cv_tree$size,cv_tree$dev,type='b')
prune_tree=prune.tree(tree,best=11)
summary(prune_tree)
plot(prune_tree)
text(prune_tree,pretty=0)

# make prediction for prune tree
y.hat=predict (prune_tree, newdata=test)
plot(y.hat ,y.test)
abline (0,1)
mean((y.hat-y.test)^2)		# 11 nodes MSE = 445498.7; original 13nodes MSE = 439125.2
# pruning tree in this case doesn't improve testing MSE, or saying 13 nodes does over-fit

# Bagging
library(randomForest)

set.seed(1)
bag=randomForest(Annual.Fees~.,data=train,mtry=ncol(data_ready) - 1 ,importance=TRUE)
bag
y.hat = predict(bag,newdata=test)
par(mfrow=c(1,1))
plot(y.hat, y.test)
abline(0,1)
mean((y.hat-y.test)^2)   #MSE = 363215.6

# reducing ntree from default (500) to 200 would reduce model's training accuracy, but reducing computation
set.seed(1)
bag=randomForest(Annual.Fees~.,data=train,mtry=ncol(data_ready)-1,ntree=200)
y.hat = predict(bag,newdata=test)
mean((y.hat-y.test)^2)  #MSE = 360925.2
plot(y.hat, y.test)
abline(0,1)


# Random Forests
ncol(data_ready) -1 # = 49 
# sqrt(p) ~ 7
max(floor((ncol(data_ready)/3)),1) # p/3 = 16
max(floor((ncol(data_ready)/2)),1) # p/2 = 24

set.seed(1)
rf=randomForest(Annual.Fees~.,data=train,mtry=16,importance=TRUE)
y.hat = predict(rf,newdata=test)
mean((y.hat-y.test)^2)  #mtry=16 MSE = 341569.2
rf2=randomForest(Annual.Fees~.,data=train,mtry=17,importance=TRUE)
y.hat = predict(rf2,newdata=test)
mean((y.hat-y.test)^2) #mtry=7 MSE = 341131.4; 
rf3=randomForest(Annual.Fees~.,data=train,mtry=24,importance=TRUE)
y.hat = predict(rf3,newdata=test)
mean((y.hat-y.test)^2) #mtry=24 MSE = 346365.8


importance(rf)
varImpPlot(rf)
summary(rf)
plot(rf)


# Boosting
library(gbm)
set.seed(1)
boost=gbm(Annual.Fees~.,data=train,distribution="gaussian",n.trees=10000,interaction.depth=4)
par(mfrow=c(1,1))
summary(boost)
par(mfrow=c(1,2))
plot(boost,i="Past.Due.Total.Balance")
plot(boost,i="Property.Ownership_Own")
y.hat=predict(boost,newdata=test,n.trees=10000)
mean((y.hat-y.test)^2)  #MSE = 359925.2
boost=gbm(Annual.Fees~.,data=train,distribution="gaussian",n.trees=10000,interaction.depth=4,shrinkage=0.2,verbose=F) #shrinkage
y.hat=predict(boost,newdata=test,n.trees=10000)
mean((y.hat-y.test)^2)  #MSE = 385345
summary(boost)





