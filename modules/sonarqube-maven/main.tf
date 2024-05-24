# This file contains the main configuration for provisioning SonarQube and Maven server.

# IAM role and policy for the Sonarqube-Maven build agent
resource "aws_iam_role" "sonar_maven_role" {
  name = "sonar-maven-role"

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

resource "aws_iam_policy" "sonar_maven_policy" {
  name        = "sonar-maven-policy"
  description = "Policy for sonarqube-maven-server to access necessary AWS services"

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

resource "aws_iam_role_policy_attachment" "sonar_maven_policy_attach" {
  role       = aws_iam_role.sonar_maven_role.name
  policy_arn = aws_iam_policy.sonar_maven_policy.arn
}

# IAM instance profile for the Sonarqube-Maven build agent
resource "aws_iam_instance_profile" "sonar_maven_profile" {
  name = aws_iam_role.sonar_maven_role.name
  role = aws_iam_role.sonar_maven_role.name
}

# Security group to allow SSH, HTTP, and SonarQube access
resource "aws_security_group" "sonar_maven_sg" {
  name        = "sonar_maven_security_group"
  description = "Allow SSH, HTTP, and SonarQube access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# EC2 instance for SonarQube and Maven server
resource "aws_instance" "sonar_maven_server" {
  ami                         = "ami-04b70fa74e45c3917" # Ubuntu 20.04 AMI in us-east-1
  instance_type               = "t2.medium"
  key_name                    = var.existing_key_name
  security_groups             = [aws_security_group.sonar_maven_sg.name]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.sonar_maven_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y openjdk-11-jdk maven wget unzip
              # Install SonarQube
              sudo useradd -m -d /opt/sonarqube sonarqube
              cd /opt/sonarqube
              sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.2.1.49989.zip
              sudo unzip sonarqube-9.2.1.49989.zip
              sudo chown -R sonarqube:sonarqube sonarqube-9.2.1.49989
              sudo mv sonarqube-9.2.1.49989 sonarqube
              # Setup SonarQube as a service
              sudo bash -c 'cat <<EOT > /etc/systemd/system/sonarqube.service
              [Unit]
              Description=SonarQube service
              After=syslog.target network.target

              [Service]
              Type=forking
              ExecStart=/opt/sonarqube/sonarqube/bin/linux-x86-64/sonar.sh start
              ExecStop=/opt/sonarqube/sonarqube/bin/linux-x86-64/sonar.sh stop
              User=sonarqube
              Group=sonarqube
              Restart=always
              LimitNOFILE=65536

              [Install]
              WantedBy=multi-user.target
              EOT'
              sudo systemctl start sonarqube
              sudo systemctl enable sonarqube
              EOF

  tags = {
    Name = "SonarQube and Maven Server"
  }
}