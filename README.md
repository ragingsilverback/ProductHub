# ProductHub
Full Stack App Solution for a Supermarket Chain leveraging Elasticsearch with Flutter Frontend and FastAPI Backend.

# **Project Documentation**

## **1. Design Decisions**

### **Data Model**
- **SKU (Stock Keeping Unit)**:
  - Unique identifier for each product.
  - Stored as a `keyword` in ElasticSearch for fast lookups.

- **Product Data**:
  - Includes `sku`, `name`, `category`, and `description`.
  - `category` is stored as a `keyword` to enable efficient filtering.

- **Store-Specific Data**:
  - Modeled as a nested object `stores` containing:
    - `store_id` (keyword): Unique identifier for each store.
    - `availability` (boolean): Indicates if the product is available in the store.
    - `price` (float): Price of the product in the store.
  - Stored as a nested field in ElasticSearch for advanced queries.

### **Indexing Strategy**
- **Index Name**: `product_catalog`
- **Mappings**:
  - `sku`: `keyword` for exact matching.
  - `name` and `description`: `text` for full-text search with the `standard` analyzer.
  - `stores`: `nested` type to allow querying store-specific details (e.g., price, availability).
- **Pagination**:
  - ElasticSearch uses the `from` and `size` parameters to support efficient pagination.

### **ElasticSearch Schema**
Here is the schema for the `product_catalog` index:
```json
{
  "mappings": {
    "properties": {
      "sku": {
        "type": "keyword"
      },
      "name": {
        "type": "text",
        "analyzer": "standard"
      },
      "category": {
        "type": "keyword"
      },
      "description": {
        "type": "text",
        "analyzer": "standard"
      },
      "stores": {
        "type": "nested",
        "properties": {
          "store_id": {
            "type": "keyword"
          },
          "availability": {
            "type": "boolean"
          },
          "price": {
            "type": "float"
          }
        }
      }
    }
  }
}
```

### **Backend Framework**
- **Framework**: FastAPI (Python)
  - Modern, asynchronous, and lightweight framework with built-in OpenAPI documentation.
- **Database**: ElasticSearch
  - Optimized for full-text search and handling nested data.

---

## **2. API Endpoints and Usage**

### **Base URL**
- `http://127.0.0.1:8000`

### **Endpoints**

#### **1. Get Products by Store**
- **Endpoint**: `GET /products/{store_id}`
- **Description**: Fetches all products available in the specified store.
- **Query Parameters**:
  - `page` (optional): Page number (default: 1).
  - `size` (optional): Number of products per page (default: 10).
- **Response Example**:
  ```json
  [
    {
      "sku": "SKU00001",
      "name": "Monitor",
      "category": "electronics",
      "description": "A high-quality monitor.",
      "store": {
        "store_id": "store1",
        "availability": true,
        "price": 299.99
      }
    }
  ]
  ```

#### **2. Search Products**
- **Endpoint**: `POST /products/search`
- **Description**: Searches for products in a store with optional filters.
- **Request Body**:
  ```json
  {
    "store_id": "store1",
    "category": "electronics",
    "price_range": {"min": 100, "max": 500},
    "page": 1,
    "size": 10
  }
  ```
- **Response Example**:
  ```json
  [
    {
      "sku": "SKU00002",
      "name": "Tablet",
      "category": "electronics",
      "description": "A high-quality tablet.",
      "store": {
        "store_id": "store1",
        "availability": true,
        "price": 450.00
      }
    }
  ]
  ```

#### **3. Get Product Details**
- **Endpoint**: `GET /products/{store_id}/{sku}`
- **Description**: Fetches detailed information about a specific product in a store.
- **Response Example**:
  ```json
  {
    "sku": "SKU00003",
    "name": "Smartphone",
    "category": "electronics",
    "description": "A high-quality smartphone.",
    "store": {
      "store_id": "store1",
      "availability": true,
      "price": 799.99
    }
  }
  ```

---

## **3. Instructions to Set Up and Run the Project**

### **Prerequisites**
- **Backend**:
  - Python 3.10 or later
  - ElasticSearch 8.x
- **Frontend**:
  - Flutter 3.x
  - CocoaPods (for macOS development)

### **Backend Setup**
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Start ElasticSearch**:
   - Ensure ElasticSearch is running on `http://localhost:9200`.

4. **Run the Backend**:
   ```bash
   uvicorn backend:app --reload
   ```

5. **Access API Documentation**:
   - Visit `http://127.0.0.1:8000/docs` for OpenAPI documentation.

### **ElasticSearch Setup and Bulk Data Upload**
1. **Create the Index**:
   Use the following command to create the `product_catalog` index in ElasticSearch:
   ```bash
   curl -X PUT "http://localhost:9200/product_catalog" -H 'Content-Type: application/json' -d'{
     "mappings": {
       "properties": {
         "sku": { "type": "keyword" },
         "name": { "type": "text", "analyzer": "standard" },
         "category": { "type": "keyword" },
         "description": { "type": "text", "analyzer": "standard" },
         "stores": {
           "type": "nested",
           "properties": {
             "store_id": { "type": "keyword" },
             "availability": { "type": "boolean" },
             "price": { "type": "float" }
           }
         }
       }
     }
   }'
   ```

2. **Prepare Sample Data**:
   The JSON file (`sample_data.json`) is already generated using:
   ```bash
   python generate_sample_data.py
   ```

3. **Use the Bulk Upload Script**:
   Use the following command to upload the data:
   ```bash
   python upload_to_elasticsearch.py
   ```

4. **Verify Data**:
   Run the following command to check if the data was successfully uploaded:
   ```bash
   curl -X GET "http://localhost:9200/product_catalog/_search?pretty=true&q=*:*"
   ```

### **Frontend Setup**
1. **Install Flutter**:
   - Follow the Flutter installation guide: [Flutter Docs](https://flutter.dev/docs/get-started/install).

2. **Set Up CocoaPods (for macOS)**:
   ```bash
   sudo gem install cocoapods
   cd macos
   pod install
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

4. **Test Platforms**:
   - macOS: Choose the `macos` device.
   - Web: Choose the `chrome` device.

---

## **4. Additional Notes**
- **Error Handling**:
  - All API responses include meaningful error messages and status codes.
- **Scalability**:
  - The nested structure in ElasticSearch allows efficient queries as the dataset grows.
- **Future Enhancements**:
  - Add user authentication.
  - Implement advanced filters (e.g., ratings, discounts).
  - Introduce caching for frequently accessed data.


