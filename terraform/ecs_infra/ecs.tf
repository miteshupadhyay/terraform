#---------------------------------------------------------------
# Below entire configuration is to setup the ECS Infrastructure.
#---------------------------------------------------------------

provider "aws" {
  region = var.region
}
#-----------------------------------------------------------------------
# Below configuration is to read the values from remote Infrastructure
# State File from S3 Bucket
#-----------------------------------------------------------------------

data "terraform_remote_state" "vpc-infra" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
  }
}

#-------------------------------------------------------------
# Below configuration is responsible to create the ECS Cluster.
#-------------------------------------------------------------

resource "aws_ecs_cluster" "prod-fargate-bank-service-cluster" {
  name = "Production-Fargate-Bank-Service-Cluster"
}

#-------------------------------------------------------------
# Below configuration is responsible to create the ALB
# for ECS Cluster.
#-------------------------------------------------------------

resource "aws_alb" "ecs_cluster_alb" {
  name     = "${var.ecs_cluster_name}${"-ALB"}"
  internal = false // because we want this ALB to be available through internet , this isn't a private ALB
  security_groups = [aws_security_group.ecs_alb_security_group.id]
  subnets = split(",",join(",",data.terraform_remote_state.vpc-infra.outputs.public_subnets))

  tags = {
    Name = "${var.ecs_cluster_name}.${" ALB"}"
  }
}

#------------------------------------------------------------------------
# Create an Application Load Balancer Listener so that we can attach our
# target group to the Load Balancer and to the actual Listener.
#------------------------------------------------------------------------

resource "aws_alb_listener" "ecs_alb_https_listener" {
  load_balancer_arn = aws_alb.ecs_cluster_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.ecs_domain_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_target_group.arn
  }

  depends_on = [aws_alb_target_group.ecs_default_target_group]
}

#----------------------------------------------------------------
# In order to use ALB with SubDomain and different Target Groups,
# We need to create Default target group which ALB can forward to.
#-----------------------------------------------------------------

resource "aws_alb_target_group" "ecs_default_target_group" {
  name     = "${var.ecs_cluster_name}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc-infra.outputs.vpc_id

  tags = {
    Name = "${var.ecs_cluster_name}-TG"
  }
}
#----------------------------------------------------------------
# In order to run the ECS Service under ECS Cluster , it needs to
# have proper IAM Role.
#-----------------------------------------------------------------

resource "aws_iam_role" "ecs_cluster_role" {
  name = "${var.ecs_cluster_name}-IAM-Role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
 {
   "Effect": "Allow",
   "Principal": {
     "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
   },
   "Action": "sts:AssumeRole"
  }
  ]
 }
EOF
}

resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name = "${var.ecs_cluster_name}-IAM-Role"
  role = aws_iam_role.ecs_cluster_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "ecr:*",
        "dynamodb:*",
        "cloudwatch:*",
        "s3:*",
        "rds:*",
        "sqs:*",
        "sns:*",
        "logs:*",
        "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

#-------------------------------------------
# Adding Route53 Record for ALB Domain Name .
#-------------------------------------------

resource "aws_route53_record" "ecs_load_balancer_record" {
  name = "*.${var.ecs_domain_name}"
  type = "A"
  zone_id = data.aws_route53_zone.ecs_domain.zone_id

  alias {
    evaluate_target_health  = false
    name                    = aws_alb.ecs_cluster_alb.dns_name
    zone_id                 = aws_alb.ecs_cluster_alb.zone_id
  }
}











