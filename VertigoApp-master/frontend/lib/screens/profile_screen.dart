import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../core/theme.dart';
import 'my_info_screen.dart';
import 'address_screen.dart';
import 'payment_screen.dart';
import 'faq_screen.dart';
import '../core/app_settings.dart';
import '../services/api_service.dart';
import 'splash_screen.dart';
import '../core/transitions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await ApiService.getProfile();
    if (user != null && mounted) {
      final settings = context.read<AppSettings>();
      settings.updateProfile(
        name: user.nom,
        email: user.email,
        phone: user.telephone,
      );
      settings.setStudent(user.etudiant);
    }
    setState(() => _isLoading = false);
  }

  void _showLanguagePicker(BuildContext context) {
    final settings = context.read<AppSettings>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choisir la langue / Choose language',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: VertigoTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ...['Français', 'English'].map((lang) {
              final isSelected = settings.language == lang;
              return GestureDetector(
                onTap: () {
                  settings.setLanguage(lang);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? VertigoTheme.primaryGreen.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? VertigoTheme.primaryGreen
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang == 'Français' ? '🇫🇷' : '🇬🇧',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        lang,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isSelected
                              ? VertigoTheme.primaryGreen
                              : VertigoTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: VertigoTheme.primaryGreen,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showStudentModal(BuildContext context, AppSettings settings) {
    final idController = TextEditingController(text: settings.studentId);
    bool isStudent = settings.isStudent;
    final isEn = settings.isEnglish;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEn ? 'Student status 🎓' : 'Statut étudiant 🎓',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: VertigoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setModalState(() => isStudent = !isStudent),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isStudent
                          ? VertigoTheme.primaryGreen.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isStudent
                            ? VertigoTheme.primaryGreen
                            : Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🎓', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? 'I am a student' : 'Je suis étudiant(e)',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isStudent
                                      ? VertigoTheme.primaryGreen
                                      : VertigoTheme.textDark,
                                ),
                              ),
                              Text(
                                isEn
                                    ? '-10% extra on all baskets'
                                    : '-10% sur tous les paniers',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: VertigoTheme.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isStudent,
                          onChanged: (v) => setModalState(() => isStudent = v),
                          activeColor: VertigoTheme.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isStudent) ...[
                  const SizedBox(height: 16),
                  Text(
                    isEn ? 'Student ID number' : 'Numéro étudiant',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: VertigoTheme.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: VertigoTheme.creamBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: idController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'ex: 202437411019',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: VertigoTheme.primaryGreen,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      settings.setStudent(isStudent, id: idController.text);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isStudent
                                ? isEn
                                      ? '✅ Student status activated!'
                                      : '✅ Statut étudiant activé !'
                                : isEn
                                ? 'Student status deactivated'
                                : 'Statut étudiant désactivé',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: VertigoTheme.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VertigoTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isEn ? 'Save' : 'Sauvegarder',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final t = settings.t;
    final isEn = settings.isEnglish;
    final hasPhoto =
        settings.profileImagePath != null &&
        settings.profileImagePath!.isNotEmpty;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: VertigoTheme.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3D1A), Color(0xFF3A7A32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: hasPhoto
                              ? FileImage(File(settings.profileImagePath!))
                              : null,
                          child: !hasPhoto
                              ? Text(
                                  settings.userName.isNotEmpty
                                      ? settings.userName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 42,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              SlideRightRoute(page: const MyInfoScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: VertigoTheme.salmonRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      settings.userName.isNotEmpty
                          ? settings.userName
                          : (isEn ? 'My profile' : 'Mon profil'),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      settings.userEmail,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    if (settings.isStudent) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: VertigoTheme.accentYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎓 ${isEn ? 'Student' : 'Étudiant'} · ${settings.studentId}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: VertigoTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FutureBuilder<Map<String, dynamic>>(
                      future: ApiService.getUserStats(),
                      builder: (context, snap) {
                        final stats =
                            snap.data ??
                            {
                              'basketsSaved': 0,
                              'moneySaved': 0.0,
                              'co2Avoided': 0.0,
                            };
                        final saved = (stats['moneySaved'] as double)
                            .toStringAsFixed(0);
                        final co2 = (stats['co2Avoided'] as double)
                            .toStringAsFixed(1);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat(
                              '${stats['basketsSaved']}',
                              t('baskets_saved'),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _buildStat('$saved DA', t('saved')),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _buildStat(
                              '$co2 kg',
                              isEn ? 'CO₂\navoided' : 'CO₂\névité',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Mon compte ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('my_account'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: VertigoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: t('my_info'),
                        color: VertigoTheme.primaryGreen,
                        onTap: () => Navigator.push(
                          context,
                          SlideRightRoute(page: const MyInfoScreen()),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        label: t('my_addresses'),
                        color: VertigoTheme.salmonRed,
                        onTap: () => Navigator.push(
                          context,
                          SlideRightRoute(page: const AddressScreen()),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.payment_outlined,
                        label: t('payment'),
                        color: VertigoTheme.accentYellow,
                        iconColor: VertigoTheme.textDark,
                        onTap: () => Navigator.push(
                          context,
                          SlideRightRoute(page: const PaymentScreen()),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.school_outlined,
                        label: t('student_status'),
                        color: Colors.teal,
                        subtitle: settings.isStudent
                            ? settings.studentId
                            : null,
                        onTap: () => _showStudentModal(context, settings),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Préférences ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('preferences'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: VertigoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: t('notifications'),
                        color: Colors.purple,
                        trailing: Switch(
                          value: true,
                          onChanged: (_) {},
                          activeColor: VertigoTheme.primaryGreen,
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.language_outlined,
                        label: t('language'),
                        color: Colors.blue,
                        subtitle: settings.language,
                        onTap: () => _showLanguagePicker(context),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Support ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('support'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: VertigoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(
                        icon: Icons.help_outline,
                        label: t('help_faq'),
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          SlideRightRoute(page: const FaqScreen()),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.star_outline,
                        label: t('rate_app'),
                        color: VertigoTheme.accentYellow,
                        iconColor: VertigoTheme.textDark,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEn ? '⭐ Thank you!' : '⭐ Merci !',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: VertigoTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.share_outlined,
                        label: t('share'),
                        color: VertigoTheme.primaryGreen,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEn ? '🔗 Link copied!' : '🔗 Lien copié !',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: VertigoTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Déconnexion ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () async {
                      await ApiService.logout();
                      if (mounted) {
                        context.read<AppSettings>().updateProfile(
                          name: '',
                          email: '',
                          phone: '',
                          profileImagePath: '',
                        );
                        context.read<AppSettings>().setStudent(false);
                        Navigator.of(context).pushAndRemoveUntil(
                          FadeRoute(page: const SplashScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VertigoTheme.salmonRed,
                      side: const BorderSide(color: VertigoTheme.salmonRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      t('logout'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Vertigo v3.2 · Made with 💚 in Oran',
                style: GoogleFonts.poppins(
                  color: VertigoTheme.textGrey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor ?? item.color,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: VertigoTheme.textDark,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: VertigoTheme.textGrey,
                        ),
                      )
                    : null,
                trailing:
                    item.trailing ??
                    const Icon(
                      Icons.chevron_right,
                      color: VertigoTheme.textGrey,
                    ),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color? iconColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
}
