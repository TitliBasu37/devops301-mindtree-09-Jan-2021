
variable "key_name" {
  default = " awskeypair.pem"
}


variable "pvt_key" {
  default = "/root/.ssh/ awskeypair.pem"
}


variable "sg_id" {
  default = "sg-00343899b75666c41"
}
