/// Modèle d'un avis client publié pour une pharmacopée.
/// Conforme au DTO backend `PopulationAvisResponse.java`.
class PharmacopeeAvisItemModel {
  final int id;
  final int pharmacopeeId;
  final String? nomPharmacopee;
  final int note;
  final String? commentaire;
  final DateTime? dateAvis;
  final String? reponseOfficine;
  final DateTime? dateReponse;

  const PharmacopeeAvisItemModel({
    required this.id,
    required this.pharmacopeeId,
    this.nomPharmacopee,
    required this.note,
    this.commentaire,
    this.dateAvis,
    this.reponseOfficine,
    this.dateReponse,
  });

  factory PharmacopeeAvisItemModel.fromJson(Map<String, dynamic> json) {
    return PharmacopeeAvisItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      pharmacopeeId: (json['pharmacopeeId'] as num?)?.toInt() ?? 0,
      nomPharmacopee: json['nomPharmacopee']?.toString(),
      note: (json['note'] as num?)?.toInt() ?? 5,
      commentaire: json['commentaire']?.toString(),
      dateAvis: json['dateAvis'] != null
          ? DateTime.tryParse(json['dateAvis'].toString())
          : null,
      reponseOfficine: json['reponseOfficine']?.toString(),
      dateReponse: json['dateReponse'] != null
          ? DateTime.tryParse(json['dateReponse'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pharmacopeeId': pharmacopeeId,
        'nomPharmacopee': nomPharmacopee,
        'note': note,
        'commentaire': commentaire,
        'dateAvis': dateAvis?.toIso8601String(),
        'reponseOfficine': reponseOfficine,
        'dateReponse': dateReponse?.toIso8601String(),
      };
}

