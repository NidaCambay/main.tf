provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "task-1" {
  ami = lookup(var.myami, terraform.workspace)
  instance_type = lookup(var.instance_type, terraform.workspace)
  count = 2
  key_name = lookup(var.key-pem, terraform.workspace)
  security_groups = [aws_security_group.brc-sg.name]
  tags = {
    Name = "${terraform.workspace}-server"
  }
}

resource "aws_security_group" "brc-sg" {
    name = "${terraform.workspace}-sg"
    tags = {
        Name = "${terraform.workspace}-sg"
    }

    ingress {
        from_port = 22
        protocol = "tcp"
        to_port = 22
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        protocol = -1
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

variable "myami" {
  type = map(string)
  default = {
    dev     = "ami-06640050dc3f556bb"
    prod    = "ami-08d4ac5b634553e16"
    test    = "ami-0cff7528ff583bf9a"
    staging = "ami-0ddc798b3f1a5117e"
  }
}


variable "instance_type" {
  type = map(string)
  default = {
    dev     = "t2.micro"
    prod    = "t2.nano"
    test    = "t3a.medium"
    staging = "t2.small"
  }
}

variable "key-pem" {
  type = map(string)
  default = {
    dev     = "dev-key"
    prod    = "prod-key"
    test    = "test-key"
    staging = "staging-key"
  }
}

output "instance_public_ips" {
  value = [for instance in aws_instance.task-1 : instance.public_ip]
}
