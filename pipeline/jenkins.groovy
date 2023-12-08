pipeline {
    agent any
    parameters {
        string(name: 'os', defaultValue: 'linux', description: 'Enter target OS:')
    }
    environment{
        REPO='https://github.com/silhouetteUA/kbot.git'
        BRANCH='main'
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo "Cloning repository ..."
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
        stage('Build an application and create a docker image') {
            steps {
                script {
                    sh """
                        make ${os} image
                       """
                }
            }
        }
        stage('push artifact to registry') {
            steps {
                 script {
                    docker.withRegistry('', dockerhub) {
                        sh """
                        make push-${os}
                        """
                    }
                }
            }
        }
    }
}