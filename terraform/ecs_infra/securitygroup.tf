#----------------------------------------------------------------
# Below configuration is responsible to create the Security Group.
#----------------------------------------------------------------

resource "aws_security_group" "ecs_alb_security_group" {
  name         = "${var.ecs_cluster_name}.${"-ALB-SG"}"
  description  = "This Security Group is for the ALB to Traffic for the ECS Cluster"
  vpc_id       =  data.terraform_remote_state.infrastructure.outputs.vpc_id

  # Inbound Rule for Load Balancer
  ingress {
    from_port    = 443
    protocol     = "TCP"
    to_port      = 443
    cidr_blocks  = [var.internet_cidr_blocks]
  }

  # Outbound Rule for Load Balancer
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.internet_cidr_blocks]
  }

}
