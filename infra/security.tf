# ---------- 1. ALB: the only thing open to the internet ----------
resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "Public entry point: HTTP/HTTPS from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from the internet (we use HTTP in the lab; no real TLS cert)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from the internet (what you would use in production)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "ALB forwards requests to tasks inside the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-alb-sg" }
}

# ---------- 2. Tasks: only the ALB may connect, only on the app port ----------
resource "aws_security_group" "task" {
  name        = "${var.project}-task-sg"
  description = "ECS tasks: app port only from the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App port 8080, only from the ALB security group"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # <-- SG reference, not an IP
  }

  egress {
    description = "Tasks can call out: ECR image pull, Secrets Manager, logs, DB, external APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-task-sg" }
}

# ---------- 3. Database: only the tasks may connect, only on Postgres port ----------
resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "RDS Postgres: only from ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres 5432, only from the task security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.task.id]
  }

  # No egress block: the database never needs to START a connection to anything.
  # (Replies to the tasks still work, because security groups are stateful.)

  tags = { Name = "${var.project}-db-sg" }
}
