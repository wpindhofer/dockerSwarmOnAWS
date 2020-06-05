#!/bin/bash -xe
#Create Docker Swarm Stack including the necessary S3 bucket to share information re swarm tokens
# Shell script execution example:
# createDockerSwarmStack.sh waltersdockerswarm swarm-join-tokens eu-central-1 myDockerSwarmStack SSH-docker-swarm
#Parameter 1: bucketName
#Parameter 2: bucketKey
#Parameter 3: awsRegion
#Parameter 4: stackName
#Parameter 5: keyPairName
echo "[INFO] Start createS3Bucket with Parameters $1, $2, $3, $4, $5";

#Set calling parameters to local parameters
bucketName=$1
bucketKey=$2
awsRegion=$3
stackName=$4
keyPairName=$5
fileName="userdata-swarm-instances.sh"
fullFileKey="$bucketKey/$fileName"

#Call createS3Bucket Shell script
scripts/createS3Bucket.sh $bucketName $bucketKey $awsRegion

bucketKeySlash="$bucketKey/"

if [ $? -eq 0 ]
then
  echo "Continuing with creating stack"
  aws --region $awsRegion cloudformation create-stack --stack-name $stackName \
   --template-body file://templates/AWS-DockerSwarm-CloudFormation-202005.yaml \
   --parameters ParameterKey=BucketName,ParameterValue=$bucketName \
   ParameterKey=KeyPrefix,ParameterValue=$bucketKeySlash \
   ParameterKey=KeyPairName,ParameterValue=$keyPairName
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
