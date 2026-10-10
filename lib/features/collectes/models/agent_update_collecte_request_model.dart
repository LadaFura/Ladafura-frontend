class AgentUpdateCollecteRequestModel {
  final DateTime? dateCollecte;
  final String? description;
  final String? photoUrl;
  final String? audioUrl;
  final int? sourceId;
  final int? localisationId;

  const AgentUpdateCollecteRequestModel({
    this.dateCollecte,
    this.description,
    this.photoUrl,
    this.audioUrl,
    this.sourceId,
    this.localisationId,
  });

  Map<String, dynamic> toJson() => {
        if (dateCollecte != null)
          'dateCollecte': dateCollecte!.toIso8601String(),
        if (description != null) 'description': description,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (sourceId != null) 'sourceId': sourceId,
        if (localisationId != null) 'localisationId': localisationId,
      };
}
