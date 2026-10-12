/// Modèle de notification pour l'utilisateur de l'espace Population (Citoyen).
/// Aligné avec le DTO backend Spring Boot `PopulationNotificationResponse`.
library;

enum NotificationNiveau {
  info,
  succes,
  attention,
  urgent;

  static NotificationNiveau fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'SUCCES':
        return NotificationNiveau.succes;
      case 'ATTENTION':
        return NotificationNiveau.attention;
      case 'URGENT':
        return NotificationNiveau.urgent;
      case 'INFO':
      default:
        return NotificationNiveau.info;
    }
  }
}

class PopulationNotificationModel {
  final int id;
  final String titre;
  final String message;
  final String type;
  final NotificationNiveau niveau;
  final bool lue;
  final DateTime dateNotification;
  final DateTime? dateLecture;
  final String? referenceId;
  final String? lien;

  const PopulationNotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.niveau,
    required this.lue,
    required this.dateNotification,
    this.dateLecture,
    this.referenceId,
    this.lien,
  });

  factory PopulationNotificationModel.fromJson(Map<String, dynamic> json) {
    return PopulationNotificationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      titre: json['titre'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'INFO',
      niveau: NotificationNiveau.fromString(json['niveau'] as String?),
      lue: json['lue'] as bool? ?? false,
      dateNotification: json['dateNotification'] != null
          ? DateTime.tryParse(json['dateNotification'] as String) ?? DateTime.now()
          : DateTime.now(),
      dateLecture: json['dateLecture'] != null
          ? DateTime.tryParse(json['dateLecture'] as String)
          : null,
      referenceId: json['referenceId'] as String?,
      lien: json['lien'] as String?,
    );
  }

  PopulationNotificationModel copyWith({
    int? id,
    String? titre,
    String? message,
    String? type,
    NotificationNiveau? niveau,
    bool? lue,
    DateTime? dateNotification,
    DateTime? dateLecture,
    String? referenceId,
    String? lien,
  }) {
    return PopulationNotificationModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      type: type ?? this.type,
      niveau: niveau ?? this.niveau,
      lue: lue ?? this.lue,
      dateNotification: dateNotification ?? this.dateNotification,
      dateLecture: dateLecture ?? this.dateLecture,
      referenceId: referenceId ?? this.referenceId,
      lien: lien ?? this.lien,
    );
  }
}

class PopulationNotificationStatsModel {
  final int total;
  final int nonLues;
  final int lues;
  final int commandes;
  final int avis;
  final int alertes;

  const PopulationNotificationStatsModel({
    this.total = 0,
    this.nonLues = 0,
    this.lues = 0,
    this.commandes = 0,
    this.avis = 0,
    this.alertes = 0,
  });

  factory PopulationNotificationStatsModel.fromJson(Map<String, dynamic> json) {
    return PopulationNotificationStatsModel(
      total: json['total'] as int? ?? 0,
      nonLues: json['nonLues'] as int? ?? 0,
      lues: json['lues'] as int? ?? 0,
      commandes: json['commandes'] as int? ?? 0,
      avis: json['avis'] as int? ?? 0,
      alertes: json['alertes'] as int? ?? 0,
    );
  }
}
