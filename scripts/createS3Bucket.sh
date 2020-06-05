#!/bin/bash -xe
#Create S3 bucket
#Parameter 1: bucketName
#Parameter 2: bucketKey
#Parameter 3: fileKey
#Parameter 4: awsRegion
#Parameter 5: fileName
echo "[INFO] Start createS3Bucket with Parameters $1, $2, $3, $4, $5";

#set calling parameters to local parameters
bucketName=$1
bucketKey=$2
fileKey=$3
awsRegion=$4
fileName=$5
fullFileKey="$bucketKey/$fileKey"


#Verify if bucket exists
if aws s3api head-bucket --bucket "$bucketName" 2>/dev/null; then
  echo "Bucket exists - Putting the file"
  aws s3api put-object --bucket "$bucketName" --key "$fullFileKey" --body "$fileName"
else
  echo "Bucket does not exist or no access - create new bucket"
  aws s3api create-bucket --bucket $bucketName --region $awsRegion --acl private --create-bucket-configuration LocationConstraint=$awsRegion
  #Check if bucket has been created successfully
  if aws s3api head-bucket --bucket "$bucketName" 2>/dev/null; then
    echo "Bucket created - Putting the file"
    aws s3api put-object --bucket "$bucketName" --key "$fullFileKey" --body "$fileName"
  else
    echo "Bucket creation went wrong - exit 1"
    exit 1
  fi
fi
exit 0
