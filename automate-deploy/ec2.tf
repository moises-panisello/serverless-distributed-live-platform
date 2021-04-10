## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 3 ##
## EC2 => EC2 instance creation ##
## Setup Edge machine ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-edge.md ##

data "aws_ami" "amazon-linux-2-ami" {
 most_recent = true
 filter {
  name   = "owner-alias"
  values = ["amazon"]
 }
 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
 owners = ["amazon"]
}

resource "aws_key_pair" "yourKey" {
  key_name   = var.key_name
  public_key = file("secrets/${var.key_name}.pub")
//  public_key = "ssh-rsa ********************* yourKey"
  tags = {
    Name = "${var.base_name}-${var.key_name}"
  }
}

resource "aws_security_group" "edge-machine" {
  name        = "edge-machine"
  description = "Allow SSL and SRT inbound traffic"
  ingress {
    description = "SSL from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SRT TCP from anywhere"
    from_port   = 1935
    to_port     = 1935
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SRT UDP from anywhere"
    from_port   = 1935
    to_port     = 1935
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "edge-machine"
  }
}

locals {
  instance-userdata = <<EOF
#!/bin/bash
export PATH=$PATH:/usr/local/bin
echo "--------------------------" >> /home/ec2-user/userdata-progress.txt
date >> /home/ec2-user/userdata-progress.txt
echo "--------------------------" >> /home/ec2-user/userdata-progress.txt
echo "01.Starting user data" >> /home/ec2-user/userdata-progress.txt
echo "02.Install tmux" >> /home/ec2-user/userdata-progress.txt
sudo yum install -y tmux
echo "03.Install ffmpeg" >> /home/ec2-user/userdata-progress.txt
sudo yum -y update
sudo yum -y install git
cd /home/ec2-user/
git clone https://github.com/jordicenzano/ffmpeg-compile-centos-amazon-linux.git
cd ffmpeg-compile-centos-amazon-linux
./compile-ffmpeg.sh
echo "04.Install go" >> /home/ec2-user/userdata-progress.txt
sudo yum install -y golang
echo "05.Install & Compile go-ts-segmenter" >> /home/ec2-user/userdata-progress.txt
cd /home/ec2-user/
su ec2-user -c 'go get github.com/jordicenzano/go-ts-segmenter'
cd go/src/github.com/jordicenzano/go-ts-segmenter
su ec2-user -c 'go get'
su ec2-user -c 'make'
echo "06.Finish!!!" >> /home/ec2-user/userdata-progress.txt
echo "--------------------------" >> /home/ec2-user/userdata-progress.txt
date >> /home/ec2-user/userdata-progress.txt
echo "--------------------------" >> /home/ec2-user/userdata-progress.txt
EOF
}

resource "aws_instance" "edge-machine" {
  ami           = data.aws_ami.amazon-linux-2-ami.id
  instance_type = "t3.medium"
  key_name = aws_key_pair.yourKey.key_name
  security_groups = [ aws_security_group.edge-machine.name ]
  user_data_base64 = base64encode(local.instance-userdata)
  iam_instance_profile = aws_iam_instance_profile.instance-profile-s3-full-access.id
  tags = {
    Name = "edge-machine"
  }
}

output "edge-machine_public_ip_addr" {
  value       = aws_instance.edge-machine.public_ip
  description = "edge-machine's public IP address."
}
