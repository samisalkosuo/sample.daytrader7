pipeline {
  agent any
  stages {
    stage('Package code for development deployment') {
      when {
        branch 'develop'
      }
      steps {
        sh 'bash jenkins/dev.sh'
        sh 'cat script.log'      
      }
    }
    stage('Build Docker image') {
      when {
        branch 'master'
      }
      steps {
        sh '''__ver=$(cat VERSION)
__docker_image_name=${APP_NAME}:${__ver}
docker build -t ${__docker_image_name} .'''
      }
    }
  }
  environment {
    APP_NAME = 'daytrader7'
    FILE_SERVER_PATH = '/http_files/'
  }
}