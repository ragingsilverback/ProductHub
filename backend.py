from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from typing import List, Optional
from elasticsearch import Elasticsearch
from fastapi.middleware.cors import CORSMiddleware
# Initialize FastAPI app and ElasticSearch client
app = FastAPI()
origins = ["http://localhost:51811"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # Allow specific frontend URL
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)
es = Elasticsearch("http://localhost:9200")
INDEX_NAME = "product_catalog"

# Request models
class SearchFilters(BaseModel):
    store_id: str
    category: Optional[str] = None
    price_range: Optional[dict] = None
    page: Optional[int] = 1
    size: Optional[int] = 10

# Fetch all stores
@app.get("/stores")
async def get_all_stores():
    try:
 
        query = {
        "_source": ["sku", "stores.store_id"],
        "size": 1, 
        "query": {
            "match_all": {}  
        },
        "sort": [
            { "_id": "asc" }  
        ]
        }
        response = es.search(index=INDEX_NAME, body=query)
        store_ids = []
        if response["hits"]["hits"]:
            product = response["hits"]["hits"][0]["_source"]  # First product
            sku = product.get("sku", "Unknown SKU")  # Get SKU
            store_ids = [store["store_id"] for store in product.get("stores", [])]  # Extract store IDs

            print(f"SKU: {sku}")
            print(f"Stores: {store_ids}")
        else:
            print("No products found!")
        return store_ids
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching stores: {e}")

# Fetch products by store ID
@app.get("/products/{store_id}")
async def get_products(store_id: str, page: int = 1, size: int = 10):
    try:
        query = {
            "from": (page - 1) * size,
            "size": size,
            "query": {
                "nested": {
                    "path": "stores",
                    "query": {
                        "bool": {
                            "must": [
                                {"match": {"stores.store_id": store_id}},
                                {"match": {"stores.availability": True}},
                            ]
                        }
                    },
                    "inner_hits": {
                        "size": 1,  # Retrieve only the matching store details
                        "_source": {
                            "includes": ["stores.store_id", "stores.availability", "stores.price"]
                        }
                    }
                }
            }
        }
        response = es.search(index=INDEX_NAME, body=query)
        hits =  response["hits"]["hits"]
        transformed_hits = [
            {
                "sku": hit["_source"]["sku"],
                "name": hit["_source"]["name"],
                "category": hit["_source"]["category"],
                "description": hit["_source"]["description"],
                "store": hit["inner_hits"]["stores"]["hits"]["hits"][0]["_source"]
            }
            for hit in hits
        ]
        return transformed_hits
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching products: {e}")

# Search products with filters
@app.post("/products/search")
async def search_products(filters: SearchFilters):
    try:
        must_clauses = []

        if filters.category:
            must_clauses.append({"term": {"category": filters.category}})

        nested_must_clauses = [
            {"match": {"stores.store_id": filters.store_id}},
            {"match": {"stores.availability": True}},
        ]

        if filters.price_range and "min" in filters.price_range and "max" in filters.price_range:
            nested_must_clauses.append({
                "range": {
                    "stores.price": {
                        "gte": filters.price_range.get("min"),
                        "lte": filters.price_range.get("max")
                    }
                }
            })

        query = {
            "from": (filters.page - 1) * filters.size,
            "size": filters.size,
            "query": {
                "bool":{
                    "must" : must_clauses,
                    "filter" : [
                        {
                            "nested": {
                                "path": "stores",
                                "query": {
                                    "bool": {"must": nested_must_clauses}
                                },
                                "inner_hits": {
                                    "size": 1,
                                    "_source": {
                                        "includes": ["stores.store_id", "stores.availability", "stores.price"]
                                    }
                                }
                            }
                        }
                    ]    
                }    
            }
        }
        response = es.search(index=INDEX_NAME, body=query)
        hits = response["hits"]["hits"]
        return [
            {
                "sku": hit["_source"]["sku"],
                "name": hit["_source"]["name"],
                "category": hit["_source"]["category"],
                "description": hit["_source"]["description"],
                "store": hit["inner_hits"]["stores"]["hits"]["hits"][0]["_source"]
            }
            for hit in hits
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error searching products: {e}")

# Fetch product details by SKU and store ID
@app.get("/products/{store_id}/{sku}")
async def get_product_details(store_id: str, sku: str):
    try:
        query = {
            "query": {
                "bool": {
                    "must": [
                        {"term": {"sku": sku}},
                        {
                            "nested": {
                                "path": "stores",
                                "query": {
                                    "bool": {
                                        "must": [{"match": {"stores.store_id": store_id}}]
                                    }
                                },
                                "inner_hits": {
                                    "size": 1,
                                    "_source": {
                                        "includes": ["stores.store_id", "stores.availability", "stores.price"]
                                    }
                                }
                            }
                        }
                    ]
                }
            }
        }
        response = es.search(index=INDEX_NAME, body=query)
        if response["hits"]["hits"]:
            product = response["hits"]["hits"][0]
            store_data = product["inner_hits"]["stores"]["hits"]["hits"][0]["_source"]
            return {
                "sku": product["_source"]["sku"],
                "name": product["_source"]["name"],
                "category": product["_source"]["category"],
                "description": product["_source"]["description"],
                "store": store_data
            }
        else:
            raise HTTPException(status_code=404, detail="Product not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching product details: {e}")