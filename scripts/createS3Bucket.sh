#!/bin/bash -xe
#Create S3 bucket
#Parameter 1: bucketName
#Parameter 2: bucketKey
#Parameter 3: awsRegion
echo "[INFO] Start createS3Bucket with Parameters $1, $2, $3";

#set calling parameters to local parameters
bucketName=$1
bucketKey=$2
awsRegion=$3
fileName="userdata-swarm-instances.sh"
fullFileKey="$bucketKey/$fileName"


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
