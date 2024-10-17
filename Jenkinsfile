pipeline {
    agent {   
        label 'agent1' // Use the appropriate agent label
    }

    environment {
        DOCKER_IMAGE = 'shehab19/backend' // Replace with your Docker Hub username
    }

    stages {
        stage('Fetch Code') {
            steps {
                git url: 'https://github.com/shehab-19/laravel.git', branch: 'master'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Login to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        sh '''
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
                        '''
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }
    }

    post {
        always {
            // Clean up Docker images after build
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
        }

        success {
            echo 'Build and push completed successfully'
        }
        failure {
            echo 'Build failed'
        }
    }
}
