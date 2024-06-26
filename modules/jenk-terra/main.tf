# This file contains the main configuration for provisioning Jenkins and Terraform node servers.

# IAM role and policy for Jenkins server
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "jenkins_policy" {
  name        = "jenkins-policy"
  description = "Jenkins policy for managing build operations"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:Describe*",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_policy_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

# IAM instance profile for Jenkins server
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = aws_iam_role.jenkins_role.name
  role = aws_iam_role.jenkins_role.name
}

# IAM role and policy for Terraform node
resource "aws_iam_role" "terraform_node_role" {
  name = "terraform-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "terraform_node_policy" {
  name        = "terraform-node-policy"
  description = "Policy for Terraform node"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
          "iam:ListRoles",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:TagRole",
          "iam:PassRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "sts:AssumeRole",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "ec2:CreateVpc",
          "ec2:CreateTags",
          "ec2:CreateSubnet",
          "ec2:CreateSecurityGroup",
          "ec2:CreateRouteTable",
          "ec2:CreateInternetGateway",
          "ec2:ModifyVpcAttribute",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteNetworkAclEntry"
        ],
        Resource = "*"
      }
    ]
  })
}




resource "aws_iam_role_policy_attachment" "terraform_node_policy_attach" {
  role       = aws_iam_role.terraform_node_role.name
  policy_arn = aws_iam_policy.terraform_node_policy.arn
}

# IAM instance profile for Terraform node
resource "aws_iam_instance_profile" "terraform_node_profile" {
  name = aws_iam_role.terraform_node_role.name
  role = aws_iam_role.terraform_node_role.name
}

# Security group to allow SSH and HTTP access
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_security_group"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for Jenkins server
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-04b70fa74e45c3917" # Ubuntu 20.04 AMI in us-east-1
  instance_type               = "t2.medium"
  key_name                    = var.my_key_pair
  security_groups             = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y wget gnupg2
              sudo wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add -
              sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
              sudo apt update
              sudo apt install -y java-17-amazon-corretto-jdk
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt update
              sudo apt install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "Jenkins Server"
  }
}

# EC2 instance for Terraform node
resource "aws_instance" "terraform_node" {
  ami                         = "ami-04b70fa74e45c3917" # Ubuntu 20.04 AMI in us-east-1
  instance_type               = "t2.medium"
  key_name                    = var.my_key_pair
  security_groups             = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.terraform_node_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y wget unzip gnupg2
              sudo wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add -
              sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
              sudo apt update
              sudo apt install -y java-17-amazon-corretto-jdk
              wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
              unzip terraform_1.0.11_linux_amd64.zip
              sudo mv terraform /usr/local/bin/
              EOF

  tags = {
    Name = "Terraform Node"
  }
}
