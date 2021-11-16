pipeline {
    agent any
    tools {
        terraform 'Terraform v1.0.11'
        maven '3.8.3'
    }
    stages {
        stage ("checkout from GIT") {
            steps {
                git branch: 'main', credentialsId: 'Guthub_Cred', url: 'https://github.com/miteshupadhyay/terraform'
            }
        }

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
    }
}