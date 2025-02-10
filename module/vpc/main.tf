# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "${var.organization_prefix}-vpc"
  }
}

# Data source to fetch availability zones dynamically
data "aws_availability_zones" "available" {}

# Create Public Subnets (dynamically based on the length of var.public_subnets)
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets) > 0 ? min(length(var.public_subnets), length(data.aws_availability_zones.available.names)) : 0

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.organization_prefix}-public-subnet-${count.index + 1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create Private Subnets for App Tier (dynamically for app subnets)
resource "aws_subnet" "app_private_subnets" {
  count = length(var.app_subnets) > 0 ? min(length(var.app_subnets), length(data.aws_availability_zones.available.names)) : 0

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.app_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.organization_prefix}-app-private-subnet-${count.index + 1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create Private Subnets for DB Tier (dynamically for db subnets)
resource "aws_subnet" "db_private_subnets" {
  count = length(var.db_subnets) > 0 ? min(length(var.db_subnets), length(data.aws_availability_zones.available.names)) : 0

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.db_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.organization_prefix}-db-private-subnet-${count.index + 1}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.organization_prefix}-igw"
  }
}

# Create NAT Gateway if required
resource "aws_eip" "nat_eip" {
  count = var.create_nat_gateway ? 1 : 0

  vpc = true
  tags = {
    Name = "${var.organization_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "${var.organization_prefix}-nat"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.organization_prefix}-public-rt"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_association" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route Table for App Tier Private Subnets
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.organization_prefix}-app-rt"
  }
}


resource "aws_route" "app_nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
}

resource "aws_route" "db_nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.db_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
}


resource "aws_route_table_association" "app_association" {
  count = length(var.app_subnets)

  subnet_id      = aws_subnet.app_private_subnets[count.index].id
  route_table_id = aws_route_table.app_route_table.id
}

# Create Route Table for DB Tier Private Subnets
resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.organization_prefix}-db-rt"
  }
}

resource "aws_route_table_association" "db_association" {
  count = length(var.db_subnets)

  subnet_id      = aws_subnet.db_private_subnets[count.index].id
  route_table_id = aws_route_table.db_route_table.id
}

