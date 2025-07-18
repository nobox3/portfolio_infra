output "latest_image_uri" {
  value = data.aws_ecr_image.latest.image_uri
}
