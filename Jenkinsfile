pipeline {
    agent any
    environment {
        NETLIFY_SITE_ID = '3ea33bc0-6a9f-4d9d-9a15-458e1621094a'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        CI_ENVIRONMENT_URL = 'https://shimmering-jalebi-092fe6.netlify.app/'
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
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
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
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli@20.1.1 node-jq
                    node_modules/.bin/netlify --version
                    echo "Deploying to Staging Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --json > deploy.json
                '''
                script {
                    env.STAGING_URL = sh(
                        script: "node_modules/.bin/node-jq -r '.deploy_url' deploy.json",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Staging E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
             }
            environment {
                CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
             }

            steps {
                sh '''
                    npx playwright test --reporter=line
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'E2E-STAGING', reportTitles: '', useWrapperFileDirectly: true])
                    }
            }
        }
        stage('Aprroval') {
                steps {
                        timeout(time: 5, unit: 'MINUTES') {
                            input message: 'Proceed with Production Deployment?', ok: 'Yes, Deploy', submitter: 'admin'

                        }
                     }
                    } 
        stage('Deploy Prod') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to Production Site ID: $NETLIFY-SITE-ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        } 
        stage('prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
             }
            environment {
                CI_ENVIRONMENT_URL = 'https://shimmering-jalebi-092fe6.netlify.app'
             }

            steps {
                sh '''
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