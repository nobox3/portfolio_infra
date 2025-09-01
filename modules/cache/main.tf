resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.app_id}-cache-subnet-group"
  subnet_ids = var.subnet_ids
}

module "cache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.6.0"

  replication_group_id = var.app_id

  engine             = "valkey"
  engine_version     = "8.0"
  node_type          = var.node_type
  port               = 6379
  num_cache_clusters = 2
  multi_az_enabled   = true

  # Subnet Group
  create_subnet_group = false
  subnet_group_name   = aws_elasticache_subnet_group.this.id

  # Security
  create_security_group      = false
  security_group_ids         = var.security_group_ids
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"

  # Backup
  snapshot_retention_limit = 1
  snapshot_window          = "17:00-18:00"

  # Maintenance
  maintenance_window = "fri:18:00-fri:19:00"
  apply_immediately  = true
  # notification_topic_arn = ""

  # Others
  automatic_failover_enabled = true
  auto_minor_version_upgrade = false

  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "valkey8"

  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = {
    Name = var.app_id
  }
}
