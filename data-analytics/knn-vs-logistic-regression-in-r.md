# KNN vs Logistic Regression in R

![Cover](../.gitbook/assets/cover%20%282%29.jpg)

_This image may not relate to this project at all. Source: www.childcarseats.com.au. All images, data and R Script can be found_ [_here_](https://github.com/vuduong191/Gitbook/tree/master/resources/KNN01)

> This is a short homework assignment in DSO\_530 Applied Modern Statistical Learning Methods class by professor Robertas Gabrys, USC. I completed this project with two classmates He Liu and Kurshal Bhatia. In this assignment, we compare the predictive power of KNN and Logistic Regression.

## Prompt

A child car seat company is interested in understanding what factors contribute to sales for one of its products. They have sales data on a particular model of child car seats at different stores inside and outside the United States.

To simplify the analysis, the company considers sales at a store to be “**Satisfactory**” if they are able to cover 115% of their costs at that location \(i.e., roughly 15% profit\) and “**Unsatisfactory**” if sales cover less than 115% of costs at that location \(i.e., less than 15% profit\).

The data set consists of 11 variables and 400 observations. Each observation corresponds to one of the stores.

| **Variables** | **Description** |
| :--- | :--- |
| Sales | Sales at each store \(**Satisfactory** = 1 or **Unsatisfactory** = 0\) |
| CompPrice | Price charged by competitor’s equivalent product at each store |
| Income | Local community income level \(in thousands of dollars\) |
| Advertising | Local advertising budget for company at each store \(in thousands of dollars\) |
| Population | Population size of local community \(in thousands\) |
| Price | Price company charges for its own product at the store |
| ShelveLoc | A factor with levels \(Good=1 and Bad=0\) indicating the quality of the shelving location for the car seats at each store |
| Age | Average age of the local community |
| Education | Average Education level in the local community |
| Urban | A factor with levels \(Yes=1 and No=0\) to indicate whether the store is in an urban or rural location |
| US | A factor with levels \(Yes=1 and No=0\) to indicate whether the store is in the US or not |

## Load data

```r
> carseat.data=read.csv("carseat.txt")
> head(carseat.data)
  Sales CompPrice Income Advertising Population Price ShelveLoc Age Education Urban US
1     1       138     73          11        276   120         0  42        17     1  1
2     1       111     48          16        260    83         0  65        10     1  1
3     1       113     35          10        269    80         1  59        12     1  1
4     0       117    100           4        466    97         1  55        14     1  1
5     0       141     64           3        340   128         0  38        13     1  0
6     1       124    113          13        501    72         0  78        16     0  1
```

## Create the validation set and training set

```r
testing_data=carseat.data[1:100,]
training_data=carseat.data[101:400,]
testing_y=carseat.data$Sales[1:100]
training_y=carseat.data$Sales[101:400]
testing_x=testing_data[,-1]
training_x=training_data[,-1]
```

## Train the logistic regression model

```r
> logistic_model=glm(Sales~.,data=training_data, family="binomial")
> summary(logistic_model)

Call:
glm(formula = Sales ~ ., family = "binomial", data = training_data)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-2.1090  -0.6056  -0.1899   0.4225   2.6784  

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept) -1.3913119  2.0272717  -0.686 0.492525    
CompPrice    0.1133453  0.0183759   6.168 6.91e-10 ***
Income       0.0153623  0.0061970   2.479 0.013175 *  
Advertising  0.1481729  0.0391825   3.782 0.000156 ***
Population  -0.0002905  0.0012774  -0.227 0.820126    
Price       -0.1175769  0.0150529  -7.811 5.68e-15 ***
ShelveLoc    2.6133149  0.4955569   5.273 1.34e-07 ***
Age         -0.0568264  0.0116597  -4.874 1.09e-06 ***
Education   -0.0451832  0.0641827  -0.704 0.481447    
Urban       -0.5172575  0.3888039  -1.330 0.183393    
US           0.3059033  0.5093854   0.601 0.548150    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 402.98  on 299  degrees of freedom
Residual deviance: 222.16  on 289  degrees of freedom
AIC: 244.16

Number of Fisher Scoring iterations: 6
```

Find the cutoff value

```r
> cutoff_table = data.frame(seq(0.2,0.8,by=0.05), rep(NA,13))
> colnames(cutoff_table)<-c("Cutoff", "Misclassification_error")
> for (i in 1:13){
+   y=predict(logistic_model,training_data,type="response")
+   y_result=ifelse(y>cutoff_table$Cutoff[i],1,0)
+   cutoff_table$Misclassification_error[i]<- mean(y_result!=training_y)
+ }
> cutoff_table
   Cutoff Misclassification_error
1    0.20               0.2600000
2    0.25               0.2266667
3    0.30               0.2166667
4    0.35               0.1933333
5    0.40               0.1833333
6    0.45               0.1666667
7    0.50               0.1533333
8    0.55               0.1433333
9    0.60               0.1533333
10   0.65               0.1733333
11   0.70               0.1933333
12   0.75               0.2166667
13   0.80               0.2233333
```

The misclassification rate is lowest at 14.3% whenthe cutoff value is 0.55. We will use this value to predict on the testing set.

Create confusion matrix on testing set

```r
> logistic_test_probs=predict(logistic_model,testing_data,type="response")
> logistic_test_pred_y=ifelse(logistic_test_probs>0.55,1,0)
> conf_matrix_test=table(logistic_test_pred_y, testing_y)
> conf_matrix_test
                    testing_y
logistic_test_pred_y  0  1
                   0 51 16
                   1  4 29
> misclassifaction_error_test=mean(logistic_test_pred_y!=testing_y)
> misclassifaction_error_test
[1] 0.2
```

The misclassification error for the testing set is 20%, smaller than that of the training set. This is actually a very impressive result.

False positive and false negative rates

```r
> false_positive_test=conf_matrix_test[2,1]/sum(testing_y==0)
> false_positive_test
[1] 0.07272727
> false_negative_test=conf_matrix_test[1,2]/sum(testing_y==1)
> false_negative_test
[1] 0.3555556
```

## KNN Model

First we need package "class" to run k-nearest neighbour classification. It requires the response variable to be factor.

```r
library(class)
dim(carseat.data)
class(carseat.data$Sales)
carseat.data$Sales=as.factor(carseat.data$Sales)
```

Find k to minimize misclassification rate

```r
> for (i in 1:20) {
+   set.seed(1)
+   Mn <- knn(train=training_x,test=testing_x,
+             cl=training_y,k=i)
+   result[i]<- mean(testing_y!=Mn)
+ }
> result
 [1] 0.46 0.48 0.37 0.38 0.37 0.37 0.36 0.39 0.35 0.37 0.36 0.36 0.33 0.34 0.35 0.32 0.35 0.34 0.37 0.39
> which(result==min(result))
[1] 16
```

Misclassification rate and confusion matrix

```r
> set.seed(1)
> y_pred <- knn(train=training_x,test=testing_x,cl=training_y,k=16)
> mean(y_pred!=testing_y)
[1] 0.32
> conf_matrix_test_2=table(y_pred, testing_y)
> conf_matrix_test_2
      testing_y
y_pred  0  1
     0 51 28
     1  4 17
```

False positive and false negative rates

```r
> false_positive_test_2=conf_matrix_test_2[2,1]/sum(testing_y==0)
> false_positive_test_2
[1] 0.07272727
> false_negative_test_2=conf_matrix_test_2[1,2]/sum(testing_y==1)
> false_negative_test_2
[1] 0.6222222
```

Compared with Logistic regression, KNN has higher misclassification rate. Especially, the false negative rate is substantially high at 62.2%

