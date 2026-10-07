import '../../plantes/models/produit_model.dart';
import 'panier_model.dart';

// Compatibilité descendante pour l'ancien code éventuel
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

  LignePanierModel toLignePanierModel(int ligneId) {
    return LignePanierModel(
      ligneId: ligneId,
      produitId: produit.id,
      nomProduit: produit.nom,
      forme: produit.forme,
      photoUrl: produit.photoUrl,
      prixUnitaire: produit.prixIndicatif,
      quantite: quantite,
      sousTotal: sousTotal,
      disponible: produit.disponibleEnPharmacie,
    );
  }
}
