## =============================================================================
#  Variables - Authentication                                                  #
## =============================================================================
variable "aws_region" {
  type        = string
  description = "Default region for root module"
  default     = "us-west-2"
}

## =============================================================================
#  Variables - Naming                                                          #
## =============================================================================
variable "aws_root_name" {
  type        = string
  description = "Root name prefix to use in resource name tags"
  default     = "octo"
}

variable "aws_region_name" {
  type        = string
  description = "Region name suffix to use in resource name tags"
  default     = "usw2"
}

variable "aws_environment_name" {
  type        = string
  description = "Environment name to use in resource name tags"
  default     = "prod"
}

variable "aws_source_name" {
  type        = string
  description = "Source name of the tool that constructed the resource to use in resource name tags"
  default     = "terraform"
}

variable "app_root_name" {
  type        = string
  description = "Root application name prefix to use in resource name tags"
  default     = "mabel"
}

variable "app_name" {
  type        = map
  description = "The name used for each unique application in the demo"
  default = {
    app1 = "controller"
    app2 = "payments"
    app3 = "lookup_svc"
    app4 = "etl"
  }
}

variable "demo_name" {
  type        = string
  description = "The name of the demo to use as a tag for easy resource identification"
  default     = "mabel-ecommerce-ec2-demo"
}
