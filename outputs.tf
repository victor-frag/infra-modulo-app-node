output "public_dns" {
  value = "http://${aws_instance.app_server.public_dns}:5000"
}
