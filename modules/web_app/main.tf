locals {
  selected_subnet_ids = var.public_subnet ? data.aws_subnets.public.ids : data.aws_subnets.private.ids
}

resource "aws_instance" "web_app" {
  count = var.instance_count

  ami           = "ami-04c913012f8977029"
  instance_type = var.instance_type
  #subnet_id              = data.aws_subnets.public.ids[count.index % length(data.aws_subnets.public.ids)]
  subnet_id              = local.selected_subnet_ids[count.index % length(local.selected_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web_app.id]
  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "webapp-#${count.index}"
  })

  associate_public_ip_address = true
  tags = {
    Name = "${var.name_prefix}-webapp-${count.index}"
  }
}

resource "aws_security_group" "web_app" {
  name_prefix = "${var.name_prefix}-webapp"
  description = "Allow traffic to webapp"
  vpc_id      = data.aws_vpc.selected.id


  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  lifecycle {
    create_before_destroy = true
  }
}

/*
First, see what subnets Terraform actually found:Terraformdata.aws_subnets.public.ids
Expected Output: A list like ["subnet-123", "subnet-456", "subnet-789"].
Step B: Check the LengthSee how many subnets are in that list:Terraformlength(data.aws_subnets.public.ids)
Expected Output: 3 (or however many subnets you have).
Step C: Test the "First" Instance (Index 0)Now, simulate count.index = 0:Terraformdata.aws_subnets.public.ids[0 % length(data.aws_subnets.public.ids)]
Result: It will return the 1st subnet ID in your list.
Step D: Test the "Fourth" Instance (Index 3)
To see the "Loop" (Modulo) in action, 
simulate a 4th instance (Index 3) trying to find a subnet when you only have 3 subnets:Terraformdata.aws_subnets.public.ids[3 % length(data.aws_subnets.public.ids)]
The Math: $3 \div 3 = 1$ with a remainder of 0.Result: 
It returns the 1st subnet ID again! It successfully looped back to the start.3. 
Visualizing the LoopIf you want to see the whole pattern at once, 
you can run a for loop inside the console to see where 5 instances would land:Terraform[for i in range(5) : data.aws_subnets.public.ids[i % length(data.aws_subnets.public.ids)]]
What this shows you:If your subnets are [A, B, C], 
the output will be [A, B, C, A, B]. This proves your logic perfectly balances the servers across the available subnets.
*/


resource "aws_lb_target_group" "web_app" {
  name     = "${var.name_prefix}-webapp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id


  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 3
    interval = 5
  }
}

# ability to register instances/ containers with an ALB/NLB target group
resource "aws_lb_target_group_attachment" "web_app" {
  count = var.instance_count #loop x2
  target_group_arn = aws_lb_target_group.web_app.arn
  target_id        = aws_instance.web_app[count.index].id
  port             = 80
}

# need to attached the listener arn to the listerner rule during creation
resource "aws_lb_listener_rule" "web_app" {
  #listener_arn = var.alb_listener_arn
  listener_arn = data.aws_alb_listener.listener.arn
  priority     = 500


  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app.arn
  }

  condition {
    path_pattern {
      values = ["/myname"]
    }
  }
}



