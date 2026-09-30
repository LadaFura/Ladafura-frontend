import 'package:ladafura_frontend_flutter/shared/enums/statut_commande.dart';

/// Détail d'une ligne d'article dans une commande ou un récapitulatif.
class PopulationLigneCommandeModel {
  final int? id;
  final int produitId;
  final String nomProduit;
  final String? forme;
  final String? photoUrl;
  final double prixUnitaire;
  final int quantite;
  final double sousTotal;

  const PopulationLigneCommandeModel({
    this.id,
    required this.produitId,
    required this.nomProduit,
    this.forme,
    this.photoUrl,
    required this.prixUnitaire,
    required this.quantite,
    required this.sousTotal,
  });

  factory PopulationLigneCommandeModel.fromJson(Map<String, dynamic> json) {
    return PopulationLigneCommandeModel(
      id: json['id'] as int?,
      produitId: json['produitId'] as int? ?? 0,
      nomProduit: json['nomProduit'] as String? ?? '',
      forme: json['forme'] as String?,
      photoUrl: json['photoUrl'] as String?,
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      quantite: json['quantite'] as int? ?? 1,
      sousTotal: (json['sousTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'produitId': produitId,
        'nomProduit': nomProduit,
        'forme': forme,
        'photoUrl': photoUrl,
        'prixUnitaire': prixUnitaire,
        'quantite': quantite,
        'sousTotal': sousTotal,
      };
}

/// Aperçu d'une commande dans l'historique utilisateur (US-11).
class PopulationCommandeSummaryModel {
  final int id;
  final String numero;
  final DateTime dateCommande;
  final StatutCommande statut;
  final int pharmacopeeId;
  final String nomPharmacopee;
  final String modeRetrait;
  final double montantTotal;
  final int nombreArticles;
  final String? statutPaiement;

  const PopulationCommandeSummaryModel({
    required this.id,
    required this.numero,
    required this.dateCommande,
    required this.statut,
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    required this.modeRetrait,
    required this.montantTotal,
    this.nombreArticles = 0,
    this.statutPaiement,
  });

  factory PopulationCommandeSummaryModel.fromJson(Map<String, dynamic> json) {
    return PopulationCommandeSummaryModel(
      id: json['id'] as int? ?? 0,
      numero: json['numero'] as String? ?? '',
      dateCommande: json['dateCommande'] != null
          ? DateTime.tryParse(json['dateCommande'].toString()) ?? DateTime.now()
          : DateTime.now(),
      statut: StatutCommande.fromString(json['statut']?.toString()) ??
          StatutCommande.enAttente,
      pharmacopeeId: json['pharmacopeeId'] as int? ?? 0,
      nomPharmacopee: json['nomPharmacopee'] as String? ?? '',
      modeRetrait: json['modeRetrait'] as String? ?? 'PICKUP',
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      nombreArticles: json['nombreArticles'] as int? ?? 0,
      statutPaiement: json['statutPaiement'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'dateCommande': dateCommande.toIso8601String(),
        'statut': statut.value,
        'pharmacopeeId': pharmacopeeId,
        'nomPharmacopee': nomPharmacopee,
        'modeRetrait': modeRetrait,
        'montantTotal': montantTotal,
        'nombreArticles': nombreArticles,
        'statutPaiement': statutPaiement,
      };
}

/// Fiche détaillée complète d'une commande (US-08, US-11).
class PopulationCommandeDetailModel {
  final int id;
  final String numero;
  final DateTime dateCommande;
  final DateTime? dateMiseAJour;
  final StatutCommande statut;
  final int pharmacopeeId;
  final String nomPharmacopee;
  final String? telephonePharmacopee;
  final String? adressePharmacopee;
  final String modeRetrait;
  final double montantLivraison;
  final String? adresseLivraison;
  final double totalProduit;
  final double montantTotal;
  final bool annulable;
  final List<PopulationLigneCommandeModel> lignes;
  final String? statutPaiement;

  const PopulationCommandeDetailModel({
    required this.id,
    required this.numero,
    required this.dateCommande,
    this.dateMiseAJour,
    required this.statut,
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    this.telephonePharmacopee,
    this.adressePharmacopee,
    required this.modeRetrait,
    this.montantLivraison = 0.0,
    this.adresseLivraison,
    required this.totalProduit,
    required this.montantTotal,
    this.annulable = false,
    this.lignes = const [],
    this.statutPaiement,
  });

  factory PopulationCommandeDetailModel.fromJson(Map<String, dynamic> json) {
    return PopulationCommandeDetailModel(
      id: json['id'] as int? ?? 0,
      numero: json['numero'] as String? ?? '',
      dateCommande: json['dateCommande'] != null
          ? DateTime.tryParse(json['dateCommande'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateMiseAJour: json['dateMiseAJour'] != null
          ? DateTime.tryParse(json['dateMiseAJour'].toString())
          : null,
      statut: StatutCommande.fromString(json['statut']?.toString()) ??
          StatutCommande.enAttente,
      pharmacopeeId: json['pharmacopeeId'] as int? ?? 0,
      nomPharmacopee: json['nomPharmacopee'] as String? ?? '',
      telephonePharmacopee: json['telephonePharmacopee'] as String?,
      adressePharmacopee: json['adressePharmacopee'] as String?,
      modeRetrait: json['modeRetrait'] as String? ?? 'PICKUP',
      montantLivraison: (json['montantLivraison'] as num?)?.toDouble() ?? 0.0,
      adresseLivraison: json['adresseLivraison'] as String?,
      totalProduit: (json['totalProduit'] as num?)?.toDouble() ?? 0.0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      annulable: json['annulable'] as bool? ?? false,
      lignes: (json['lignes'] as List<dynamic>?)
              ?.map((e) => PopulationLigneCommandeModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      statutPaiement: json['statutPaiement'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'dateCommande': dateCommande.toIso8601String(),
        'dateMiseAJour': dateMiseAJour?.toIso8601String(),
        'statut': statut.value,
        'pharmacopeeId': pharmacopeeId,
        'nomPharmacopee': nomPharmacopee,
        'telephonePharmacopee': telephonePharmacopee,
        'adressePharmacopee': adressePharmacopee,
        'modeRetrait': modeRetrait,
        'montantLivraison': montantLivraison,
        'adresseLivraison': adresseLivraison,
        'totalProduit': totalProduit,
        'montantTotal': montantTotal,
        'annulable': annulable,
        'lignes': lignes.map((e) => e.toJson()).toList(),
        'statutPaiement': statutPaiement,
      };
}

/// Demande de devis/récapitulatif avant confirmation de la commande.
class PopulationCommandeRecapitulatifRequestModel {
  final int pharmacopeeId;
  final int modeRetraitId;
  final String? adresseLivraison;

  const PopulationCommandeRecapitulatifRequestModel({
    required this.pharmacopeeId,
    required this.modeRetraitId,
    this.adresseLivraison,
  });

  Map<String, dynamic> toJson() => {
        'pharmacopeeId': pharmacopeeId,
        'modeRetraitId': modeRetraitId,
        if (adresseLivraison != null) 'adresseLivraison': adresseLivraison,
      };
}

/// Devis/récapitulatif chiffré avant confirmation de la commande.
class PopulationCommandeRecapitulatifModel {
  final int pharmacopeeId;
  final String nomPharmacopee;
  final String? telephonePharmacopee;
  final String modeRetrait;
  final double fraisLivraison;
  final double totalProduits;
  final double montantTotal;
  final List<PopulationLigneCommandeModel> lignes;

  const PopulationCommandeRecapitulatifModel({
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    this.telephonePharmacopee,
    required this.modeRetrait,
    this.fraisLivraison = 0.0,
    required this.totalProduits,
    required this.montantTotal,
    this.lignes = const [],
  });

  factory PopulationCommandeRecapitulatifModel.fromJson(
      Map<String, dynamic> json) {
    return PopulationCommandeRecapitulatifModel(
      pharmacopeeId: json['pharmacopeeId'] as int? ?? 0,
      nomPharmacopee: json['nomPharmacopee'] as String? ?? '',
      telephonePharmacopee: json['telephonePharmacopee'] as String?,
      modeRetrait: json['modeRetrait'] as String? ?? 'PICKUP',
      fraisLivraison: (json['fraisLivraison'] as num?)?.toDouble() ?? 0.0,
      totalProduits: (json['totalProduits'] as num?)?.toDouble() ?? 0.0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      lignes: (json['lignes'] as List<dynamic>?)
              ?.map((e) => PopulationLigneCommandeModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'pharmacopeeId': pharmacopeeId,
        'nomPharmacopee': nomPharmacopee,
        'telephonePharmacopee': telephonePharmacopee,
        'modeRetrait': modeRetrait,
        'fraisLivraison': fraisLivraison,
        'totalProduits': totalProduits,
        'montantTotal': montantTotal,
        'lignes': lignes.map((e) => e.toJson()).toList(),
      };
}

/// Requête de validation et passage définitif d'une commande (US-08).
class PopulationCreateCommandeRequestModel {
  final int pharmacopeeId;
  final int modeRetraitId;
  final String? adresseLivraison;
  final String? notes;

  const PopulationCreateCommandeRequestModel({
    required this.pharmacopeeId,
    required this.modeRetraitId,
    this.adresseLivraison,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'pharmacopeeId': pharmacopeeId,
        'modeRetraitId': modeRetraitId,
        if (adresseLivraison != null) 'adresseLivraison': adresseLivraison,
        if (notes != null) 'notes': notes,
      };
}

/// Suivi en direct du statut d'une commande.
class PopulationCommandeStatutModel {
  final int id;
  final String numero;
  final StatutCommande statut;
  final DateTime dateCommande;
  final DateTime? dateMiseAJour;
  final String modeRetrait;
  final bool annulable;
  final String message;

  const PopulationCommandeStatutModel({
    required this.id,
    required this.numero,
    required this.statut,
    required this.dateCommande,
    this.dateMiseAJour,
    required this.modeRetrait,
    this.annulable = false,
    required this.message,
  });

  factory PopulationCommandeStatutModel.fromJson(Map<String, dynamic> json) {
    return PopulationCommandeStatutModel(
      id: json['id'] as int? ?? 0,
      numero: json['numero'] as String? ?? '',
      statut: StatutCommande.fromString(json['statut']?.toString()) ??
          StatutCommande.enAttente,
      dateCommande: json['dateCommande'] != null
          ? DateTime.tryParse(json['dateCommande'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateMiseAJour: json['dateMiseAJour'] != null
          ? DateTime.tryParse(json['dateMiseAJour'].toString())
          : null,
      modeRetrait: json['modeRetrait'] as String? ?? 'PICKUP',
      annulable: json['annulable'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'statut': statut.value,
        'dateCommande': dateCommande.toIso8601String(),
        'dateMiseAJour': dateMiseAJour?.toIso8601String(),
        'modeRetrait': modeRetrait,
        'annulable': annulable,
        'message': message,
      };
}
