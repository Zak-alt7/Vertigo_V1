import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/app_settings.dart';
import '../models/order.dart';
import '../models/basket.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0;
  List<Order> _orders = [];
  bool _isLoading = true;

  // Commandes actives = statut "Confirmée"
  List<Order> get _activeOrders =>
      _orders.where((o) => o.status == 'Confirmée').toList();

  // Historique = tout ce qui n'est pas "Confirmée"
  List<Order> get _historyOrders =>
      _orders.where((o) => o.status != 'Confirmée').toList();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await ApiService.getMyOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  // Met à jour le statut via SharedPreferences (même pattern que ApiService)
  Future<void> _confirmReceiptOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('orders_local') ?? [];

      final updated = ordersJson.map((jsonStr) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          if (map['id'].toString() == order.id) {
            map['status'] = 'Récupérée';
            return jsonEncode(map);
          }
        } catch (_) {}
        return jsonStr;
      }).toList();

      await prefs.setStringList('orders_local', updated);
      await _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Commande récupérée avec succès !',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: VertigoTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur confirmReceipt: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final t = settings.t;

    return Scaffold(
      backgroundColor: VertigoTheme.creamBg,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: VertigoTheme.primaryGreen,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('my_orders'),
                          style: GoogleFonts.fredoka(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: VertigoTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildTab(
                              t('in_progress'),
                              0,
                              badge: _activeOrders.length,
                            ),
                            const SizedBox(width: 12),
                            _buildTab(t('history'), 1),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // ── Contenu ──────────────────────────────────────────
                  Expanded(
                    child: RefreshIndicator(
                      color: VertigoTheme.primaryGreen,
                      onRefresh: _loadOrders,
                      child: _selectedTab == 0
                          ? _buildActiveOrders(t)
                          : _buildHistory(t),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTab(String label, int index, {int badge = 0}) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? VertigoTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? VertigoTheme.primaryGreen
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : VertigoTheme.textGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : VertigoTheme.salmonRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ONGLET EN COURS
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildActiveOrders(String Function(String) t) {
    if (_activeOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_outlined,
        message: 'Aucune commande en cours',
        sub: 'Tes commandes actives apparaîtront ici',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _activeOrders.length,
      itemBuilder: (context, index) {
        final order = _activeOrders[index];
        return _buildActiveOrderCard(order, t);
      },
    );
  }

  Widget _buildActiveOrderCard(Order order, String Function(String) t) {
    final basket = order.basket;
    final dateStr =
        '${order.date.day}/${order.date.month}/${order.date.year} à ${order.date.hour}:${order.date.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── En-tête ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: VertigoTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '● COMMANDE #${order.id}',
                    style: GoogleFonts.poppins(
                      color: VertigoTheme.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    color: VertigoTheme.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Panier info ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    basket.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        basket.store.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: VertigoTheme.textDark,
                        ),
                      ),
                      Text(
                        basket.title,
                        style: GoogleFonts.poppins(
                          color: VertigoTheme.textGrey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.totalPrice.toStringAsFixed(0)} DA',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: VertigoTheme.primaryGreen,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Timeline ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTimeline(t),
          ),

          const SizedBox(height: 20),

          // ── Bandeau adresse ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VertigoTheme.primaryGreen.withOpacity(0.08),
                  VertigoTheme.primaryGreen.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: VertigoTheme.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Text('📍', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('ready'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: VertigoTheme.primaryGreen,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        basket.store.address,
                        style: GoogleFonts.poppins(
                          color: VertigoTheme.textGrey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Bouton Confirmer réception ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _showConfirmDialog(order, t),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VertigoTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  t('confirm_receipt'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String Function(String) t) {
    final steps = [
      {'label': t('order_placed'), 'done': true},
      {'label': t('restaurant_accepted'), 'done': true},
      {'label': t('preparing'), 'done': true},
      {'label': t('ready_pickup'), 'done': false},
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isDone = step['done'] as bool;
        final isLast = i == steps.length - 1;
        final isActive = !isDone && (i == 0 || (steps[i - 1]['done'] as bool));

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cercle + ligne verticale
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? VertigoTheme.primaryGreen
                        : isActive
                        ? VertigoTheme.primaryGreen.withOpacity(0.2)
                        : Colors.grey.shade200,
                    border: Border.all(
                      color: isDone
                          ? VertigoTheme.primaryGreen
                          : isActive
                          ? VertigoTheme.primaryGreen
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : isActive
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            color: VertigoTheme.primaryGreen,
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 26,
                    color: isDone
                        ? VertigoTheme.primaryGreen
                        : Colors.grey.shade200,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    step['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isDone || isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isDone
                          ? VertigoTheme.textDark
                          : isActive
                          ? VertigoTheme.primaryGreen
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _showConfirmDialog(
    Order order,
    String Function(String) t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Confirmer la réception ?',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: VertigoTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action indique que tu as bien récupéré ton panier.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: VertigoTheme.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VertigoTheme.textGrey,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VertigoTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirmer',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _confirmReceiptOrder(order);
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ONGLET HISTORIQUE
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildHistory(String Function(String) t) {
    if (_historyOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_outlined,
        message: 'Aucun historique',
        sub: 'Tes commandes récupérées apparaîtront ici',
      );
    }

    // Calcul des stats pour la carte impact
    double totalSaved = 0;
    for (var o in _historyOrders) {
      totalSaved += (o.basket.originalPrice - o.basket.discountedPrice);
    }
    final co2 = _historyOrders.length * 1.5;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Carte impact ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3D1A), Color(0xFF3A7A32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: VertigoTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ton impact 🌍',
                style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem(
                    '${_historyOrders.length}',
                    t('baskets_saved'),
                    '🧺',
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    '${totalSaved.toStringAsFixed(0)} DA',
                    t('saved'),
                    '💰',
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    '${co2.toStringAsFixed(1)} kg',
                    'CO₂ évité',
                    '🌱',
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Liste des commandes récupérées ─────────────────────────
        ..._historyOrders.reversed
            .map((order) => _buildHistoryCard(order))
            .toList(),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, String emoji) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildHistoryCard(Order order) {
    final basket = order.basket;
    final dateStr = '${order.date.day}/${order.date.month}/${order.date.year}';
    final saved = order.basket.originalPrice - order.basket.discountedPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image panier
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              basket.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Infos commande
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  basket.store.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: VertigoTheme.textDark,
                  ),
                ),
                Text(
                  basket.title,
                  style: GoogleFonts.poppins(
                    color: VertigoTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: VertigoTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✅ Récupérée',
                        style: GoogleFonts.poppins(
                          color: VertigoTheme.primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Prix + économie
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${order.totalPrice.toStringAsFixed(0)} DA',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: VertigoTheme.textDark,
                  fontSize: 14,
                ),
              ),
              if (saved > 0)
                Text(
                  '-${saved.toStringAsFixed(0)} DA',
                  style: GoogleFonts.poppins(
                    color: VertigoTheme.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String sub,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: VertigoTheme.primaryGreen.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: VertigoTheme.primaryGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: VertigoTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            style: GoogleFonts.poppins(
              color: VertigoTheme.textGrey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
