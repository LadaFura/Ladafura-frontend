class AgentCreateCollecteRequestModel {
  final DateTime? dateCollecte;
  final String? description;
  final String? photoUrl;
  final String? audioUrl;
  final int? sourceId;
  final int? localisationId;
  final bool soumettre;

  const AgentCreateCollecteRequestModel({
    this.dateCollecte,
    this.description,
    this.photoUrl,
    this.audioUrl,
    this.sourceId,
    this.localisationId,
    this.soumettre = false,
  });

  Map<String, dynamic> toJson() => {
        if (dateCollecte != null)
          'dateCollecte': dateCollecte!.toIso8601String(),
        if (description != null) 'description': description,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (sourceId != null) 'sourceId': sourceId,
        if (localisationId != null) 'localisationId': localisationId,
        'soumettre': soumettre,
      };
}
