
provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_instance" "example" {
  ami           = "ami-06aa3f7caf3a30282" # ubuntu 20 AMI, replace with your desired AMI
  instance_type = "t2.small"
  key_name      = "ADMIN_KEYPAIR"
  tags = {
    Name = "example-instance"
  }

  # Create a security group for SSH access
  vpc_security_group_ids = [aws_security_group.example.id]

  provisioner "local-exec" {
    command = <<-EOF
      echo "---
_all:
  hosts:
    example_instance:
      ansible_host: ${self.public_ip}
      ansible_user: ubuntu
      ansible_python_interpreter: /usr/bin/python3
      ansible_ssh_private_key_file: ADMIN_KEYPAIR.pem
  children:
    example_instances:
      hosts:
        example_instance
  vars:
    instance_ip: ${self.public_ip}
" > inventory
    EOF
  }

  provisioner "local-exec" {
    # Pause for 30 seconds before executing the Ansible playbook
    command = "sleep 60"
  }
  provisioner "local-exec" {
    # Execute the Ansible playbook using the created inventory file
    command = "ansible-playbook -i inventory configure_instance.yml"
  }
}

# Create a security group allowing SSH from your IP
resource "aws_security_group" "example" {
  name        = "allow-ssh-from-your-ip"
  description = "Allow SSH from your IP"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your actual public IP
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
# Output the public IP address for Ansible
output "instance_ip" {
  value = aws_instance.example.public_ip
}



#===========================================================================================================================================


# provider "aws" {
#   region = var.aws_region
# }


# #Create security group with firewall rules
# resource "aws_security_group" "jenkins-sg-2024" {
#   name        = var.security_group
#   description = "security group for Ec2 instance"

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#  ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#  # outbound from jenkis server
#   egress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags= {
#     Name = var.security_group
#   }
# }

# resource "aws_instance" "myFirstInstance" {
#   ami           = var.ami_id
#   key_name = var.key_name
#   instance_type = var.instance_type
#   vpc_security_group_ids = [aws_security_group.jenkins-sg-2024.id]
#   tags= {
#     Name = var.tag_name
#   }
# }
