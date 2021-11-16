#-----------------------------------------------------------------------
# Below entire configuration is to defined the variables at other places.
#-----------------------------------------------------------------------

variable "region" {
  default     = "ap-south-1"
  description = "AWS Region"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
}

variable "public_Subnet_1_cidr" {
  description = "CIDR of Public Subnet One"
}
variable "public_Subnet_2_cidr" {
  description = "CIDR of Public Subnet Two"
}
variable "public_Subnet_3_cidr" {
  description = "CIDR of Public Subnet Three"
}
variable "private_Subnet_1_cidr" {
  description = "CIDR of Private Subnet One"
}
variable "private_Subnet_2_cidr" {
  description = "CIDR of Private Subnet Two"
}
variable "private_Subnet_3_cidr" {
  description = "CIDR of Private Subnet Three"
}