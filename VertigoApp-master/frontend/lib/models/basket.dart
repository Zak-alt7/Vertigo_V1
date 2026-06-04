import 'store.dart';

class Basket {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final int totalSlots;
  int remainingSlots;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final Store store;
  final String types;
  double note;
  bool isFavorite;

  Basket({
    required this.id,
    required this.title,
    String? titleEn,
    required this.description,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.totalSlots,
    required this.remainingSlots,
    required this.pickupStart,
    required this.pickupEnd,
    required this.store,
    required this.types,
    required this.note,
    this.isFavorite = false,
  }) : titleEn = titleEn ?? title;

  double get discountPercent =>
      ((originalPrice - discountedPrice) / originalPrice * 100);

  bool get isAlmostGone => remainingSlots <= 2;

  factory Basket.fromJson(Map<String, dynamic> json, Store store) {
    final title = json['name'] ?? '';
    return Basket(
      id: json['id']?.toString() ?? '',
      title: title,
      titleEn: json['nameEn'] ?? title,
      description: json['description'] ?? '',
      imageUrl: json['panierImagePath'] ?? '',
      originalPrice: (json['originalPrice'] ?? json['panierPrix'] ?? 0.0)
          .toDouble(),
      discountedPrice: (json['discountedPrice'] ?? json['panierPrix'] ?? 0.0)
          .toDouble(),
      totalSlots: json['totalSlots'] ?? json['nBdispo'] ?? 0,
      remainingSlots: json['remainingSlots'] ?? json['nBdispo'] ?? 0,
      pickupStart: DateTime.now(),
      pickupEnd: DateTime.now(),
      store: store,
      types: json['types'] ?? '',
      note: (json['note'] ?? json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': int.tryParse(id) ?? 0,
    'name': title,
    'description': description,
    'panierImagePath': imageUrl,
    'panierPrix': discountedPrice,
    'nBdispo': remainingSlots,
    'note': note,
  };
}
