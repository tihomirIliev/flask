pipeline {
	agent any
	environment {
		image_name="798169696925.dkr.ecr.us-east-1.amazonaws.com/myapp"
        }
	stages{
		stage('Build'){
			steps{
				sh '''
					docker build -t "$image_name:$GIT_COMMIT" .
				'''
			}
		}
		stage('Test'){
			steps{
				sh '''
					sudo lsof -i :5000 && sleep 7 && docker run -dit -p 5000:5000 $image_name:$GIT_COMMIT || docker run -dit -p 5000:5000 $image_name:$GIT_COMMIT
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
			steps{
				sh '''
					aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 798169696925.dkr.ecr.us-east-1.amazonaws.com
					docker push $image_name:$GIT_COMMIT
					
					kubectl get secrets ecrsecret || kubectl create secret generic ecrsecret \
					  --from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json \
					  --type=kubernetes.io/dockerconfigjson
				'''	
			}	
		}
		stage('Deploy_DEV'){
			when{
				expression{
					env.BRANCH_NAME == "developments"
				}
			}
			steps{
				sh '''
					kubectl create namespace dev
					kubectl get secret ecrsecret --namespace=default -oyaml > ecrsecret.yaml | kubectl apply --namespace=dev -f ecrsecret.yaml
					helm upgrade flask helm/ --atomic --wait --install --namespace=dev --set deployment.tag=$GIT_COMMIT --set deployment.env=dev
				'''
			}
		}
		stage('Deploy_UAT'){
			when{
				expression{
        		               env.BRANCH_NAME == "staging"
				}
			}
			steps{
				sh '''
					kubectl create namespace uat
					kubectl get secret ecrsecret --namespace=default -oyaml yaml | kubectl apply --namespace=uat -f -
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
			steps{
				sh '''
					kubectl create namespace prod
					kubectl get secret ecrsecret --namespace=default -oyaml yaml | kubectl apply --namespace=prod -f -
					helm upgrade flask helm/ --atomic --wait --install --namespace=prod --set deployment.tag=$GIT_COMMIT --set deployment.env=prod       
				'''
			}
		}
	}
}	
