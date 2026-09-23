pipeline {
    agent any

    options {
        // The Checkout stage below does the checkout
        skipDefaultCheckout(true)
    }

    environment {
        IMAGE_NAME = 'end-to-end-devops-project'
        IMAGE_TAG  = "${BUILD_NUMBER}"
        // Docker Hub username and access token from Jenkins Credentials
        DOCKERHUB_CREDS = credentials('dockerhub-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv .venv
                    .venv/bin/pip install -r requirements.txt flake8 bandit pytest
                '''
            }
        }

        stage('Parallel Checks') {
            parallel {
                stage('Linting') {
                    steps {
                        sh '.venv/bin/flake8 app.py tests'
                    }
                }
                stage('Security Scan') {
                    steps {
                        sh '.venv/bin/bandit -r app.py'
                    }
                }
            }
        }

        stage('Unit Tests') {
            steps {
                sh '.venv/bin/python -m pytest -v'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDS_PSW" | docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin
                    docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_CREDS_USR/$IMAGE_NAME:$IMAGE_TAG
                    docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_CREDS_USR/$IMAGE_NAME:latest
                    docker push $DOCKERHUB_CREDS_USR/$IMAGE_NAME:$IMAGE_TAG
                    docker push $DOCKERHUB_CREDS_USR/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Update GitOps Repository') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    sh '''
                        git clone https://$GIT_USER:$GIT_TOKEN@github.com/sbaransi/end-to-end-devops-gitops.git gitops
                        cd gitops
                        sed -i "s/^tag: .*/tag: '$IMAGE_TAG'/" end-to-end-devops-project/dev/values.yaml
                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@localhost"
                        git add end-to-end-devops-project/dev/values.yaml
                        git commit -m "Update dev image tag to $IMAGE_TAG"
                        git push origin main
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
        always {
            sh 'docker logout || true'
            // Remove only the local images this build created; the pushed copies stay on Docker Hub
            sh 'docker rmi $IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_CREDS_USR/$IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_CREDS_USR/$IMAGE_NAME:latest || true'
        }
    }
}
