resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = local.normalized_name

  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  db_name               = var.db_name
  username              = var.username
  password              = var.password
  port                  = local.port
  multi_az              = var.multi_az
  publicly_accessible   = var.publicly_accessible
  storage_encrypted     = true
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  apply_immediately         = var.apply_immediately
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.normalized_name}-final"

  tags = merge(var.tags, {
    Name = local.normalized_name
  })

  lifecycle {
    precondition {
      condition     = !contains(["aurora-mysql", "aurora-postgresql"], var.engine)
      error_message = "Aurora engines require use_aurora = true."
    }
  }
}
