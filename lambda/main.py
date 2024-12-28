import os
import json
import requests
from requests.auth import HTTPBasicAuth

def lambda_handler(event, context):
    alchemy_api_key = os.environ.get("ALCHEMY_API_KEY")
    opensearch_endpoint = os.environ.get("OPENSEARCH_ENDPOINT")
    index_name = os.environ.get("INDEX_NAME", "blockchain-transactions")

    # Example: Fetch blockchain data from Alchemy
    # Update the URL and endpoint as per Alchemy’s API documentation
    alchemy_url = f"https://eth-mainnet.g.alchemy.com/v2/{alchemy_api_key}/getTransactions"
    response = requests.get(alchemy_url)
    data = response.json()

    # Prepare bulk indexing to OpenSearch
    documents = data.get("transactions", [])
    bulk_data = ""
    for doc in documents:
        index_action = json.dumps({"index": {"_index": index_name}})
        doc_json = json.dumps(doc)
        bulk_data += f"{index_action}\n{doc_json}\n"

    # Send to OpenSearch
    headers = {"Content-Type": "application/x-ndjson"}
    bulk_url = f"https://{opensearch_endpoint}/_bulk"
    opensearch_response = requests.post(bulk_url, headers=headers, data=bulk_data, auth=HTTPBasicAuth("admin", "admin"))

    if opensearch_response.status_code == 200:
        return {
            "statusCode": 200,
            "body": "Data successfully ingested into OpenSearch"
        }
    else:
        return {
            "statusCode": opensearch_response.status_code,
            "body": opensearch_response.text
        }
