## ========================================================================== ##
#  Demo - Mabel eCommerce Application Tier                                     #
## ========================================================================== ##

# Provides: The required Ubuntu 18.04 server image that will be used for the EC2 instances
# Modifications: Do not modify!
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Provides: The subnet needed for the EC2 instances to acquire an IP address and connect to the VPC's network
# Note: This uses a single subnet to keep the code simple. Otherwise, we need a map of subnets with multiple workstreams.
# Modifications: Pick any other subnet desired, but do not select more than one.
data "aws_subnet" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.aws_root_name}-vpc-${var.aws_environment_name}-private-01-${var.aws_region_name}"]
  }
}

# Provides: The VPC id so that we can determine the correct VPC security group in the next data call
# Modifications: Change ["${var.aws_root_name}-vpc-dev-${var.aws_region_name}"] to match your VPC naming format
# Modifications: Change ["${var.aws_root_name}-sg-open-${var.aws_region_name}"] to match your Security Group naming format
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.aws_root_name}-vpc-prod-${var.aws_region_name}"]
  }
}
data "aws_security_group" "this" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = ["${var.aws_root_name}-sg-open-${var.aws_region_name}"]
  }
}

# Provides: Four (4) EC2 instances for the demo to look like a lift-and-shift application.
# Note: var "app_name" is mapped to app1:controller, app2:payments, app3:lookup_svc, app4:etl
# Modifications: Change the "app_name" var map to whatever names you desire by editing vars.tf, terraform.tfvars, or in-line var.
resource "aws_instance" "this" {
  for_each               = var.app_name
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.this.id
  key_name               = "${var.aws_root_name}-kp-${var.aws_region_name}"
  vpc_security_group_ids = [data.aws_security_group.this.id]
  tags = {
    Name        = "${var.app_root_name}-ec2-${each.value}-${var.aws_region_name}" # Note: ${each.value} is matching each "var.app_name" key name (e.g. "app1", "app2") to the map of application names (e.g. "controller", "payments")
    Environment = var.aws_environment_name
    Source      = var.aws_source_name
    Demo        = var.demo_name
  }
  volume_tags = {
    Name        = "${var.app_root_name}-ebs-${each.value}-root-${var.aws_region_name}"
    Environment = var.aws_environment_name
    Source      = var.aws_source_name
    Demo        = var.demo_name
  }
  lifecycle {
    ignore_changes = [volume_tags] # Note: Each volume name tag includes the purpose for the volume (e.g. "root", "app", and "temp"). Ignoring changes prevents false drift positives.
  }
}

# Provides: An additional EBS volume for each EC2 instance in the demo. Most instance will ultimately have 2 volumes, except for ETL.
# Modifications: Do not modify!
resource "aws_ebs_volume" "this" {
  for_each          = aws_instance.this
  availability_zone = data.aws_subnet.this.availability_zone
  size              = 1 # Note: 1 GB is adequate for this demo.
  tags = {
    Name        = "${var.app_root_name}-ebs-${var.app_name[each.key]}-app-${var.aws_region_name}" # Note: ${var.app_name[each.key]} is matching each generic key name (e.g. "app1") to the map of application names (e.g. "payments")
    Environment = var.aws_environment_name
    Source      = var.aws_source_name
    Demo        = var.demo_name
  }
}

# Provides: The attachment between each new EBS volume and the target EC2 instance.
# Note: Device names must match the pattern "/dev/sd[f-p]" for hvm instances. Do not use sda1 (root).
# Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
# Modifications: Do not modify!
resource "aws_volume_attachment" "this" {
  for_each    = aws_ebs_volume.this
  device_name = "/dev/sdh"
  instance_id = aws_instance.this[each.key].id # Note: aws_instance.this[each.key].id is matching each generic key name (e.g. "app1") to the map of instance id values (e.g. i-032785e8a5041c0ef)
  volume_id   = each.value.id
  depends_on  = [aws_instance.this, aws_ebs_volume.this]
}

# Provides: An third EBS volume storing temporary files for the ETL EC2 instance in the demo. This volume will be excluded from protection by Rubrik Polaris.
# Modifications: Do not modify!
resource "aws_ebs_volume" "this_temp" {
  availability_zone = data.aws_subnet.this.availability_zone
  size              = 1 # Note: 1 GB is adequate for this demo.
  tags = {
    Name        = "${var.app_root_name}-ebs-${var.app_name["app4"]}-temp-${var.aws_region_name}"
    Environment = var.aws_environment_name
    Source      = var.aws_source_name
    Demo        = var.demo_name
  }
}

resource "aws_volume_attachment" "this_temp" {
  device_name = "/dev/sdi"
  instance_id = aws_instance.this["app4"].id
  volume_id   = aws_ebs_volume.this_temp.id
  depends_on  = [aws_instance.this, aws_ebs_volume.this_temp]

}