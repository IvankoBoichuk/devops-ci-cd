resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = local.normalized_name

  engine          = var.engine
  engine_version  = var.engine_version
  database_name   = var.db_name
  master_username = var.username
  master_password = var.password
  port            = local.port

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  apply_immediately            = var.apply_immediately
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : "${local.normalized_name}-cluster-final"
  storage_encrypted            = true

  tags = merge(var.tags, {
    Name = local.normalized_name
  })

  lifecycle {
    precondition {
      condition     = contains(["aurora-mysql", "aurora-postgresql"], var.engine)
      error_message = "Aurora cluster supports only aurora-mysql or aurora-postgresql engines."
    }
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? var.aurora_instance_count : 0

  identifier          = "${local.normalized_name}-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.this[0].id
  instance_class      = var.instance_class
  engine              = var.engine
  engine_version      = var.engine_version
  publicly_accessible = var.publicly_accessible

  db_subnet_group_name       = aws_db_subnet_group.this.name
  db_parameter_group_name    = aws_db_parameter_group.this.name
  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  tags = merge(var.tags, {
    Name = "${local.normalized_name}-${count.index + 1}"
    Role = count.index == 0 ? "writer" : "reader"
  })
}
