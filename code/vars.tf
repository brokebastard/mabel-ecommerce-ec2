## =============================================================================
#  Variables - Authentication                                                  #
## =============================================================================
variable "aws_access_key" {
  type        = string
  description = "Access key authorized for this action"
}

variable "aws_secret_key" {
  type        = string
  description = "Secret key authorized for this action"
}

## =============================================================================
#  Variables - Location                                                        #
## =============================================================================
variable "aws_region" {
  type        = string
  description = "Region to create Mabel resources"
  default     = "us-west-2"
}

## =============================================================================
#  Variables - Network                                                        #
## =============================================================================
variable "aws_vpc" {
  type        = string
  description = "VPC to deploy Mabel instances"
}

variable "aws_subnet" {
  type        = string
  description = "Subnet to deploy Mabel instances"
}

variable "aws_security_group" {
  type        = string
  description = "Security Group to associate with Mabel instances"
}

## =============================================================================
#  Variables - Mabel App                                                       #
## =============================================================================
variable "aws_key_pair_name" {
  type        = string
  description = "Key Pair name to associate with Mabel instances"
}

variable "aws_mabel_app_name" {
  type        = map
  description = "The name used for each unique application in the demo"
  default = {
    app1 = "controller"
    app2 = "payments"
    app3 = "lookup_svc"
    app4 = "etl"
  }
}

## =============================================================================
#  Variables - Tags                                                            #
## =============================================================================
variable "aws_environment_name" {
  type        = string
  description = "Tag for environment tier"
}

variable "aws_region_name" {
  type        = string
  description = "Tag for Region used as a Name suffix"
}
