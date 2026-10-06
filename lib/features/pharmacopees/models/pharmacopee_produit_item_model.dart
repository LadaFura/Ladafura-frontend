import '../../plantes/models/produit_model.dart';

/// Produit proposé par une pharmacopée avec son prix de vente et son stock disponible.
/// Conforme au DTO backend `PopulationPharmacopeeProduitItemResponse.java`.
class PharmacopeeProduitItemModel {
  final int disponibiliteId;
  final int produitId;
  final String nom;
  final String? description;
  final String? forme;
  final double prix;
  final String? photoUrl;
  final int? categorieId;
  final String? categorieNom;
  final bool disponible;
  final int quantiteStock;

  const PharmacopeeProduitItemModel({
    required this.disponibiliteId,
    required this.produitId,
    required this.nom,
    this.description,
    this.forme,
    required this.prix,
    this.photoUrl,
    this.categorieId,
    this.categorieNom,
    required this.disponible,
    required this.quantiteStock,
  });

  /// Prix formaté en Francs CFA (ex: "2 500 FCFA").
  String get prixFormate {
    final intValue = prix.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  /// Statut textuel du stock
  String get stockLibelle {
    if (!disponible || quantiteStock <= 0) return 'Épuisé';
    if (quantiteStock <= 3) return 'Plus que $quantiteStock en stock';
    return 'En stock';
  }

  /// Convertit cet item en ProduitModel pour compatibilité avec le panier
  ProduitModel toProduitModel() {
    return ProduitModel(
      id: produitId,
      nom: nom,
      description: description,
      forme: forme,
      prixIndicatif: prix,
      photoUrl: photoUrl,
      categorieId: categorieId,
      categorieNom: categorieNom,
      disponibleEnPharmacie: disponible,
    );
  }

  factory PharmacopeeProduitItemModel.fromJson(Map<String, dynamic> json) {
    return PharmacopeeProduitItemModel(
      disponibiliteId: (json['disponibiliteId'] as num?)?.toInt() ?? 0,
      produitId: (json['produitId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      nom: json['nom']?.toString() ?? 'Remède Traditionnel',
      description: json['description']?.toString(),
      forme: json['forme']?.toString(),
      prix: (json['prix'] as num?)?.toDouble() ??
          (json['prixIndicatif'] as num?)?.toDouble() ??
          0.0,
      photoUrl: json['photoUrl']?.toString(),
      categorieId: (json['categorieId'] as num?)?.toInt(),
      categorieNom: json['categorieNom']?.toString() ?? 'Phytothérapie',
      disponible: json['disponible'] as bool? ?? (json['quantiteStock'] != null && (json['quantiteStock'] as num) > 0),
      quantiteStock: (json['quantiteStock'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'disponibiliteId': disponibiliteId,
        'produitId': produitId,
        'nom': nom,
        'description': description,
        'forme': forme,
        'prix': prix,
        'photoUrl': photoUrl,
        'categorieId': categorieId,
        'categorieNom': categorieNom,
        'disponible': disponible,
        'quantiteStock': quantiteStock,
      };
}
