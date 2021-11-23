ecs_cluster_name = "Production-ECS-Cluster"
internet_cidr_blocks = "0.0.0.0/0"

remote_state_key = "bank-service-dev"
remote_state_bucket = "bank-service-terraform-remote-state"

# Service Variable
/*
ecs_service_name = "bank-service-app"
docker_container_port = 8080
desired_task_number = 2
spring_profile = "default"
memory = 1024*/
ecs_domain_name = "cloudtechlearn.com"
