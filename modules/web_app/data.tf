data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id" # It only looks for subnets located inside the VPC you identified above. 
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"   # This is the "label" filter.
    values = ["*public*"] # looks for subnets where the Name tag contains the word "public".
  }
}


data "aws_subnets" "private" {
  filter {
    name   = "vpc-id" # It only looks for subnets located inside the VPC you identified above. 
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"    # This is the "label" filter.
    values = ["*private*"] # looks for subnets where the Name tag contains the word "private".
  }
}

/*

1. data "aws_vpc" "selected"
Think of this as a search query for a specific virtual network.

data: Tells Terraform this is a read-only fetch, not a "create" command.

"aws_vpc": The type of resource you are looking for.

"selected": This is just a nickname (local name) you are giving this search result 
so you can reference it later as data.aws_vpc.selected.cidr_block, for example.

id = var.vpc_id: This is the search criteria. It says: "Go find the VPC that matches the ID I provided in my variables."

2. data "aws_subnets" "public"
This is a more complex "filter" query. It’s looking for a list of subnets that meet specific requirements.

Filter 1 (vpc-id): It only looks for subnets located inside the VPC you identified above. 
This prevents it from grabbing subnets from other projects or regions.

Filter 2 (tag:Name): This is the "label" filter.

It looks for subnets where the Name tag contains the word "public".

The asterisks (*public*) are wildcards. It will match names like my-public-subnet, public-1a, or PROD-PUBLIC-NET.

Why is this useful?
Imagine you are writing a script to launch a Web Server (EC2 instance).
 You don't want to hardcode the Subnet ID because it might change.

By using these data sources, your script becomes dynamic:

It finds the VPC.

It finds all the "public" subnets in that VPC automatically.

You can then tell your EC2 instance: "Just launch yourself in the first public subnet you found in that list."

How to use the results
Once Terraform runs these queries, you can access the information like this:

data.aws_vpc.selected.arn (The Amazon Resource Name of the VPC)

data.aws_subnets.public.ids (A list of all the subnet IDs that matched your "public" filter)

Quick Tip: If Terraform can't find a match for these (e.g., 
if no subnet has "public" in its name), the plan will fail with an error. 
It’s a great way to ensure your environment is set up correctly before trying to deploy.
*/

# the value will be pump in from the root/main.tf 
# similar as of var.vpc_id
data "aws_lb" "shared_alb" {
  name = var.alb_name
}

# this will give you the alb listener arn
data "aws_alb_listener" "listener" {
  load_balancer_arn = data.aws_lb.shared_alb.arn
  port    = 80
}