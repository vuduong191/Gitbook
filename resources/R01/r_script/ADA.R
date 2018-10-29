# Libraries used. Make sure you install and load them all before running.
library(readxl)
library(stringr)
library(dplyr)
att <- read_xls("attendance.xls")
head(att,n=15)
tail(att,n=10)

#Remove rows with more than 5 NA values
#Remove columns 3,5,7,9,11,13,15,17. They contains useless data
nacount <- is.na(att)
removerow<-rowSums(nacount)>5
removecolumn <-seq(3,17,2)
att2 <- att[!removerow,-removecolumn]
# Define cnames vector
cnames <- c("state", "avg_attend_pct", "avg_hr_per_day", "avg_day_per_yr", "avg_hr_per_yr","avg_attend_pct", "avg_hr_per_day", "avg_attend_pct", "avg_hr_per_day")
# Assign column names of att2
colnames(att2) <- cnames
head(att2)
# Remove all periods and white spaces around state names
att2$state<-str_replace_all(att2$state,"\\.","")
att2$state <-str_trim(att2$state)
head(att2$state)
#Make sure you apply names before you run str_replace_all function, because if you call str_replace_all on att2[1], instead of att2$state, things will be messy. att2[1] is a dataframe, while att2$state is a vector.

# Subset just elementary schools: att_elem
att_elem <- att2[,c(1,6,7)]

# Subset just secondary schools: att_sec
att_sec <- att2[,c(1,8,9)]

# Subset all schools: att4
att4 <- att2[,1:5]

# Change columns to numeric using dplyr

att4 <- mutate_at(att4, vars(-state), funs(as.numeric))
str(att4)
# You can actually use sapply to do this
# cols<-c(2:ncol(att4))
# att5[, cols] <- sapply(att4[,cols],as.numeric)
