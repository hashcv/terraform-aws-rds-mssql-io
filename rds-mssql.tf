resource "aws_db_subnet_group" "default_rds_mssql" {
  name        = "${var.environment}-rds-mssql-subnet-group"
  description = "The ${var.environment} rds-mssql private subnet group."
  subnet_ids  = ["${var.vpc_subnet_ids}"]

  tags {
    Name = "${var.environment}-rds-mssql-subnet-group"
    Env  = "${var.environment}"
  }
}

resource "aws_security_group" "rds_mssql_security_group" {
  name        = "${var.environment}-all-rds-mssql-internal"
  description = "${var.environment} allow all vpc traffic to rds mssql."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_blocks}"]
  }

  tags {
    Name = "${var.environment}-all-rds-mssql-internal"
    Env  = "${var.environment}"
  }
}

resource "aws_db_instance" "default_mssql" {
  depends_on                = ["aws_db_subnet_group.default_rds_mssql"]
  identifier                = "${var.identifier}"
  allocated_storage         = "${var.rds_allocated_storage}"
  storage_type              = "${var.rds_storage_type}"
  iops                      = "${var.rds_iops}"
  option_group_name         = "${var.rds_option_group_name}"
  publicly_accessible       = "${var.rds_publicly_accessible}"
  license_model             = "license-included"
  engine                    = "sqlserver-se"
  engine_version            = "13.00"
  instance_class            = "${var.rds_instance_class}"
  multi_az                  = "${var.rds_multi_az}"
  username                  = "${var.mssql_admin_username}"
  password                  = "${var.mssql_admin_password}"
  vpc_security_group_ids    = ["${aws_security_group.rds_mssql_security_group.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.default_rds_mssql.id}"
  backup_retention_period   = 3
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  final_snapshot_identifier = "${var.environment}-mssql-final-snapshot"
  timezone                  = "Central Europe Standard Time"
}

// Identifier of the mssql DB instance.
output "mssql_id" {
  value = "${aws_db_instance.default_mssql.id}"
}

// Address of the mssql DB instance.
output "mssql_address" {
  value = "${aws_db_instance.default_mssql.address}"
}
