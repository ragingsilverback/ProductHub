import 'package:flutter/material.dart';
import 'screens/store_selector.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      home: StoreSelectorScreen(),
    );
  }
}