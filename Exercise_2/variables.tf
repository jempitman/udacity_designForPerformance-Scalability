# TODO: Define the variable for aws_region
variable "region"{
  description = "AWS region for lambda function to be deployed"
  type = string
  default = "us-east-1"
}

variable "greeting" {
  description = "Greeting message to be set as an Environment Variable"
  type = string
  default = "Hello"
}