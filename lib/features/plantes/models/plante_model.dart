import 'package:ladafura_frontend_flutter/shared/models/plante_sommaire_model.dart';

/// Modèle pour les noms vernaculaires dans les langues maliennes (Bambara, Peul, etc.).
class PopulationNomVernaculaireModel {
  final int? id;
  final String nom;
  final String langue;
  final String? pays;
  final String? audioUrl;

  const PopulationNomVernaculaireModel({
    this.id,
    required this.nom,
    required this.langue,
    this.pays,
    this.audioUrl,
  });

  factory PopulationNomVernaculaireModel.fromJson(dynamic json) {
    if (json is String) {
      return PopulationNomVernaculaireModel(
        nom: json,
        langue: '',
      );
    }
    if (json is Map<String, dynamic>) {
      return PopulationNomVernaculaireModel(
        id: json['id'] as int?,
        nom: json['nom'] as String? ?? '',
        langue: json['langue'] as String? ?? 'Bambara',
        pays: json['pays'] as String? ?? 'Mali',
        audioUrl: json['audioUrl'] as String?,
      );
    }
    return PopulationNomVernaculaireModel(
      nom: json?.toString() ?? '',
      langue: '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nom': nom,
        'langue': langue,
        'pays': pays,
        if (audioUrl != null) 'audioUrl': audioUrl,
      };
}

/// Modèle pour les savoirs et usages traditionnels validés (séparés des études scientifiques).
class PopulationConnaissanceTraditionnelleModel {
  final int? id;
  final String usageRapporte;
  final String? partieUtilisee;
  final String? modePreparation;
  final String? posologie;
  final String? precautions;
  final String? informateurSource;

  const PopulationConnaissanceTraditionnelleModel({
    this.id,
    required this.usageRapporte,
    this.partieUtilisee,
    this.modePreparation,
    this.posologie,
    this.precautions,
    this.informateurSource,
  });

  factory PopulationConnaissanceTraditionnelleModel.fromJson(
      Map<String, dynamic> json) {
    return PopulationConnaissanceTraditionnelleModel(
      id: json['id'] as int?,
      usageRapporte: json['usageRapporte'] as String? ?? '',
      partieUtilisee: json['partieUtilisee'] as String?,
      modePreparation: (json['modePreparation'] ?? json['preparation']) as String?,
      posologie: json['posologie'] as String?,
      precautions: (json['precautions'] ?? json['precaution']) as String?,
      informateurSource: (json['informateurSource'] ?? json['description']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'usageRapporte': usageRapporte,
        'partieUtilisee': partieUtilisee,
        'modePreparation': modePreparation,
        'posologie': posologie,
        'precautions': precautions,
        'informateurSource': informateurSource,
      };
}

/// Modèle pour les publications scientifiques et études cliniques documentées.
class PopulationEtudeScientifiqueModel {
  final int? id;
  final String titre;
  final String? auteurs;
  final String? annee;
  final String? revueOuInstitution;
  final String? resume;
  final String? urlDocument;

  const PopulationEtudeScientifiqueModel({
    this.id,
    required this.titre,
    this.auteurs,
    this.annee,
    this.revueOuInstitution,
    this.resume,
    this.urlDocument,
  });

  factory PopulationEtudeScientifiqueModel.fromJson(Map<String, dynamic> json) {
    return PopulationEtudeScientifiqueModel(
      id: json['id'] as int?,
      titre: json['titre'] as String? ?? '',
      auteurs: json['auteurs'] as String?,
      annee: json['annee']?.toString(),
      revueOuInstitution: (json['revueOuInstitution'] ?? json['reference']) as String?,
      resume: json['resume'] as String?,
      urlDocument: (json['urlDocument'] ?? json['documentUrl']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'titre': titre,
        'auteurs': auteurs,
        'annee': annee,
        'revueOuInstitution': revueOuInstitution,
        'resume': resume,
        'urlDocument': urlDocument,
      };
}

/// Association d'une plante à une pathologie/maladie.
class PopulationPlanteMaladieModel {
  final int? id;
  final String nom;
  final String? description;

  const PopulationPlanteMaladieModel({
    this.id,
    required this.nom,
    this.description,
  });

  factory PopulationPlanteMaladieModel.fromJson(dynamic json) {
    if (json is String) {
      return PopulationPlanteMaladieModel(
        nom: json,
      );
    }
    if (json is Map<String, dynamic>) {
      return PopulationPlanteMaladieModel(
        id: json['id'] as int?,
        nom: json['nom'] as String? ?? '',
        description: json['description'] as String?,
      );
    }
    return PopulationPlanteMaladieModel(
      nom: json?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nom': nom,
        'description': description,
      };
}

/// Média rattaché à une plante (photo, enregistrement audio de terrain).
class PopulationPlanteMediaModel {
  final int? id;
  final String url;
  final String typeMedia; // IMAGE, AUDIO
  final String? description;

  const PopulationPlanteMediaModel({
    this.id,
    required this.url,
    required this.typeMedia,
    this.description,
  });

  factory PopulationPlanteMediaModel.fromJson(Map<String, dynamic> json) {
    return PopulationPlanteMediaModel(
      id: json['id'] as int?,
      url: json['url'] as String? ?? '',
      typeMedia: json['typeMedia'] as String? ?? 'IMAGE',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'url': url,
        'typeMedia': typeMedia,
        'description': description,
      };
}

/// Localité malienne répertoriée pour la présence de la plante.
class PopulationPlanteLocaliteModel {
  final int? id;
  final String region;
  final String? cercle;
  final String? commune;

  const PopulationPlanteLocaliteModel({
    this.id,
    required this.region,
    this.cercle,
    this.commune,
  });

  factory PopulationPlanteLocaliteModel.fromJson(Map<String, dynamic> json) {
    return PopulationPlanteLocaliteModel(
      id: json['id'] as int?,
      region: json['region'] as String? ?? '',
      cercle: json['cercle'] as String?,
      commune: json['commune'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'region': region,
        'cercle': cercle,
        'commune': commune,
      };
}

/// Fiche détaillée complète d'une plante médicinale (US-02, ENF11).
class PopulationPlanteDetailModel {
  final int id;
  final String nomScientifique;
  final String description;
  final String? photoUrl;
  final String? avertissementMedical;
  final List<PopulationNomVernaculaireModel> nomsVernaculaires;
  final List<PopulationConnaissanceTraditionnelleModel>
      connaissancesTraditionnelles;
  final List<PopulationEtudeScientifiqueModel> etudesScientifiques;
  final List<PopulationPlanteMaladieModel> maladiesAssociees;
  final List<PopulationPlanteMediaModel> medias;
  final List<PopulationPlanteLocaliteModel> localites;

  const PopulationPlanteDetailModel({
    required this.id,
    required this.nomScientifique,
    required this.description,
    this.photoUrl,
    this.avertissementMedical,
    this.nomsVernaculaires = const [],
    this.connaissancesTraditionnelles = const [],
    this.etudesScientifiques = const [],
    this.maladiesAssociees = const [],
    this.medias = const [],
    this.localites = const [],
  });

  /// Noms vernaculaires sous forme de chaîne lisible (ex: "Kinkéliba (Bambara), ...")
  String get nomsVernaculairesConcat {
    if (nomsVernaculaires.isEmpty) return 'Non renseigné';
    return nomsVernaculaires.map((nv) => '${nv.nom} (${nv.langue})').join(', ');
  }

  /// Convertit en PlanteSommaireModel pour l'affichage en carte
  PlanteSommaireModel toSommaire() {
    return PlanteSommaireModel(
      id: id,
      nomScientifique: nomScientifique,
      description: description,
      photoUrl: photoUrl,
      nomsVernaculaires: nomsVernaculaires.map((nv) => nv.nom).toList(),
      maladies: maladiesAssociees.map((m) => m.nom).toList(),
      nombreConnaissances: connaissancesTraditionnelles.length,
      nombreEtudesScientifiques: etudesScientifiques.length,
    );
  }

  factory PopulationPlanteDetailModel.fromJson(Map<String, dynamic> json) {
    // Dans le cas d'une réponse sommaire, le champ peut s'appeler 'maladies'
    final rawMaladies = json['maladiesAssociees'] ?? json['maladies'];

    return PopulationPlanteDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nomScientifique: json['nomScientifique'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      avertissementMedical: json['avertissementMedical'] as String?,
      nomsVernaculaires: (json['nomsVernaculaires'] as List<dynamic>?)
              ?.map(PopulationNomVernaculaireModel.fromJson)
              .toList() ??
          [],
      connaissancesTraditionnelles: (json['connaissancesTraditionnelles']
                  as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PopulationConnaissanceTraditionnelleModel.fromJson)
              .toList() ??
          [],
      etudesScientifiques: (json['etudesScientifiques'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PopulationEtudeScientifiqueModel.fromJson)
              .toList() ??
          [],
      maladiesAssociees: (rawMaladies as List<dynamic>?)
              ?.map(PopulationPlanteMaladieModel.fromJson)
              .toList() ??
          [],
      medias: (json['medias'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PopulationPlanteMediaModel.fromJson)
              .toList() ??
          [],
      localites: (json['localites'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PopulationPlanteLocaliteModel.fromJson)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomScientifique': nomScientifique,
        'description': description,
        'photoUrl': photoUrl,
        'avertissementMedical': avertissementMedical,
        'nomsVernaculaires': nomsVernaculaires.map((e) => e.toJson()).toList(),
        'connaissancesTraditionnelles':
            connaissancesTraditionnelles.map((e) => e.toJson()).toList(),
        'etudesScientifiques':
            etudesScientifiques.map((e) => e.toJson()).toList(),
        'maladiesAssociees': maladiesAssociees.map((e) => e.toJson()).toList(),
        'medias': medias.map((e) => e.toJson()).toList(),
        'localites': localites.map((e) => e.toJson()).toList(),
      };
}
