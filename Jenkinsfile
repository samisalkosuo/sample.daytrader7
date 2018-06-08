pipeline {
  agent any
  stages {
    stage('Package code for development deployment') {
      when {
        branch 'develop'
      }
      steps {
        sh '''__ver=$(cat VERSION)
tar -cf ${DOCKER_IMAGE_NAME}-${__ver}.tar docker-build-cache/ lib/ pom.xml Dockerfile daytrader-ee7-ejb/  	daytrader-ee7-web/  	daytrader-ee7-wlpcfg/ daytrader-ee7/
ls -latr'''
        sh 'tar -tf daytrader*tar'
      }
    }
    stage('Build Docker image') {
      when {
        branch 'master'
      }
      steps {
        sh '''__ver=$(cat VERSION)
docker build -t ${DOCKER_IMAGE_NAME}:${__ver} .'''
      }
    }
  }
  environment {
    DOCKER_IMAGE_NAME = 'daytrader7'
  }
}