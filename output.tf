output "my_ip_public_public_EC2" {
  value = aws_instance.ec2_public_example.public_ip  
}

output "my_ip_private_public_EC2" {
  value = aws_instance.ec2_public_example.private_ip 
}

output "my_ip_private_private_EC2" {
  value = aws_instance.ec2_private_example.private_ip 
}
