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
      id: json['id'],
      titre: json['titre'],
      message: json['message'],
      type: json['type'],
      niveau: json['niveau'],
      lue: json['lue'],
      dateNotification: DateTime.parse(json['dateNotification']),
      dateLecture: json['dateLecture'] != null
          ? DateTime.parse(json['dateLecture'])
          : null,
      referenceId: json['referenceId'],
      lien: json['lien'],
    );
  }
}
