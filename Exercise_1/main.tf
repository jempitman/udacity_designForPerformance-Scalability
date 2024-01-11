# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region = "us-east-1"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "UdacityT2" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "t2.micro"
  count         = "4"
  subnet_id     = "subnet-0908cde7188ca22aa" #existing subnet with vpc-0bb336940c9e64be6, CIDR block:172.31.64.0/20

  tags = {
    Name = "Udacity T2"
  }
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
/*
resource "aws_instance" "UdacityM4" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "m4.large"
  count         = "2"
  subnet_id     = "subnet-0ac4b14d24d1826b1" #existing subnet with vpc-0bb336940c9e64be6, CIDR block:172.31.48.0/20

  tags = {
    Name = "Udacity M4"
  }
}*/
