import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/basket.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../models/store.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5096/api';

  //auth

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', data['id']);
        await prefs.setString('userName', data['nom'] ?? '');
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setString('userPhone', data['telephone'] ?? ''); // ← AJOUTE
        await prefs.setBool('isStudent', data['etudiant'] ?? false); // ← AJOUTE
        print('✅ Login OK - userName: ${data['nom']}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erreur login: $e');
      return false;
    }
  }

  static Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erreur register: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('favorites_local'); // ← favoris effacés
    await prefs.remove('orders_local'); // ← commandes effacées
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final orders = await getMyOrders();
    double totalSaved = 0;
    for (var order in orders) {
      totalSaved += (order.basket.originalPrice - order.basket.discountedPrice);
    }
    return {
      'basketsSaved': orders.length,
      'moneySaved': totalSaved,
      'co2Avoided': orders.length * 1.5,
    };
  }

  //paneir─────────────────────────────────────────────

  static Future<List<Basket>> getPaniers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/deals'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          final store = Store.fromJson({
            'idBoutique': json['boutiqueId'],
            'nomBoutique': json['boutiqueNom'],
            'boutiqueImagePath': json['boutiqueImage'],
            'localisation': json['boutiqueLocalisation'],
            'note': json['boutiqueRating'],
          });
          return Basket.fromJson(json, store);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erreur getPaniers: $e');
      return [];
    }
  }

  //favoris ─────────────────────────────────────────────

  static Future<List<int>> getFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites_local');
    return favorites?.map((id) => int.parse(id)).toList() ?? [];
  }

  static Future<bool> addFavoris(int panierId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites_local') ?? [];
    if (!favorites.contains(panierId.toString())) {
      favorites.add(panierId.toString());
      await prefs.setStringList('favorites_local', favorites);
    }
    return true;
  }

  static Future<bool> removeFavoris(int panierId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites_local') ?? [];
    favorites.remove(panierId.toString());
    await prefs.setStringList('favorites_local', favorites);
    return true;
  }

  //commande ─────────────────────────────────────────────

  static Future<List<Order>> getMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getStringList('orders_local');

    if (ordersJson == null) return [];

    final List<Order> orders = [];
    for (String jsonStr in ordersJson) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonStr);

        // Récupérer le panier associé
        final store = Store.fromJson({
          'idBoutique': json['boutiqueId'],
          'nomBoutique': json['boutiqueNom'],
          'boutiqueImagePath': json['boutiqueImage'],
          'localisation': json['boutiqueLocalisation'],
          'note': json['boutiqueRating'],
        });

        final basket = Basket.fromJson(json['basket'], store);

        orders.add(
          Order(
            id: json['id'].toString(),
            date: DateTime.parse(json['date']),
            totalPrice: json['totalPrice'].toDouble(),
            status: json['status'],
            basket: basket,
            store: store,
          ),
        );
      } catch (e) {
        print('Erreur lecture commande: $e');
      }
    }
    return orders;
  }

  static Future<bool> createOrder(int panierId, double prix) async {
    try {
      // Récupérer le panier
      final allBaskets = await getPaniers();
      final basket = allBaskets.firstWhere((b) => b.id == panierId.toString());

      // Créer la commande
      final orderData = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'basket': {
          'id': basket.id,
          'name': basket.title,
          'description': basket.description,
          'panierImagePath': basket.imageUrl,
          'originalPrice': basket.originalPrice,
          'discountedPrice': basket.discountedPrice,
          'nBdispo': basket.remainingSlots,
        },
        'boutiqueId': int.tryParse(basket.store.id) ?? 0,
        'boutiqueNom': basket.store.name,
        'boutiqueImage': basket.store.imageUrl,
        'boutiqueLocalisation': basket.store.address,
        'boutiqueRating': basket.store.rating,
        'date': DateTime.now().toIso8601String(),
        'totalPrice': prix,
        'status': 'Confirmée',
      };

      // Sauvegarder
      final prefs = await SharedPreferences.getInstance();
      final orders = prefs.getStringList('orders_local') ?? [];
      orders.add(jsonEncode(orderData));
      await prefs.setStringList('orders_local', orders);

      print('✅ Commande sauvegardée');
      return true;
    } catch (e) {
      print('❌ Erreur createOrder: $e');
      return false;
    }
  }
  //profil─────────────────────────────────────────────

  static Future<Utilisateur?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['nom'] ?? '');
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setString('userPhone', data['telephone'] ?? '');
        return Utilisateur(
          id: data['id'],
          nom: data['nom'] ?? '',
          email: data['email'] ?? '',
          telephone: data['telephone'] ?? '',
          etudiant: data['etudiant'] ?? false,
        );
      }
      return null;
    } catch (e) {
      print('Erreur getProfile: $e');
      return null;
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    if (userData.containsKey('nom'))
      await prefs.setString('userName', userData['nom']);
    if (userData.containsKey('email'))
      await prefs.setString('userEmail', userData['email']);
    if (userData.containsKey('telephone'))
      await prefs.setString('userPhone', userData['telephone']);
    return true;
  }
}
