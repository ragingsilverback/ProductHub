import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000"; // Backend URL

  Future<List<dynamic>> fetchStores() async {
    try {
        print("Fetching data inside API service");
      final response = await http.get(Uri.parse("$baseUrl/stores"));
      print("Got data from backend");
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch stores");
      }
    } catch (e) {
      throw Exception("Failed to fetch stores: $e");
    }
  }

  Future<List<dynamic>> fetchProducts(String storeId, int page, int size) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/$storeId?page=$page&size=$size"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch products");
      }
    } catch (e) {
      throw Exception("Failed to fetch products: $e");
    }
  }

  Future<List<dynamic>> searchProducts(
      String storeId, String? category, Map<String, dynamic>? priceRange, int page, int size) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/products/search"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "store_id": storeId,
          "category": category,
          "price_range": priceRange,
          "page": page,
          "size": size,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to search products");
      }
    } catch (e) {
      throw Exception("Failed to search products: $e");
    }
  }

  Future<Map<String, dynamic>> fetchProductDetails(String storeId, String sku) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products/$storeId/$sku"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch product details");
      }
    } catch (e) {
      throw Exception("Failed to fetch product details: $e");
    }
  }
}