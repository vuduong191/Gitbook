# KNN vs Logistic Regression in R



####  Prompt

A child car seat company is interested in understanding what factors contribute to sales for one of its products. They have sales data on a particular model of child car seats at different stores inside and outside the United States. 

To simplify the analysis, the company considers sales at a store to be “**Satisfactory**” if they are able to cover 115% of their costs at that location \(i.e., roughly 15% profit\) and “**Unsatisfactory**” if sales cover less than 115% of costs at that location \(i.e., less than 15% profit\). 

The data set consists of 11 variables and 400 observations.  Each observation corresponds to one of the stores.

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

