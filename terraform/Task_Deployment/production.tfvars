#Remote State Variable

remote_state_key    = "ecs-infra"
remote_state_bucket = "bank-service-terraform-remote-state"

#service variables
ecs_service_name      = "bankserviceapp"
docker_container_port = 8080
desired_task_number   = "2"
spring_profile        = "default"
memory                = 1024
#docker_image_url      = "test"







