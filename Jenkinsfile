pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {

        stage('AWS') {
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
                        aws ecs register-task-definition \
                        CLUSTER_TD_REVISION=$(--cli-input-json file://aws/LearningJenkinsApp-task-prod.json | jq .taskDefinition.revision)
                        aws ecs update-service \
                            --cluster LearningJenkinsApp-prod \
                                --service LearningJenkinsApp-taskdefinition-prod-service-1j2h73 \
                                    --task-definition LearningJenkinsApp-taskdefinition-prod:CLUSTER_TD_REVISION
                        echo $CLUSTER_TD_REVISION
                    '''
                }
            }
        }

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



    }
}
