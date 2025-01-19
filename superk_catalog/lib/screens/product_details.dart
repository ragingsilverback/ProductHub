import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String storeId;
  final String sku;

  ProductDetailsScreen({required this.storeId, required this.sku});

  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Details")),
      body: FutureBuilder(
        future: _apiService.fetchProductDetails(storeId, sku),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final product = snapshot.data as Map<String, dynamic>;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SKU: ${product["sku"]}", style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  )),
                  Text("Name: ${product["name"]}", style: TextStyle(fontSize: 20)),
                  Text("Category: ${product["category"]}"),
                  Text("Description: ${product["description"]}"),
                  Text("Price: \$${product["store"]["price"]}"),
                  Text("Availability: ${product["store"]["availability"] ? "Yes" : "No"}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}