pipeline {
  agent { docker { image 'docker:20.10.21' args '-v /var/run/docker.sock:/var/run/docker.sock' } }
  stages {
    stage('Build & Test') {
      steps {
        // Here 'docker' is available, since we're inside a 'docker' agent
        docker.build("docker-react:${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
      }
    }
  }
}
