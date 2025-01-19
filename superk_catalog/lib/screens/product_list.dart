import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'store_selector.dart';

class ProductListScreen extends StatefulWidget {
  final String storeId;
  ProductListScreen({required this.storeId});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  RangeValues _priceRange = RangeValues(0, 1000);
  bool _showFilters = false;
  bool _isListView = true;

  Future<void> _goBackToStoreSelector() async {
    // Clear the selected store from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedStore');
    
    // Navigate back to store selector
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StoreSelectorScreen()),
    );
  }

  Widget _buildProductCard(dynamic product) {
    // Generate a unique image URL for each product using its SKU
    String imageUrl = "https://picsum.photos/300/300?random=${product["sku"]}";

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              storeId: widget.storeId,
              sku: product["sku"],
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Container(
              height: 120,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU: ${product["sku"]}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    product["name"],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Price: \$${product["store"]["price"]}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<dynamic> products) {
    if (_isListView) {
      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          String imageUrl = "https://picsum.photos/100/100?random=${product["sku"]}";
          
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SKU: ${product["sku"]}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(product["name"]),
              ],
            ),
            subtitle: Text("Price: \$${product["store"]["price"]}"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(
                  storeId: widget.storeId,
                  sku: product["sku"],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65, // Adjusted for image height
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        padding: EdgeInsets.all(8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.store),
          onPressed: _goBackToStoreSelector,
        ),
        title: Text("Products in ${widget.storeId}"),
        actions: [
          IconButton(
            icon: Icon(_isListView ? Icons.grid_view : Icons.list),
            onPressed: () => setState(() => _isListView = !_isListView),
          ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          if (_showFilters) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: ['All', 'Electronics', 'Clothing', 'Food']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                  SizedBox(height: 8),
                  Text('Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}'),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}'
                    ),
                    onChanged: (values) => setState(() => _priceRange = values),
                  ),
                ],
              ),
            ),
          ],

          Expanded(
            child: FutureBuilder(
              future: _apiService.fetchProducts(widget.storeId, _currentPage, _itemsPerPage),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  var products = snapshot.data as List<dynamic>;
                  
                  products = products.where((product) {
                    final matchesSearch = _searchController.text.isEmpty ||
                        product["name"].toString().toLowerCase().contains(
                            _searchController.text.toLowerCase());
                    final matchesCategory = _selectedCategory == 'All' ||
                        product["category"] == _selectedCategory;
                    final price = double.parse(product["store"]["price"].toString());
                    final matchesPrice = price >= _priceRange.start && 
                        price <= _priceRange.end;
                    
                    return matchesSearch && matchesCategory && matchesPrice;
                  }).toList();

                  return _buildProductList(products);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                  child: Text('Previous'),
                ),
                Text('Page $_currentPage'),
                ElevatedButton(
                  onPressed: () => setState(() => _currentPage++),
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
