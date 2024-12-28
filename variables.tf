variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "my-eks-cluster"
}

variable "cluster_version" {
  default = "1.27"
}

variable "vpc_id" {}
variable "private_subnets" {
  type = list(string)
}

variable "project_name" {
  default = "blockchain-search"
}

variable "api_stage" {
  default = "dev"
}

variable "alchemy_api_key" {
  type = string
}
