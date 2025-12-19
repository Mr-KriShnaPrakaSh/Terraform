# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env_name}-vpc"
  }
}

# -------------------------------
# Public Subnets
# -------------------------------
resource "aws_subnet" "public" {
  for_each = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "${var.aws_region}-${each.key}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_name}-public-${each.key}"
  }
}

# -------------------------------
# Private Subnets
# -------------------------------
resource "aws_subnet" "private" {
  for_each = {
    a = "10.0.101.0/24"
    b = "10.0.102.0/24"
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "${var.aws_region}-${each.key}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env_name}-private-${each.key}"
  }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_name}-igw"
  }
}

# -------------------------------
# NAT Gateway
# -------------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.env_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public["a"].id
  depends_on    = [aws_internet_gateway.igw, aws_eip.nat_eip]
  tags = {
    Name = "${var.env_name}-nat"
  }
}

# -------------------------------
# Route Tables
# -------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.env_name}-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  depends_on = [aws_nat_gateway.nat]
  tags = {
    Name = "${var.env_name}-private-rt"
  }
}

# -------------------------------
# Route Table Associations
# -------------------------------
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id

  depends_on = [aws_route_table.public_rt]
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
  
  depends_on = [aws_route_table.private_rt]
}

# -------------------------------
# Security Group (App)
# -------------------------------
resource "aws_security_group" "app_sg" {
  name        = "${var.env_name}-sg"
  description = "Allow inbound traffic for app"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP ports
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-sg"
  }
}

# -------------------------------
# Security Group (RDS)
# -------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "${var.env_name}-rds-sg"
  description = "Allow DB Traffic"
  vpc_id      = aws_vpc.main.id

ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [aws_security_group.app_sg.id]
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-rds-sg"
  }
}

