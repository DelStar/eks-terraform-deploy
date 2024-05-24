# This file contains the main configuration for provisioning Jenkins and Terraform build agent servers.

# Create an AWS key pair for SSH access
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins_key"
  public_key = file(var.public_key_path)
}

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

# IAM role and policy for Terraform build agent
resource "aws_iam_role" "terraform_build_agent_role" {
  name = "terraform-build-agent-role"

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

resource "aws_iam_policy" "terraform_build_agent_policy" {
  name        = "terraform-build-agent-policy"
  description = "Policy for Terraform build agent"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:Describe*",
        "s3:GetObject",
        "s3:ListBucket",
        "iam:ListRoles",
        "iam:GetRole",
        "sts:AssumeRole"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_build_agent_policy_attach" {
  role       = aws_iam_role.terraform_build_agent_role.name
  policy_arn = aws_iam_policy.terraform_build_agent_policy.arn
}

# IAM instance profile for Terraform build agent
resource "aws_iam_instance_profile" "terraform_build_agent_profile" {
  name = aws_iam_role.terraform_build_agent_role.name
  role = aws_iam_role.terraform_build_agent_role.name
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
  key_name                    = aws_key_pair.jenkins_key.key_name
  security_groups             = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y openjdk-11-jdk
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

# EC2 instance for Terraform build agent
resource "aws_instance" "terraform_build_agent" {
  ami                         = "ami-04b70fa74e45c3917" # Ubuntu 20.04 AMI in us-east-1
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.jenkins_key.key_name
  security_groups             = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.terraform_build_agent_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y wget unzip
              wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
              unzip terraform_1.0.11_linux_amd64.zip
              sudo mv terraform /usr/local/bin/
              EOF

  tags = {
    Name = "Terraform Build Agent"
  }
}
