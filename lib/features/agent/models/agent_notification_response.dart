class AgentNotificationResponse {
  final int id;
  final String titre;
  final String message;
  final String type;
  final String niveau;
  final bool lue;
  final DateTime dateNotification;
  final DateTime? dateLecture;
  final String? referenceId;
  final String? lien;

  AgentNotificationResponse({
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

  factory AgentNotificationResponse.fromJson(Map<String, dynamic> json) {
    return AgentNotificationResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titre: json['titre'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'INFO',
      niveau: json['niveau'] as String? ?? 'INFO',
      lue: json['lue'] as bool? ?? false,
      dateNotification: json['dateNotification'] != null
          ? DateTime.tryParse(json['dateNotification'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateLecture: json['dateLecture'] != null
          ? DateTime.tryParse(json['dateLecture'].toString())
          : null,
      referenceId: json['referenceId']?.toString(),
      lien: json['lien'] as String?,
    );
  }
}
