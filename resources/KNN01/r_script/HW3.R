#1. Logistic Regression
carseat.data=read.csv("carseat.txt")
head(carseat.data)

testing_data=carseat.data[1:100,]
training_data=carseat.data[101:400,]
testing_y=carseat.data$Sales[1:100]
training_y=carseat.data$Sales[101:400]
testing_x=testing_data[,-1]
training_x=training_data[,-1]

#Train logistic regression model
logistic_model=glm(Sales~.,data=training_data, family="binomial")
logistic_model
summary(logistic_model)

#create confusion matrix to compare actual and predicted values on training set
cutoff_table = data.frame(seq(0.2,0.8,by=0.05), rep(NA,13))
colnames(cutoff_table)<-c("Cutoff", "Misclassification_error")
for (i in 1:13){
  y=predict(logistic_model,training_data,type="response")
  y_result=ifelse(y>cutoff_table$Cutoff[i],1,0)
  cutoff_table$Misclassification_error[i]<- mean(y_result!=training_y)
}
cutoff_table

#create confusion matrix to compare actual and predicted values on testing set
logistic_test_probs=predict(logistic_model,testing_data,type="response")
logistic_test_pred_y=ifelse(logistic_test_probs>0.55,1,0)
conf_matrix_test=table(logistic_test_pred_y, testing_y)
conf_matrix_test
misclassifaction_error_test=mean(logistic_test_pred_y!=testing_y)
misclassifaction_error_test
false_positive_test=conf_matrix_test[2,1]/sum(testing_y==0)
false_positive_test
false_negative_test=conf_matrix_test[1,2]/sum(testing_y==1)
false_negative_test




#2. KNN

library(class)
dim(carseat.data)
class(carseat.data$Sales)
carseat.data$Sales=as.factor(carseat.data$Sales)

set.seed(1)
testing_data=carseat.data[1:100,]
training_data=carseat.data[101:400,]
testing_y=carseat.data$Sales[1:100]
training_y=carseat.data$Sales[101:400]
testing_x=testing_data[,-1]
training_x=training_data[,-1]

# Loop with k from 1 to 20
result <- c(rep(0,20))
for (i in 1:20) {
  set.seed(1)
  Mn <- knn(train=training_x,test=testing_x,
            cl=training_y,k=i)
  result[i]<- mean(testing_y!=Mn)
}
result
min(result)

# Find k that has the lowest misclassification
which(result==min(result))

# Confusion matrix
set.seed(1)
y_pred <- knn(train=training_x,test=testing_x,cl=training_y,k=16)
mean(y_pred!=testing_y)
conf_matrix_test_2=table(y_pred, testing_y)
conf_matrix_test_2

# False positive and false negative rates
false_positive_test_2=conf_matrix_test_2[2,1]/sum(testing_y==0)
false_positive_test_2
false_negative_test_2=conf_matrix_test_2[1,2]/sum(testing_y==1)
false_negative_test_2







