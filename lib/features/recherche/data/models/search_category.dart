/// Catégories de filtrage pour les résultats de recherche LADAFURA.
enum SearchCategory {
  all('Tous'),
  pharmacopees('Pharmacopée'),
  plantes('Plante');

  final String label;
  const SearchCategory(this.label);
}
