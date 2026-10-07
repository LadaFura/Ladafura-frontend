/// Méthode de paiement disponible sur LADAFURA.
///
/// Conforme au DTO backend `PopulationMethodePaiementInfoDto.java` et à l'enum `MethodePaiement.java`.
class MethodePaiementModel {
  final String code; // 'MOBILE_MONEY', 'CASH', 'CARTE_BANCAIRE'
  final String libelle;
  final String description;
  final bool disponible;
  final List<String> operateurs;
  final String instructions;

  const MethodePaiementModel({
    required this.code,
    required this.libelle,
    required this.description,
    this.disponible = true,
    this.operateurs = const [],
    this.instructions = '',
  });

  bool get isMobileMoney => code == 'MOBILE_MONEY';
  bool get isCash => code == 'CASH';
  bool get isCarteBancaire => code == 'CARTE_BANCAIRE';

  factory MethodePaiementModel.fromJson(Map<String, dynamic> json) {
    return MethodePaiementModel(
      code: json['code']?.toString() ?? 'MOBILE_MONEY',
      libelle: json['libelle']?.toString() ?? 'Moyen de paiement',
      description: json['description']?.toString() ?? '',
      disponible: json['disponible'] as bool? ?? true,
      operateurs: (json['operateurs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      instructions: json['instructions']?.toString() ?? '',
    );
  }
}

/// Confirmation et reçu d'une transaction de règlement.
///
/// Conforme au DTO backend `PopulationPaiementResponse.java`.
class PaiementResponseModel {
  final int id;
  final String reference;
  final int commandeId;
  final String numeroCommande;
  final double montant;
  final String methode;
  final String libelleMethode;
  final String statut; // 'REUSSI', 'EN_ATTENTE', 'ECHOUE', 'ANNULE'
  final DateTime datePaiement;
  final bool succes;
  final String message;
  final String statutCommande;

  const PaiementResponseModel({
    required this.id,
    required this.reference,
    required this.commandeId,
    required this.numeroCommande,
    required this.montant,
    required this.methode,
    required this.libelleMethode,
    required this.statut,
    required this.datePaiement,
    required this.succes,
    required this.message,
    required this.statutCommande,
  });

  String get montantFormate {
    final intValue = montant.round();
    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  factory PaiementResponseModel.fromJson(Map<String, dynamic> json) {
    return PaiementResponseModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reference: json['reference']?.toString() ?? '',
      commandeId: (json['commandeId'] as num?)?.toInt() ?? 0,
      numeroCommande: json['numeroCommande']?.toString() ?? '',
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      methode: json['methode']?.toString() ?? 'MOBILE_MONEY',
      libelleMethode: json['libelleMethode']?.toString() ?? '',
      statut: json['statut']?.toString() ?? 'EN_ATTENTE',
      datePaiement: json['datePaiement'] != null
          ? DateTime.tryParse(json['datePaiement'].toString()) ?? DateTime.now()
          : DateTime.now(),
      succes: json['succes'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      statutCommande: json['statutCommande']?.toString() ?? 'CONFIRMEE',
    );
  }
}

