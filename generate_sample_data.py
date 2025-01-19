import json
import random

# Number of SKUs and stores
NUM_SKUS = 10000
NUM_STORES = 50

# Random store IDs
store_ids = [f"store{i}" for i in range(1, NUM_STORES + 1)]

# Random categories and products
categories = ["groceries", "electronics", "fashion", "toys", "books"]
product_names = {
    "groceries": ["Rice", "Sugar", "Flour", "Pasta", "Oil"],
    "electronics": ["Headphones", "Smartphone", "Tablet", "Laptop", "Monitor"],
    "fashion": ["T-shirt", "Jeans", "Jacket", "Sneakers", "Hat"],
    "toys": ["Action Figure", "Board Game", "Puzzle", "Toy Car", "Doll"],
    "books": ["Novel", "Biography", "Textbook", "Comics", "Magazine"]
}

# Function to generate a random price
def random_price():
    return round(random.uniform(5, 500), 2)

# Function to generate store-specific data
def generate_stores_data():
    store_data = []
    for store_id in store_ids:
        store_data.append({
            "store_id": store_id,
            "availability": random.choice([True, False]),
            "price": random_price() if random.choice([True, False]) else 0
        })
    return store_data

# Generate dataset
dataset = []
for sku_id in range(1, NUM_SKUS + 1):
    category = random.choice(categories)
    product_name = random.choice(product_names[category])
    dataset.append({
        "sku": f"SKU{sku_id:05d}",
        "name": product_name,
        "category": category,
        "description": f"A high-quality {product_name.lower()} in the {category} category.",
        "stores": generate_stores_data()
    })

# Save to a JSON file
output_file = "sample_data.json"
with open(output_file, "w") as f:
    json.dump(dataset, f, indent=2)

print(f"Sample data for {NUM_SKUS} SKUs across {NUM_STORES} stores has been saved to {output_file}.")