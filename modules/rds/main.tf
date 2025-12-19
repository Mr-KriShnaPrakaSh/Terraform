resource "aws_db_subnet_group" "main" {
  name       = "${var.env_name}-db-subnet"
  subnet_ids = var.private_subnet
  tags = { Name = "${var.env_name}-db-subnet" }
}

resource "aws_db_instance" "primary" {
  identifier              = "${var.env_name}-db"
  engine                  = "postgres"
  engine_version          = "15.13"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [var.rds_sg_id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 1
}

resource "aws_db_instance" "replica" {
  identifier             = "${var.env_name}-db-replica"
  replicate_source_db    = aws_db_instance.primary.arn
  instance_class         = var.db_instance_class
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
}

