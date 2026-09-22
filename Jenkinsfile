pipeline {
    agent any

    options {
        // The Checkout stage below does the checkout
        skipDefaultCheckout(true)
    }

    environment {
        IMAGE_NAME = 'end-to-end-devops-project'
        IMAGE_TAG  = "${BUILD_NUMBER}"
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
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
