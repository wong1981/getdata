# Set to TRUE to attempt the download automatically
# May not work on all platforms or in VM environments
download.file.automatically <- TRUE

data.file <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
localfile <- './dataset.zip'
local.data.dir <- './UCI HAR Dataset'
tidy.data.file <- './tidy-UCI-HAR-dataset.csv'
tidy.avgs.data.file <- './tidy-UCI-HAR-avgs-dataset.csv'
tidy.avgs.data.txt <- './tidy-UCI-HAR-avgs-dataset.txt'




# Make sure the original data file is in the working directry, downloading
# it if needed (and allowed)
if (! file.exists(localfile)) {
  if (download.file.automatically) {
    download.file(data.file,
                  destfile = localfile)
  }
}

# Crash if file is not present
if (! file.exists(localfile)) {
  stop(paste(localfile, 'must be present in working directory.'))
}

# Uncompress the original data file
if (! file.exists(local.data.dir)) {
  unzip(localfile)
}

# Fail if unzip failed
if (! file.exists(local.data.dir)) {
  stop(paste('Unable to unpack the compressed data.'))
}

# Read activity labels
acts <- read.table(paste(local.data.dir, 'activity_labels.txt', sep = '/'),
                   header = FALSE)
names(acts) <- c('id', 'name')

# Read feature labels
feats <- read.table(paste(local.data.dir, 'features.txt', sep = '/'),
                    header = FALSE)
names(feats) <- c('id', 'name')

# Read the plain data files, assigning sensible column names
train.X <- read.table(paste(local.data.dir, 'train', 'X_train.txt', sep = '/'),
                      header = FALSE)
names(train.X) <- feats$name
train.y <- read.table(paste(local.data.dir, 'train', 'y_train.txt', sep = '/'),
                      header = FALSE)
names(train.y) <- c('activity')
train.subject <- read.table(paste(local.data.dir, 'train', 'subject_train.txt',
                                  sep = '/'),
                            header = FALSE)
names(train.subject) <- c('subject')
test.X <- read.table(paste(local.data.dir, 'test', 'X_test.txt', sep = '/'),
                     header = FALSE)
names(test.X) <- feats$name
test.y <- read.table(paste(local.data.dir, 'test', 'y_test.txt', sep = '/'),
                     header = FALSE)
names(test.y) <- c('activity')
test.subject <- read.table(paste(local.data.dir, 'test', 'subject_test.txt',
                                 sep = '/'),
                           header = FALSE)
names(test.subject) <- c('subject')

# Merge the training and test sets
X <- rbind(train.X, test.X)
y <- rbind(train.y, test.y)
subject <- rbind(train.subject, test.subject)

# Extract just the mean and SD features
# Note that this includes meanFreq()s - it's not clear whether we need those,
# but they're easy to exlude if not needed.
X <- X[, grep('mean|std', feats$name)]

# Convert activity labels to meaningful names
y$activity <- acts[y$activity,]$name

# Merge partial data sets together
tidy.data.set <- cbind(subject, y, X)

# Dump the data set
write.csv(tidy.data.set, tidy.data.file)

# Compute the averages grouped by subject and activity
tidy.avgs.data.set <- aggregate(tidy.data.set[, 3:dim(tidy.data.set)[2]],
                                list(tidy.data.set$subject,
                                     tidy.data.set$activity),
                                mean)
names(tidy.avgs.data.set)[1:2] <- c('subject', 'activity')

# Dump the second data set
write.csv(tidy.avgs.data.set, tidy.avgs.data.file)

#Dump tidy datset in txt
write.table(tidy.avgs.data.set, tidy.avgs.data.txt, row.name=FALSE)

