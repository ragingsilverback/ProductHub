import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_list.dart';  // Assuming ProductListScreen is in this file
import '../services/api_service.dart';  // Correct path to your ApiService

class StoreSelectorScreen extends StatefulWidget {
  @override
  _StoreSelectorScreenState createState() => _StoreSelectorScreenState();
}

class _StoreSelectorScreenState extends State<StoreSelectorScreen> {
  final ApiService _apiService = ApiService();
  List<String> _stores = [];
  String? _selectedStore;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredStores = [];
  bool _isLoading = true;  // Add loading state

  @override
  void initState() {
    super.initState();
    _loadStores();
    // Add listener to search controller
    _searchController.addListener(() {
      _filterStores(_searchController.text);
    });
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final stores = await _apiService.fetchStores();
      setState(() {
        _stores = List<String>.from(stores);
        _filteredStores = _stores;
        _isLoading = false;
      });
      print('Loaded stores: $_stores'); // Debug print
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Failed to load stores: $e");
    }
  }

  void _filterStores(String query) {
    print('Filtering with query: $query'); // Debug print
    print('Original stores: $_stores'); // Debug print
    
    setState(() {
      if (query.isEmpty) {
        _filteredStores = List<String>.from(_stores);
      } else {
        _filteredStores = _stores
            .where((store) => 
                store.toLowerCase().contains(query.trim().toLowerCase()))
            .toList();
      }
      _selectedStore = null;
    });
    
    print('Filtered stores: $_filteredStores'); // Debug print
  }

  void _onStoreSelected(String? store) async {
    if (store != null) {
      setState(() {
        _selectedStore = store;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("selectedStore", store);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductListScreen(storeId: store)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select a Store")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stores...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_stores.isEmpty)
              Text('No stores available')
            else if (_filteredStores.isEmpty)
              Text('No matching stores found')
            else
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedStore,
                hint: Text("Choose a store"),
                items: _filteredStores.map((store) => DropdownMenuItem(
                      value: store,
                      child: Text(store),
                    )).toList(),
                onChanged: _onStoreSelected,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}