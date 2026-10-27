# ==========================================
# 1. CREATE THREE VPCs
# ==========================================

resource "aws_vpc" "mumbai" {
  provider             = aws.mumbai
  cidr_block           = var.mumbai_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "Mumbai-VPC"
  })
}

resource "aws_vpc" "virginia" {
  provider             = aws.virginia
  cidr_block           = var.virginia_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "Virginia-VPC"
  })
}

resource "aws_vpc" "canada" {
  provider             = aws.canada
  cidr_block           = var.canada_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "Canada-VPC"
  })
}

# ==========================================
# 2. CREATE THREE SUBNETS
# ==========================================

resource "aws_subnet" "mumbai" {
  provider          = aws.mumbai
  vpc_id            = aws_vpc.mumbai.id
  cidr_block        = var.mumbai_subnet_cidr
  availability_zone = "ap-south-1a"

  tags = merge(local.common_tags, {
    Name = "Mumbai-Subnet"
  })
}

resource "aws_subnet" "virginia" {
  provider          = aws.virginia
  vpc_id            = aws_vpc.virginia.id
  cidr_block        = var.virginia_subnet_cidr
  availability_zone = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = "Virginia-Subnet"
  })
}

resource "aws_subnet" "canada" {
  provider          = aws.canada
  vpc_id            = aws_vpc.canada.id
  cidr_block        = var.canada_subnet_cidr
  availability_zone = "ca-central-1a"

  tags = merge(local.common_tags, {
    Name = "Canada-Subnet"
  })
}

# ==========================================
# 3. CREATE THREE ROUTE TABLES
# ==========================================

resource "aws_route_table" "mumbai" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai.id

  tags = merge(local.common_tags, {
    Name = "Mumbai-Route-Table"
  })
}

resource "aws_route_table" "virginia" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia.id

  tags = merge(local.common_tags, {
    Name = "Virginia-Route-Table"
  })
}

resource "aws_route_table" "canada" {
  provider = aws.canada
  vpc_id   = aws_vpc.canada.id

  tags = merge(local.common_tags, {
    Name = "Canada-Route-Table"
  })
}

# ==========================================
# 4. SUBNET ROUTE TABLE ASSOCIATIONS
# ==========================================

resource "aws_route_table_association" "mumbai" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.mumbai.id
  route_table_id = aws_route_table.mumbai.id
}

resource "aws_route_table_association" "virginia" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.virginia.id
  route_table_id = aws_route_table.virginia.id
}

resource "aws_route_table_association" "canada" {
  provider       = aws.canada
  subnet_id      = aws_subnet.canada.id
  route_table_id = aws_route_table.canada.id
} 


# ==========================================
# 5. MUMBAI TO VIRGINIA PEERING
# ==========================================

resource "aws_vpc_peering_connection" "mumbai_virginia" {
  provider    = aws.mumbai
  vpc_id      = aws_vpc.mumbai.id
  peer_vpc_id = aws_vpc.virginia.id
  peer_region = "us-east-1"
  auto_accept = false

  tags = merge(local.common_tags, {
    Name = "Mumbai-Virginia-Peering"
  })
}

resource "aws_vpc_peering_connection_accepter" "virginia" {
  provider                  = aws.virginia
  vpc_peering_connection_id = aws_vpc_peering_connection.mumbai_virginia.id
  auto_accept               = true

  tags = merge(local.common_tags, {
    Name = "Mumbai-Virginia-Peering"
  })
}

# ==========================================
# 6. MUMBAI TO CANADA PEERING
# ==========================================

resource "aws_vpc_peering_connection" "mumbai_canada" {
  provider    = aws.mumbai
  vpc_id      = aws_vpc.mumbai.id
  peer_vpc_id = aws_vpc.canada.id
  peer_region = "ca-central-1"
  auto_accept = false

  tags = merge(local.common_tags, {
    Name = "Mumbai-Canada-Peering"
  })
}

resource "aws_vpc_peering_connection_accepter" "canada" {
  provider                  = aws.canada
  vpc_peering_connection_id = aws_vpc_peering_connection.mumbai_canada.id
  auto_accept               = true

  tags = merge(local.common_tags, {
    Name = "Mumbai-Canada-Peering"
  })
}

# ==========================================
# 7. VIRGINIA TO CANADA PEERING
# ==========================================

resource "aws_vpc_peering_connection" "virginia_canada" {
  provider    = aws.virginia
  vpc_id      = aws_vpc.virginia.id
  peer_vpc_id = aws_vpc.canada.id
  peer_region = "ca-central-1"
  auto_accept = false

  tags = merge(local.common_tags, {
    Name = "Virginia-Canada-Peering"
  })
}

resource "aws_vpc_peering_connection_accepter" "canada_virginia" {
  provider                  = aws.canada
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_canada.id
  auto_accept               = true

  tags = merge(local.common_tags, {
    Name = "Virginia-Canada-Peering"
  })
}
# ==========================================
# 8. MUMBAI TO VIRGINIA ROUTE
# ==========================================

resource "aws_route" "mumbai_to_virginia" {
  provider                  = aws.mumbai
  route_table_id            = aws_route_table.mumbai.id
  destination_cidr_block    = var.virginia_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mumbai_virginia.id

  depends_on = [
    aws_vpc_peering_connection_accepter.virginia
  ]
}

# VIRGINIA TO MUMBAI
resource "aws_route" "virginia_to_mumbai" {
  provider                  = aws.virginia
  route_table_id            = aws_route_table.virginia.id
  destination_cidr_block    = var.mumbai_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mumbai_virginia.id

  depends_on = [
    aws_vpc_peering_connection_accepter.virginia
  ]
}

# ==========================================
# 9. MUMBAI TO CANADA ROUTE
# ==========================================

resource "aws_route" "mumbai_to_canada" {
  provider                  = aws.mumbai
  route_table_id            = aws_route_table.mumbai.id
  destination_cidr_block    = var.canada_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mumbai_canada.id

  depends_on = [
    aws_vpc_peering_connection_accepter.canada
  ]
}

# CANADA TO MUMBAI
resource "aws_route" "canada_to_mumbai" {
  provider                  = aws.canada
  route_table_id            = aws_route_table.canada.id
  destination_cidr_block    = var.mumbai_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mumbai_canada.id

  depends_on = [
    aws_vpc_peering_connection_accepter.canada
  ]
}

# ==========================================
# 10. VIRGINIA TO CANADA ROUTE
# ==========================================

resource "aws_route" "virginia_to_canada" {
  provider                  = aws.virginia
  route_table_id            = aws_route_table.virginia.id
  destination_cidr_block    = var.canada_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_canada.id

  depends_on = [
    aws_vpc_peering_connection_accepter.canada_virginia
  ]
}

# CANADA TO VIRGINIA
resource "aws_route" "canada_to_virginia" {
  provider                  = aws.canada
  route_table_id            = aws_route_table.canada.id
  destination_cidr_block    = var.virginia_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_canada.id

  depends_on = [
    aws_vpc_peering_connection_accepter.canada_virginia
  ]
}