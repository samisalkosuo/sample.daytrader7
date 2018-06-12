pipeline {
  agent any
  stages {
    stage('begin deployment - dev') {
      when {
        branch 'develop'
      }
      steps {
        slackSend(message: "Deployment build started: ${env.JOB_NAME} ${env.BUILD_NUMBER}...", channel: '#deployments', failOnError: true,color: '#0000FF')
      }
    }
    stage('begin deployment - prod') {
      when {
        branch 'master'
      }
      steps {
        slackSend(message: "Production build started: ${env.JOB_NAME} ${env.BUILD_NUMBER}...", channel: '#deployments', failOnError: true,color: '#0000FF')
      }
    }
    stage('Build Docker image') {
      steps {
        sh '''__ver=$(cat VERSION)
__docker_image_name=${APP_NAME}:${__ver}
docker build -t ${__docker_image_name} .
docker tag ${__docker_image_name} ${APP_NAME}:latest'''
      }
    }
    stage('Development deployment to AWS') {
      when {
        branch 'develop'
      }
      steps {
        sh 'bash jenkins/deploy_dev_aws.sh'
      }
    }
    stage('Production deployment to ICP') {
      when {
        branch 'master'
      }
      steps {
        sh ''''__ver=$(cat VERSION)
__docker_image_name=${APP_NAME}:${__ver}
bash jenkins/deploy_prod_icp.sh ${__docker_image_name}
'''
      }
    }
    stage('end deployment - dev') {
      when {
        branch 'develop'
      }
      environment { 
        IP_ADDRESS = sh (returnStdout: true, script: 'cat IP_ADDRESS').trim()
      }
      steps {
        sh 'echo "APP URL: https://${IP_ADDRESS}/"'
        slackSend(message: "Development build ended : ${env.JOB_NAME} ${env.BUILD_NUMBER}\n\nApplication URL: http://${env.IP_ADDRESS}/daytrader", channel: '#deployments', failOnError: true,color: '#0000FF')
      }
    }
    stage('end deployment - prod') {
      when {
        branch 'master'
      }
      steps {
        slackSend(message: 'Production build ended.', channel: '#deployments', failOnError: true,color: '#0000FF')
      }
    }  
  }
  post { 
        failure { 
            slackSend(message: "FAILURE: ${env.JOB_NAME} ${env.BUILD_NUMBER}.", channel: '#deployments',color: '#FF0000')
        }
        success { 
            slackSend(message: "SUCCESS: ${env.JOB_NAME} ${env.BUILD_NUMBER}.", channel: '#deployments',color: '#00FF00')

        }
    }
  environment {
    APP_NAME = 'daytrader7'
    FILE_SERVER_PATH = '/http_files/'
    HTTP_FILE_SERVER = 'http://159.122.99.115:8088'
  }
}