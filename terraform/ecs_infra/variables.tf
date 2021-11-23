#-----------------------------------------------------------------------
# Below entire configuration is to defined the variables at other places.
#-----------------------------------------------------------------------

variable "region" {
  default     = "ap-south-1"
  description = "AWS Region"
}
variable "ecs_cluster_name" {}
variable "remote_state_bucket" {}
variable "remote_state_key" {}
variable "internet_cidr_blocks" {}
variable "ecs_domain_name" {}

#Application Variables for Task
/*
variable "ecs_service_name" {}
variable "docker_image_url" {}
variable "memory" {}
variable "docker_container_port" {}
variable "spring_profile" {}
variable desired_task_number{}*/
