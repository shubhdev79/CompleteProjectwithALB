
resource "aws_vpc" "Mgmt-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Management-VPC"
  }
}

resource "aws_vpc" "Prd-VPC" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Production-VPC"
  }
}

resource "aws_subnet" "Mgmt-Subnet" {
  vpc_id     = "${aws_vpc.Mgmt-VPC.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Mgmt-Public-Subnet-1"
  }
}

resource "aws_subnet" "Prd-Subnet-1" {
  vpc_id     = "${aws_vpc.Prd-VPC.id}"
  cidr_block = "172.16.1.0/24"

  tags = {
    Name = "Prod-Public-Subnet-1"
  }
}

resource "aws_subnet" "Prd-Subnet-2" {
  vpc_id     = "${aws_vpc.Prd-VPC.id}"
  cidr_block = "172.16.2.0/24"

  tags = {
    Name = "Prod-Public-Subnet2"
  }
}

resource "aws_subnet" "Prd-Subnet-3" {
  vpc_id     = "${aws_vpc.Prd-VPC.id}"
  cidr_block = "172.16.3.0/24"

  tags = {
    Name = "Prod-Private-Subnet1"
  }
}

resource "aws_subnet" "Prd-Subnet-4" {
  vpc_id     = "${aws_vpc.Prd-VPC.id}"
  cidr_block = "172.16.4.0/24"

  tags = {
    Name = "Prod-Private-Subnet2"
  }
}

#Creating Internet Gateway for Management
resource "aws_internet_gateway" "Mgmt-IGW" {
  vpc_id = "${aws_vpc.Mgmt-VPC.id}"

  tags = {
    Name = "Mgmt-IGW"
  }
}

#Creating Internet Gateway for Production
resource "aws_internet_gateway" "Prod-IGW" {
  vpc_id = "${aws_vpc.Prd-VPC.id}"

  tags = {
    Name = "Prod-IGW"
  }
}

# Creation of Route Tables -----------------------------------------------------

resource "aws_route_table" "Mgmt-PublicRouteTable" {
  vpc_id = "${aws_vpc.Mgmt-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Mgmt-IGW.id}"
  }

 route {
    cidr_block = "172.0.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peermgtprd.id}"
  }


  tags = {
    Name = "Mgmt-PublicRouteTable"
  }
}

#---------------------------------------------------------------

resource "aws_route_table" "Prod-PublicRouteTable" {
  vpc_id = "${aws_vpc.Prd-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Prod-IGW.id}"
  }

  route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peermgtprd.id}"
  }

  tags = {
    Name = "Prod-PublicRouteTable"
  }
}

#---------------------------------------------------------------

resource "aws_route_table" "Prod-PrivateRouteTable" {
  vpc_id = "${aws_vpc.Prd-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Prod-IGW.id}"
  }
  
  route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peermgtprd.id}"
  
  }
  tags = {
    Name = "Prod-PrivateRouteTable"
  }
}


	#Route Table Association  ------------------------
resource "aws_route_table_association" "Mgmt-RouteTableAssociation" {
  subnet_id      = "${aws_subnet.Mgmt-Subnet.id}"
  route_table_id = "${aws_route_table.Mgmt-PublicRouteTable.id}"
}


resource "aws_route_table_association" "Prod-RouteTableAssociation-1" {
  subnet_id      = "${aws_subnet.Prd-Subnet-1.id}"
  route_table_id = "${aws_route_table.Prod-PublicRouteTable.id}"
}

resource "aws_route_table_association" "Prod-RouteTableAssociatio-2" {
  subnet_id      = "${aws_subnet.Prd-Subnet-2.id}"
  route_table_id = "${aws_route_table.Prod-PublicRouteTable.id}"
}


resource "aws_route_table_association" "Pvt-RouteTableAssociation-1" {
  subnet_id      = "${aws_subnet.Prd-Subnet-3.id}"
  route_table_id = "${aws_route_table.Prod-PrivateRouteTable.id}"
}

resource "aws_route_table_association" "Pvt-RouteTableAssociation-2" {
  subnet_id      = "${aws_subnet.Prd-Subnet-4.id}"
  route_table_id = "${aws_route_table.Prod-PrivateRouteTable.id}"
}

# VPC PEERING CONNECTION --
data "aws_caller_identity" "peer" {
  provider = "aws"
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peermgtprd" {
  vpc_id        = "${aws_vpc.Mgmt-VPC.id}"
  peer_vpc_id   = "${aws_vpc.Prd-VPC.id}"
  peer_owner_id = "${data.aws_caller_identity.peer.account_id}"
  peer_region   = "us-east-1"
  auto_accept   = false

  tags = {
           Name = "peermgtprd"
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = "aws"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peermgtprd.id}"
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}
