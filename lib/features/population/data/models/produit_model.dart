/// Modèle synthétique d'un médicament traditionnel ou produit de pharmacopée (Fura).
///
/// Conforme au DTO backend `PopulationProduitSummaryResponse.java`.
class ProduitModel {
  final int id;
  final String nom;
  final String? description;
  final String? forme;
  final double prixIndicatif;
  final String? photoUrl;
  final int? categorieId;
  final String? categorieNom;
  final List<String> plantesPrincipales;
  final int nombrePharmacopees;
  final bool disponibleEnPharmacie;
  final double noteMoyenne;
  final int nombreAvis;

  const ProduitModel({
    required this.id,
    required this.nom,
    this.description,
    this.forme,
    required this.prixIndicatif,
    this.photoUrl,
    this.categorieId,
    this.categorieNom,
    this.plantesPrincipales = const [],
    this.nombrePharmacopees = 1,
    this.disponibleEnPharmacie = true,
    this.noteMoyenne = 4.8,
    this.nombreAvis = 15,
  });

  /// Prix formaté en Francs CFA (ex: "2 500 FCFA").
  String get prixFormate {
    final intValue = prixIndicatif.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory ProduitModel.fromJson(Map<String, dynamic> json) {
    return ProduitModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? 'Remède Traditionnel',
      description: json['description']?.toString(),
      forme: json['forme']?.toString() ?? 'Préparation traditionnelle',
      prixIndicatif: (json['prixIndicatif'] as num?)?.toDouble() ?? 2500.0,
      photoUrl: json['photoUrl']?.toString(),
      categorieId: (json['categorieId'] as num?)?.toInt(),
      categorieNom: json['categorieNom']?.toString() ?? 'Phytothérapie',
      plantesPrincipales: (json['plantesPrincipales'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      nombrePharmacopees: (json['nombrePharmacopees'] as num?)?.toInt() ?? 1,
      disponibleEnPharmacie: json['disponibleEnPharmacie'] as bool? ?? true,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 4.8,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'forme': forme,
        'prixIndicatif': prixIndicatif,
        'photoUrl': photoUrl,
        'categorieId': categorieId,
        'categorieNom': categorieNom,
        'plantesPrincipales': plantesPrincipales,
        'nombrePharmacopees': nombrePharmacopees,
        'disponibleEnPharmacie': disponibleEnPharmacie,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
      };
}
