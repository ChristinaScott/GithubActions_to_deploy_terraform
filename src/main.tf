provider "aws"{
  region = "us-west-2"
  }


terraform {
  backend "s3" {
   bucket = "christina-terraform-gitactions" 
    key = "terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "SharanyaChristina-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id # resource_keysyntax. logicalId. Id  = !Ref 
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2"
  map_public_ip_on_launch = true
  tags = {
    Name = "Christina-PublicSubnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Christina-IGW"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Christina-routeTable"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Sharanya-SecurityGroup"
  }
}



resource "aws_instance" "my_ec2" {
  ami                    = "ami-04dd23e62ed049936"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "Chrisiina-Ec2Instance"
  }
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}
