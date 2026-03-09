/*
module "web_app" {
  source = "./modules/web_app"

  name_prefix = "ju"

  instance_type  = "t2.micro"
  instance_count = 2

  vpc_id        = "vpc-0bce6847fdfeea730"
  public_subnet = true
}
*/


module "web_app" {
  source         = "./modules/web_app"
  name_prefix    = "ju"
  instance_type  = "t2.micro"
  instance_count = 2
  vpc_id         = "vpc-0bce6847fdfeea730"
  public_subnet  = false
  #alb_listener_arn = "..."
  alb_name = "osy-alb"
}

