
variable "key_name" {
  default = "terraform-key"
}


variable "pvt_key" {
  default = "/root/.ssh/awskeypair.pem"
}


variable "sg_id" {
  default = "sg-02b2c644d114edbf9"
}

variable "instance_count" {
  default = "2"
}

variable "amis" {
  type = "map"

  default = {
    us-east-2 = "ami-01aab85a5e4a5a0fe"
  }
}
