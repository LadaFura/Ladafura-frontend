/// Modèle pour les filtres d'affichage professionnels sur la carte.
class CarteFilterModel {
  final bool showOnlyOpen;
  final bool showOnlyWithDelivery;
  final bool showOnlyPickup;
  final bool showOnlyTopRated;
  final String? selectedRegion;

  const CarteFilterModel({
    this.showOnlyOpen = false,
    this.showOnlyWithDelivery = false,
    this.showOnlyPickup = false,
    this.showOnlyTopRated = false,
    this.selectedRegion,
  });

  bool get hasActiveFilters =>
      showOnlyOpen ||
      showOnlyWithDelivery ||
      showOnlyPickup ||
      showOnlyTopRated ||
      selectedRegion != null;

  CarteFilterModel copyWith({
    bool? showOnlyOpen,
    bool? showOnlyWithDelivery,
    bool? showOnlyPickup,
    bool? showOnlyTopRated,
    String? selectedRegion,
  }) {
    return CarteFilterModel(
      showOnlyOpen: showOnlyOpen ?? this.showOnlyOpen,
      showOnlyWithDelivery: showOnlyWithDelivery ?? this.showOnlyWithDelivery,
      showOnlyPickup: showOnlyPickup ?? this.showOnlyPickup,
      showOnlyTopRated: showOnlyTopRated ?? this.showOnlyTopRated,
      selectedRegion: selectedRegion ?? this.selectedRegion,
    );
  }
}

