/// Résumé synthétique d'un remède ou produit traditionnel dans le catalogue LADAFURA.
/// 
/// Conforme au DTO backend `PopulationProduitSummaryResponse.java` (US-04 & US-06).
class ProduitSommaireModel {
  final int id;
  final String nom;
  final String? description;
  final String? forme;
  final double? prixIndicatif;
  final String? photoUrl;
  final int? categorieId;
  final String? categorieNom;
  final List<String> plantesPrincipales;
  final int nombrePharmacopees;
  final bool disponibleEnPharmacie;
  final double? noteMoyenne;
  final int nombreAvis;

  const ProduitSommaireModel({
    required this.id,
    required this.nom,
    this.description,
    this.forme,
    this.prixIndicatif,
    this.photoUrl,
    this.categorieId,
    this.categorieNom,
    this.plantesPrincipales = const [],
    this.nombrePharmacopees = 0,
    this.disponibleEnPharmacie = false,
    this.noteMoyenne,
    this.nombreAvis = 0,
  });

  /// Indique si le produit est actuellement en stock dans au moins une officine.
  bool get isDisponible => disponibleEnPharmacie && nombrePharmacopees > 0;

  /// Indique si le produit possède une image officielle.
  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  /// Prix formaté en Franc CFA avec séparateur de milliers (ex: "2 500 FCFA").
  String get prixFormate {
    if (prixIndicatif == null) return 'Prix non communiqué';
    final intPrice = prixIndicatif!.toInt();
    final formatted = intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  /// Note moyenne formatée (ex: "4.5 / 5").
  String get noteFormatee =>
      noteMoyenne != null ? '${noteMoyenne!.toStringAsFixed(1)} / 5' : 'Nouveau';

  ProduitSommaireModel copyWith({
    int? id,
    String? nom,
    String? description,
    String? forme,
    double? prixIndicatif,
    String? photoUrl,
    int? categorieId,
    String? categorieNom,
    List<String>? plantesPrincipales,
    int? nombrePharmacopees,
    bool? disponibleEnPharmacie,
    double? noteMoyenne,
    int? nombreAvis,
  }) {
    return ProduitSommaireModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      forme: forme ?? this.forme,
      prixIndicatif: prixIndicatif ?? this.prixIndicatif,
      photoUrl: photoUrl ?? this.photoUrl,
      categorieId: categorieId ?? this.categorieId,
      categorieNom: categorieNom ?? this.categorieNom,
      plantesPrincipales: plantesPrincipales ?? this.plantesPrincipales,
      nombrePharmacopees: nombrePharmacopees ?? this.nombrePharmacopees,
      disponibleEnPharmacie:
          disponibleEnPharmacie ?? this.disponibleEnPharmacie,
      noteMoyenne: noteMoyenne ?? this.noteMoyenne,
      nombreAvis: nombreAvis ?? this.nombreAvis,
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

  factory ProduitSommaireModel.fromJson(Map<String, dynamic> json) {
    return ProduitSommaireModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      forme: json['forme']?.toString(),
      prixIndicatif: (json['prixIndicatif'] as num?)?.toDouble(),
      photoUrl: json['photoUrl']?.toString(),
      categorieId: (json['categorieId'] as num?)?.toInt(),
      categorieNom: json['categorieNom']?.toString(),
      plantesPrincipales: json['plantesPrincipales'] is List
          ? (json['plantesPrincipales'] as List)
              .map((e) => e.toString())
              .toList()
          : const [],
      nombrePharmacopees: (json['nombrePharmacopees'] as num?)?.toInt() ?? 0,
      disponibleEnPharmacie:
          (json['disponibleEnPharmacie'] as bool?) ?? false,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble(),
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'ProduitSommaireModel(id: $id, nom: $nom, prix: $prixFormate, dispo: $isDisponible)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProduitSommaireModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nom == other.nom;

  @override
  int get hashCode => id.hashCode ^ nom.hashCode;
}
