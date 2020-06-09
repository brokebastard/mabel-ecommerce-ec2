## ========================================================================== ##
#  Demo - Mabel eCommerce Application Tier                                     #
## ========================================================================== ##

# Provides: The required Ubuntu 18.04 server image that will be used for the EC2 instances.
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
  owners = ["099720109477"] # Canonical AWS Account
}

# Provides: The subnet needed for the EC2 instances to acquire an IP address and connect to the VPC's network.
# Note: This uses a single subnet to keep the code simple. Otherwise, we need a map of subnets with multiple workstreams.
data "aws_subnet" "this" {
  id = var.aws_subnet
}

# Provides: The VPC id so that we can determine the correct VPC security group in the next data call.
data "aws_security_group" "this" {
  vpc_id = var.aws_vpc
  id     = var.aws_security_group
}

# Provides: Four (4) EC2 instances for the demo to look like a lift-and-shift application.
# Note: var "aws_mabel_app_name" is mapped to app1:controller, app2:payments, app3:lookup_svc, app4:etl by default.
resource "aws_instance" "this" {
  for_each               = var.aws_mabel_app_name
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.this.id
  key_name               = var.aws_key_pair_name
  vpc_security_group_ids = [data.aws_security_group.this.id]
  tags = {
    Name        = "mabel-ec2-${each.value}-${var.aws_region_name}" # Note: ${each.value} is matching each "var.app_name" key name (e.g. "app1", "app2") to the map of application names (e.g. "controller", "payments")
    environment = var.aws_environment_name
    source      = "Terraform"
    demo        = "Mabel eCommerce Demo"
  }
  volume_tags = {
    Name        = "mabel-ebs-${each.value}-root-${var.aws_region_name}"
    environment = var.aws_environment_name
    source      = "Terraform"
    demo        = "Mabel eCommerce Demo"
  }
  lifecycle {
    ignore_changes = [volume_tags] # Note: Each volume name tag includes the purpose for the volume (e.g. "root", "app", and "temp"). Ignoring changes prevents false drift positives.
  }
}

# Provides: An additional EBS volume for each EC2 instance in the demo. Most instance will ultimately have 2 volumes, except for ETL.
resource "aws_ebs_volume" "this" {
  for_each          = aws_instance.this
  availability_zone = data.aws_subnet.this.availability_zone
  size              = 1 # Note: 1 GB is adequate for this demo.
  tags = {
    Name        = "mabel-ebs-${var.aws_mabel_app_name[each.key]}-app-${var.aws_region_name}" # Note: ${var.app_name[each.key]} is matching each generic key name (e.g. "app1") to the map of application names (e.g. "payments")
    environment = var.aws_environment_name
    source      = "Terraform"
    demo        = "Mabel eCommerce Demo"
  }
}

# Provides: The attachment between each new EBS volume and the target EC2 instance.
# Note: Device names must match the pattern "/dev/sd[f-p]" for hvm instances. Do not use sda1 (root).
# Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
resource "aws_volume_attachment" "this" {
  for_each    = aws_ebs_volume.this
  device_name = "/dev/sdh"
  instance_id = aws_instance.this[each.key].id # Note: aws_instance.this[each.key].id is matching each generic key name (e.g. "app1") to the map of instance id values (e.g. i-032785e8a5041c0ef)
  volume_id   = each.value.id
  depends_on  = [aws_instance.this, aws_ebs_volume.this]
}

# Provides: An third EBS volume storing temporary files for the ETL EC2 instance in the demo. This volume will be excluded from protection by Rubrik Polaris.
resource "aws_ebs_volume" "this_temp" {
  availability_zone = data.aws_subnet.this.availability_zone
  size              = 1 # Note: 1 GB is adequate for this demo.
  tags = {
    Name        = "mabel-ebs-${var.aws_mabel_app_name["app4"]}-temp-${var.aws_region_name}"
    environment = var.aws_environment_name
    source      = "Terraform"
    demo        = "Mabel eCommerce Demo"
  }
}

resource "aws_volume_attachment" "this_temp" {
  device_name = "/dev/sdi"
  instance_id = aws_instance.this["app4"].id
  volume_id   = aws_ebs_volume.this_temp.id
  depends_on  = [aws_instance.this, aws_ebs_volume.this_temp]

}
