/// Option de mise à disposition d'une commande (Livraison ou Pickup).
///
/// Conforme au DTO backend `PopulationModeRetraitOptionDto.java`.
class ModeRetraitOptionModel {
  final int id;
  final String type; // 'LIVRAISON' ou 'PICKUP'
  final String libelle;
  final bool actif;
  final double frais;
  final bool gratuit;
  final String? description;
  final String? adresseRetrait;

  const ModeRetraitOptionModel({
    required this.id,
    required this.type,
    required this.libelle,
    this.actif = true,
    this.frais = 0.0,
    this.gratuit = false,
    this.description,
    this.adresseRetrait,
  });

  bool get isLivraison => type.toUpperCase() == 'LIVRAISON';
  bool get isPickup => type.toUpperCase() == 'PICKUP';

  String get fraisFormate {
    if (gratuit || frais <= 0) return 'Gratuit';
    final intValue = frais.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory ModeRetraitOptionModel.fromJson(Map<String, dynamic> json) {
    return ModeRetraitOptionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'PICKUP',
      libelle: json['libelle']?.toString() ??
          (json['type'] == 'LIVRAISON'
              ? 'Livraison à domicile'
              : 'Retrait en officine'),
      actif: json['actif'] as bool? ?? true,
      frais: (json['frais'] as num?)?.toDouble() ?? 0.0,
      gratuit: json['gratuit'] as bool? ?? false,
      description: json['description']?.toString(),
      adresseRetrait: json['adresseRetrait']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'libelle': libelle,
        'actif': actif,
        'frais': frais,
        'gratuit': gratuit,
        'description': description,
        'adresseRetrait': adresseRetrait,
      };
}

/// Récapitulatif des modes de livraison et retrait proposés par une officine.
///
/// Conforme au DTO backend `PopulationPharmacopeeRetraitOptionsResponse.java`.
class PharmacopeeRetraitOptionsModel {
  final int pharmacopeeId;
  final String nomPharmacopee;
  final String? telephonePharmacopee;
  final String? adressePharmacopee;
  final bool proposeLivraison;
  final double fraisLivraison;
  final bool proposePickup;
  final List<ModeRetraitOptionModel> options;

  const PharmacopeeRetraitOptionsModel({
    required this.pharmacopeeId,
    required this.nomPharmacopee,
    this.telephonePharmacopee,
    this.adressePharmacopee,
    this.proposeLivraison = false,
    this.fraisLivraison = 0.0,
    this.proposePickup = true,
    this.options = const [],
  });

  factory PharmacopeeRetraitOptionsModel.fromJson(Map<String, dynamic> json) {
    return PharmacopeeRetraitOptionsModel(
      pharmacopeeId: (json['pharmacopeeId'] as num?)?.toInt() ?? 0,
      nomPharmacopee: json['nomPharmacopee']?.toString() ?? 'Pharmacopée',
      telephonePharmacopee: json['telephonePharmacopee']?.toString(),
      adressePharmacopee: json['adressePharmacopee']?.toString(),
      proposeLivraison: json['proposeLivraison'] as bool? ?? false,
      fraisLivraison: (json['fraisLivraison'] as num?)?.toDouble() ?? 0.0,
      proposePickup: json['proposePickup'] as bool? ?? true,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) =>
                  ModeRetraitOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

