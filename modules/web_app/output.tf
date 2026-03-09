# 1. Output the list of Subnet IDs used by the instances
output "instance_subnet_ids" {
  description = "The IDs of the subnets where the instances were deployed"
  value       = aws_instance.web_app[*].subnet_id
}

# 2. Output the Public IPs (so you can visit the web apps)
output "instance_public_ips" {
  description = "The public IP addresses of the web server instances"
  value       = aws_instance.web_app[*].public_ip
}

# 3. Output a Map of Name to Subnet (for better readability)
output "instance_placement_map" {
  description = "A map showing which instance is in which subnet"
  value = {
    for i in aws_instance.web_app : i.tags["Name"] => i.subnet_id
  }
}

/*
instance_subnet_ids: Uses the Splat Operator ([*]). Since you have count = 2, this creates a simple list like ["subnet-123", "subnet-456"]. This is what you specifically asked to see.
instance_public_ips: This is practically essential. Without this, you won't know which IP addresses to type into your browser to see your index.html.
instance_placement_map: This uses a for loop. It’s the "human-readable" version. Instead of just a list of IDs, it shows you:

prod-webapp-0 -> subnet-123
prod-webapp-1 -> subnet-456

*/


/*
1. The Loop: for i in aws_instance.web_app
aws_instance.web_app: This is your list of 2 instances (because you used count = 2).

i: This is just a temporary nickname (an iterator).

On the first lap of the loop, i represents web_app[0].

On the second lap, i represents web_app[1].

2. The Key: i.tags["Name"]
This looks at the current instance (i) and pulls the value of the tag labeled "Name".

From your main.tf, we know these names are ${var.name_prefix}-webapp-0 and ${var.name_prefix}-webapp-1.

3. The Separator: =>
In Terraform, this symbol means "map to." It separates the Key (the name) from the Value (the subnet).

4. The Value: i.subnet_id
This grabs the actual Subnet ID that Terraform assigned to that specific instance.

What the result looks like
If you had no loop and just used a simple output, you'd get two separate lists that you'd have to manually match up. With this for loop, Terraform gives you a clean, organized dictionary:

Terraform
instance_placement_map = {
  "prod-webapp-0" = "subnet-0a1b2c3d"
  "prod-webapp-1" = "subnet-0x9y8z7w"
}ur
*/