output "controlplane_public_ip" {
  value = aws_instance.controlplane.public_ip
}

output "controlplane_private_ip" {
  value = aws_instance.controlplane.private_ip
}