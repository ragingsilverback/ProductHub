import json
from elasticsearch import Elasticsearch

# Initialize ElasticSearch client
es = Elasticsearch(["http://localhost:9200"])

# Index name
INDEX_NAME = "product_catalog"

# Load sample data
with open("sample_data.json", "r") as file:
    data = json.load(file)

# Prepare bulk upload data
bulk_data = ""
for record in data:
    action = {"index": {"_index": INDEX_NAME}}
    bulk_data += json.dumps(action) + "\n" + json.dumps(record) + "\n"

# Upload data in bulk
response = es.bulk(body=bulk_data)
if response.get("errors"):
    print("Some errors occurred during bulk upload:")
    print(response)
else:
    print("Bulk upload completed successfully.")