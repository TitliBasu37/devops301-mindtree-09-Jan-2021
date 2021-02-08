terraform {
  backend "local" {
     path = "/var/tmp/terraform-local-backend/terraform.tfstate"
  }
}


provider "aws" {
   region = var.region
   version = ">=3.7,<=3.11"
}

variable "region" {
   default = "us-east-2"
}


data "aws_availability_zones" "zones_east" {}

data "aws_ami" "myami" {
   most_recent = true
   owners = ["amazon"]

  filter {
    name = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server*"]

  }

}


resource "aws_instance" "dev-app" {
  ami               = "ami-0ebc8f6f580a04647"
  #availability_zone = data.aws_availability_zones.zones_east.names[count.index]
  instance_type     = "t2.micro"
  #count             = 1
  key_name          = var.key_name
  vpc_security_group_ids = [var.sg_id] 
 
  lifecycle {
     create_before_destroy = true
  } 
  tags = {
       Name = "Dev-app-test"
    }


  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.pvt_key)
    host   = self.public_ip
   }
   

  provisioner "remote-exec" {
     inline = [
       "sudo apt-get update",
       "sudo apt-get install python sshpass -y"
      ]

  }
}

resource "aws_instance" "stage-app" {
  ami               = "ami-0ebc8f6f580a04647"
  #availability_zone = data.aws_availability_zones.zones_east.names[count.index]
  instance_type     = "t2.micro"
  #count             = 1
  key_name          = var.key_name
  vpc_security_group_ids = [var.sg_id] 
 
  lifecycle {
     create_before_destroy = true
  } 
  tags = {
       Name = "Dev-app-test"
    }


  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.pvt_key)
    host   = self.public_ip
   }
   

  provisioner "remote-exec" {
     inline = [
       "sudo apt-get update",
       "sudo apt-get install python sshpass -y"
      ]

  }
}

resource "null_resource" "ansible-main" {
  provisioner "local-exec" {
    command = <<EOT
           > jenkins-ci.ini;
        echo "[jenkins-ci]"| tee -a jenkins-ci.ini;
        export ANSIBLE_HOST_KEY_CHECKING=False;
        echo "${aws_instance.dev-app.public_ip}" | tee -a jenkins-ci.ini;
        ansible-playbook  --key-file=${var.pvt_key} -i jenkins-ci.ini -u ubuntu ./ansible-code/petclinic.yaml  -v
      EOT
  }
depends_on = [aws_instance.dev-app]
}

resource "null_resource" "ansible-worker" {
    provisioner "local-exec" {
    command = <<EOT
           > java-ci.ini;
        echo "[java-ci]"| tee -a java-ci.ini;
        export ANSIBLE_HOST_KEY_CHECKING=False;
        echo "${aws_instance.stage-app.public_ip}" | tee -a java-ci.ini;
        ansible-playbook  --key-file=${var.pvt_key} -i java-ci.ini -u ubuntu ./ansible-code/petclinic.yaml  -v
      EOT
  }
  
  depends_on = [aws_instance.stage-app]
}




output "frontend_public_ips" {
  value = aws_instance.dev-app.public_ip
}
output "stage_public_ips" {
  value = aws_instance.stage-app.public_ip
}
