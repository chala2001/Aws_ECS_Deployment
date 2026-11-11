output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
output "data_subnet_ids" { value = [for s in aws_subnet.data : s.id] }
output "alb_sg_id" { value = aws_security_group.alb.id }
output "task_sg_id" { value = aws_security_group.task.id }
output "db_sg_id" { value = aws_security_group.db.id }
output "ecr_repository_url" { value = aws_ecr_repository.app.repository_url }
