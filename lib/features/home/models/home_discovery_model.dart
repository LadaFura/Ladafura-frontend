import '../../pharmacopees/models/pharmacopee_model.dart';
import '../../plantes/models/produit_model.dart';
import '../../../shared/models/plante_sommaire_model.dart';

/// Modèle agrégé pour les données de la page d'accueil.
class HomeDiscoveryData {
  final List<PharmacopeeModel> pharmacopeesProches;
  final List<ProduitModel> produitsPopulaires;
  final List<PlanteSommaireModel> plantesPopulaires;

  const HomeDiscoveryData({
    this.pharmacopeesProches = const [],
    this.produitsPopulaires = const [],
    this.plantesPopulaires = const [],
  });
}
