pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'oopdaddy/docker-react'
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_EB_APP_NAME = 'docker-react'
        AWS_EB_ENV_NAME = 'Docker-react-env'
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/pranavnan/docker-react.git',
                        credentialsId: 'github-creds'
                    ]]
                ])
                echo "Branch: ${env.BRANCH_NAME}"
                echo "Change ID: ${env.CHANGE_ID}"
                echo "Build URL: ${env.BUILD_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}", "-f Dockerfile.dev .")
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh "docker run -e CI=true ${DOCKER_IMAGE} npm run test"
                }
            }
        }

        stage('Build Production Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}-prod", "-f Dockerfile .")
                }
            }
        }

        stage('Deploy to AWS') {
            when {
                branch 'master'
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                        aws elasticbeanstalk create-application-version \
                            --application-name ${AWS_EB_APP_NAME} \
                            --version-label ${BUILD_NUMBER} \
                            --source-bundle S3Bucket="${AWS_S3_BUCKET}",S3Key="${AWS_S3_KEY}"

                        aws elasticbeanstalk update-environment \
                            --application-name ${AWS_EB_APP_NAME} \
                            --environment-name ${AWS_EB_ENV_NAME} \
                            --version-label ${BUILD_NUMBER}
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            echo "Build Status: ${currentBuild.currentResult}"
            echo "Webhook Payload: ${env.GITHUB_PAYLOAD}"
        }
        success {
            script {
                if (env.CHANGE_ID) {
                    echo "PR #${env.CHANGE_ID} tests passed successfully"
                } else if (env.BRANCH_NAME == 'master') {
                    echo "Successfully deployed to AWS"
                }
            }
        }
        failure {
            script {
                if (env.CHANGE_ID) {
                    echo "PR #${env.CHANGE_ID} tests failed"
                } else if (env.BRANCH_NAME == 'master') {
                    echo "Deployment to AWS failed"
                }
            }
        }
    }
} 