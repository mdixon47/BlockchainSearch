# Capstone Project Proposal: Building a Blockchain Transaction Search Engine

## Objective:
Develop a search engine to query blockchain transactions using a cryptocurrency address, transaction date, and currency type. This project will leverage cloud-based and open-source technologies to deliver a scalable, cost-effective solution.

## Project Overview:
The proposed system aims to provide users with a robust search engine to access blockchain transaction data in real-time. The architecture will utilize AWS Elastic Kubernetes Service (EKS) to host OpenSearch (open-source) alongside complementary tools like Kibana for visualization and Logstash for log processing. This approach significantly reduces costs compared to AWS Managed OpenSearch, which can exceed $50,000 annually for a 3-node cluster.

## System Architecture:

### Data Ingestion Layer:
- **Data Sources**: Blockchain transaction data will be ingested using APIs provided by cryptocurrency platforms, formatted as JSON.
- **API Gateway**: AWS API Gateway will serve as the entry point for receiving transaction data.
- **AWS Lambda Functions**: Lambda will act as the middleware for processing API requests:
  - **PUT Requests**: Push raw blockchain data directly to OpenSearch.
  - **GET Requests**: Query OpenSearch to retrieve transaction data for users.

### Data Storage and Indexing:

#### OpenSearch on EKS:
- OpenSearch, an open-source search and analytics engine, will be deployed on AWS EKS clusters to provide cost-effective scalability and high availability. This includes:
  - Customizable node configurations to optimize storage and compute resources.
  - Indexing JSON data for efficient searches by address, date, and currency type.

#### Kibana for Visualization:
- Kibana will enable graphical representations of blockchain data trends and insights.

### Data Flow:
1. Blockchain transaction data is collected through Web APIs in JSON format.
2. Data flows from the API Gateway to OpenSearch via Lambda functions without transformation, ensuring integrity.

### User Interface:
- A lightweight web interface will allow users to input search parameters (crypto address, transaction date, and currency type).
- Results will be retrieved from OpenSearch and displayed in a clean, user-friendly format.

## Technological Considerations:

### Cost Optimization:
- Hosting OpenSearch and its ecosystem (Kibana, Logstash) on EKS reduces dependency on AWS Managed OpenSearch, minimizing annual costs significantly.

### Scalability:
- Kubernetes ensures the architecture can scale horizontally, accommodating increasing transaction data and user demands.

### Security:
- AWS services like API Gateway and Lambda provide robust authentication and encryption, securing data ingress and egress.

### Performance:
- OpenSearch is optimized for high-throughput querying and indexing, supporting large datasets typical of blockchain ecosystems.

## Expected Outcome:
This project will deliver a fully functional, cost-effective blockchain transaction search engine capable of handling real-time queries. It will also provide valuable insights into blockchain transaction data through visualizations, making it a practical tool for users and businesses interested in cryptocurrency analytics.


