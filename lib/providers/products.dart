import 'dart:convert';

import 'package:flutter/material.dart';
import '/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl: 'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl: 'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items => [..._items];

  List<Product> get favoriteItems => _items.where((product) => product.isFavorite).toList();

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse('https://shop-flutter-e2a36-default-rtdb.firebaseio.com/products.json');
    // final firestoreUrl = Uri.parse(
    //     'https://firestore.googleapis.com/v1/projects/shop-flutter-e2a36/databases/(default)/documents/products');
    try {
      final response = await http.get(url);
      // final firestoreRes = await http.get(firestoreUrl);
      // final fetchFirestore = jsonDecode(firestoreRes.body) as Map<String, dynamic>;
      // print(fetchFirestore['documents'][0]['fields']['title']);
      if (jsonDecode(response.body) == null) {
        return;
      }
      final fetchData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      fetchData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('https://shop-flutter-e2a36-default-rtdb.firebaseio.com/products.json');
    // final url = Uri.https('shop-flutter-e2a36-default-rtdb.firebaseio.com', '/products.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse('https://shop-flutter-e2a36-default-rtdb.firebaseio.com/products/$id.json');
      await http.patch(
        url,
        body: jsonEncode({
          'title': newProduct.title,
          'price': newProduct.price,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
        }),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('https://shop-flutter-e2a36-default-rtdb.firebaseio.com/products/$id.json');
    final existProductIndex = _items.indexWhere((product) => product.id == id);
    var existProduct = _items[existProductIndex];
    _items.removeAt(existProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      print('an error occured');
      _items.insert(existProductIndex, existProduct);
      notifyListeners();
    }
  }
}
