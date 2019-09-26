# This is application load balancer script 

resource "aws_alb" "LB4-WebIIS" {
  name               = "LB4-WebIIS"
  internal           = false
  load_balancer_type = "application"  # Application load blancer
  #security_groups    = ["${aws_security_group.Alb-SecurityGroup.id}"]  #Application load  balancer securiy group specified here.
  
  #subnets           = ["${aws_subnet.*.id}"] # Both public subnet details are here where ALB going to reside.
  subnets            = ["${aws_subnet.Prd-Subnet-1.id}","${aws_subnet.Prd-Subnet-2.id}"]  #==> ALB need two subnets in different AZ
  
  #enable_deletion_protection = true  # If this value is true while destroying with terraform it wont delete.
  enable_deletion_protection = false

-----------------------------------------------
  #access_logs {
   # bucket  = "${aws_s3_bucket.tfalbksrlogs.bucket}" # S3 bucket to store Appliation laod balalncer logs.
    #prefix  = "LB4-WebIIS-lb"
    #enabled = true
  #}
-----------------------------------------------

  tags = {
    Environment = "LB4-WebIIS"
  }
}

# Create a new target group for the application load balancer.
resource "aws_alb_target_group" "Alb-group" {
  name     = "terraform-alb-IISWeb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.Prd-VPC.id}"

  stickiness {
    type = "lb_cookie"
  }

  # Alter the destination of the health check to be the login page.
  #health_check {
   
    #path = "/login"
              #path = "/index.html"
    #port = 80
  #}
}

# Assignment of the EC2 instances to the target group
resource "aws_alb_target_group_attachment" "alb_backend-01_http" {
  target_group_arn = "${aws_alb_target_group.Alb-group.arn}"
  target_id        = "${aws_instance.web_server-IIS-1.id}"
  port             = 80
}
resource "aws_alb_target_group_attachment" "alb_backend-02_http" {
  target_group_arn = "${aws_alb_target_group.Alb-group.arn}"
  target_id        = "${aws_instance.web_server-IIS-2.id}"
  port             = 80
}

# Create a new application load balancer listener for HTTP.
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.LB4-WebIIS.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.Alb-group.arn}"
    type             = "forward"
  }
}

# Create a new application load balancer listener for HTTPS.
#resource "aws_alb_listener" "listener_https" {
 # load_balancer_arn = "${aws_alb.LB4-WebIIS.arn}"
  #port              = "443"
 # protocol          = "HTTPS"
  #ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  #certificate_arn   = #"arn:aws:acm:us-east-2:940881489336:certificate/390ea786-cf07-4fc2-a11f-939891558acc"
  #certificate_arn   = "${var.certificate_arn}"
  
  #default_action {
    #target_group_arn = "${aws_alb_target_group.Alb-group.arn}"
    #type             = "forward"
  #}
#}