pipeline {
  agent any

  stages {
    // checks last commit message and if it contains string 'nobuild', no build is done
    stage('to build or not') {
      when {
        anyOf { branch 'master'; branch 'develop' }
      }
      environment { 
        COMMIT_MSG = sh (returnStdout: true, script: 'git log --oneline -1 ${GIT_COMMIT}').trim()        
      }
      steps {
        sh 'echo "Commit message:  ${COMMIT_MSG}"'
        sh 'echo ${COMMIT_MSG} > commit_msg.txt'
        script {          
          def commitMsg = readFile 'commit_msg.txt'
          if (commitMsg.indexOf("nobuild")>-1 ) {
            currentBuild.result = 'ABORTED'
            slackSend(message: "ABORTED automatically because of commit message: ${env.JOB_NAME} ${env.BUILD_NUMBER}.", channel: '#deployments',color: '#FF0000')
            error('Aborting because of commit message.')
            }
        }
      }
    }

    stage('begin deployment - dev') {
      when {
        branch 'develop'
      }
      steps {
        slackSend(message: "DEV build started: ${env.JOB_NAME} ${env.BUILD_NUMBER}...", channel: '#deployments', failOnError: true,color: '#0000FF')
      }
    }
    stage('begin deployment - prod') {
      when {
        branch 'master'
      }
      steps {
        slackSend(message: "PROD build started: ${env.JOB_NAME} ${env.BUILD_NUMBER}...", channel: '#deployments', failOnError: true,color: '#0000FF')
      }
    }

    stage('Build Docker image') {
      when {
        anyOf { branch 'master'; branch 'develop' }
      }
      steps {
        slackSend(message: "Building Docker image...", channel: '#deployments', failOnError: true,color: '#0000FF')
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
        slackSend(message: "Saving ${env.APP_NAME} Docker image...", channel: '#deployments', failOnError: true,color: '#0000FF')
        sh 'bash jenkins/dev_aws/deploy_step_1.sh'
        slackSend(message: "Uploading ${env.APP_NAME} Docker image to IBM Cloud Object Storage...", channel: '#deployments', failOnError: true,color: '#0000FF')
        sh 'bash jenkins/dev_aws/deploy_step_2.sh'
        slackSend(message: "Deploying ${env.APP_NAME} to AWS using CAM...", channel: '#deployments', failOnError: true,color: '#0000FF')
        sh 'bash jenkins/dev_aws/deploy_step_3.sh'
      }
    }

    stage('Production deployment to ICP') {
      when {
        branch 'master'
      }
      steps {
        slackSend(message: "Pushing ${env.APP_NAME} Docker image to ICP...", channel: '#deployments', failOnError: true,color: '#0000FF')
        sh '''__ver=$(cat VERSION)
__docker_image_name=${APP_NAME}:${__ver}
bash jenkins/prod_icp/deploy_step_1.sh ${__docker_image_name}
'''
        slackSend(message: "Deploying Helm chart ${env.APP_NAME}...", channel: '#deployments', failOnError: true,color: '#0000FF')
        sh '''__ver=$(cat VERSION)
__docker_image_name=${APP_NAME}:${__ver}
bash jenkins/prod_icp/deploy_step_helm.sh ${__docker_image_name}
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
        slackSend(message: "Development build ended: ${env.JOB_NAME} ${env.BUILD_NUMBER}\nApp running in AWS.\n\nApplication URL: https://${IP_ADDRESS}/", channel: '#deployments', failOnError: true,color: '#0000FF')
      }
    }

    stage('end deployment - prod') {
      when {
        branch 'master'
      }
      environment { 
        ICP_APP_URL = sh (returnStdout: true, script: 'cat ICP_APP_URL').trim()
      }
      steps {
        slackSend(message: "Production build ended: ${env.JOB_NAME} ${env.BUILD_NUMBER}\nApp running in ICP.\n\nApplication URL: ${ICP_APP_URL}", channel: '#deployments', failOnError: true,color: '#0000FF')
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
  }

}