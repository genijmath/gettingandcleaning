###############################################################################
# defines function run_analisys() which loads                                 #
# "Human Activity Recognition Using Smartphones Dataset"                      #
# and returns a data frame which provides mean values for features            #
# based on means and standard deviations by activity and subject_id.          #
#                                                                             #
# Location of the input dataset is determined by in.dir global variable.      #
#                                                                             #
# This dataset was used in the following publication:                         #
#                                                                             #
# Davide Anguita, Alessandro Ghio, Luca Oneto,                                #
# Xavier Parra and Jorge L. Reyes-Ortiz.                                      #
# Human Activity Recognition on Smartphones using a Multiclass                #
# Hardware-Friendly Support Vector Machine.                                   #
# International Workshop of Ambient Assisted Living (IWAAL 2012).             #
# Vitoria-Gasteiz, Spain. Dec 2012.                                           #
###############################################################################

###############################################################################
###################                   SETTINGS              ###################
###############################################################################
#in.dir <- paste0("/media/yevgen/adde6142-c0eb-41e9-b7a8-264f7c8b4728/",
#                 "Lectures/Getting and Cleaning Data/assignments/",
#                 "UCI HAR Dataset")
in.dir = "."
production = TRUE  # TRUE: read all data, FALSE: read portion of data.
NROWS = ifelse(production, -1, 25)
###############################################################################


###############################################################################
###################                  LIBRARIES              ###################
###############################################################################

library(dplyr)

###############################################################################
##################            HELPER FUNCTIONS              ###################
###############################################################################
# reads the features.
# subsetType takes values "train", "test". 
# root.folder is a folder containing subfolders "train" and "test".
# dataset is loaded from <root.folder>/<subsetType>/X_<subsetType>.txt file.
# <root.folder>/features.txt provides column names.
# nrows allows loading only a subset of available data, negative values 
#   indicate that the whole.file needs to be loaded.
# output is a dataframe of features.
loadFeatures <- function(subsetType, root.folder = in.dir, nrows = NROWS) {
  n.features <-561
  df <- read.table(
    file.path(root.folder, subsetType, paste0("X_", subsetType, ".txt")), 
    comment.char = "",
    colClasses = rep("numeric", n.features),
    nrows = nrows)
  names <- readLines(file.path(root.folder, "features.txt"))
  # extract.name transforms "2 tBodyAcc-mean()-Y" into tBodyAcc.mean.Y.2.
  # feature id (2 in this case) is kept as a part of variable name because
  # some feature names are duplicated. For example,
  # 461 fBodyGyro-bandsEnergy()-1,8
  # 475 fBodyGyro-bandsEnergy()-1,8
  extract.name <- function(s) {
    words <- strsplit(s, " ", TRUE)[[1]]
    make.names(gsub("()", "", paste(words[[2]], words[[1]]), fixed = TRUE))
  }  
  names(df) <- sapply(names, extract.name, USE.NAMES = FALSE)
  # src column is created to simplify data tracking.
  cbind(src = sprintf("%s:%04d", subsetType, 1:nrow(df)), df)
}

# reads activities, adds subject-id as an activity attribute.
# subsetType takes values "train", "test". 
# root.folder is a folder containing subfolders "train" and "test".
# dataset is loaded from <root.folder>/<subsetType>/y_<subsetType>.txt file.
# activity_labels.txt provides explaination codes.
# <subsetType>/subject_<subsetType>.txt is used to add subject_id for each 
# record.
# nrows allows loading only a subset of available data, negative values 
#   indicate that the whole.file needs to be loaded.
# output is a dataframe with a single column describing activity 
#   as a factor variable.
loadActivities <- function(subsetType, root.folder = in.dir, nrows = NROWS) {
  df <- read.table(
    file.path(root.folder, subsetType, paste0("y_", subsetType, ".txt")),
    comment.char="",
    colClasses = c("integer"),
    nrows = nrows)
  # add subject_id column
  # prepend subject_id with 0 if necessary.
  subject_id <- readLines(
    file.path(root.folder, subsetType, paste0("subject_", subsetType, ".txt")))
  df <- cbind(
    data.frame(sprintf("%02d", as.integer(subject_id)), stringsAsFactors=FALSE), 
    df)
  # add row number as obs.id so that we could properly merge later.
  df <- add.obs.id(df)
  names(df) <- c("obs.id", "subject_id", "activity.id")
  # desciption contains strings like "3 WALKING_DOWNSTAIRS"
  # activity.descr <- readLines(file.path(root.folder, "activity_labels.txt"))
  # split each line into a pair of words, and make a data frame out of it.
  # result is a matrix like
  # "1"  "WALKING"           
  # "2"  "WALKING_UPSTAIRS" 
  activity.df <- t(data.frame(
    sapply(activity.descr, function(x) strsplit(x, " "))))
  dimnames(activity.df) <-list(NULL, c("activity.id", "activity"))
  activity.df <- data.frame(activity.df)
  df <- merge(df, activity.df, by = "activity.id")
  df <- arrange(df, obs.id)
  # src column is created to simplify data tracking.
  cbind(src = sprintf("%s:%04d", subsetType, df$obs.id),
        select(df, -obs.id, -activity.id))
}

# adds obs.id column to X with values 1..nrow(X)
add.obs.id <- function(X) {
  cbind(obs.id = 1:nrow(X), X)
}

###############################################################################
##################               PRIMARY FUNCTION            ##################
###############################################################################

run_analysis <- function() {
  # Step 1. 
  # Merges the training and the test sets to create one data set.
  features <- add.obs.id(rbind(loadFeatures("train"), 
                               loadFeatures("test")))
  activities <- add.obs.id(rbind(loadActivities("train"), 
                                 loadActivities("test")))
  # all.data has columns: src, activity, <measurements>
  all.data <- select(merge(activities, select(features, -src), by = "obs.id"), 
                     -obs.id)
  
  # Step 2. 
  # Extracts only the measurements on the mean and standard deviation for 
  # each measurement.
  
  # keep only names containing mean or std
  stat.names <- names(all.data)[grep("(mean|std)", names(all.data))] 
  mean.std.data <- all.data[,c("src", "activity", "subject_id", stat.names)]
  
  # Step 3. 
  # Uses descriptive activity names to name the activities in the data set.
  # Done.
  
  # Step 4. 
  # Appropriately labels the data set with descriptive variable names. 
  # Done.
  
  # Step 5. 
  # From the data set in step 4, creates a second, independent tidy data set 
  # with the average of each variable for each activity and each subject.
  
  R <- ddply(mean.std.data, .(activity, subject_id), numcolwise(mean))
  # add "mean.of." prefix to each summary variable name
  names(R) <- c("activity", "subject_id", 
                sapply(stat.names, function(s) paste0("mean.of.", s)))
  R
}
