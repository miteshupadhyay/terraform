#---------------------------------------------------------------
# Below entire configuration is to create all the VPC Resources.
#---------------------------------------------------------------

provider "aws" {
  region = var.region
}

#------------------------------------------------------
# Below configuration is responsible to create the VPC.
#------------------------------------------------------

resource "aws_vpc" "prod-bank-service-vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true              // In Order to provide our EC2 , a public Hostname

  tags = {
    Name = "Production-VPC"
  }
}

#----------------------------------------------------------------------------
# Below configuration is responsible to create the Public and Private Subnets.
#----------------------------------------------------------------------------


resource "aws_subnet" "public-subnet-1" {
  cidr_block        = var.public_Subnet_1_cidr
  vpc_id            = aws_vpc.prod-bank-service-vpc.id
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block        = var.public_Subnet_2_cidr
  vpc_id            = aws_vpc.prod-bank-service-vpc.id
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  cidr_block        = var.public_Subnet_3_cidr
  vpc_id            = aws_vpc.prod-bank-service-vpc.id
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Public Subnet 3"
  }
}


resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.private_Subnet_1_cidr
  vpc_id            = aws_vpc.prod-bank-service-vpc.id
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block        = var.private_Subnet_2_cidr
  vpc_id            = aws_vpc.prod-bank-service-vpc.id
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_subnet" "private-subnet-3" {
  cidr_block        = var.private_Subnet_3_cidr
  vpc_id            = aws_vpc.prod-bank-service-vpc.id
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Private Subnet 3"
  }
}

#----------------------------------------------------------------
# Below configuration is responsible to create Route Tables.
#----------------------------------------------------------------

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.prod-bank-service-vpc.id
  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.prod-bank-service-vpc.id
  tags = {
    Name = "Private-Route-Table"
  }
}

#--------------------------------------------------------------------------------------------------
# Below configuration is responsible to Associate Public Route Tables with respected Public Subnets.
#--------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.public-subnet-2.id
}

resource "aws_route_table_association" "public-subnet-3-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.public-subnet-3.id
}

#--------------------------------------------------------------------------------------------------
# Below configuration is responsible to Associate Private Route Tables with respected Private Subnets.
#--------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "private-subnet-1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "private-subnet-2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.private-subnet-2.id
}

resource "aws_route_table_association" "private-subnet-3-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.private-subnet-3.id
}

#--------------------------------------------------------------------------------------------------
# We want our private Subnet Resource to access internet , but do not want to allow traffic from
# the outside world. We would create a NAT Gateway for that , but before that we will be creating
# this Elastic IP.
#--------------------------------------------------------------------------------------------------

resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "Production EIP"
  }
}

#------------------------------------------------------------
# Below configuration is responsible to Create a NAT Gateway.
#------------------------------------------------------------

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "Production NAT Gateway"
  }
  depends_on = [aws_eip.elastic-ip-for-nat-gw]  // Creation of NAT GW is depends on the EIP Creation.
}


#-----------------------------------------------------------------
# We need to associate the NAT GW with the Private Route Table now.
# Below configuration is responsible to this association.
#-----------------------------------------------------------------

resource "aws_route" "nat-gw-route" {
  route_table_id          = aws_route_table.private-route-table.id
  nat_gateway_id          = aws_nat_gateway.nat-gw.id
  destination_cidr_block  = "0.0.0.0/0" // This will allow access internet traffic from our instances to the outside world but not vise versa.
}

#----------------------------------------------------------------------------
# We need to Create an Internet Gateway , so that outside traffic be entertain,
# and Public resources can be accessed publicly
#-----------------------------------------------------------------------------

resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.prod-bank-service-vpc.id
  tags = {
    Name = "Production Internet Gateway"
  }
}

#----------------------------------------------------------------------------
# Once IGW gets created , will need to map that to Public Route Table.
#-----------------------------------------------------------------------------

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.production-igw.id
  destination_cidr_block = "0.0.0.0/0"  // Allow our public resources to connect to internet properly
}