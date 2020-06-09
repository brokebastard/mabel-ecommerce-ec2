## =============================================================================
#  Variable Definitions                                                        #
## =============================================================================
# Authentication
aws_access_key = ""
aws_secret_key = ""

# Location
aws_region = "us-west-2"

# Network
aws_vpc = "vpc-1111111111111111"
aws_subnet = "subnet-1111111111111111"
aws_security_group = "sg-1111111111111111"

# Mabel App
aws_key_pair_name = ""
aws_mabel_app_name = {
    app1 = "controller"
    app2 = "payments"
    app3 = "lookup_svc"
    app4 = "etl"
  }

# Tags
aws_environment_name = "test"
aws_region_name = "usw2"