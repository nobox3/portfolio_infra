output "group_names" {
  value = {
    web   = aws_cloudwatch_log_group.web.name
    nginx = aws_cloudwatch_log_group.nginx.name
  }
}
