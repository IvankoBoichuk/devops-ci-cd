locals {
  normalized_name = replace(var.identifier, "_", "-")

  engine_major_match = regexall("^[0-9]+", var.engine_version)
  engine_minor_match = regexall("^[0-9]+\\.([0-9]+)", var.engine_version)

  engine_major = length(local.engine_major_match) > 0 ? local.engine_major_match[0] : null
  engine_minor = length(local.engine_minor_match) > 0 ? local.engine_minor_match[0][0] : null

  is_postgres_family = contains(["postgres", "aurora-postgresql"], var.engine)

  parameter_group_family = var.parameter_group_family != null ? var.parameter_group_family : (
    var.engine == "postgres" ? "postgres${local.engine_major}" :
    var.engine == "mysql" ? "mysql${local.engine_major}.${local.engine_minor}" :
    var.engine == "aurora-postgresql" ? "aurora-postgresql${local.engine_major}" :
    var.engine == "aurora-mysql" ? "aurora-mysql${local.engine_major}.${local.engine_minor}" :
    null
  )

  cluster_parameter_group_family = var.cluster_parameter_group_family != null ? var.cluster_parameter_group_family : (
    var.engine == "aurora-postgresql" ? "aurora-postgresql${local.engine_major}" :
    var.engine == "aurora-mysql" ? "aurora-mysql${local.engine_major}.${local.engine_minor}" :
    null
  )

  port = var.port != null ? var.port : (
    contains(["postgres", "aurora-postgresql"], var.engine) ? 5432 : 3306
  )

  db_parameters = concat(
    [
      {
        name  = "max_connections"
        value = var.max_connections
      }
    ],
    local.is_postgres_family ? [
      {
        name  = "log_statement"
        value = var.log_statement
      },
      {
        name  = "work_mem"
        value = var.work_mem
      }
    ] : []
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.normalized_name}-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.normalized_name}-subnets"
  })
}

resource "aws_security_group" "this" {
  name        = "${local.normalized_name}-sg"
  description = "Security group for ${var.identifier} RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Database access from allowed CIDR blocks"
    from_port   = local.port
    to_port     = local.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.normalized_name}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  count = length(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  from_port                    = local.port
  ip_protocol                  = "tcp"
  to_port                      = local.port
}

resource "aws_db_parameter_group" "this" {
  name        = "${local.normalized_name}-db-params"
  family      = local.parameter_group_family
  description = "DB parameter group for ${var.identifier}"

  dynamic "parameter" {
    for_each = local.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = "pending-reboot"
    }
  }

  tags = merge(var.tags, {
    Name = "${local.normalized_name}-db-params"
  })

  lifecycle {
    precondition {
      condition     = local.parameter_group_family != null
      error_message = "Unable to derive DB parameter group family. Set parameter_group_family explicitly."
    }
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name        = "${local.normalized_name}-cluster-params"
  family      = local.cluster_parameter_group_family
  description = "Cluster parameter group for ${var.identifier}"

  dynamic "parameter" {
    for_each = local.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = "pending-reboot"
    }
  }

  tags = merge(var.tags, {
    Name = "${local.normalized_name}-cluster-params"
  })

  lifecycle {
    precondition {
      condition     = local.cluster_parameter_group_family != null
      error_message = "Unable to derive Aurora cluster parameter group family. Set cluster_parameter_group_family explicitly."
    }
  }
}
