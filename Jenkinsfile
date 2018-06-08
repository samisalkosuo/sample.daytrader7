pipeline {
  agent any
  stages {
    stage('begin deployment - dev') {
      when {
        branch 'develop'
      }
      steps {
        slackSend(message: 'Development build began...', channel: '#deployments', failOnError: true)
      }
    }
    stage('begin deployment - prod') {
      when {
        branch 'master'
      }
      steps {
        slackSend(message: 'Production build began...', channel: '#deployments', failOnError: true)
      }
    }
    stage('Package code for development deployment') {
      when {
        branch 'develop'
      }
      steps {
        sh 'bash jenkins/dev.sh'
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
    stage('end deployment - dev') {
      when {
        branch 'develop'
      }
      environment { 
        APP_DOWNLOAD_URL= sh (returnStdout: true, script: 'cat DOWNLOAD_URL_${BUILD_ID}.txt').trim()
      }
      steps {
        slackSend(message: 'Development build ended. App download: ${APP_DOWNLOAD_URL}', channel: '#deployments', failOnError: true)
      }
    }
    stage('end deployment - prod') {
      when {
        branch 'master'
      }
      steps {
        slackSend(message: 'Production build ended.', channel: '#deployments', failOnError: true)
      }
    }  
  }
  environment {
    APP_NAME = 'daytrader7'
    FILE_SERVER_PATH = '/http_files/'
    HTTP_FILE_SERVER = 'http://159.122.99.115:8088'
  }
}