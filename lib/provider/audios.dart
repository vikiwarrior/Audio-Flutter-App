import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Audios with ChangeNotifier {
  List<Audio> _items = [];
  List<Audio> get items {
    return [..._items];
  }

  List<Audio> favitems(String userid) {
    return _items.where((item) => item.owner == userid).toList();
  }

  Future<void> fetchAndSetAudios() async {
    const url =
        'https://audio-app-1305a-default-rtdb.firebaseio.com/audios.json';

    try {
      final response = await http.get(Uri.parse(url));

      print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<Audio> loadedProducts = [];
      extractedData.forEach((prodid, data) {
        // print(data['is']);
        loadedProducts.add(Audio(
            id: prodid,
            audioUrl: data['audioUrl'],
            title: data['title'],
            owner: data['owner'],
            likedBy: data['likedBy']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      // print('sss');
      throw (error);
    }
  }

  Future<void> addAudio(Audio audio) async {
    const url =
        'https://audio-app-1305a-default-rtdb.firebaseio.com/audios.json';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'title': audio.title,
          'audioUrl': audio.audioUrl,
          'owner': audio.owner,
          'likedBy': audio.likedBy,
        }),
      );

      final newProduct = Audio(
          audioUrl: audio.audioUrl,
          title: audio.title,
          id: json.decode(response.body)['name'],
          owner: audio.owner,
          likedBy: audio.likedBy);
      _items.add(newProduct);

      notifyListeners();
    } catch (err) {
      print(err);
      throw (err);
    }
  }

//increment - decrement 
  void incrementlike(String id) {

   // get karke fir post kardenge
   //  
    final url =
        'https://audio-app-1305a-default-rtdb.firebaseio.com/audios/$id.json';
    notifyListeners();
  }

  void decrementlike() {
    
  }

  // Future<void> updateProducts(String id, Product product) async {
  //   var productIndex = _items.indexWhere((prod) => prod.id == id);
  //   if (productIndex >= 0) {
  //     final url =
  //         'https://shop-app-d4b38-default-rtdb.firebaseio.com/products/$id.json';
  //     await http.patch(url,
  //         body: json.encode({
  //           'title': product.title,
  //           'description': product.description,
  //           'price': product.price,
  //           'imageUrl': product.imageUrl,
  //         }));

  //     _items[productIndex] = product;
  //     notifyListeners();
  //   } else {
  //     print('check...');
  //   }
  // }

  // void deleteProduct(String id) {
  //   final url =
  //       'https://shop-app-d4b38-default-rtdb.firebaseio.com/products/$id.json';
  //   final removedProdIndex = _items.indexWhere((prod) => prod.id == id);
  //   var removedproduct = _items[removedProdIndex];
  //   _items.removeAt(removedProdIndex);
  //   http.delete(url).then((_) {
  //     removedproduct = null;
  //   }).catchError((_) {
  //     _items.insert(removedProdIndex, removedproduct);
  //     notifyListeners();
  //   });
  //   _items.removeWhere((prod) => prod.id == id);
  //   notifyListeners();
  // }

  // Product findById(String id) {
  //   return _items.firstWhere((prod) => prod.id == id);
  // }
}
