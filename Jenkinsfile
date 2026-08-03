// Declarative Jenkins Pipeline for Terraform
// Replace placeholders (OWNER/REPO, credentials ids) before running
pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  parameters {
    string(name: 'GIT_REPO', defaultValue: 'https://github.com/OWNER/REPO.git', description: 'Git repository containing Terraform code')
    string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Git branch to build')
    string(name: 'TF_WORKING_DIR', defaultValue: 'terraform/day18-weekendtasks--1-8-26/task1-task2', description: 'Path to Terraform configuration relative to repo root')
    string(name: 'TF_STATE_BUCKET', defaultValue: 'my-terraform-state-bucket', description: 'S3 bucket for Terraform state')
    string(name: 'TF_STATE_KEY', defaultValue: 'path/to/terraform.tfstate', description: 'S3 key for Terraform state')
    string(name: 'TF_STATE_REGION', defaultValue: 'us-east-1', description: 'AWS region for backend S3/DynamoDB')
    string(name: 'TF_STATE_DYNAMODB', defaultValue: 'terraform-state-locks', description: 'DynamoDB table for state locking')
  }

  environment {
    // Add Jenkins credentials IDs here and configure them in Jenkins
    AWS_CREDENTIALS_ID = 'aws-creds'         // Jenkins credential (AWS IAM user with S3/DynamoDB/EC2 perms)
    GIT_CREDENTIALS_ID = 'github-creds'     // (optional) GitHub credentials id if private repo
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: "*/${params.GIT_BRANCH}"]], userRemoteConfigs: [[url: params.GIT_REPO, credentialsId: env.GIT_CREDENTIALS_ID]]])
      }
    }

    stage('Terraform Init') {
      steps {
        dir(params.TF_WORKING_DIR) {
          withCredentials([usernamePassword(credentialsId: env.AWS_CREDENTIALS_ID, usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh '''
              export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
              export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
              terraform init -input=false -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="key=${TF_STATE_KEY}" -backend-config="region=${TF_STATE_REGION}" -backend-config="dynamodb_table=${TF_STATE_DYNAMODB}"
            '''
          }
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        dir(params.TF_WORKING_DIR) {
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir(params.TF_WORKING_DIR) {
          sh 'terraform plan -out=tfplan'
          archiveArtifacts artifacts: "${params.TF_WORKING_DIR}/tfplan", allowEmptyArchive: true
        }
      }
    }

    stage('Manager Approval') {
      steps {
        script {
          timeout(time: 1, unit: 'HOURS') {
            input message: 'Approve Terraform apply to provision infrastructure?', ok: 'Apply'
          }
        }
      }
    }

    stage('Apply') {
      steps {
        // Ensure only one apply runs at a time across jobs
        lock(resource: 'terraform-deploy') {
          dir(params.TF_WORKING_DIR) {
            withCredentials([usernamePassword(credentialsId: env.AWS_CREDENTIALS_ID, usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
              sh '''
                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                terraform apply -input=false -auto-approve tfplan
              '''
            }
          }
        }
      }
    }
  }

  post {
    success {
      echo 'Terraform apply completed successfully.'
    }
    failure {
      echo 'Terraform pipeline failed. Check logs.'
    }
  }
}
