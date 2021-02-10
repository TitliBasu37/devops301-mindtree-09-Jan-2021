
variable "key_name" {
  default = "terraform-key"
}


variable "pvt_key" {
  default = "/root/.ssh/awskeypair.pem"
}


variable "sg_id" {
  default = "sg-00343899b75666c41"
}

variable "instance_count" {
  default = "2"
}

variable "ami" {
  default ="ami-01aab85a5e4a5a0fe"
  
}
