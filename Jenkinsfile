pipeline {
    agent any

    stages {
        stage('Agent Inspection') {
            steps {
                sh '''
                    echo "===== WHOAMI ====="
                    whoami || true

                    echo "===== PATH ====="
                    echo $PATH

                    echo "===== PYTHON ====="
                    which python || true
                    which python3 || true

                    echo "===== PIP ====="
                    which pip || true
                    which pip3 || true

                    echo "===== DOCKER ====="
                    which docker || true

                    echo "===== OS ====="
                    uname -a || true
                '''
            }
        }
    }
}
