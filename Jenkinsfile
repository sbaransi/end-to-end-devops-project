pipeline {
    agent any

    environment {
        APP_NAME = 'end-to-end-devops-project'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Source already checked out from GitHub'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 --version
                    pip3 install -r requirements.txt
                '''
            }
        }

        stage('Validate Application') {
            steps {
                sh '''
                    python3 -m py_compile app.py
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${APP_NAME}:latest .
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }
    }
}
