import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/basket.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Basket basket;
  const DetailScreen({super.key, required this.basket});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _reserved = false;
  bool _isLoading = false;

  Future<void> _reserveBasket() async {
    setState(() => _isLoading = true);

    final success = await ApiService.createOrder(
      int.parse(widget.basket.id),
      widget.basket.discountedPrice,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      setState(() => _reserved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Panier réservé ! Bonne dégustation 🎉',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: VertigoTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Erreur lors de la réservation. Veuillez réessayer.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: VertigoTheme.salmonRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.basket;

    return Scaffold(
      backgroundColor: VertigoTheme.creamBg,
      body: Stack(
        children: [
          // Contenu scrollable
          CustomScrollView(
            slivers: [
              // Grande photo en haut
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: VertigoTheme.primaryGreen,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: VertigoTheme.textDark,
                      size: 20,
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () async {
                      setState(
                        () => widget.basket.isFavorite =
                            !widget.basket.isFavorite,
                      );
                      if (widget.basket.isFavorite) {
                        await ApiService.addFavoris(
                          int.parse(widget.basket.id),
                        );
                      } else {
                        await ApiService.removeFavoris(
                          int.parse(widget.basket.id),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        b.isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: b.isFavorite
                            ? VertigoTheme.salmonRed
                            : VertigoTheme.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        b.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // Dégradé bas
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Badge réduction
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: VertigoTheme.accentYellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '-${b.discountPercent.toStringAsFixed(0)}% de réduction',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: VertigoTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                      // Badge presque épuisé
                      if (b.isAlmostGone)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: VertigoTheme.salmonRed,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '🔥 Plus que ${b.remainingSlots} !',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du resto + catégorie
                      Row(
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
                              b.store.category,
                              style: GoogleFonts.poppins(
                                color: VertigoTheme.primaryGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Note
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: VertigoTheme.accentYellow,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                b.store.rating.toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Nom du panier
                      Text(
                        b.title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: VertigoTheme.textDark,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Nom du resto
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 16,
                            color: VertigoTheme.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            b.store.name,
                            style: GoogleFonts.poppins(
                              color: VertigoTheme.textGrey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: VertigoTheme.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${b.store.distance} km',
                            style: GoogleFonts.poppins(
                              color: VertigoTheme.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Prix
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prix Vertigo',
                                  style: GoogleFonts.poppins(
                                    color: VertigoTheme.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${b.discountedPrice.toStringAsFixed(0)} DA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: VertigoTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Prix original',
                                  style: GoogleFonts.poppins(
                                    color: VertigoTheme.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${b.originalPrice.toStringAsFixed(0)} DA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: VertigoTheme.textGrey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: VertigoTheme.accentYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '-${b.discountPercent.toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Infos retrait
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Infos de retrait',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: VertigoTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: VertigoTheme.primaryGreen
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: VertigoTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Horaire de retrait',
                                      style: GoogleFonts.poppins(
                                        color: VertigoTheme.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${b.pickupStart.hour}h${b.pickupStart.minute.toString().padLeft(2, '0')} - ${b.pickupEnd.hour}h${b.pickupEnd.minute.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: VertigoTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: VertigoTheme.primaryGreen
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: VertigoTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Adresse',
                                        style: GoogleFonts.poppins(
                                          color: VertigoTheme.textGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        b.store.address,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: VertigoTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: VertigoTheme.primaryGreen
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: VertigoTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Paniers restants',
                                      style: GoogleFonts.poppins(
                                        color: VertigoTheme.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${b.remainingSlots} sur ${b.totalSlots} disponibles',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: b.isAlmostGone
                                            ? VertigoTheme.salmonRed
                                            : VertigoTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: VertigoTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.description,
                        style: GoogleFonts.poppins(
                          color: VertigoTheme.textGrey,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                      // Espace pour le bouton fixe en bas
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bouton réserver fixe en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _reserveBasket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _reserved
                        ? VertigoTheme.textGrey
                        : VertigoTheme.salmonRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _reserved
                              ? '✅ Réservé — Annuler'
                              : 'Réserver ce panier →',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
