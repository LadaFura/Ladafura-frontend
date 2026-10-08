import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/services_providers.dart';

/// Écran d'accueil Onboarding moderne et immersif inspiré du design system LADAFURA.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color _deepGreenBg = Color(0xFF02170E);
  static const Color _accentGreen = Color(0xFF4ADE80);

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      imagePath: 'assets/images/onboarding_bg_1.png',
      titlePrefix: 'Découvrez la richesse\nde la pharmacopée ',
      titleHighlight: 'malienne',
      description:
          'Des plantes, des savoirs, des solutions naturelles pour votre bien-être.',
      showLogo: true,
      slideType: _SlideType.intro,
    ),
    _OnboardingSlideData(
      imagePath: 'assets/images/onboarding_bg_2.png',
      titlePrefix: 'Trouvez facilement\nles pharmacopées ',
      titleHighlight: 'près de vous',
      description:
          'Localisez les pharmacies, consultez leurs produits et accédez à leurs informations en quelques clics.',
      showLogo: false,
      slideType: _SlideType.pharmacies,
    ),
    _OnboardingSlideData(
      imagePath: 'assets/images/onboarding_bg_3.png',
      titlePrefix: 'Commandez en toute\nconfiance',
      titleHighlight: '',
      description:
          'Profitez de produits naturels de qualité, avec plusieurs options de livraison et de paiement sécurisées.',
      showLogo: false,
      slideType: _SlideType.commande,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go(RouteNames.visitorHomePath);
  }

  void _onNext() {
    if (_currentPage == _slides.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepGreenBg,
      body: Stack(
        children: [
          // 1. Carrousel de diapositives plein écran
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildSlideContent(_slides[index]);
            },
          ),

          // 2. Barre d'action supérieure (Logo & bouton Passer)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_slides[_currentPage].showLogo)
                    _buildLogoHeader()
                  else
                    const SizedBox.shrink(),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                      ),
                      child: Text(
                        'Passer',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Barre de navigation inférieure (Indicateurs & Bouton Suivant/Commencer)
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicateurs de pagination
                    Row(
                      children: List.generate(
                        _slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentPage == index ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _accentGreen
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    // Bouton Suivant / Commencer blanc épuré
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      elevation: 4,
                      shadowColor: Colors.black45,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: _onNext,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _slides.length - 1
                                    ? 'Commencer'
                                    : 'Suivant',
                                style: const TextStyle(
                                  color: Color(0xFF03170E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Color(0xFF03170E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.eco_rounded,
              color: _accentGreen,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LADAFURA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'La nature à portée de main',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlideContent(_OnboardingSlideData slide) {
    return Stack(
      children: [
        // Image de fond
        Positioned.fill(
          child: Image.asset(
            slide.imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) => Container(
              color: _deepGreenBg,
            ),
          ),
        ),

        // Dégradé sombre harmonieux
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.20, 0.45, 0.70, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  const Color(0x6603170E),
                  const Color(0xE602170E),
                  _deepGreenBg,
                ],
              ),
            ),
          ),
        ),

        // Badges flottants contextuels selon la diapositive
        if (slide.slideType == _SlideType.pharmacies)
          Positioned(
            right: 18,
            top: MediaQuery.of(context).size.height * 0.25,
            child: _buildPharmacieFloatingBadges(),
          )
        else if (slide.slideType == _SlideType.commande)
          Positioned(
            right: 18,
            top: MediaQuery.of(context).size.height * 0.22,
            child: _buildCommandeFloatingBadges(),
          ),

        // Textes descriptifs (Titre & sous-titre)
        Positioned(
          left: 24,
          right: 24,
          bottom: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  children: [
                    TextSpan(text: slide.titlePrefix),
                    if (slide.titleHighlight.isNotEmpty)
                      TextSpan(
                        text: slide.titleHighlight,
                        style: const TextStyle(
                          color: _accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                slide.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3 boutons circulaires effet verre pour l'écran Pharmacopées
  Widget _buildPharmacieFloatingBadges() {
    final icons = [
      Icons.search_rounded,
      Icons.location_on_rounded,
      Icons.eco_rounded,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: icons.map((icon) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 3 badges d'assurance qualité effet verre pour l'écran Commande
  Widget _buildCommandeFloatingBadges() {
    final items = [
      (Icons.verified_user_outlined, 'Produits\nnaturels'),
      (Icons.local_shipping_outlined, 'Livraison\nrapide'),
      (Icons.eco_outlined, 'Qualité\ngarantie'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.26),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$1,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

enum _SlideType {
  intro,
  pharmacies,
  commande,
}

class _OnboardingSlideData {
  final String imagePath;
  final String titlePrefix;
  final String titleHighlight;
  final String description;
  final bool showLogo;
  final _SlideType slideType;

  const _OnboardingSlideData({
    required this.imagePath,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.description,
    required this.showLogo,
    required this.slideType,
  });
}
