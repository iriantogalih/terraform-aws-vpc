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

variable "ami_linux" {
    type=string
    default =  "ami-003c463c8207b4dfa"  
}

variable "ami_windows" {
    type=string
    default =  "ami-048154cf4850e4efd"  
}

variable "iam_instance_profile"{
    type = string
    default = "ec2-s3-access"
}