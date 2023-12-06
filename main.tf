# main.tf

# Dostawca AWS
provider "aws" {
  region = "eu-central-1"
}


# Konfiguracja VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Konfiguracja podsieci
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-subnet"
  }
}

# Konfiguracja grupy bezpieczeństwa
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["178.235.183.190/32"] 
  }

  tags = {
    Name = "my-security-group"
  }
}

# Konfiguracja roli IAM
resource "aws_iam_role" "my_role" {
  name = "my-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Konfiguracja zasady uprawnień
resource "aws_iam_policy" "my_policy" {
  name        = "my-policy"
  description = "My IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Przypisanie zasady uprawnień do roli IAM
resource "aws_iam_role_policy_attachment" "my_attach" {
  policy_arn = aws_iam_policy.my_policy.arn
  role       = aws_iam_role.my_role.name
}

# Konfiguracja instancji EC2 dla węzła głównego Kubernetes
resource "aws_instance" "master_node" {
  ami           = "ami-06dd92ecc74fdfb36"
  instance_type = "t3.micro"
  key_name      = "anti_key"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  iam_instance_profile = aws_iam_role.my_role.name

  tags = {
    Name = "master_node"
  }
}

# Konfiguracja instancji EC2 dla węzłów roboczych Kubernetes
resource "aws_instance" "worker_node" {
  ami           = "ami-0479653c00e0a5e59"
  instance_type = "t3.micro"
  key_name      = "anti_key"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  iam_instance_profile = aws_iam_role.my_role.name

  tags = {
    Name = "worker_node"
  }
}

