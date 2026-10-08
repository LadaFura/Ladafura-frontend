import 'paiement_model.dart';

/// Ligne d'article détaillée dans une commande ou un devis récapitulatif.
///
/// Conforme au DTO backend `PopulationLigneCommandeDto.java`.
class CommandeLigneModel {
  final int id;
  final int produitId;
  final String nomProduit;
  final String? forme;
  final String? photoUrl;
  final double prixUnitaire;
  final int quantite;
  final double sousTotal;

  const CommandeLigneModel({
    required this.id,
    required this.produitId,
    required this.nomProduit,
    this.forme,
    this.photoUrl,
    required this.prixUnitaire,
    required this.quantite,
    required this.sousTotal,
  });

  String get prixUnitaireFormate {
    final intValue = prixUnitaire.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String get sousTotalFormate {
    final intValue = sousTotal.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory CommandeLigneModel.fromJson(Map<String, dynamic> json) {
    return CommandeLigneModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      produitId: (json['produitId'] as num?)?.toInt() ?? 0,
      nomProduit: json['nomProduit']?.toString() ?? 'Produit',
      forme: json['forme']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      quantite: (json['quantite'] as num?)?.toInt() ?? 1,
      sousTotal: (json['sousTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'produitId': produitId,
        'nomProduit': nomProduit,
        'forme': forme,
        'photoUrl': photoUrl,
        'prixUnitaire': prixUnitaire,
        'quantite': quantite,
        'sousTotal': sousTotal,
      };
}

/// Devis et simulation chiffrée avant confirmation de la commande.
///
/// Conforme au DTO backend `PopulationCommandeRecapitulatifResponse.java`.
class CommandeRecapitulatifModel {
  final int pharmacopeeId;
  final String nomPharmacopee;
  final String? telephonePharmacopee;
  final String modeRetrait;
  final double fraisLivraison;
  final double totalProduits;
  final double montantTotal;
  final int nombreArticles;
  final List<CommandeLigneModel> lignes;

  const CommandeRecapitulatifModel({
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    this.telephonePharmacopee,
    required this.modeRetrait,
    this.fraisLivraison = 0.0,
    required this.totalProduits,
    required this.montantTotal,
    this.nombreArticles = 0,
    this.lignes = const [],
  });

  String get totalProduitsFormate {
    final intValue = totalProduits.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String get fraisLivraisonFormate {
    if (fraisLivraison <= 0) return 'Gratuit';
    final intValue = fraisLivraison.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String get montantTotalFormate {
    final intValue = montantTotal.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory CommandeRecapitulatifModel.fromJson(Map<String, dynamic> json) {
    return CommandeRecapitulatifModel(
      pharmacopeeId: (json['pharmacopeeId'] as num?)?.toInt() ?? 0,
      nomPharmacopee: json['nomPharmacopee']?.toString() ?? 'Pharmacopée',
      telephonePharmacopee: json['telephonePharmacopee']?.toString(),
      modeRetrait: json['modeRetrait']?.toString() ?? 'PICKUP',
      fraisLivraison: (json['fraisLivraison'] as num?)?.toDouble() ?? 0.0,
      totalProduits: (json['totalProduits'] as num?)?.toDouble() ?? 0.0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      nombreArticles: (json['nombreArticles'] as num?)?.toInt() ?? 0,
      lignes: (json['lignes'] as List<dynamic>?)
              ?.map((e) => CommandeLigneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// Aperçu d'une commande dans la liste historique.
///
/// Conforme au DTO backend `PopulationCommandeSummaryResponse.java`.
class CommandeSummaryModel {
  final int id;
  final String numero;
  final DateTime dateCommande;
  final String statut;
  final int pharmacopeeId;
  final String nomPharmacopee;
  final String modeRetrait;
  final double totalProduit;
  final double montantLivraison;
  final double montantTotal;
  final int nombreArticles;
  final bool annulable;

  const CommandeSummaryModel({
    required this.id,
    required this.numero,
    required this.dateCommande,
    required this.statut,
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    required this.modeRetrait,
    this.totalProduit = 0.0,
    this.montantLivraison = 0.0,
    required this.montantTotal,
    this.nombreArticles = 0,
    this.annulable = false,
  });

  String get montantTotalFormate {
    final intValue = montantTotal.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory CommandeSummaryModel.fromJson(Map<String, dynamic> json) {
    return CommandeSummaryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      numero: json['numero']?.toString() ?? '',
      dateCommande: json['dateCommande'] != null
          ? DateTime.tryParse(json['dateCommande'].toString()) ?? DateTime.now()
          : DateTime.now(),
      statut: json['statut']?.toString() ?? 'EN_ATTENTE',
      pharmacopeeId: (json['pharmacopeeId'] as num?)?.toInt() ?? 0,
      nomPharmacopee: json['nomPharmacopee']?.toString() ?? 'Pharmacopée',
      modeRetrait: json['modeRetrait']?.toString() ?? 'PICKUP',
      totalProduit: (json['totalProduit'] as num?)?.toDouble() ?? 0.0,
      montantLivraison: (json['montantLivraison'] as num?)?.toDouble() ?? 0.0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      nombreArticles: (json['nombreArticles'] as num?)?.toInt() ?? 0,
      annulable: json['annulable'] as bool? ?? false,
    );
  }
}

/// Fiche détaillée complète d'une commande.
///
/// Conforme au DTO backend `PopulationCommandeDetailResponse.java`.
class CommandeDetailModel {
  final int id;
  final String numero;
  final DateTime dateCommande;
  final DateTime? dateMiseAJour;
  final String statut;
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
  final List<CommandeLigneModel> lignes;
  final String statutPaiement;
  final int? paiementId;
  final String? referencePaiement;
  final String? methodePaiement;
  final String? libellePaiement;

  const CommandeDetailModel({
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
    this.totalProduit = 0.0,
    required this.montantTotal,
    this.annulable = false,
    this.lignes = const [],
    this.statutPaiement = 'EN_ATTENTE',
    this.paiementId,
    this.referencePaiement,
    this.methodePaiement,
    this.libellePaiement,
  });

  bool get isLivraison => modeRetrait.toUpperCase() == 'LIVRAISON';
  bool get isPickup => modeRetrait.toUpperCase() == 'PICKUP';

  String get montantTotalFormate {
    final intValue = montantTotal.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String get totalProduitFormate {
    final intValue = totalProduit.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String get montantLivraisonFormate {
    if (montantLivraison <= 0) return 'Gratuit';
    final intValue = montantLivraison.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  PaiementResponseModel toPaiementResponse() {
    return PaiementResponseModel(
      id: paiementId ?? 0,
      reference: referencePaiement ?? '',
      commandeId: id,
      numeroCommande: numero,
      montant: montantTotal,
      methode: methodePaiement ?? 'CASH',
      libelleMethode: libellePaiement ?? (methodePaiement ?? 'Règlement'),
      statut: statutPaiement,
      datePaiement: dateCommande,
      succes: statutPaiement == 'REUSSI' || statutPaiement == 'EN_ATTENTE',
      message: statutPaiement == 'REUSSI'
          ? 'Votre paiement a été validé avec succès.'
          : 'Règlement en attente de perception.',
      statutCommande: statut,
    );
  }

  factory CommandeDetailModel.fromJson(Map<String, dynamic> json) {
    return CommandeDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      numero: json['numero']?.toString() ?? '',
      dateCommande: json['dateCommande'] != null
          ? DateTime.tryParse(json['dateCommande'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateMiseAJour: json['dateMiseAJour'] != null
          ? DateTime.tryParse(json['dateMiseAJour'].toString())
          : null,
      statut: json['statut']?.toString() ?? 'EN_ATTENTE',
      pharmacopeeId: (json['pharmacopeeId'] as num?)?.toInt() ?? 0,
      nomPharmacopee: json['nomPharmacopee']?.toString() ?? 'Pharmacopée',
      telephonePharmacopee: json['telephonePharmacopee']?.toString(),
      adressePharmacopee: json['adressePharmacopee']?.toString(),
      modeRetrait: json['modeRetrait']?.toString() ?? 'PICKUP',
      montantLivraison: (json['montantLivraison'] as num?)?.toDouble() ?? 0.0,
      adresseLivraison: json['adresseLivraison']?.toString(),
      totalProduit: (json['totalProduit'] as num?)?.toDouble() ?? 0.0,
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      annulable: json['annulable'] as bool? ?? false,
      lignes: (json['lignes'] as List<dynamic>?)
              ?.map((e) => CommandeLigneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      statutPaiement: json['statutPaiement']?.toString() ?? 'EN_ATTENTE',
      paiementId: (json['paiementId'] as num?)?.toInt(),
      referencePaiement: json['referencePaiement']?.toString(),
      methodePaiement: json['methodePaiement']?.toString(),
      libellePaiement: json['libellePaiement']?.toString(),
    );
  }
}

// Adaptateur pour l'ancien CommandeModel
class CommandeItemModel {
  final int produitId;
  final String nomProduit;
  final int quantite;
  final double prixUnitaire;

  const CommandeItemModel({
    required this.produitId,
    required this.nomProduit,
    required this.quantite,
    required this.prixUnitaire,
  });

  factory CommandeItemModel.fromJson(Map<String, dynamic> json) {
    return CommandeItemModel(
      produitId: json['produitId'] as int? ?? 0,
      nomProduit: json['nomProduit'] as String? ?? '',
      quantite: json['quantite'] as int? ?? 1,
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CommandeModel {
  final int id;
  final String numeroCommande;
  final String statut;
  final double montantTotal;
  final DateTime dateCreation;
  final List<CommandeItemModel> items;

  const CommandeModel({
    required this.id,
    required this.numeroCommande,
    required this.statut,
    required this.montantTotal,
    required this.dateCreation,
    this.items = const [],
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'] as int? ?? 0,
      numeroCommande: json['numero'] as String? ??
          json['numeroCommande'] as String? ??
          '',
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      dateCreation: json['dateCommande'] != null
          ? DateTime.tryParse(json['dateCommande'] as String) ?? DateTime.now()
          : (json['dateCreation'] != null
              ? DateTime.tryParse(json['dateCreation'] as String) ??
                  DateTime.now()
              : DateTime.now()),
      items: (json['lignes'] as List?)
              ?.map((e) => CommandeItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
