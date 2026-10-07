/// Modèle représentant l'éligibilité d'un citoyen à noter une pharmacopée.
/// Conforme au DTO backend `PopulationEligibiliteAvisResponse.java`.
class PharmacopeeEligibiliteAvisModel {
  final int pharmacopeeId;
  final String? nomPharmacopee;
  final bool eligible;
  final bool dejaEvalue;
  final int? avisId;
  final String? message;

  const PharmacopeeEligibiliteAvisModel({
    required this.pharmacopeeId,
    this.nomPharmacopee,
    required this.eligible,
    required this.dejaEvalue,
    this.avisId,
    this.message,
  });

  factory PharmacopeeEligibiliteAvisModel.fromJson(Map<String, dynamic> json) {
    return PharmacopeeEligibiliteAvisModel(
      pharmacopeeId: (json['pharmacopeeId'] as num?)?.toInt() ?? 0,
      nomPharmacopee: json['nomPharmacopee']?.toString(),
      eligible: json['eligible'] == true,
      dejaEvalue: json['dejaEvalue'] == true,
      avisId: (json['avisId'] as num?)?.toInt(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'pharmacopeeId': pharmacopeeId,
        'nomPharmacopee': nomPharmacopee,
        'eligible': eligible,
        'dejaEvalue': dejaEvalue,
        'avisId': avisId,
        'message': message,
      };
}

