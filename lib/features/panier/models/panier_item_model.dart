import '../../plantes/models/produit_model.dart';

class PanierItemModel {
  final ProduitModel produit;
  final int quantite;

  const PanierItemModel({
    required this.produit,
    this.quantite = 1,
  });

  double get sousTotal => produit.prixIndicatif * quantite;

  PanierItemModel copyWith({
    ProduitModel? produit,
    int? quantite,
  }) {
    return PanierItemModel(
      produit: produit ?? this.produit,
      quantite: quantite ?? this.quantite,
    );
  }
}
