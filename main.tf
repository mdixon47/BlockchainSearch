terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}




provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = module.eks.cluster_token
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = module.eks.cluster_token
}

# --------------------
# EKS Cluster
# --------------------
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.31.6"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_capacity = var.node_desired_capacity
      max_capacity     = var.node_max_capacity
      min_capacity     = var.node_min_capacity
      instance_type    = var.node_instance_type
      key_name         = var.node_key_name
    }
  }
}

# --------------------
# OpenSearch Helm Chart (Self-Managed on EKS)
# --------------------
resource "helm_release" "opensearch" {
  name       = "opensearch"
  repository = "https://opensearch-project.github.io/helm-charts/"
  chart      = "opensearch"
  namespace  = "opensearch-namespace"

  create_namespace = true

  values = [
    <<-EOF
    clusterName: "opensearch-cluster"
    replicas: 1
    service:
      type: LoadBalancer
    EOF
  ]
}

data "kubernetes_service" "opensearch_svc" {
  metadata {
    name      = "opensearch"
    namespace = "opensearch-namespace"
  }
}

output "opensearch_endpoint" {
  value = data.kubernetes_service.opensearch_svc.status[0].load_balancer_ingress[0].hostname
}

# --------------------
# Lambda Function
# --------------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "fetch_and_index" {
  function_name = "${var.project_name}-fetch-index"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda.zip"

  environment {
    variables = {
      ALCHEMY_API_KEY     = var.alchemy_api_key
      OPENSEARCH_ENDPOINT = data.kubernetes_service.opensearch_svc.status[0].load_balancer_ingress[0].hostname
      INDEX_NAME          = "blockchain-transactions"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# --------------------
# API Gateway
# --------------------
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api"
  description = "API Gateway for blockchain data ingestion"
}

resource "aws_api_gateway_resource" "fetch_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "fetch"
}

resource "aws_api_gateway_method" "fetch_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.fetch_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fetch_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.fetch_resource.id
  http_method             = aws_api_gateway_method.fetch_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.fetch_and_index.invoke_arn
}

output "api_invoke_url" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}/${var.api_stage}/fetch"
}
