pipeline {
  agent any
  stages {
    stage('Package code for development deployment') {
      when {
        branch 'develop'
      }
      steps {
        sh '__ver=$(cat VERSION);__tar_name=${APP_NAME}-${__ver}.tar'
        sh 'tar -cf ${__tar_name} docker-build-cache/ lib/ pom.xml Dockerfile daytrader-ee7-ejb/ daytrader-ee7-web/ daytrader-ee7-wlpcfg/ daytrader-ee7/'
        sh 'gzip ${__tar_name}'
        sh 'mv ${__tar_name}* ${FILE_SERVER_PATH}/'
      }
    }
    stage('Build Docker image') {
      when {
        branch 'master'
      }
      steps {
        sh '__ver=$(cat VERSION);__docker_image_name=${APP_NAME}:${__ver}'
        sh 'docker build -t ${__docker_image_name} .'
      }
    }
  }
  environment {
    APP_NAME = 'daytrader7'
    FILE_SERVER_PATH = '/root/http_files'
  }
}