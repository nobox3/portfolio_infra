output "this" {
  value = {
    region       = var.region
    organization = var.organization
    project      = var.project
    workspace    = var.workspace
  }
}
