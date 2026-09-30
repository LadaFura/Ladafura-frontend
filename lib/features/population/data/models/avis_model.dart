/// Détail d'un avis client et statut de modération (US-12).
class PopulationAvisModel {
  final int id;
  final int produitId;
  final String nomProduit;
  final String? formeProduit;
  final String? photoProduitUrl;
  final int note; // 1 à 5 étoiles
  final String? commentaire;
  final DateTime dateAvis;
  final String statut; // EN_ATTENTE, PUBLIE, REJETE, MASQUE
  final String? statutLibelle;

  const PopulationAvisModel({
    required this.id,
    required this.produitId,
    required this.nomProduit,
    this.formeProduit,
    this.photoProduitUrl,
    required this.note,
    this.commentaire,
    required this.dateAvis,
    this.statut = 'EN_ATTENTE',
    this.statutLibelle,
  });

  bool get isPublie => statut == 'PUBLIE';
  bool get isEnAttente => statut == 'EN_ATTENTE';

  factory PopulationAvisModel.fromJson(Map<String, dynamic> json) {
    return PopulationAvisModel(
      id: json['id'] as int? ?? 0,
      produitId: json['produitId'] as int? ?? 0,
      nomProduit: json['nomProduit'] as String? ?? '',
      formeProduit: json['formeProduit'] as String?,
      photoProduitUrl: json['photoProduitUrl'] as String?,
      note: json['note'] as int? ?? 5,
      commentaire: json['commentaire'] as String?,
      dateAvis: json['dateAvis'] != null
          ? DateTime.tryParse(json['dateAvis'].toString()) ?? DateTime.now()
          : DateTime.now(),
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      statutLibelle: json['statutLibelle'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'produitId': produitId,
        'nomProduit': nomProduit,
        'formeProduit': formeProduit,
        'photoProduitUrl': photoProduitUrl,
        'note': note,
        'commentaire': commentaire,
        'dateAvis': dateAvis.toIso8601String(),
        'statut': statut,
        'statutLibelle': statutLibelle,
      };
}

/// Vérification préalable de l'éligibilité pour déposer un avis (commande reçue).
class PopulationEligibiliteAvisModel {
  final int produitId;
  final String nomProduit;
  final bool eligible;
  final bool dejaEvalue;
  final int? avisId;
  final String? message;

  const PopulationEligibiliteAvisModel({
    required this.produitId,
    required this.nomProduit,
    this.eligible = false,
    this.dejaEvalue = false,
    this.avisId,
    this.message,
  });

  factory PopulationEligibiliteAvisModel.fromJson(Map<String, dynamic> json) {
    return PopulationEligibiliteAvisModel(
      produitId: json['produitId'] as int? ?? 0,
      nomProduit: json['nomProduit'] as String? ?? '',
      eligible: json['eligible'] as bool? ?? false,
      dejaEvalue: json['dejaEvalue'] as bool? ?? false,
      avisId: json['avisId'] as int?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'produitId': produitId,
        'nomProduit': nomProduit,
        'eligible': eligible,
        'dejaEvalue': dejaEvalue,
        if (avisId != null) 'avisId': avisId,
        'message': message,
      };
}

/// Demande de publication ou modification d'un avis client.
class PopulationCreateAvisRequestModel {
  final int produitId;
  final int note; // 1 à 5
  final String? commentaire;

  const PopulationCreateAvisRequestModel({
    required this.produitId,
    required this.note,
    this.commentaire,
  });

  Map<String, dynamic> toJson() => {
        'produitId': produitId,
        'note': note,
        if (commentaire != null) 'commentaire': commentaire,
      };
}
