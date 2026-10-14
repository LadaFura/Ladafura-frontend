class Statistiques {
  final int total;
  final int brouillons;
  final int enAttente;
  final int soumises;
  final int enExamen;
  final int validees;
  final int rejetees;
  final double tauxValidation;

  Statistiques({
    required this.total,
    required this.brouillons,
    required this.enAttente,
    required this.soumises,
    required this.enExamen,
    required this.validees,
    required this.rejetees,
    required this.tauxValidation,
  });

  factory Statistiques.fromJson(Map<String, dynamic> json) {
    return Statistiques(
      total: (json['total'] as num?)?.toInt() ?? 0,
      brouillons: (json['brouillons'] as num?)?.toInt() ?? 0,
      enAttente: (json['enAttente'] as num?)?.toInt() ?? 0,
      soumises: (json['soumises'] as num?)?.toInt() ?? 0,
      enExamen: (json['enExamen'] as num?)?.toInt() ?? 0,
      validees: (json['validees'] as num?)?.toInt() ?? 0,
      rejetees: (json['rejetees'] as num?)?.toInt() ?? 0,
      tauxValidation: (json['tauxValidation'] as num?)?.toDouble() ?? 0.0,
    );
  }
}