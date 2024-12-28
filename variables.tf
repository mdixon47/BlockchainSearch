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

variable "node_desired_capacity" {
  description = "Desired number of nodes in the EKS managed node group"
  type        = number
  default     = 2
}

variable "node_max_capacity" {
  description = "Maximum number of nodes in the EKS managed node group"
  type        = number
  default     = 4
}

variable "node_min_capacity" {
  description = "Minimum number of nodes in the EKS managed node group"
  type        = number
  default     = 1
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS managed node group"
  type        = string
  default     = "m5.large"
}

variable "node_key_name" {
  description = "Key pair name for the EKS managed node group"
  type        = string
  default     = ""
}
