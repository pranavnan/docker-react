// Jenkinsfile

pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        // Pull the PR branch’s code
        checkout scm
      }
    }

    stage('Build & Test') {
      steps {
        script {
          // Build the Docker image.
          // The Dockerfile itself runs `npm test` and will abort if tests fail.
          docker.build(
            /* image name */ "docker-react:${env.CHANGE_ID ?: env.BRANCH_NAME}-${env.BUILD_NUMBER}"
          )
        }
      }
    }
  }

  post {
    success {
      echo "✅ Build & tests passed for ${env.CHANGE_ID ? "PR #${env.CHANGE_ID}" : env.BRANCH_NAME}"
    }
    failure {
      echo "❌ Build or tests failed for ${env.CHANGE_ID ? "PR #${env.CHANGE_ID}" : env.BRANCH_NAME}"
    }
  }
}
