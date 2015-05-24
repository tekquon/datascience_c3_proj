## Step 0: Set up libraries, get Zip Data File and Unzip
library(dplyr)
library(stringr)
library(knitr)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./data")) {
  dir.create("./data")
}
setwd("./data")
download.file(url, destfile="./wearable.zip", method="curl")
unzip("./wearable.zip")

## Step 1:  Get Test Data
setwd("./UCI\ HAR\ Dataset/test")
test_users <- read.table("./subject_test.txt", col.names = c("User_ID"))
test_activities <- read.table("./y_test.txt", col.names = c("Activity_ID"))
test_observations <- read.table("./X_test.txt")
test_data <- cbind(test_users,test_activities,test_observations)
test_data$type = "test"

## Step 2: Get Train Data
setwd("../train")
train_users <- read.table("./subject_train.txt", col.names = c("User_ID"))
train_activities <- read.table("./y_train.txt", col.names = c("Activity_ID"))
train_observations <- read.table("./X_train.txt")
train_data <- cbind(train_users,train_activities,train_observations)
train_data$type = "train"

## Step 3: Combine Test & Train Data
data <- rbind(test_data, train_data)

## Step 4: Get data column names
setwd("../")
colNames <- read.table("./features.txt", col.names = c("OriginalColNum", "ColName"), stringsAsFactors = FALSE)
colNames$ColNum <- colNames$OriginalColNum + 2

## Step 5: Get mean & std columns - defined if a variable includes "mean()" or "std()" and renames data column
means <- grepl("mean()", fixed=TRUE, colNames$ColName)
std <- grepl("std()", fixed=TRUE, colNames$ColName)
includedCols <- c(1,2,564) ##Need to include User_ID and Activity_ID columns
j <- 1
for(i in colNames$ColNum) {
  if(means[j] | std[j]) {
    includedCols <- c(includedCols,i)
    names(data)[i] <- colNames[j,"ColName"]
  }
  j = j+1
}

## Step 6: Removes Extra Unnecessary Columns
data <- select(data, includedCols)

## Step 7: Adds Descriptive Activity Names to Data
activityNames <- read.table("./activity_labels.txt", col.names = c("Activity_ID", "Activity_Name"), stringsAsFactors = TRUE)
data <- merge(data, activityNames, by.x = "Activity_ID", by.y = "Activity_ID")

## Step 8: Creates tidy data set of average variable by user & activity
tidy <- data %>% group_by(User_ID, Activity_Name, Activity_ID, type) %>% summarise_each(funs(mean))

## Step 9: Writes tidy data set to an external file
setwd("../../")
write.table(tidy, file="./q5.txt", row.name = FALSE)

##Step 10: Create the Codebook
cb <- data.frame(VariableName = names(tidy))
cb$MeasurementType[5:length(cb)] <- ifelse(grepl("mean()", cb$VariableName[5:length(cb)], "mean"), "mean", "standard deviation")
cb$MeasurementType[1:4] <- "Description"
j <- 1
for(i in lapply(tidy, class))
{
  cb$DataType[j] <- i[[1]]
  j = j+1
}
cb$Axis <- ifelse(grepl("-X", cb$VariableName), "X", ifelse(grepl("-Y", cb$VariableName), "Y", ifelse(grepl("-Z", cb$VariableName), "Z", "N/A")))
cb$TimeFreq <- ifelse(substr(cb$VariableName, 1,1) == "t", "time", ifelse(substr(cb$VariableName, 1,1) == "f", "frequency domain signals", "N/A"))
cb$Description[5:length(cb$VariableName)] <- str_extract(substr(cb$VariableName[5:length(cb$VariableName)],2,nchar(as.character(cb$VariableName[5:length(cb$VariableName)]))), "^[^-]+")
cb$Description[1] <- "ID Number for the User"
cb$Description[2] <- "Name of the Activity User Was Engaged for Observations"
cb$Description[3] <- "ID Number of the Activity"
cb$Description[4] <- "Type of user: either train or test"
cb$Methodology[5:length(cb$Methodology)] <- "Mean of this variable, grouped by the 'Description' variables" 
cb$Methodology[1:4] <- "Descriptor that the variables have been grouped by"
cb_output <- kable(cb, format = "markdown")
write(cb_output, "CodeBook.md")