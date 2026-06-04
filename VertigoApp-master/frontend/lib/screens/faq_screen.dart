import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_settings.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<Map<String, dynamic>> _getFaqs(bool isEn) => [
        {
          'question': isEn ? 'What is Vertigo?' : 'C\'est quoi Vertigo ?',
          'answer': isEn
              ? 'Vertigo is an app that lets you pick up surprise baskets at reduced prices from local merchants in Oran and surroundings. You save food and money!'
              : 'Vertigo est une application qui te permet de récupérer des paniers surprises à prix réduit chez des commerçants locaux à Oran et ses alentours. Tu sauves de la nourriture et tu fais des économies !',
          'expanded': false,
        },
        {
          'question': isEn
              ? 'How do I reserve a basket?'
              : 'Comment réserver un panier ?',
          'answer': isEn
              ? 'Simple! Browse available baskets, tap the one you want, then press "Reserve this basket". You\'ll get a confirmation and just need to go to the store at the indicated time.'
              : 'C\'est simple ! Parcours les paniers disponibles, clique sur celui qui t\'intéresse, puis appuie sur "Réserver ce panier". Tu recevras une confirmation et tu n\'auras plus qu\'à te rendre au commerce aux horaires indiqués.',
          'expanded': false,
        },
        {
          'question': isEn
              ? 'How do I know when my basket is ready?'
              : 'Comment savoir quand mon panier est prêt ?',
          'answer': isEn
              ? 'You\'ll receive a notification as soon as your basket is ready to pick up. You can also track your order status in the "Orders" tab.'
              : 'Tu recevras une notification dès que ton panier est prêt à être récupéré. Tu peux aussi suivre l\'état de ta commande dans l\'onglet "Commandes".',
          'expanded': false,
        },
        {
          'question':
              isEn ? 'How do I pay?' : 'Comment payer ?',
          'answer': isEn
              ? 'You can pay cash at the store when picking up, or via CIB/EDAHABIA or BaridiMob. Set your payment method in Profile → Payment.'
              : 'Tu peux payer en espèces directement au commerce lors de la récupération, ou via CIB/EDAHABIA ou BaridiMob. Configure ta méthode de paiement dans Profil → Paiement.',
          'expanded': false,
        },
        {
          'question': isEn
              ? 'Can I cancel my reservation?'
              : 'Puis-je annuler ma réservation ?',
          'answer': isEn
              ? 'Yes, you can cancel up to 30 minutes before pickup time. After that, cancellation is no longer possible.'
              : 'Oui, tu peux annuler ta réservation jusqu\'à 30 minutes avant l\'heure de récupération. Au-delà, l\'annulation n\'est plus possible.',
          'expanded': false,
        },
        {
          'question': isEn
              ? 'What\'s in a surprise basket?'
              : 'Que contient un panier surprise ?',
          'answer': isEn
              ? 'Baskets contain the day\'s unsold items from the merchant. You don\'t know exactly what\'s inside, but the value is always much higher than the price paid!'
              : 'Les paniers contiennent les invendus du jour du commerçant. Tu ne sais pas exactement ce qu\'il y a dedans, mais la valeur est toujours bien supérieure au prix payé !',
          'expanded': false,
        },
        {
          'question': isEn
              ? 'Is there a student discount?'
              : 'Y a-t-il une réduction étudiant ?',
          'answer': isEn
              ? 'Yes! Students get an extra 10% off all baskets. Activate your student status in Profile → Student status and enter your student ID number.'
              : 'Oui ! Les étudiants bénéficient de -10% supplémentaire sur tous les paniers. Active ton statut étudiant dans Profil → Statut étudiant et entre ton numéro étudiant.',
          'expanded': false,
        },
        {
          'question': isEn
              ? 'How do I report a problem?'
              : 'Comment signaler un problème ?',
          'answer': isEn
              ? 'If you have a problem with an order, contact us at support@vertigo.dz or via the app chat.'
              : 'Si tu as un problème avec une commande, contacte-nous directement via l\'email support@vertigo.dz ou via le chat de l\'application.',
          'expanded': false,
        },
      ];

  late List<Map<String, dynamic>> _faqs;
  bool _lastIsEn = false;

  @override
  void initState() {
    super.initState();
    _faqs = _getFaqs(false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final isEn = settings.isEnglish;

    if (isEn != _lastIsEn) {
      _lastIsEn = isEn;
      _faqs = _getFaqs(isEn);
    }

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
          settings.t('help_faq'),
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: VertigoTheme.textDark,
              fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
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
                        Text(
                          isEn
                              ? 'How can we help? 💚'
                              : 'Comment on peut t\'aider ? 💚',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEn
                              ? 'Find all answers here'
                              : 'Retrouve toutes les réponses ici',
                          style: GoogleFonts.poppins(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Text('🤝', style: TextStyle(fontSize: 40)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              isEn ? 'Frequently asked questions' : 'Questions fréquentes',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: VertigoTheme.textDark),
            ),

            const SizedBox(height: 12),

            ...List.generate(_faqs.length, (index) {
              final faq = _faqs[index];
              final isExpanded = faq['expanded'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isExpanded
                        ? VertigoTheme.primaryGreen.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(faq['question'] as String,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: VertigoTheme.textDark)),
                      trailing: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down,
                            color: isExpanded
                                ? VertigoTheme.primaryGreen
                                : VertigoTheme.textGrey),
                      ),
                      onTap: () => setState(
                          () => _faqs[index]['expanded'] = !isExpanded),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(faq['answer'] as String,
                            style: GoogleFonts.poppins(
                                color: VertigoTheme.textGrey,
                                fontSize: 13,
                                height: 1.6)),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  const Text('📧', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    isEn
                        ? 'Didn\'t find your answer?'
                        : 'Tu n\'as pas trouvé ta réponse ?',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: VertigoTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn
                        ? 'Contact us at support@vertigo.dz'
                        : 'Contacte-nous à support@vertigo.dz',
                    style: GoogleFonts.poppins(
                        color: VertigoTheme.textGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VertigoTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEn ? 'Contact support' : 'Contacter le support',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}