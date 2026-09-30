/// Modèle d'une pathologie documentée dans LADAFURA (US-03).
class PopulationMaladieModel {
  final int id;
  final String nom;
  final String? description;
  final int nombrePlantesAssociees;

  const PopulationMaladieModel({
    required this.id,
    required this.nom,
    this.description,
    this.nombrePlantesAssociees = 0,
  });

  factory PopulationMaladieModel.fromJson(Map<String, dynamic> json) {
    return PopulationMaladieModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      nombrePlantesAssociees: json['nombrePlantesAssociees'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        if (description != null) 'description': description,
        'nombrePlantesAssociees': nombrePlantesAssociees,
      };
}
