class CommandeItemModel {
  final int produitId;
  final String nomProduit;
  final int quantite;
  final double prixUnitaire;

  const CommandeItemModel({
    required this.produitId,
    required this.nomProduit,
    required this.quantite,
    required this.prixUnitaire,
  });

  factory CommandeItemModel.fromJson(Map<String, dynamic> json) {
    return CommandeItemModel(
      produitId: json['produitId'] as int? ?? 0,
      nomProduit: json['nomProduit'] as String? ?? '',
      quantite: json['quantite'] as int? ?? 1,
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CommandeModel {
  final int id;
  final String numeroCommande;
  final String statut;
  final double montantTotal;
  final DateTime dateCreation;
  final List<CommandeItemModel> items;

  const CommandeModel({
    required this.id,
    required this.numeroCommande,
    required this.statut,
    required this.montantTotal,
    required this.dateCreation,
    this.items = const [],
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'] as int? ?? 0,
      numeroCommande: json['numeroCommande'] as String? ?? '',
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: (json['items'] as List?)
              ?.map((e) => CommandeItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
