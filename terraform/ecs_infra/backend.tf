#--------------------------------------------------------------------------------
# This Backend file is responsible to keep the state file into remote respository.
#--------------------------------------------------------------------------------
terraform {
  backend "s3" {
    # Bucket where Terraform State File will get stored.
    bucket = "bank-service-terraform-remote-state"

    # This Ensures that the State file is Stored Encrypted at Rest in S3.
    encrypt = true

    # This will be used as a folder in which you store the state file.
    workspace_key_prefix = "bankserviceapi"

    # Region of the S3 Bucket
    region = "ap-south-1"

    # This key would be state file's File Name
    key = "ecs-infra"
  }
}