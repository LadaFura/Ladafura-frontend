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
      total: json['total'],
      brouillons: json['brouillons'],
      enAttente: json['enAttente'],
      soumises: json['soumises'],
      enExamen: json['enExamen'],
      validees: json['validees'],
      rejetees: json['rejetees'],
      tauxValidation: (json['tauxValidation'] as num).toDouble(),
    );
  }
}