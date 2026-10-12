import 'package:flutter/material.dart';

/// Données d'un slide du carrousel d'accueil
class HomeBannerSlideData {
  final String tag;
  final String title;
  final String subtitle;
  final String buttonText;
  final String imagePath;
  final VoidCallback? onAction;

  const HomeBannerSlideData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imagePath,
    this.onAction,
  });
}

/// Carrousel interactif fidèle à la maquette officielle LADAFURA.
/// Comprend le tag "Découvrez", le titre fort, le sous-titre, le bouton pilule "Explorer →"
/// et les indicateurs de pagination (pilule verte active + points).
class HomeBannerCarousel extends StatefulWidget {
  final VoidCallback? onExplore;

  const HomeBannerCarousel({super.key, this.onExplore});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late final List<HomeBannerSlideData> _slides;

  @override
  void initState() {
    super.initState();
    _slides = [
      HomeBannerSlideData(
        tag: 'Découvrez',
        title: 'La richesse de notre\npharmacopée traditionnelle',
        subtitle: 'Des plantes, des produits naturels\npour votre bien-être.',
        buttonText: 'Explorer',
        imagePath: 'assets/images/home_banner_mortar.png',
        onAction: widget.onExplore,
      ),
      HomeBannerSlideData(
        tag: 'Plantes & Remèdes',
        title: 'Des savoirs ancestraux\nvalidés par la science',
        subtitle: 'Découvrez les vertus thérapeutiques\net modes de préparation.',
        buttonText: 'Consulter',
        imagePath: 'assets/images/home_banner_mortar.png',
        onAction: widget.onExplore,
      ),
      HomeBannerSlideData(
        tag: 'À proximité',
        title: 'Trouvez les pharmacopées\npartout au Mali',
        subtitle: 'Localisez rapidement les tradipraticiens\net officines agréées.',
        buttonText: 'Localiser',
        imagePath: 'assets/images/home_banner_mortar.png',
        onAction: widget.onExplore,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Conteneur principal du slide
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return _buildSlideCard(slide, isDark);
            },
          ),
        ),
        const SizedBox(height: 10),

        // 2. Indicateurs de pagination (pilule allongée verte + dots arrondis)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF65B741)
                    : (isDark
                        ? Colors.white24
                        : const Color(0xFFCFDACF)),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSlideCard(HomeBannerSlideData slide, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F261B) : const Color(0xFFE2EFE3),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Arrière-plan visuel : mortier & herbes sur la droite
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 250,
              child: Image.asset(
                slide.imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            // Dégradé pour fondre l'image dans le fond vert doux à gauche
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF0D2418),
                            const Color(0xFF0D2418).withValues(alpha: 0.95),
                            const Color(0xFF0D2418).withValues(alpha: 0.40),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFFDEEDE0),
                            const Color(0xFFDEEDE0).withValues(alpha: 0.95),
                            const Color(0xFFDEEDE0).withValues(alpha: 0.40),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.52, 0.75, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Contenu texte & boutons au premier plan
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge "Découvrez" avec icône feuille
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C5231),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              slide.tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Titre principal
                      Text(
                        slide.title,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0C3822),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Sous-titre
                      Text(
                        slide.subtitle,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? const Color(0xFFBDD3C5)
                              : const Color(0xFF526D5B),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),

                  // Bouton pilule "Explorer →"
                  InkWell(
                    onTap: slide.onAction ?? widget.onExplore,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C5231),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C5231).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slide.buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
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
