# # Getting and Cleaning Data -- Class Project

# run_analysis.R performs the following actions:
# 1) Downloads the Galaxy S data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and unzips onto a data folder within the working directory
# 2) Reads test and train data from the dataset
# --Note: Inertial Signals are not utilized
# 3) Combines test and train data into a tidy dataset
# 5) Filters out all columns that are not mean or standard deviations
# --Note: columns with mean() and std() are identified as true means and std for purposes of this project per features_info.txt
# 6) Creates a tidy dataset of the mean values identified above, organized by user, activity, and user type (train/test)
# --Note: tidy as each user/activity pair only has one line of observation
#
# Requirements:
# -Installation of dplyr package
# -Internet connection
 
