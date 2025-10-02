pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = '3ea33bc0-6a9f-4d9d-9a15-458e1621094a'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        CI_ENVIRONMENT_URL = 'https://shimmering-jalebi-092fe6.netlify.app/'
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }
    
    stages {
        stage('Docker') {
            steps{

                sh 'docker build -t my-playwright .'

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
                    echo 'small change'
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        } 
        // parallel stage 
        stage('Tests'){
            parallel{
                stage('Test unit') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                            always {
                                 junit 'jest-results/junit.xml'
                             }
                     }
                }
                stage('E2E') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            serve -s build &
                            sleep 10
                            npx playwright test --reporter=line
                        '''
                    }
                    post {
                            always {
                                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                             }
                     }
                }
            }
        }


        stage('Deploy Staging') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
             }
            environment {
                CI_ENVIRONMENT_URL = 'STAGIN_URL'
             }

            steps {
                sh '''
                    netlify --version
                    echo "Deploying to Staging Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --json > deploy.json
                    CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy.json)
                    npx playwright test --reporter=line
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'E2E-STAGING', reportTitles: '', useWrapperFileDirectly: true])
                    }
            }
        }
/*        stage('Aprroval') {
                steps {
                        timeout(time: 5, unit: 'MINUTES') {
                            input message: 'Proceed with Production Deployment?', ok: 'Yes, Deploy', submitter: 'admin'

                        }
                     }
         } */
        stage('Deploy Prod') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
             }
            environment {
                CI_ENVIRONMENT_URL = 'https://shimmering-jalebi-092fe6.netlify.app'
             }

            steps {
                sh '''
                    node --version
                    netlify --version
                    echo "Deploying to Production Site ID: $NETLIFY-SITE-ID"
                    netlify status
                    netlify deploy --dir=build --prod
                    npx playwright test --reporter=line
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'E2E-PROD', reportTitles: '', useWrapperFileDirectly: true])
                    }
            }
    }

    }

}