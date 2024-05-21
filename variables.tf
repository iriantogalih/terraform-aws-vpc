variable "instance_type" {
  type= string   
  default = "t2.micro"
}

variable "enable_public" {
    type = bool
    default = true
}

variable "environment_name" {
    type= string
    default = "dev"
}
