#!/bin/bash -xe
#Create Docker Swarm Stack including the necessary S3 bucket to share information re swarm tokens
# Shell script execution example:
#Parameter 1: bucketName - bucket is used to temporary store data for creating the cluster - bucket can exist or will be created otherwise
#Parameter 2: bucketKey - bucketkey to store the temporary data
#Parameter 3: awsRegion - Region to create the cluster
#Parameter 4: stackName - Name of the CloudFormation stack
#Parameter 5: keyPairName - Name of the SSH keypair necessary to log into EC2 instances
#Parameter 6: scriptLocation - Location of the UserData script
#Parameter 7: stackLocation - Location of the CloudFormation template
echo "[INFO] Start createS3Bucket with Parameters $1, $2, $3, $4, $5, $6, $7";

#Set calling parameters to local parameters
bucketName=$1
bucketKey=$2
awsRegion=$3
stackName=$4
keyPairName=$5
scriptLocation=$6
stackLocation=$7

#Name of the UserData script uploaded using scriptLocation
fileKey="userdata-script.sh"
#Template needs the bucketkey ending with /
bucketKeySlash="$bucketKey/"

#Call createS3Bucket Shell script
./scripts/createS3Bucket.sh $bucketName $bucketKey $fileKey $awsRegion $scriptLocation


if [ $? -eq 0 ]
then
  echo "Continuing with creating stack"
  aws --region $awsRegion cloudformation create-stack --stack-name $stackName \
   --template-body file://$stackLocation \
   --parameters ParameterKey=BucketName,ParameterValue=$bucketName \
   ParameterKey=KeyPrefix,ParameterValue=$bucketKeySlash \
   ParameterKey=ScriptName,ParameterValue=$fileKey \
   ParameterKey=KeyPairName,ParameterValue=$keyPairName \
   --capabilities CAPABILITY_NAMED_IAM
  if [ $? -eq 0 ]
  then
    echo "Stack created"
    exit 0
  else
    echo "Failure creating stack"
    exit 1
  fi
else
  echo "Error in createS3bucket script"
  exit 1
fi
