enum TypeFavori {
  plante('PLANTE', 'Plantes'),
  produit('PRODUIT', 'Produits'),
  pharmacopee('PHARMACOPEE', 'Pharmacopées');

  final String backendValue;
  final String label;
  const TypeFavori(this.backendValue, this.label);

  static TypeFavori fromString(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'PRODUIT':
        return TypeFavori.produit;
      case 'PHARMACOPEE':
        return TypeFavori.pharmacopee;
      case 'PLANTE':
      default:
        return TypeFavori.plante;
    }
  }
}

class FavoriPlanteSummary {
  final int id;
  final String nomScientifique;
  final String? description;
  final String? photoUrl;
  final List<String> nomsVernaculaires;
  final List<String> maladies;

  const FavoriPlanteSummary({
    required this.id,
    required this.nomScientifique,
    this.description,
    this.photoUrl,
    this.nomsVernaculaires = const [],
    this.maladies = const [],
  });

  factory FavoriPlanteSummary.fromJson(Map<String, dynamic> json) {
    return FavoriPlanteSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nomScientifique: json['nomScientifique']?.toString() ?? '',
      description: json['description']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      nomsVernaculaires: (json['nomsVernaculaires'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      maladies: (json['maladies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class FavoriProduitSummary {
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
  final double noteMoyenne;
  final int nombreAvis;

  const FavoriProduitSummary({
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
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
  });

  factory FavoriProduitSummary.fromJson(Map<String, dynamic> json) {
    return FavoriProduitSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      forme: json['forme']?.toString(),
      prixIndicatif: (json['prixIndicatif'] as num?)?.toDouble(),
      photoUrl: json['photoUrl']?.toString(),
      categorieId: (json['categorieId'] as num?)?.toInt(),
      categorieNom: json['categorieNom']?.toString(),
      plantesPrincipales: (json['plantesPrincipales'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      nombrePharmacopees: (json['nombrePharmacopees'] as num?)?.toInt() ?? 0,
      disponibleEnPharmacie: json['disponibleEnPharmacie'] == true,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
    );
  }
}

class FavoriPharmacopeeSummary {
  final int id;
  final String nom;
  final String? description;
  final String? telephone;
  final String? region;
  final String? cercle;
  final String? commune;
  final String? localite;
  final bool proposeLivraison;
  final bool proposePickup;
  final int nombreProduits;
  final double noteMoyenne;
  final int nombreAvis;
  final String? photoUrl;

  const FavoriPharmacopeeSummary({
    required this.id,
    required this.nom,
    this.description,
    this.telephone,
    this.region,
    this.cercle,
    this.commune,
    this.localite,
    this.proposeLivraison = false,
    this.proposePickup = true,
    this.nombreProduits = 0,
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
    this.photoUrl,
  });

  String get adresseCourte {
    final parts = [localite, commune, region]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    return parts.isEmpty ? 'Mali' : parts.join(', ');
  }

  factory FavoriPharmacopeeSummary.fromJson(Map<String, dynamic> json) {
    return FavoriPharmacopeeSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      telephone: json['telephone']?.toString(),
      region: json['region']?.toString(),
      cercle: json['cercle']?.toString(),
      commune: json['commune']?.toString(),
      localite: json['localite']?.toString(),
      proposeLivraison: json['proposeLivraison'] == true,
      proposePickup: json['proposePickup'] != false,
      nombreProduits: (json['nombreProduits'] as num?)?.toInt() ?? 0,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
      nombreAvis: (json['nombreAvis'] as num?)?.toInt() ?? 0,
      photoUrl: json['photoUrl']?.toString(),
    );
  }
}

class FavoriItemModel {
  final int id;
  final TypeFavori type;
  final DateTime? dateAjout;
  final FavoriPlanteSummary? plante;
  final FavoriProduitSummary? produit;
  final FavoriPharmacopeeSummary? pharmacopee;

  const FavoriItemModel({
    required this.id,
    required this.type,
    this.dateAjout,
    this.plante,
    this.produit,
    this.pharmacopee,
  });

  int get cibleId {
    switch (type) {
      case TypeFavori.plante:
        return plante?.id ?? 0;
      case TypeFavori.produit:
        return produit?.id ?? 0;
      case TypeFavori.pharmacopee:
        return pharmacopee?.id ?? 0;
    }
  }

  factory FavoriItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: TypeFavori.fromString(json['type']?.toString()),
      dateAjout: json['dateAjout'] != null
          ? DateTime.tryParse(json['dateAjout'].toString())
          : null,
      plante: json['plante'] is Map<String, dynamic>
          ? FavoriPlanteSummary.fromJson(
              json['plante'] as Map<String, dynamic>)
          : null,
      produit: json['produit'] is Map<String, dynamic>
          ? FavoriProduitSummary.fromJson(
              json['produit'] as Map<String, dynamic>)
          : null,
      pharmacopee: json['pharmacopee'] is Map<String, dynamic>
          ? FavoriPharmacopeeSummary.fromJson(
              json['pharmacopee'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FavoriCountModel {
  final int total;
  final int totalPlantes;
  final int totalProduits;
  final int totalPharmacopees;

  const FavoriCountModel({
    this.total = 0,
    this.totalPlantes = 0,
    this.totalProduits = 0,
    this.totalPharmacopees = 0,
  });

  factory FavoriCountModel.fromJson(Map<String, dynamic> json) {
    return FavoriCountModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPlantes: (json['totalPlantes'] as num?)?.toInt() ?? 0,
      totalProduits: (json['totalProduits'] as num?)?.toInt() ?? 0,
      totalPharmacopees: (json['totalPharmacopees'] as num?)?.toInt() ?? 0,
    );
  }
}

class ToggleFavoriResponse {
  final TypeFavori type;
  final int cibleId;
  final bool favori;
  final int? favoriId;
  final String message;

  const ToggleFavoriResponse({
    required this.type,
    required this.cibleId,
    required this.favori,
    this.favoriId,
    required this.message,
  });

  factory ToggleFavoriResponse.fromJson(Map<String, dynamic> json) {
    return ToggleFavoriResponse(
      type: TypeFavori.fromString(json['type']?.toString()),
      cibleId: (json['cibleId'] as num?)?.toInt() ?? 0,
      favori: json['favori'] == true,
      favoriId: (json['favoriId'] as num?)?.toInt(),
      message: json['message']?.toString() ?? '',
    );
  }
}

