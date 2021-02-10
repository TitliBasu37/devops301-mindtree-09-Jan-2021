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
  count = var.instance_count
  ami               = "ami-0ebc8f6f580a04647"
  instance_type     = "t2.micro"
  key_name          = var.key_name
  vpc_security_group_ids = [var.sg_id] 
  tags = {
       Name = format("Dev-app-worker%d", count.index + 1)
    }


  connection {
    type  = "ssh"
    user = "ubuntu"
    private_key = file(var.pvt_key)
    host = element(self.*.public_ip, count.index)
   }
   

  provisioner "remote-exec" {
     inline = [
       "sudo apt-get update",
       "sudo apt-get install python sshpass -y"
      ]


  }
}


resource "null_resource" "ansible-main" {
  count = var.instance_count
  provisioner "local-exec" {
    command = <<EOT
           > jenkins-ci.ini;
        echo "[jenkins-ci]"| tee -a jenkins-ci.ini;
        export ANSIBLE_HOST_KEY_CHECKING=False;
        echo "element(aws_instance.dev-app.*.public_ip, count.index)" | tee -a jenkins-ci.ini;
        ansible-playbook  --key-file=${var.pvt_key} -i jenkins-ci.ini -u ubuntu ./ansible-code/petclinic.yaml  -v
      EOT
  }
  depends_on = [aws_instance.dev-app]
}




output "frontend_public_ips" {
  value = aws_instance.dev-app.*.public_ip
}
