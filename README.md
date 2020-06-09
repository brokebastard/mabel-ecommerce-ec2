# README - Using Terraform to Provision Mabel eCommerce in AWS

================================================================================

## Mabel eCommerce in AWS

Terraform code sample for Mabel eCommerce resource configuration
_Use at your own risk._

## :white_check_mark: Prerequisites

There are a few services you'll need in order to get this project off the ground:

* AWS Account with permissions to create resources
* Rubrik Polaris SaaS Subscription
* Terraform

## :blue_book: How to Use This Project

Ensure the following resources are created in AWS:

1. VPC in your desired region. Oregon (us-west-2) is selected by default.
1. A subnet with 4 or more available private IP addresses in your VPC.
1. A security group to assign to the Mabel eCommerce EC2 instances.
1. A Key Pair to assign to the Mabel eCommerce EC2 instances for console access.

Gather the required `id` or `name` values for each of these resources. Supply the values into the `terraform.tfvars` file along with an AWS access key and secret key with permissions to create and delete resources.

## :pushpin: License

* [MIT License](LICENSE)
