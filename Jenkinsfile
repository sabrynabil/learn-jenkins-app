pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ECS_CLUSTER = 'LearningJenkinsApp-prod'
        AWS_ECS_SERVICE = 'LearningJenkinsApp-taskdefinition-prod-service-1j2h73'
        AWS_ECS_TASK_DEFINITION = 'LearningJenkinsApp-taskdefinition-prod'  
    }

    stages {



        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
        stage('Build Docker image') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }

            steps {
                sh '''
                    amazon-linux-extras install docker
                    docker build -t myjenkinsapp .
                '''
            }
        }        
        stage('DEploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "-u root --entrypoint=''"
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        yum install -y jq
                        CLUSTER_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/LearningJenkinsApp-task-prod.json | jq '.taskDefinition.revision')
                        aws ecs update-service \
                            --cluster $AWS_ECS_CLUSTER \
                                --service $AWS_ECS_SERVICE \
                                    --task-definition $AWS_ECS_TASK_DEFINITION:$CLUSTER_TD_REVISION
                        aws ecs wait services-stable \
                            --cluster $AWS_ECS_CLUSTER \
                                --services $AWS_ECS_SERVICE
                    '''
                }
            }
        }



    }
}
