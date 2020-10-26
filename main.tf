# Script for course CC615x - Cloud Computing Infrastructure
# IaC - Migration BallotOnline web site
# USMx - edX
# October 2020
# Hugo Aquino, Panama

# The script originally ran on Terraform 0.11.3 version, it was migrated to 0.13.5 version

# Before execute this script, execute "aws configure" in order to enable 
# AWS Access Key ID
# AWS Secret Access Key
# Default region name
# Default output format

# Generate a key executing
# "ssh-keygen"
# Save on the directory where you will run this script: <absolute_path>/cc615x-key-iac
# The key name must be cc615x-key-iac.pub, save on the directory where you will run this script <absolute_path>
# Left in blank "passphrase"

# This script originally ran on Terraform v0.11.3
# To install this version these are steps:
# wget https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
# unzip terraform_0.11.3_linux_amd64.zip
# sudo mv terraform /usr/local/bin/
# terraform --version

# This script runs on Terraform v0.13.5
# To install this version these are steps:
# wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
# unzip terraform_0.13.5_linux_amd64.zip
# sudo mv terraform /usr/local/bin/
# terraform --version

# The first time the script runs, Terraform has be intilized with "terraform apply"

# To run the script type: 
# terraform apply -var "minimum=<minimum_instances>" -var "maximum=<maximum_instances>"

# The script will run in a new Terraform version (the original version ran in 0.11.3)
terraform {
  required_version = ">= 0.13"
}

# Variable to define the minimum and maximum amount of instances to be created
variable minimum {
  default = 2
}

variable maximum {
  default = 3
}

# AWS deployment
provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

# To get Availability Zones info
data "aws_availability_zones" "all" {}

# Key generated
resource "aws_key_pair" "cc615x-key-iac" {
  key_name   = "cc615x-key-iac"
  #public_key = "${file("cc615-key-iac.pub")}" # Line used on v0.11.3
  public_key = file("cc615x-key-iac.pub")
}

# Getting information from the environment
# VPC
data "aws_vpc" "default" {
  default = true
}

# Print VPC ID
output "vpc_id" {
  #value = "${data.aws_vpc.default.id}" # Line used on v0.11.3
  value = data.aws_vpc.default.id
}

# Print VPC IP range 
output "vpc_cidr_block" {
  #value = "${data.aws_vpc.default.cidr_block}" # Line used on v0.11.3
  value = data.aws_vpc.default.cidr_block
}

# Subnets
data "aws_subnet_ids" "all" {
  #vpc_id = "${data.aws_vpc.default.id}" # Line used on v0.11.3
  vpc_id = data.aws_vpc.default.id
}

# Print Subnets IDs
output "subnet_ids" {
  #value = ["${data.aws_subnet_ids.all.ids}"] # Line used on v0.11.3
  value = [data.aws_subnet_ids.all.ids]
}

# Security Group
data "aws_security_group" "default" {
  #vpc_id = "${data.aws_vpc.default.id}" # Line used on v0.11.3
  vpc_id = data.aws_vpc.default.id
}

# Print Security Group
output "security_group" {
  #value = ["${data.aws_security_group.default.id}"] # Line used on v0.11.3
  value = [data.aws_security_group.default.id]
}

# Availability Zones
data "aws_availability_zones" "all_zones" {}

output "availability_zones" {
  #value = ["${data.aws_availability_zones.all_zones.names}"] # Line used on v0.11.3
  value = [data.aws_availability_zones.all_zones.names]
}

# Create Load Balancer
resource "aws_elb" "CC615x-LB-IaC" {
  name = "CC615-LB-IaC"
  #availability_zones = ["${data.aws_availability_zones.all_zones.names}"] # Line used on v0.11.3
  availability_zones = data.aws_availability_zones.all.names
  #security_groups = ["${data.aws_security_group.default.id}"] # Line used on v0.11.3
  security_groups = [data.aws_security_group.default.id]

  listener {
    instance_port = 80
    instance_protocol = "HTTP"
    lb_port = 80
    lb_protocol = "HTTP"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/"
    interval = 30
  }

  tags = {
    Name = "CC615x-Webserver-IaC"
  }
}

# Print Load Balancer DNS name
output "elb_dns_name" {
  #value = "${aws_elb.CC615-LB-IaC.dns_name}" # Line used on v0.11.3
  value = aws_elb.CC615x-LB-IaC.dns_name 
}

# Create Launch Template
resource "aws_launch_template" "CC615x_Lab_IaC" {
  name                                 = "CC615x_Lab_IaC"
  description                          = "CC615x Lab for Webserver migration for BallotOnline using IaC"
  disable_api_termination              = true
  image_id                             = "ami-07b919afaa5833920" # Image created with the course site files and nginx service
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  key_name                             = "cc615x-key-iac"
 #vpc_security_group_ids               = ["${data.aws_security_group.default.id}"] # Line used on v0.11.3
  vpc_security_group_ids               = [data.aws_security_group.default.id]
}

# Create Auto Scaling Group integrating the Lauch Template and Load Balancer
resource "aws_autoscaling_group" "CC615x-Lab-Scaling-Group-IaC" {
  name             = "CC615x-Lab-Scaling-Group-IaC"
  #min_size         = "${var.minimum}" # Line used on v0.11.3 version
  min_size         = var.minimum
  #desired_capacity = "${var.minimum}" # Line used on v0.11.3 version
  desired_capacity = var.minimum
  #max_size         = "${var.maximum}" # Line used on v0.11.3 version
  max_size         = var.maximum
  #availability_zones = ["${data.aws_availability_zones.all_zones.names}"] # Line used on v0.11.3
  availability_zones = data.aws_availability_zones.all.names
  #load_balancers = ["${aws_elb.CC615-LB-IaC.name}"] # Line used on v0.11.3
  load_balancers = [aws_elb.CC615x-LB-IaC.name]
  launch_template {
    #id      = "${aws_launch_template.CC615_Lab_IaC.id}" # Line used on v0.11.3
    id       = aws_launch_template.CC615x_Lab_IaC.id
    version = "$Default"
  }
}
