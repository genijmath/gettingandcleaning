# Code book for *Getting and Cleaning Data* course project.

## Input

[Human Activity Recognition Using Smartphones Dataset](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
dataset used in the paper of

*Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012*

## Processing

###1. Loading features

The following files are used:

* train/X_train.txt - features extracted from training portion of HARUS dataset;
* test/X_test.txt - features extracted from testing portion of HARUS dataset ;
* features.txt - feature names.

Feature names are used to label columns for data frames extracted from *X_train.txt* and
*X_test.txt* files. Since some feature names are duplicated (for instance, 
`461 fBodyGyro-bandsEnergy()-1,8` and `475 fBodyGyro-bandsEnergy()-1,8`) feature ordinal
number were kept as a part of column label. In order to make labels R-friendly and 
easier to read names where adjusted by removing `()` substrings and replacing non-alphabetic
characters with dots. For example, feature named `461 fBodyGyro-bandsEnergy()-1,8` 
is labeled with `fBodyGyro.bandsEnergy.1.8.461`.

See `loadFeatures` function for details.

###2. Loading activities

The following files are used:

* train/y_train.txt - activity ids from training portion of HARUS dataset;
* test/y_test.txt - activity ids from testing portion of HARUS dataset;
* train/subject_train.txt - identifiers of people performing activities from the training portion of HARUS dataset;
* test/subject_test.txt - identifiers of people performing activities from the testing portion of HARUS dataset;
* activity_labels.txt - description of activity ids.

Notes:

* subject ids and activity id data is combined by row number; 
* activity lables are merged by activity id to form more human-friently factor variables;
* subject ids are converted into 0-padded strings in order to improve sort ordering.

See `loadActivities` function for details.

###3. Variable selection
Variables (features) with labels containing *std* or *mean* are selected (including labels containing *meanFreq* substring).

###4. Computation
For every activity/subject\_id combination mean value for every feature from the previous section is calculated. Result is stored in a column named after original column with "mean.of." prefix prepended. For example, mean value of *tBodyAcc.mean.X.1* variable is stored in *mean.of.tBodyAcc.mean.X.1* column (so the value of this column is a mean of means). 

##Output
Output of run\_analysis() function is a data-frame having activity variable (factor), subject\_id (character), and 79 variables computed above (starting with *mean.of.*). Refer to *features_info.txt* file of HARUS dataset for semantics of variables. 

Column names of the output:
```
activity
subject_id
mean.of.tBodyAcc.mean.X.1
mean.of.tBodyAcc.mean.Y.2
mean.of.tBodyAcc.mean.Z.3
mean.of.tBodyAcc.std.X.4
mean.of.tBodyAcc.std.Y.5
mean.of.tBodyAcc.std.Z.6
mean.of.tGravityAcc.mean.X.41
mean.of.tGravityAcc.mean.Y.42
mean.of.tGravityAcc.mean.Z.43
mean.of.tGravityAcc.std.X.44
mean.of.tGravityAcc.std.Y.45
mean.of.tGravityAcc.std.Z.46
mean.of.tBodyAccJerk.mean.X.81
mean.of.tBodyAccJerk.mean.Y.82
mean.of.tBodyAccJerk.mean.Z.83
mean.of.tBodyAccJerk.std.X.84
mean.of.tBodyAccJerk.std.Y.85
mean.of.tBodyAccJerk.std.Z.86
mean.of.tBodyGyro.mean.X.121
mean.of.tBodyGyro.mean.Y.122
mean.of.tBodyGyro.mean.Z.123
mean.of.tBodyGyro.std.X.124
mean.of.tBodyGyro.std.Y.125
mean.of.tBodyGyro.std.Z.126
mean.of.tBodyGyroJerk.mean.X.161
mean.of.tBodyGyroJerk.mean.Y.162
mean.of.tBodyGyroJerk.mean.Z.163
mean.of.tBodyGyroJerk.std.X.164
mean.of.tBodyGyroJerk.std.Y.165
mean.of.tBodyGyroJerk.std.Z.166
mean.of.tBodyAccMag.mean.201
mean.of.tBodyAccMag.std.202
mean.of.tGravityAccMag.mean.214
mean.of.tGravityAccMag.std.215
mean.of.tBodyAccJerkMag.mean.227
mean.of.tBodyAccJerkMag.std.228
mean.of.tBodyGyroMag.mean.240
mean.of.tBodyGyroMag.std.241
mean.of.tBodyGyroJerkMag.mean.253
mean.of.tBodyGyroJerkMag.std.254
mean.of.fBodyAcc.mean.X.266
mean.of.fBodyAcc.mean.Y.267
mean.of.fBodyAcc.mean.Z.268
mean.of.fBodyAcc.std.X.269
mean.of.fBodyAcc.std.Y.270
mean.of.fBodyAcc.std.Z.271
mean.of.fBodyAcc.meanFreq.X.294
mean.of.fBodyAcc.meanFreq.Y.295
mean.of.fBodyAcc.meanFreq.Z.296
mean.of.fBodyAccJerk.mean.X.345
mean.of.fBodyAccJerk.mean.Y.346
mean.of.fBodyAccJerk.mean.Z.347
mean.of.fBodyAccJerk.std.X.348
mean.of.fBodyAccJerk.std.Y.349
mean.of.fBodyAccJerk.std.Z.350
mean.of.fBodyAccJerk.meanFreq.X.373
mean.of.fBodyAccJerk.meanFreq.Y.374
mean.of.fBodyAccJerk.meanFreq.Z.375
mean.of.fBodyGyro.mean.X.424
mean.of.fBodyGyro.mean.Y.425
mean.of.fBodyGyro.mean.Z.426
mean.of.fBodyGyro.std.X.427
mean.of.fBodyGyro.std.Y.428
mean.of.fBodyGyro.std.Z.429
mean.of.fBodyGyro.meanFreq.X.452
mean.of.fBodyGyro.meanFreq.Y.453
mean.of.fBodyGyro.meanFreq.Z.454
mean.of.fBodyAccMag.mean.503
mean.of.fBodyAccMag.std.504
mean.of.fBodyAccMag.meanFreq.513
mean.of.fBodyBodyAccJerkMag.mean.516
mean.of.fBodyBodyAccJerkMag.std.517
mean.of.fBodyBodyAccJerkMag.meanFreq.526
mean.of.fBodyBodyGyroMag.mean.529
mean.of.fBodyBodyGyroMag.std.530
mean.of.fBodyBodyGyroMag.meanFreq.539
mean.of.fBodyBodyGyroJerkMag.mean.542
mean.of.fBodyBodyGyroJerkMag.std.543
mean.of.fBodyBodyGyroJerkMag.meanFreq.552
```

