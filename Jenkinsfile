def GIT_COMMIT_WITH_V
def dockerImage=""


pipeline {
    agent any
    environment{
        AWS_ACCOUNT_ID="819754052673"
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="bank-service-api"
        IMAGE_TAG="v1"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
    tools {
        terraform 'Terraform v1.0.11'
        maven '3.8.3'
        dockerTool 'docker'
    }
    stages {
        // Checkout Code from Git Repository
        stage ("checkout from GIT") {
            steps {
                git branch: 'main', credentialsId: 'Guthub_Cred', url: 'https://github.com/miteshupadhyay/terraform'
            }
        }

        // Build and Compile Code
        stage ("Compile & Build") {
            steps {
                sh "mvn clean package"
            }
        }

        // Building Docker image
        stage('Building Docker image') {
           steps{
              script {
                   dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
              }
            }

        // Once Image gets Build Login to ECR Repository
        stage('Logging into AWS ECR') {
            steps {
                script {
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }

            }
        }

        // Uploading Docker image into AWS ECR
        stage('Pushing Docker Image to ECR') {
         steps{
             script {
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
             }
            }
          }

        // Terraform Initilization
        stage ("terraform Init") {
            steps {
                  dir('terraform/vpc_infra') {
                      sh 'terraform init'
                 }

            }
        }

        // Terraform Plan - VPC
         stage ("terraform Plan - VPC") {
                    steps {
                          dir('terraform/vpc_infra')
                          {
                                sh 'terraform plan -var-file="production.tfvars"'
                          }
                    }
                }

         // Terraform Apply - VPC
         stage ("terraform Apply - VPC") {
                    steps {
                          dir('terraform/vpc_infra')
                          {
                            sh 'terraform apply -auto-approve -var-file="production.tfvars"'
                          }
                    }
                }
/*
       stage ("Compile & Build") {
            steps {
                sh "mvn clean package"
            }
        }

        stage ("Push Docker Image to ECR") {
            steps {
                 sh 'terraform --version'
            }
        }
        stage ("terraform Init") {
            steps {
                 sh "pwd"
                  dir('terraform/vpc_infra') {
                      sh "pwd"
                      sh 'terraform init'
                 }

            }
        }
        stage ("terraform Plan") {
            steps {
                  dir('terraform/vpc_infra')
                  {
                        sh 'terraform plan -var-file="production.tfvars"'
                  }
            }
        }
        stage ("terraform Apply") {
            steps {
                  dir('terraform/vpc_infra')
                  {
                    sh 'terraform apply -auto-approve -var-file="production.tfvars"'
                  }
            }
        }
        stage ("Maven version") {
            steps {
                 sh 'mvn --version'
            }
        }
        */
    }
}