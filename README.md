### This is Multibranch Pipeline setup for deploying a simple flask application to Kind Kubernetes
### The deployment uses Service from type NodePort
### Three types of branches have to be created - developments, staging, main (production)

### Usage
  - Create IAM user and login to AWS with "aws configure" 
  - Create Jenkins with Terraform (new AWS EC2 instance). The setup is in folder "infrastructure".  
  - Navigate to "infrastructure" folder, then run "terraform init" -> "terraform apply"
  - Setup git (after completing Jenkins instalation) - "ssh-keygen" keys, add the private key to EC2 instance (ssh-add id_rsa), the public key add in git

### Configuring Jenkins

 - Select new item -> Multibranch Pipeline -> OK

![selecting_MBP](https://user-images.githubusercontent.com/44411127/215773175-bf94c4d3-f0c4-436c-a76a-4d9cd6f22b6d.PNG)

 - Connect Jenkins to Git:
 	- Navigate to "Credentials" tab -> Create github credentials from type 'ssh username and private key'. 
	- Type your git hub username and add the private key generated in the Jenkins server (EC2 instance)

 - Set up of the pipeline:
 	- Configuration -> Branch Sources -> add ssh link of your repository, select your git credentials

![branch_source](https://user-images.githubusercontent.com/44411127/215773250-34684296-b772-461e-9146-72ff6b6c071d.PNG)

 - Scan Multibranch Pipeline 
	Jenkins will search for Jenkinsfile in the branches across the repository. Upon finding it, the pipeline will be triggered for that branch 

![start_pipeline](https://user-images.githubusercontent.com/44411127/215773339-6515c136-3988-4189-93fc-ac98dac3c1fd.PNG)
 
After the deployments are completed, the flask app can be accessed locally on the EC2 instance. In the CLI type "curl 'NODE IP':'NODEPORT'".
  - / - show "Hello World"
  - /pragmatic - show the environment
  - /picture - show the html 

### Technologies used
  - AWS (EC2, ECR, IAM)	
  - Terraform
  - Docker 
  - Kind/Kubernetes
  - Helm
  - Git
  - Jenkins

### License
  - Tihomir Iliev
  - email: tisho.xmg@gmail.com
  - linkedin: linkedin.com/in/tihomir-iliev-50333016a
  

