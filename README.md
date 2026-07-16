# Terraform AWS Infrastructure

У проєкті додано універсальний модуль `modules/rds`, який за одним прапорцем створює або Aurora Cluster, або звичайний RDS instance.

## Що робить модуль `rds`

- `use_aurora = true` створює `aws_rds_cluster` і щонайменше один `aws_rds_cluster_instance` (writer).
- `use_aurora = false` створює один `aws_db_instance`.
- В обох режимах автоматично створюються:
  - `aws_db_subnet_group`
  - `aws_security_group`
  - `aws_db_parameter_group`
- Для Aurora додатково створюється `aws_rds_cluster_parameter_group`.

## Приклад використання

```hcl
module "rds" {
  source = "./modules/rds"

  identifier       = "demo-dev-db"
  use_aurora       = true
  engine           = "aurora-postgresql"
  engine_version   = "16.4"
  instance_class   = "db.t4g.medium"
  multi_az         = false

  db_name          = "appdb"
  username         = "appuser"
  password         = var.rds_password

  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids

  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  aurora_instance_count = 1

  tags = {
    Project     = "devops-ci-cd"
    Environment = "dev"
  }
}
```

## Змінні модуля

| Змінна | Тип | Default | Опис |
|---|---|---|---|
| `identifier` | `string` | n/a | Базовий ідентифікатор RDS instance або Aurora cluster |
| `use_aurora` | `bool` | `true` | Перемикає режим між Aurora і звичайним RDS |
| `engine` | `string` | n/a | Тип БД: `postgres`, `mysql`, `aurora-postgresql`, `aurora-mysql` |
| `engine_version` | `string` | n/a | Версія engine |
| `instance_class` | `string` | n/a | Клас інстансу |
| `multi_az` | `bool` | `false` | Використовується для звичайного RDS instance |
| `db_name` | `string` | n/a | Назва бази даних |
| `username` | `string` | n/a | Master username |
| `password` | `string` | n/a | Master password |
| `vpc_id` | `string` | n/a | VPC для security group |
| `subnet_ids` | `list(string)` | n/a | Підмережі для DB subnet group |
| `allowed_cidr_blocks` | `list(string)` | `[]` | CIDR, яким дозволений доступ до БД |
| `allowed_security_group_ids` | `list(string)` | `[]` | Security groups, яким дозволений доступ до БД |
| `parameter_group_family` | `string` | `null` | Явний `family` для `aws_db_parameter_group`, якщо авто-визначення не підходить |
| `cluster_parameter_group_family` | `string` | `null` | Явний `family` для `aws_rds_cluster_parameter_group` |
| `port` | `number` | `null` | Порт БД; якщо `null`, вибирається типовий |
| `allocated_storage` | `number` | `20` | Розмір диска для звичайного RDS |
| `max_allocated_storage` | `number` | `100` | Storage autoscaling для звичайного RDS |
| `storage_type` | `string` | `gp3` | Тип storage для звичайного RDS |
| `aurora_instance_count` | `number` | `1` | Кількість інстансів у Aurora cluster |
| `publicly_accessible` | `bool` | `false` | Публічна доступність БД |
| `backup_retention_period` | `number` | `7` | Зберігання backup у днях |
| `backup_window` | `string` | `"03:00-04:00"` | Вікно backup |
| `maintenance_window` | `string` | `"Mon:04:00-Mon:05:00"` | Вікно maintenance |
| `apply_immediately` | `bool` | `false` | Застосовувати зміни відразу |
| `deletion_protection` | `bool` | `false` | Захист від видалення |
| `skip_final_snapshot` | `bool` | `true` | Пропускати фінальний snapshot при destroy |
| `max_connections` | `string` | `"200"` | Параметр `max_connections` |
| `log_statement` | `string` | `"ddl"` | Параметр `log_statement` |
| `work_mem` | `string` | `"4096"` | Параметр `work_mem` |
| `tags` | `map(string)` | `{}` | Теги AWS ресурсів |

## Як змінити тип БД

Для перемикання між режимами достатньо змінити:

```hcl
use_aurora = true
engine     = "aurora-postgresql"
```

або:

```hcl
use_aurora = false
engine     = "postgres"
```

## Як змінити engine, версію та клас інстансу

Приклади:

```hcl
engine         = "aurora-mysql"
engine_version = "8.0.mysql_aurora.3.08.0"
instance_class = "db.r6g.large"
```

```hcl
engine         = "postgres"
engine_version = "16.4"
instance_class = "db.t4g.small"
multi_az       = true
```

## Нотатки

- Для Aurora модуль створює cluster parameter group і instance parameter group окремо.
- `parameter_group_family` і `cluster_parameter_group_family` зазвичай виводяться автоматично з `engine` та `engine_version`, але їх можна задати вручну для нестандартних версій.
- Для production варто вимкнути `skip_final_snapshot` і ввімкнути `deletion_protection`.
