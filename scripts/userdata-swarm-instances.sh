#!/bin/bash -xe
#cfn signaling functions
#Parameter 1: InitMode: initData initialises UserData, initDocker initialises Docker
#Parameter 2: AWS StackName
#Parameter 3: AWS region
#Parameter 4: Current Instance Logical ID
#Parameter 5: Signal target within CloudFormation in order to signal successful run of the scripts
echo "[INFO] Start UserData with Parameters $1, $2, $3, $4, $5";

#set calling parameters to local parameters
mode=$1
awsStackName=$2
awsRegion=$3
awsInstanceLogicalId=$4
awsSignalTarget=$5

if [ $mode == "initData" ]
then
  function cfn_fail
  {
    cfn-signal -e 1 --stack $awsStackName --region $awsRegion --resource $awsSignalTarget
    exit 1
  }
  function cfn_success
  {
    cfn-signal -e 0 --stack $awsStackName --region $awsRegion --resource $awsSignalTarget
    exit 0
  }
  yum update -y
  yum install git -y
  until git clone https://github.com/aws-quickstart/quickstart-linux-utilities.git ; do echo "Retrying"; done
  cd /quickstart-linux-utilities;
  source quickstart-cfn-tools.source;
  qs_update-os || qs_err;
  qs_bootstrap_pip || qs_err " pip bootstrap failed ";
  qs_aws-cfn-bootstrap || qs_err " cfn bootstrap failed ";
  echo "[INFO] Executing config-sets";
  cfn-init -v --stack $awsStackName --region $awsRegion --resource $awsInstanceLogicalId --configsets ec2_bootstrap || cfn_fail;
  [ $(qs_status) == 0 ] && cfn_success || cfn_fail
fi

if [ $mode == "initDocker" ]
then
  yum update -y
  amazon-linux-extras install -y docker
  service docker start
  usermod -a -G docker ec2-user
  chmod 777 /var/run/docker.sock
  chkconfig docker on
fi
