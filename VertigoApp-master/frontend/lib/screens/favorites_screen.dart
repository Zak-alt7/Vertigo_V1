import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';

import '../core/app_settings.dart';
import '../models/basket.dart';
import '../models/store.dart';

import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Basket> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    // Récupérer tous les paniers et filtrer les favoris
    final allBaskets = await ApiService.getPaniers();
    final favoritesIds = await ApiService.getFavoris();

    final favorites = allBaskets
        .where((b) => favoritesIds.contains(int.parse(b.id)))
        .toList();

    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Basket basket) async {
    final success = await ApiService.removeFavoris(int.parse(basket.id));

    if (success && mounted) {
      setState(() {
        _favorites.removeWhere((b) => b.id == basket.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${basket.title} retiré des favoris'),
          backgroundColor: VertigoTheme.salmonRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: VertigoTheme.salmonRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final t = settings.t;

    return Scaffold(
      backgroundColor: VertigoTheme.creamBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Text(
                    settings.isEnglish ? 'My Favorites ❤️' : 'Mes Favoris ❤️',
                    style: GoogleFonts.fredoka(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: VertigoTheme.primaryGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: VertigoTheme.salmonRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_favorites.length} ${settings.isEnglish ? 'baskets' : 'paniers'}',
                      style: GoogleFonts.poppins(
                        color: VertigoTheme.salmonRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _favorites.isEmpty
                  ? _buildEmpty(settings)
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        return _FavoriteCard(
                          basket: _favorites[index],
                          onRemove: () => setState(() {
                            _favorites[index].isFavorite = false;
                          }),
                          isEnglish: settings.isEnglish,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppSettings settings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💔', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            settings.isEnglish ? 'No favorites yet' : 'Pas encore de favoris',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: VertigoTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            settings.isEnglish
                ? 'Tap ❤️ on a basket to save it here'
                : 'Appuie sur ❤️ sur un panier\npour le sauvegarder ici',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: VertigoTheme.textGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Basket basket;
  final VoidCallback onRemove;
  final bool isEnglish;

  const _FavoriteCard({
    required this.basket,
    required this.onRemove,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(basket: basket)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: Image.network(
                basket.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_outlined, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      basket.store.name,
                      style: GoogleFonts.poppins(
                        color: VertigoTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      basket.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: VertigoTheme.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${basket.discountedPrice.toStringAsFixed(0)} DA',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: VertigoTheme.primaryGreen,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${basket.originalPrice.toStringAsFixed(0)} DA',
                          style: GoogleFonts.poppins(
                            color: VertigoTheme.textGrey,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VertigoTheme.salmonRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: VertigoTheme.salmonRed,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
