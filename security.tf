resource "aws_security_group" "Alb-SecurityGroup" {
    name = "Alb-SecurityGroup"
    description = "Allow incoming connections from Internet and RDP"
    vpc_id = "${aws_vpc.Mgmt-VPC.id}"

    ingress { 
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${"0.0.0.0/0"}"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${"0.0.0.0/0"}"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

   tags = {
       
        Name= "Alb-SecurityGroup"
    }
}

#--------------------------------------------------------------------->>

resource "aws_security_group" "MgmtSecurityGroup" {
    name = "MgmtSecurityGroup"
    description = "Allow incoming connections from Internet and RDP"
    vpc_id = "${aws_vpc.Mgmt-VPC.id}"

    ingress { 
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${"0.0.0.0/0"}"]
    }

    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["${"0.0.0.0/0"}"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

   tags = {
       
        Name= "MgmtSecurityGroup"
    }
}

#--------------------------------------------------------------------->>

resource "aws_security_group" "ProdSecurityGroup" {
    name = "ProdSecurityGroup"
    description = "Allow incoming connections from Internet and RDP"
    vpc_id = "${aws_vpc.Prd-VPC.id}"

    ingress { 
        from_port = 80
        to_port = 80
        protocol = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
        security_groups = ["${aws_security_group.Alb-SecurityGroup.id}"]
        #cidr_blocks = ["${aws_security_group.Alb-SecurityGroup.id}"]

    }

    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        #cidr_blocks = ["${aws_security_group.MgmtSecurityGroup.id}"]
        security_groups = ["${aws_security_group.MgmtSecurityGroup.id}"]
        #cidr_blocks = ["0.0.0.0/0"]

    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

   tags = {
       
        Name= "ProdSecurityGroup"
    }
}

