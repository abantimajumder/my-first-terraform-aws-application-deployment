project_name = "terraform-aws-application"
aws_vpc_name = "main-vpc"
vpc_cidr_range = "10.0.0.0/16"
availability_zone_subnet =  ["us-east-1a", "us-east-1b"]
web_public_subnets = ["10.0.0.0/20", "10.0.16.0/20"]
web_private_subnets =  ["10.0.48.0/20", "10.0.64.0/20"]
app_private_subnets = ["10.0.96.0/20", "10.0.112.0/20"]
db_private_subnets = ["10.0.144.0/20", "10.0.160.0/20"]
Environment = "dev"


