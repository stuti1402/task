import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _undoFavState(bool oldState) {
    isFavorite = oldState;
    notifyListeners();
  }

  Future<void> toggleFavoriteState() async {
    final oldState = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse('https://shop-flutter-e2a36-default-rtdb.firebaseio.com/products/$id.json');
    try {
      final response = await http.patch(
        url,
        body: jsonEncode({
          'isFavorite': isFavorite,
        }),
      );
      if (response.statusCode >= 400) {
        _undoFavState(oldState);
      }
    } catch (e) {
      _undoFavState(oldState);
    }
  }
}
