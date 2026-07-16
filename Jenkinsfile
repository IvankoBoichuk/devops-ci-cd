pipeline {
  agent {
    kubernetes {
      label 'kaniko-git-agent'
      defaultContainer 'git'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: git
      image: alpine/git:2.45.2
      command: ['cat']
      tty: true
    - name: aws
      image: amazon/aws-cli:latest
      command: ['cat']
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      command: ['/busybox/cat']
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
  volumes:
    - name: docker-config
      emptyDir: {}
'''
    }
  }

  options {
    disableConcurrentBuilds()
  }

  environment {
    AWS_REGION      = 'us-east-1'
    AWS_DEFAULT_REGION = 'us-east-1'
    APP_SOURCE_DIR  = 'devops-ci-cd-lesson-4'
    DOCKERFILE_PATH = 'devops-ci-cd-lesson-4/Dockerfile'
  }

  parameters {
    string(name: 'ECR_REPOSITORY', defaultValue: '', description: 'Full ECR repository URL, e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/app')
    string(name: 'DEPLOY_REPO_URL', defaultValue: '', description: 'HTTPS URL of the GitOps/deployment repository to update')
    string(name: 'DEPLOY_VALUES_FILE', defaultValue: 'charts/django-app/values.yaml', description: 'Path to values.yaml inside deployment repository')
    string(name: 'DEPLOY_BRANCH', defaultValue: 'final-project', description: 'Branch in the deployment repository to update')
  }

  stages {
    stage('Validate Parameters') {
      steps {
        script {
          if (!params.ECR_REPOSITORY?.trim()) {
            error('ECR_REPOSITORY parameter is required')
          }
          if (!params.DEPLOY_REPO_URL?.trim()) {
            error('DEPLOY_REPO_URL parameter is required')
          }
          env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
        }
      }
    }

    stage('Build And Push Image') {
      steps {
        container('kaniko') {
          sh '''
            set -eu
            /kaniko/executor \
              --context "${WORKSPACE}/${APP_SOURCE_DIR}" \
              --dockerfile "${WORKSPACE}/${DOCKERFILE_PATH}" \
              --destination "${ECR_REPOSITORY}:${IMAGE_TAG}" \
              --build-arg BUILDKIT_INLINE_CACHE=1
          '''
        }
      }
    }

    stage('Update Deployment Repository') {
      steps {
        container('git') {
          withCredentials([
            usernamePassword(
              credentialsId: 'gitops-repo-creds',
              usernameVariable: 'GIT_USERNAME',
              passwordVariable: 'GIT_TOKEN'
            )
          ]) {
            sh '''
              set -eu

              rm -rf deploy-repo
              git clone "https://${GIT_USERNAME}:${GIT_TOKEN}@${DEPLOY_REPO_URL#https://}" deploy-repo
              cd deploy-repo

              git checkout "${DEPLOY_BRANCH}"

              VALUES_FILE="${DEPLOY_VALUES_FILE}"
              if [ ! -f "${VALUES_FILE}" ]; then
                echo "values file not found: ${VALUES_FILE}"
                exit 1
              fi

              sed -i 's|^\\([[:space:]]*tag:[[:space:]]*\\).*|\\1"'"${IMAGE_TAG}"'"|' "${VALUES_FILE}"

              git config user.name "Jenkins CI"
              git config user.email "jenkins@example.local"

              if git diff --quiet -- "${VALUES_FILE}"; then
                echo "No changes in ${VALUES_FILE}"
                exit 0
              fi

              git add "${VALUES_FILE}"
              git commit -m "Update application image tag to ${IMAGE_TAG}"
              git push origin "${DEPLOY_BRANCH}"
            '''
          }
        }
      }
    }

  }

  post {
    success {
      echo "Pushed image: ${params.ECR_REPOSITORY}:${env.IMAGE_TAG}"
    }
    failure {
      echo "Pipeline failed. Check Jenkins logs and Kubernetes agent pods."
    }
    always {
      cleanWs()
    }
  }
}
