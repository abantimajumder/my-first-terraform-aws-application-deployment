#######################
#VPC creation
#######################
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_range
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
    Environment = var.Environment
  }
}
#######################
# puclic subnet creation 
#######################

resource "aws_subnet" "web_public" {
  count = length(var.web_public_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.web_public_subnets[count.index]
  availability_zone = var.availability_zone_subnet[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-web-public-${count.index + 1 }"
    Environment = var.Environment
  }
}
#######################
# private subnet creation 
#######################

resource "aws_subnet" "web_private" {
  count = length(var.web_private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.web_private_subnets[count.index]
  availability_zone = var.availability_zone_subnet[count.index]
  tags = {
    Name = "${var.project_name}-web-private-${count.index + 1 }"
    Environment = var.Environment
  }
}

resource "aws_subnet" "app_private" {
  count = length(var.app_private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.app_private_subnets[count.index]
  availability_zone = var.availability_zone_subnet[count.index]
  tags = {
    Name = "${var.project_name}-app-private-${count.index + 1 }"
    Environment = var.Environment
  }
}

resource "aws_subnet" "db_private" {
  count = length(var.db_private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.db_private_subnets[count.index]
  availability_zone = var.availability_zone_subnet[count.index]
  tags = {
    Name = "${var.project_name}-db-private-${count.index + 1 }"
    Environment = var.Environment
  }
}

#################################
#internet gateway
#################################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
    Environment = var.Environment
  }
}

#################################
# NAT Gateway elastic ip
#################################

resource "aws_eip" "nat" {
  count = length(var.web_public_subnets)
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip-${count.index + 1}"
    Environment = var.Environment
  }
}

#################################
# NAT Gateway 
#################################
resource "aws_nat_gateway" "my_nat_gateway" {

  count = length(var.web_public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.web_public[count.index].id

  tags = {
    Name        = "${var.project_name}-nat-${count.index + 1}"
    Environment = var.Environment
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

#################################
# security group for frontend alb
#################################

resource "aws_security_group" "sg_frontend_alb" {
  name        = "${var.project_name}-frontend-alb-sg"
  description = "Allow HTTP access from internet"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound only inside VPC
  egress {
    description = "Outbound only to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-frontend-alb-sg"
    Environment = var.Environment
  }
}

#################################
# security group for backend alb
#################################

resource "aws_security_group" "sg_backend_alb" {
  name        = "${var.project_name}-backend-alb-sg"
  description = "Allow HTTP access from internet"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    description = "traffic from web application private subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_frontend_ec2.id]
  }

  # Outbound only inside VPC
  egress {
    description = "Outbound only to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-backend-alb-sg"
    Environment = var.Environment
  }
}

#################################
# security group for frontend ec2 
#################################
resource "aws_security_group" "sg_frontend_ec2" {
  name        = "${var.project_name}-sg_frontend_ec2"
  description = "traffic from frontend alb"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    description = "traffic from fronend alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_frontend_alb.id]
  }

  # Outbound only inside VPC
  egress {
    description = "Outbound only to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg_frontend_ec2"
    Environment = var.Environment
  }
}

#################################
# security group for backend ec2 
#################################

resource "aws_security_group" "sg_backend_ec2" {
  name        = var.sg_backend_ec2
  description = "Allow HTTP access from internet"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    description = "traffic from backend alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_backend_alb.id]
  }

  # Outbound only inside VPC
  egress {
    description = "Outbound only to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-backend-alb-sg"
    Environment = var.Environment
  }
}

#################################
# security group for db instances
#################################

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_backend_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.Environment
  }
}
###################################
#route table for web public subnets
###################################

resource "aws_route_table" "web_public_subnet_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "${var.project_name}-web-public-subnet-rt"
    Environment = var.Environment
  }
}

###################################
#route table for web private subnets
###################################

resource "aws_route_table" "web_private_subnet_rt" {
  count  = length(var.web_private_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway[count.index].id
  }
  tags = {
    Name        = "${var.project_name}-web-private-subnet-rt-${count.index + 1}"
    Environment = var.Environment
  }
}

###################################
#route table for app private subnets
###################################

resource "aws_route_table" "app_private_subnet_rt" {
  count  = length(var.app_private_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway[count.index].id
  }

  tags = {
    Name        = "${var.project_name}-app-private-subnet-rt-${count.index + 1}"
    Environment = var.Environment
  }
}

###################################
#route table for db private subnets
###################################

resource "aws_route_table" "db_private_subnet_rt" {

  count  = length(var.db_private_subnets)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway[count.index].id
  }

  tags = {
    Name        = "${var.project_name}-db-private-subnet-rt-${count.index + 1}"
    Environment = var.Environment
  }
}

###################################
# Route Table Associations
###################################
resource "aws_route_table_association" "web_public" {
  count          = length(var.web_public_subnets)
  subnet_id      = aws_subnet.web_public[count.index].id
  route_table_id = aws_route_table.web_public_subnet_rt.id
}

resource "aws_route_table_association" "web_private" {
  count          = length(var.web_private_subnets)
  subnet_id      = aws_subnet.web_private[count.index].id
  route_table_id = aws_route_table.web_private_subnet_rt[count.index].id
}

resource "aws_route_table_association" "app_private" {
  count          = length(var.app_private_subnets)
  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.app_private_subnet_rt[count.index].id
}

resource "aws_route_table_association" "db_private" {
  count          = length(var.db_private_subnets)
  subnet_id      = aws_subnet.db_private[count.index].id
  route_table_id = aws_route_table.db_private_subnet_rt[count.index].id
}