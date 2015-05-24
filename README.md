---
title: "Getting and Cleaning Data - Class Project"
output: html_document
---

This document explains the code to re-create the tidy dataset of the mean values of the mean/standard deviation measurements by user/activity found in the Galaxy data here:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# The Data

### Raw Data
The data is split into training data (70%) and test data (30%).  Within each set of data, the following files are included:

*X Data: Provides values from the features of the experiment on a per-subject basis
*Subject Data: Provides unique ID values for each subject, corresponding to the line of the X & Y data
*Y Data: Provides the activity in which the subject was performing to receive the X data

In addition, there are descriptive data that apply to both data sets above:
*Activity Labels: Friendly / descriptive names that correspond with the "Y" data above
*Features Info: Provides the column/X observation descriptive names for the X data


### Tidy Data within R

Within R, the data is maintained in a tidy fashion.  Each observation is kept in a separate line, and train/test data is flagged appropriately. X data, Subject, Y data, Activity Labels, and Features Info are all mapped into one dataset (across several columns) to run the analysis needed to provide the output, described below.

# The Code

A detailed overview will be provided for each section of code.

### Step 0 - Set Up
Before beginning, the dplyr library is loaded and the data described above is downloaded and unzipped to the data folder within the current workding directly.

### Step 1 - Loading The Test Data
All 3 data types described above (X, Y, Subject) are loaded into data frames within R using 
```{r}
read.table()
```
cbind() is used to connect the datasets into one.

### Step 2 - Loading the Train Data
Same steps as step 1, but with train data.

### Step 3 - Combining the Data
Data is combined into one data set using rbind().

NOTE: To distinguish between train and test data and conform to tidy data standards, a new 'type' column has been added to distinguish between 'train' and 'test' data.

### Step 4 - Getting the Column Names
The features info is imported to give a more descriptive name for our current columns of data.  Column names are kept in a colNames data frame, with appropriate mapping to the columns in the new data set above.

### Step 5 - Determine Which Columns to Keep 
Per the assignment instructions, the variables remaining are means and standard deviations of the data set's standard  variables.  These are variables containing one of the following strings

```{r}
mean()
```
```{r}
sd()
```

Once the remaining columns are determined, each column in the existing data set is renamed.

### Step 6 - Remove Unnecessary Columns
To reduce strain on memory, all unnecessary columns are removed after determining which to keep in the last step.

### Step 7 - Add Descriptive Activity Names to Data
The activity labels are merged with the existing dataset, so each observation now has a descriptive friendly name of what was taking place during the measurement.

### Step 8 - Output Tidy Data Set Created
Using the existing tidy data, a summary data set is formulated using the dplyr to calculate a mean across all non-descriptive variables, organized by subject, activity, and type (train/test).

```{r}
tidy <- data %>% group_by(User_ID, Activity_Name, Activity_ID, type) %>% summarise_each(funs(mean))
```

### Step 9 - Write Data to File
The data set created in step 8 is written to a file named "q5.txt" in the current working directory.

### Step 10 - Creates the codebook
This block creates the codebook of the variable names in the final tidy dataset.  Codebook describes the variables in table format.
```{r}
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
```
