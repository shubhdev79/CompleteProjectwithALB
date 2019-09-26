
resource "aws_instance" "JumpBox-Server" {
ami = "ami-034e1d78dd9d4a332"
instance_type = "t2.micro"
key_name = var.key_name
subnet_id = "${aws_subnet.Mgmt-Subnet.id}"
vpc_security_group_ids = ["${aws_security_group.MgmtSecurityGroup.id}""]
security_groups = ["MgmtSecurityGroup"]
associate_public_ip_address = "true"

tags = {
Name = "JumpBox-Server"
}
}

#-----------------------------------------------------------

resource "aws_instance" "web_server-IIS-1" {
ami = "ami-034e1d78dd9d4a332"
instance_type = "t2.micro"
key_name = var.key_name
subnet_id = "${aws_subnet.Prd-Subnet-1.id}"
security_groups = ["ProdSecurityGroup"]
associate_public_ip_address = "true"

tags = {
Name = "web_server-IIS-1"
}
}

#-----------------------------------------------------------

resource "aws_instance" "web_server-IIS-2" {
ami = "ami-034e1d78dd9d4a332"
instance_type = "t2.micro"
key_name = var.key_name
subnet_id = "${aws_subnet.Prd-Subnet-2.id}"
security_groups = ["ProdSecurityGroup"]
associate_public_ip_address = "true"

tags = {
Name = "web_server-IIS-2"
}
}