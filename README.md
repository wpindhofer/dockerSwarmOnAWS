# dockerSwarmOnAWS
Cloud Formation template to create a Docker Swarm on AWS EC2

The template creates...
- a VPC with 2 public Subnets
- an ALB to access the Swarm Nodes
- one EC2 instance running the Docker Swarm Leader node
- one AutoScalingGroup running 2 Docker Swarm Master nodes
- one AutoScalingGroup running 2 Docker Swarm Worker nodes
- other necessary parts like ACLs, Policies, SGs.

The template consists of 4 parts:
- createDockerSwarmStack.sh: Starter script to trigger the template creation
- createS3Bucket.sh: Create the necessary S3 bucket to store the necessary temporary data like swarm join tokens (triggered by starter script)
- AWS-DockerSwarm-CloudFormation-2020005.yaml: The CloudFormation template which creates the Docker Swarm cluster
- userdata-swarm-instances.sh: The script which is used to initialize the EC2 instances - is used in the UserData part of the instance creation within the CloudFormation template

## Usage and preconditions
In order to run the starter script successfully, the following configuration is necessary:
- Obviously, a linux shell is necessary to run the scripts
- AWS CLI 2.x is necessary including access to an account with the rights to create policies, buckets and stacks

If you clone the repository and run the script, the following parameters should work well:

'./createDockerSwarmStack.sh waltersdockerswarm swarm-join-tokens eu-central-1 myDockerSwarmStack SSH-docker-swarm scripts/userdata-swarm-instances.sh templates/AWS-DockerSwarm-CloudFormation-202005.yaml'

Also, a detailed description of the starter scripts parameters can be found in the script.

## Next...
The docker swarm is not production ready. Mostly because security hardening is missing. Also, it is not necessary to assign public IPs to each swarm node - this has been done to simplify the access to the machines. A better solution would be to use a NAT Gateway and a bastion host.

## Feedback - Yes, Please!
Please let me know what you think about the solution and if you find any weak spots or issues, feel free to contribute!
