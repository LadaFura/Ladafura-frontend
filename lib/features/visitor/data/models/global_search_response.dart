/// Modèle de résultat consolidé de la recherche universelle LADAFURA.
class GlobalSearchResponse {
  final String query;
  final int totalResultats;
  final List<PlanteSearchItem> plantes;
  final List<MaladieSearchItem> maladies;
  final List<ProduitSearchItem> produits;

  const GlobalSearchResponse({
    required this.query,
    this.totalResultats = 0,
    this.plantes = const [],
    this.maladies = const [],
    this.produits = const [],
  });

  factory GlobalSearchResponse.fromJson(Map<String, dynamic> json) {
    return GlobalSearchResponse(
      query: json['query']?.toString() ?? '',
      totalResultats: (json['totalResultats'] as num?)?.toInt() ?? 0,
      plantes: (json['plantes'] as List<dynamic>?)
              ?.map((e) => PlanteSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      maladies: (json['maladies'] as List<dynamic>?)
              ?.map(
                  (e) => MaladieSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      produits: (json['produits'] as List<dynamic>?)
              ?.map(
                  (e) => ProduitSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  bool get isEmpty => plantes.isEmpty && maladies.isEmpty && produits.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class PlanteSearchItem {
  final int id;
  final String nomScientifique;
  final String? description;
  final String? photoUrl;
  final List<String> nomsVernaculaires;

  const PlanteSearchItem({
    required this.id,
    required this.nomScientifique,
    this.description,
    this.photoUrl,
    this.nomsVernaculaires = const [],
  });

  factory PlanteSearchItem.fromJson(Map<String, dynamic> json) {
    return PlanteSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nomScientifique: json['nomScientifique']?.toString() ?? '',
      description: json['description']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      nomsVernaculaires: (json['nomsVernaculaires'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class MaladieSearchItem {
  final int id;
  final String nom;
  final String? description;
  final int nombrePlantesAssociees;

  const MaladieSearchItem({
    required this.id,
    required this.nom,
    this.description,
    this.nombrePlantesAssociees = 0,
  });

  factory MaladieSearchItem.fromJson(Map<String, dynamic> json) {
    return MaladieSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      nombrePlantesAssociees:
          (json['nombrePlantesAssociees'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProduitSearchItem {
  final int id;
  final String nom;
  final String? description;
  final double prix;
  final String? photoUrl;

  const ProduitSearchItem({
    required this.id,
    required this.nom,
    this.description,
    this.prix = 0.0,
    this.photoUrl,
  });

  factory ProduitSearchItem.fromJson(Map<String, dynamic> json) {
    return ProduitSearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl']?.toString(),
    );
  }
}
