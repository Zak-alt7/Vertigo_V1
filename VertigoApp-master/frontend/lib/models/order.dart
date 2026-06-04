import 'basket.dart';
import 'store.dart';

class Order {
  final String id;
  final DateTime date;
  final double totalPrice;
  final String status;
  final Basket basket;
  final Store store;

  Order({
    required this.id,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.basket,
    required this.store,
  });

  factory Order.fromJson(
    Map<String, dynamic> json,
    Basket basket,
    Store store,
  ) {
    return Order(
      id: json['id'].toString(),
      date: DateTime.parse(
        json['dateDeCommande'] ?? DateTime.now().toIso8601String(),
      ),
      totalPrice: (json['prix'] as num).toDouble(),
      status: json['statut'] == true ? 'Récupérée' : 'Confirmée',
      basket: basket,
      store: store,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': int.tryParse(id) ?? 0,
    'clientId': 0,
    'panierId': int.tryParse(basket.id) ?? 0,
    'dateDeCommande': date.toIso8601String(),
    'prix': totalPrice,
    'statut': status == 'Récupérée' ? true : false,
    'reduction': false,
  };
}
