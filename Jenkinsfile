pipeline {
    agent {
        docker {
            image 'node:18' // Includes bash, npm, etc.
            args '-v /var/run/docker.sock:/var/run/docker.sock' // Allow docker commands
        }
    }

    environment {
        DOCKER_IMAGE = 'oopdaddy/docker-react'
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_EB_APP_NAME = 'docker-react'
        AWS_EB_ENV_NAME = 'Docker-react-env'
        AWS_S3_BUCKET = 'your-eb-s3-bucket-name'
        AWS_S3_KEY = "docker-react/${BUILD_NUMBER}.zip"
        HOME = '/home/node'
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.BRANCH_NAME}"
                echo "Change ID (PR): ${env.CHANGE_ID}"
                echo "Build URL: ${env.BUILD_URL}"
            }
        }

        stage('Check Environment') {
            steps {
                sh '''
                    echo "User:"
                    whoami
                    echo "Docker version:"
                    docker version
                    echo "Working dir: $(pwd)"
                    echo "Node version:"
                    node -v
                    echo "NPM version:"
                    npm -v
                '''
            }
        }

        stage('Build Dev Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE} -f Dockerfile.dev .'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'docker run -e CI=true ${DOCKER_IMAGE} npm run test'
            }
        }

        stage('Build Prod Image') {
            when {
                branch 'master'
            }
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}-prod -f Dockerfile .'
            }
        }

        stage('Package App') {
            when {
                branch 'master'
            }
            steps {
                sh '''
                    zip -r ${BUILD_NUMBER}.zip * .[^.]* -x Jenkinsfile
                    aws s3 cp ${BUILD_NUMBER}.zip s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}
                '''
            }
        }

        stage('Deploy to AWS EB') {
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
            echo "Build Result: ${currentBuild.currentResult}"
        }

        success {
            script {
                if (env.CHANGE_ID) {
                    echo "✅ PR #${env.CHANGE_ID} tests passed."
                } else if (env.BRANCH_NAME == 'master') {
                    echo "🚀 Successfully deployed to AWS EB!"
                }
            }
        }

        failure {
            script {
                if (env.CHANGE_ID) {
                    echo "❌ PR #${env.CHANGE_ID} tests failed."
                } else if (env.BRANCH_NAME == 'master') {
                    echo "❌ Deployment to AWS EB failed."
                }
            }
        }
    }
}
