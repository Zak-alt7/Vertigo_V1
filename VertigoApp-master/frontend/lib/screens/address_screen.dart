import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_settings.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'label': 'Maison',
      'labelEn': 'Home',
      'address': '12 Rue Larbi Ben M\'hidi, Oran',
      'icon': Icons.home_outlined,
      'selected': true,
    },
    {
      'label': 'Travail',
      'labelEn': 'Work',
      'address': '45 Avenue Mohammed V, Oran',
      'icon': Icons.work_outline,
      'selected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final isEn = settings.isEnglish;

    return Scaffold(
      backgroundColor: VertigoTheme.creamBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back,
                color: VertigoTheme.textDark, size: 20),
          ),
        ),
        title: Text(
          settings.t('my_addresses'),
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: VertigoTheme.textDark,
              fontSize: 18),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(_addresses.length, (index) {
              final addr = _addresses[index];
              final isSelected = addr['selected'] as bool;
              return GestureDetector(
                onTap: () => setState(() {
                  for (var a in _addresses) {
                    a['selected'] = false;
                  }
                  _addresses[index]['selected'] = true;
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? VertigoTheme.primaryGreen
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? VertigoTheme.primaryGreen.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(addr['icon'] as IconData,
                            color: isSelected
                                ? VertigoTheme.primaryGreen
                                : VertigoTheme.textGrey,
                            size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn
                                  ? addr['labelEn'] as String
                                  : addr['label'] as String,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: VertigoTheme.textDark),
                            ),
                            Text(addr['address'] as String,
                                style: GoogleFonts.poppins(
                                    color: VertigoTheme.textGrey,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: VertigoTheme.primaryGreen),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _showAddAddress(context, isEn),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: VertigoTheme.primaryGreen.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        color: VertigoTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      isEn ? 'Add an address' : 'Ajouter une adresse',
                      style: GoogleFonts.poppins(
                          color: VertigoTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddress(BuildContext context, bool isEn) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
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
                isEn ? 'New address' : 'Nouvelle adresse',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: VertigoTheme.textDark),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: VertigoTheme.creamBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: isEn
                        ? 'Ex: 23 Boulevard Zabana, Oran'
                        : 'Ex: 23 Boulevard Zabana, Oran',
                    hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: VertigoTheme.primaryGreen),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        _addresses.add({
                          'label': isEn ? 'Other' : 'Autre',
                          'labelEn': 'Other',
                          'address': controller.text,
                          'icon': Icons.location_on_outlined,
                          'selected': false,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VertigoTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEn ? 'Add' : 'Ajouter',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}