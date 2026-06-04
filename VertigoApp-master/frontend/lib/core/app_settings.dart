import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  String _language = 'Français';
  bool _isStudent = false;
  String _studentId = '';
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String? _profileImagePath;

  String get language => _language;
  bool get isStudent => _isStudent;
  String get studentId => _studentId;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String? get profileImagePath => _profileImagePath;
  bool get isEnglish => _language == 'English';

  // Appelé au démarrage dans main.dart
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _userPhone = prefs.getString('userPhone') ?? '';
    _isStudent = prefs.getBool('isStudent') ?? false;
    _studentId = prefs.getString('studentId') ?? '';
    _language = prefs.getString('language') ?? 'Français';
    _profileImagePath = prefs.getString('profileImagePath');
    notifyListeners();
  }

  void setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  void setStudent(bool value, {String id = ''}) async {
    _isStudent = value;
    _studentId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isStudent', value);
    await prefs.setString('studentId', id);
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImagePath,
  }) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('userName', name);
    if (email != null) await prefs.setString('userEmail', email);
    if (phone != null) await prefs.setString('userPhone', phone);
    if (profileImagePath != null)
      await prefs.setString('profileImagePath', profileImagePath);
    notifyListeners();
  }

  String t(String key) {
    if (_language == 'English') return _en[key] ?? key;
    return _fr[key] ?? key;
  }

  static const Map<String, String> _fr = {
    'deals': 'Deals',
    'favorites': 'Favoris',
    'orders': 'Commandes',
    'profile': 'Profil',
    'search_hint': 'Rechercher un panier...',
    'categories': 'Catégories',
    'available_baskets': 'Paniers disponibles 🧺',
    'results': 'résultats',
    'meals_saved': 'repas\nsauvés aujourd\'hui 🌍',
    'around_oran': 'à Oran & alentours',
    'no_basket': 'Aucun panier trouvé',
    'try_other': 'Essaie un autre mot clé',
    'reserve': 'Réserver ce panier →',
    'reserved': '✅ Réservé — Annuler',
    'pickup_info': 'Infos de retrait',
    'pickup_time': 'Horaire de retrait',
    'address': 'Adresse',
    'slots_left': 'Paniers restants',
    'description': 'Description',
    'original_price': 'Prix original',
    'vertigo_price': 'Prix Vertigo',
    'my_account': 'Mon compte',
    'my_info': 'Mes informations',
    'my_addresses': 'Mes adresses',
    'payment': 'Paiement',
    'preferences': 'Préférences',
    'notifications': 'Notifications',
    'language': 'Langue',
    'support': 'Support',
    'help_faq': 'Aide & FAQ',
    'rate_app': 'Noter l\'app',
    'share': 'Partager Vertigo',
    'logout': 'Se déconnecter',
    'baskets_saved': 'Paniers\nsauvés',
    'saved': 'Économisé',
    'student_status': 'Statut étudiant 🎓',
    'student_id': 'N° étudiant',
    'is_student': 'Je suis étudiant(e)',
    'student_discount': '-10% supplémentaire sur tous les paniers',
    'welcome_back': 'Bon retour ! 👋',
    'login_subtitle': 'Connecte-toi à ton compte',
    'email': 'Email',
    'password': 'Mot de passe',
    'forgot_password': 'Mot de passe oublié ?',
    'login': 'Se connecter',
    'no_account': 'Pas encore de compte ? ',
    'register': 'S\'inscrire',
    'create_account': 'Créer un compte 🎉',
    'join': 'Rejoins la communauté Vertigo',
    'full_name': 'Nom complet *',
    'phone': 'Téléphone',
    'confirm_password': 'Confirmer le mot de passe *',
    'accept_terms': 'J\'accepte les ',
    'terms': 'conditions d\'utilisation',
    'create': 'Créer mon compte 🚀',
    'already_account': 'Déjà un compte ? ',
    'sign_in': 'Se connecter',
    'my_orders': 'Mes Commandes 🧺',
    'in_progress': 'En cours',
    'history': 'Historique',
    'ready': 'Prêt à récupérer ! 🎉',
    'confirm_receipt': 'Confirmer la réception',
    'timeline': 'Timeline',
    'order_placed': 'Commande passée',
    'restaurant_accepted': 'Restaurant accepté',
    'preparing': 'Panier en préparation',
    'ready_pickup': '🎉 Prêt à récupérer !',
    'received': '✅ Reçu',
  };

  static const Map<String, String> _en = {
    'deals': 'Deals',
    'favorites': 'Favorites',
    'orders': 'Orders',
    'profile': 'Profile',
    'search_hint': 'Search for a basket...',
    'categories': 'Categories',
    'available_baskets': 'Available baskets 🧺',
    'results': 'results',
    'meals_saved': 'meals\nsaved today 🌍',
    'around_oran': 'in Oran & surroundings',
    'no_basket': 'No basket found',
    'try_other': 'Try another keyword',
    'reserve': 'Reserve this basket →',
    'reserved': '✅ Reserved — Cancel',
    'pickup_info': 'Pickup info',
    'pickup_time': 'Pickup time',
    'address': 'Address',
    'slots_left': 'Baskets left',
    'description': 'Description',
    'original_price': 'Original price',
    'vertigo_price': 'Vertigo price',
    'my_account': 'My account',
    'my_info': 'My information',
    'my_addresses': 'My addresses',
    'payment': 'Payment',
    'preferences': 'Preferences',
    'notifications': 'Notifications',
    'language': 'Language',
    'support': 'Support',
    'help_faq': 'Help & FAQ',
    'rate_app': 'Rate the app',
    'share': 'Share Vertigo',
    'logout': 'Log out',
    'baskets_saved': 'Baskets\nsaved',
    'saved': 'Saved',
    'student_status': 'Student status 🎓',
    'student_id': 'Student ID',
    'is_student': 'I am a student',
    'student_discount': '-10% extra on all baskets',
    'welcome_back': 'Welcome back! 👋',
    'login_subtitle': 'Log in to your account',
    'email': 'Email',
    'password': 'Password',
    'forgot_password': 'Forgot password?',
    'login': 'Log in',
    'no_account': 'No account yet? ',
    'register': 'Sign up',
    'create_account': 'Create an account 🎉',
    'join': 'Join the Vertigo community',
    'full_name': 'Full name *',
    'phone': 'Phone',
    'confirm_password': 'Confirm password *',
    'accept_terms': 'I accept the ',
    'terms': 'terms of use',
    'create': 'Create my account 🚀',
    'already_account': 'Already have an account? ',
    'sign_in': 'Log in',
    'my_orders': 'My Orders 🧺',
    'in_progress': 'In progress',
    'history': 'History',
    'ready': 'Ready to pick up! 🎉',
    'confirm_receipt': 'Confirm receipt',
    'timeline': 'Timeline',
    'order_placed': 'Order placed',
    'restaurant_accepted': 'Restaurant accepted',
    'preparing': 'Preparing your basket',
    'ready_pickup': '🎉 Ready to pick up!',
    'received': '✅ Received',
  };
}
