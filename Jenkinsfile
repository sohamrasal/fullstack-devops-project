pipeline {
    agent { label 'agent-ec2' }

    tools {
        maven 'Maven'
    }

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = '837402981643.dkr.ecr.ap-south-1.amazonaws.com/backend-repo'
        IMAGE_TAG = "${BUILD_NUMBER}"
        NEXUS_URL = 'http://http://k8s-nexus-nexusing-b92cb36a87-467731962.ap-south-1.elb.amazonaws.com/'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sohamrasal/fullstack-devops-project.git'
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh 'mvn clean install -DskipTests'
                }
            }
        }

        stage('Sonar Scan') {
            steps {
                dir('backend') {
                    withSonarQubeEnv('sonar-server') {
                        sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=fullstack-devops-project \
                        -Dsonar.projectName=fullstack-devops-project
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                dir('backend') {
                    withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh '''
                        JAR=$(ls target/*.jar | head -n 1)

                        echo "Uploading $JAR to Nexus..."

                        curl -v -u $USER:$PASS \
                          --upload-file $JAR \
                          $NEXUS_URL/repository/maven-releases/backend/${BUILD_NUMBER}/backend-${BUILD_NUMBER}.jar
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $ECR_REPO:$IMAGE_TAG ./backend
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REPO
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker push $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                echo "Deploying to Kubernetes..."

                kubectl apply -f k8s/backend-deployment.yaml
                kubectl apply -f k8s/backend-service.yaml
                kubectl apply -f k8s/backend-ingress.yaml

                kubectl rollout status deployment backend
                '''
            }
        }
    }
}
