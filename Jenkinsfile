pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "837402981643"
        REGION = "ap-south-1"
        REPO = "backend-repo"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/sohamrasal/fullstack-devops-project.git'
            }
        }

        stage('Build JAR') {
            steps {
                dir('backend') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('backend') {
                    sh '''
                    docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest .
                    '''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $REGION | \
                docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                kubectl apply -f k8s/backend-deployment.yaml
                '''
            }
        }
    }
}
