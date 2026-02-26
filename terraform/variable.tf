variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  default     = "eu-west-1"
}

variable "ami_id" {
    description = "AMI ID for the ec2 instance"
    default = ""
}

variable "instance_type" {
    description = "EC2 instance type"
    default = "t2.large"
}


variable "my_enviroment" {
  description = "Instance type for the EC2 instance"
  default     = "dev"
}
