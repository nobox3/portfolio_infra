data "aws_region" "current" {}

data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.12.0"

  identifier = var.app_id

  engine         = "postgres"
  engine_version = "16.6"
  instance_class = var.instance_class

  manage_master_user_password = false
  db_name                     = var.db_name
  username                    = var.username
  password                    = var.password

  # Storage
  storage_type          = "gp2"
  allocated_storage     = var.allocated_storage
  max_allocated_storage = 0

  # Availability & durability
  multi_az = false

  # Connectivity
  db_subnet_group_name   = var.db_subnet_group_name
  publicly_accessible    = false
  vpc_security_group_ids = var.vpc_security_group_ids
  availability_zone      = "${data.aws_region.current.region}a"
  port                   = 5432

  # Database authentication
  iam_database_authentication_enabled = false

  # Backup
  backup_retention_period  = 1
  backup_window            = "17:00-18:00"
  copy_tags_to_snapshot    = true
  delete_automated_backups = true
  skip_final_snapshot      = true

  # Encryption
  storage_encrypted = true
  kms_key_id        = data.aws_kms_alias.rds.target_key_arn

  # Performance Insights (db.t3.micro, db.t3.small are not supported)
  performance_insights_enabled = false
  # performance_insights_kms_key_id       = data.aws_kms_alias.rds.target_key_arn
  # performance_insights_retention_period = 7

  # Monitoring
  database_insights_mode = "standard"
  monitoring_interval    = 60
  create_monitoring_role = true

  # Log exports
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Maintenance
  auto_minor_version_upgrade = false
  maintenance_window         = "fri:18:00-fri:19:00"

  # Deletion protection
  deletion_protection = false

  # Option group
  create_db_option_group = false

  # Parameter Group
  parameter_group_name = var.app_id
  family               = "postgres16"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = {
    Name = var.app_id
  }
}
