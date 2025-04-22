pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'oopdaddy/docker-react'
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_EB_APP_NAME = 'docker-react'
        AWS_EB_ENV_NAME = 'Docker-react-env'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
        }
        success {
            script {
                if (env.CHANGE_ID) {
                    // This is a PR
                    echo "PR #${env.CHANGE_ID} tests passed successfully"
                } else if (env.BRANCH_NAME == 'master') {
                    // This is a master branch build
                    echo "Successfully deployed to AWS"
                }
            }
        }
        failure {
            script {
                if (env.CHANGE_ID) {
                    // This is a PR
                    echo "PR #${env.CHANGE_ID} tests failed"
                } else if (env.BRANCH_NAME == 'master') {
                    // This is a master branch build
                    echo "Deployment to AWS failed"
                }
            }
        }
    }
} 