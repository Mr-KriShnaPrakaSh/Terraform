output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet" {
  value = values(aws_subnet.public)[*].id
}

output "private_subnet" {
  value = values(aws_subnet.private)[*].id
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

