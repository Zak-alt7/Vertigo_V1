import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_settings.dart';
import '../models/basket.dart';
import '../models/store.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';

  // Valeurs backend — ne jamais changer
  String _selectedCategory = 'Tous';
  final List<String> _backendCategories = [
    'Tous',
    'Bakery Basket',
    'Food Basket',
    'Grocery Basket',
    'Surprise Basket',
  ];

  // Traductions FR
  final Map<String, String> _categoryFr = {
    'Tous': 'Tous',
    'Bakery Basket': 'Boulangerie',
    'Food Basket': 'Cuisine',
    'Grocery Basket': 'Épicerie',
    'Surprise Basket': 'Surprise',
  };

  // Traductions EN
  final Map<String, String> _categoryEn = {
    'Tous': 'All',
    'Bakery Basket': 'Bakery',
    'Food Basket': 'Food',
    'Grocery Basket': 'Grocery',
    'Surprise Basket': 'Surprise',
  };

  late AnimationController _counterController;
  late Animation<int> _counterAnimation;

  List<Basket> _baskets = [];
  bool _isLoading = true;

  List<Basket> get _filteredBaskets {
    var baskets = _selectedCategory == 'Tous'
        ? _baskets
        : _baskets.where((b) => b.types == _selectedCategory).toList();

    if (_searchQuery.isNotEmpty) {
      baskets = baskets
          .where(
            (b) =>
                b.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                b.store.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return baskets;
  }

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _counterAnimation = IntTween(begin: 0, end: 247).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOut),
    );
    _counterController.forward();
    _loadBaskets();
  }

  Future<void> _loadBaskets() async {
    setState(() => _isLoading = true);
    final baskets = await ApiService.getPaniers();
    setState(() {
      _baskets = baskets;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final t = settings.t;
    final isEn = settings.isEnglish;
    final catLabels = isEn ? _categoryEn : _categoryFr;

    return Scaffold(
      backgroundColor: VertigoTheme.creamBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VertigoTheme.primaryGreen,
              ),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: Colors.white,
                  elevation: innerBoxIsScrolled ? 4 : 0,
                  shadowColor: Colors.black12,
                  toolbarHeight: 130,
                  flexibleSpace: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/logo.png',
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Vertigo',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: VertigoTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: VertigoTheme.creamBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.search,
                                  color: VertigoTheme.primaryGreen,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) =>
                                        setState(() => _searchQuery = value),
                                    decoration: InputDecoration(
                                      hintText: t('search_hint'),
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey.shade400,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _searchQuery = ''),
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: VertigoTheme.textGrey,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Bannière
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3D1A), Color(0xFF3A7A32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedBuilder(
                                    animation: _counterAnimation,
                                    builder: (context, child) {
                                      return RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${_counterAnimation.value} ',
                                              style: GoogleFonts.fredoka(
                                                fontSize: 36,
                                                color:
                                                    VertigoTheme.accentYellow,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: t('meals_saved'),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t('around_oran'),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Catégories
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 12),
                      child: Text(
                        t('categories'),
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: VertigoTheme.textDark,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _backendCategories.length,
                        itemBuilder: (context, index) {
                          final backendCat = _backendCategories[index];
                          final isSelected = backendCat == _selectedCategory;
                          final label = catLabels[backendCat] ?? backendCat;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = backendCat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? VertigoTheme.primaryGreen
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? Colors.white
                                        : VertigoTheme.textGrey,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Titre
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t('available_baskets'),
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: VertigoTheme.textDark,
                            ),
                          ),
                          Text(
                            '${_filteredBaskets.length} ${t('results')}',
                            style: GoogleFonts.poppins(
                              color: VertigoTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_filteredBaskets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Text('🔍', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 16),
                              Text(
                                t('no_basket'),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: VertigoTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t('try_other'),
                                style: GoogleFonts.poppins(
                                  color: VertigoTheme.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: _filteredBaskets.length,
                          itemBuilder: (context, index) {
                            return _BasketCard(
                              basket: _filteredBaskets[index],
                              onFavoriteChanged: _loadBaskets,
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BasketCard extends StatefulWidget {
  final Basket basket;
  final VoidCallback onFavoriteChanged;

  const _BasketCard({required this.basket, required this.onFavoriteChanged});

  @override
  State<_BasketCard> createState() => _BasketCardState();
}

class _BasketCardState extends State<_BasketCard> {
  bool _isLoading = false;

  Future<void> _toggleFavorite() async {
    setState(() => _isLoading = true);

    if (widget.basket.isFavorite) {
      await ApiService.removeFavoris(int.parse(widget.basket.id));
    } else {
      await ApiService.addFavoris(int.parse(widget.basket.id));
    }

    widget.basket.isFavorite = !widget.basket.isFavorite;
    widget.onFavoriteChanged();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.basket;
    final settings = context.watch<AppSettings>();

    final displayPrice = settings.isStudent
        ? b.discountedPrice * 0.9
        : b.discountedPrice;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(basket: b)),
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    b.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (b.isAlmostGone)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Builder(
                      builder: (context) {
                        final isEn = context.watch<AppSettings>().isEnglish;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: VertigoTheme.salmonRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isEn
                                ? 'Only ${b.remainingSlots} left!'
                                : 'Plus que ${b.remainingSlots} !',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (settings.isStudent)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🎓 -10%',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: VertigoTheme.primaryGreen,
                              ),
                            )
                          : Icon(
                              b.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: b.isFavorite
                                  ? VertigoTheme.salmonRed
                                  : Colors.grey,
                              size: 16,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: VertigoTheme.accentYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${b.discountPercent.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        color: VertigoTheme.textDark,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.store.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: VertigoTheme.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    b.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: VertigoTheme.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${displayPrice.toStringAsFixed(0)} DA',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: VertigoTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${b.originalPrice.toStringAsFixed(0)} DA',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: VertigoTheme.textGrey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: VertigoTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${b.pickupStart.hour}h${b.pickupStart.minute.toString().padLeft(2, '0')} - ${b.pickupEnd.hour}h${b.pickupEnd.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: VertigoTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
