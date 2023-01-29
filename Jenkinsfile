pipeline {
	agent any
	environment {
		image_name="798169696925.dkr.ecr.us-east-1.amazonaws.com/myapp"
        }
	stages{
		stage('Build'){
			step{
				sh '''
					docker build -t "$image_name:$GIT_COMMIT" .
				'''
			}
		}
		stage('Test'){
			step{
				sh '''
					docker run -dit -p 5000:5000 $image_name:$GIT_COMMIT
					sleep 5
					curl localhost:5000
					exit_status=$?
					if [[ $exit_status == 0 ]]
					then echo "SUCCESSFULL TESTS" && docker stop $(docker ps | grep $image_name:$GIT_COMMIT | awk '{print $1}')
					else echo "TEST FAILED" && docker stop $(docker ps | grep $image_name:$GIT_COMMIT | awk '{print $1}') && exit 1
					fi
				'''
			}

		}
		stage('Push'){
			step{
				sh '''
					aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 798169696925.dkr.ecr.us-east-1.amazonaws.com
					docker push $image_name:$GIT_COMMIT
				'''	
			}	
		}
		stage('Deploy_DEV'){
			when{
				expression{
					env.BRANCH_NAME == "development"
				}
			}
			step{
				sh '''
					kubectl create namespace dev
					kubectl create secret generic ecrsecret \
					  --from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json \
					  --type=kubernetes.io/dockerconfigjson \
					  --namespace=dev
					helm upgrade flask helm/ --atomic --wait --install --namespace=dev --set deployment.tag=$GIT_COMMIT --set deployment.env=dev
				'''
			}
		}
		stage('Deploy_UAT'){
			when{
				expression{
                    env.BRANCH_NAME == "uat"
				}
			}
			step{
				sh '''
					kubectl create namespace uat
					kubectl create secret generic ecrsecret \
						--from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json \
						--type=kubernetes.io/dockerconfigjson \
						--namespace=uat
					helm upgrade flask helm/ --atomic --wait --install --namespace=uat --set deployment.tag=$GIT_COMMIT --set deployment.env=uat       
				'''
			}

		}
        stage('Deploy_PROD'){
			when{
				expression{
						env.BRANCH_NAME == "main"
				}
			}
			step{
				sh '''
					kubectl create namespace prod
					kubectl create secret generic ecrsecret \
						--from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json \
						--type=kubernetes.io/dockerconfigjson \
						--namespace=prod
					helm upgrade flask helm/ --atomic --wait --install --namespace=prod --set deployment.tag=$GIT_COMMIT --set deployment.env=prod       
				'''
			}
		}
	}
}	
