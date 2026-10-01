import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/services_providers.dart';
import '../../../shared/models/plante_sommaire_model.dart';
import '../data/models/pharmacopee_model.dart';
import '../data/models/produit_model.dart';

/// Données de repli réalistes pour les pharmacopées maliennes
final List<PharmacopeeModel> _fallbackPharmacopees = [
  const PharmacopeeModel(
    id: 1,
    nom: 'Pharmacie Jnane Awrad',
    description:
        'Officine agréée spécialisée en phytothérapie et remèdes sahéliens.',
    telephone: '+223 76 12 34 56',
    region: 'Bamako',
    cercle: 'Bamako',
    commune: 'Commune V',
    localite: 'Badalabougou',
    latitude: 12.6280,
    longitude: -7.9950,
    proposeLivraison: true,
    proposePickup: true,
    nombreProduits: 34,
    noteMoyenne: 4.5,
    nombreAvis: 100,
    photoUrl: 'assets/images/pharmacie_sample.png',
  ),
  const PharmacopeeModel(
    id: 2,
    nom: 'Pharmacie Traditionnelle du Mandé',
    description: 'Centre de valorisation des savoirs ancestraux du Mandé.',
    telephone: '+223 66 98 74 12',
    region: 'Koulikoro',
    cercle: 'Kati',
    commune: 'Siby',
    localite: 'Grand Marché de Siby',
    latitude: 12.3847,
    longitude: -8.3341,
    proposeLivraison: true,
    proposePickup: true,
    nombreProduits: 48,
    noteMoyenne: 4.8,
    nombreAvis: 142,
    photoUrl: 'assets/images/pharmacie_sample.png',
  ),
  const PharmacopeeModel(
    id: 3,
    nom: 'Officine Botanique Djoliba',
    description:
        'Préparations traditionnelles, tisanes et poudres médicinales certifiées.',
    telephone: '+223 70 45 89 20',
    region: 'Bamako',
    cercle: 'Bamako',
    commune: 'Commune IV',
    localite: 'Lafiabougou',
    latitude: 12.6450,
    longitude: -8.0300,
    proposeLivraison: true,
    proposePickup: true,
    nombreProduits: 22,
    noteMoyenne: 4.6,
    nombreAvis: 88,
    photoUrl: 'assets/images/pharmacie_sample.png',
  ),
];

/// Données de repli pour les médicaments traditionnels (Fura) populaires
final List<ProduitModel> _fallbackProduits = [
  const ProduitModel(
    id: 1,
    nom: 'Tisane Kinkéliba Bio',
    description: 'Infusion détoxifiante hépatique et régulatrice de tension.',
    forme: 'Sachet d\'infusion (100g)',
    prixIndicatif: 1500.0,
    categorieNom: 'Tisanes & Infusions',
    plantesPrincipales: ['Combretum micranthum'],
    disponibleEnPharmacie: true,
    noteMoyenne: 4.9,
    nombreAvis: 120,
    photoUrl: null,
  ),
  const ProduitModel(
    id: 2,
    nom: 'Sirop Balanites Énergie',
    description:
        'Sirop fortifiant à base de dattes du désert (Balanites aegyptiaca).',
    forme: 'Flacon 250ml',
    prixIndicatif: 2500.0,
    categorieNom: 'Sirops & Émulsions',
    plantesPrincipales: ['Balanites aegyptiaca'],
    disponibleEnPharmacie: true,
    noteMoyenne: 4.7,
    nombreAvis: 85,
    photoUrl: null,
  ),
  const ProduitModel(
    id: 3,
    nom: 'Poudre de Moringa Pure',
    description:
        'Superaliment riche en vitamines, antioxydants et minéraux essentiels.',
    forme: 'Pot hermétique 200g',
    prixIndicatif: 2000.0,
    categorieNom: 'Poudres Médicinales',
    plantesPrincipales: ['Moringa oleifera'],
    disponibleEnPharmacie: true,
    noteMoyenne: 4.8,
    nombreAvis: 96,
    photoUrl: null,
  ),
  const ProduitModel(
    id: 4,
    nom: 'Baume Karité & Neem',
    description: 'Soin apaisant pour les affections cutanées et dermatoses.',
    forme: 'Pot 150g',
    prixIndicatif: 1800.0,
    categorieNom: 'Baumes & Pommades',
    plantesPrincipales: ['Vitellaria paradoxa', 'Azadirachta indica'],
    disponibleEnPharmacie: true,
    noteMoyenne: 4.6,
    nombreAvis: 64,
    photoUrl: null,
  ),
];

/// Données de repli pour les plantes les plus consultées
final List<PlanteSommaireModel> _fallbackPlantes = [
  const PlanteSommaireModel(
    id: 1,
    nomScientifique: 'Combretum micranthum',
    description:
        'Arbuste sahélien réputé pour son infusion bienfaisante digestive et hypotensive.',
    nomsVernaculaires: ['Kinkéliba', 'Sere', 'Kokobe'],
    maladies: ['Hypertension', 'Troubles digestifs', 'Fièvre bilieuse'],
    nombreConnaissances: 6,
    nombreEtudesScientifiques: 4,
  ),
  const PlanteSommaireModel(
    id: 2,
    nomScientifique: 'Moringa oleifera',
    description:
        'L\'arbre de vie africain aux multiples vertus nutritionnelles et immunitaires.',
    nomsVernaculaires: ['Moringa', 'Nebedaye', 'Arbre miracle'],
    maladies: ['Diabète', 'Anémie', 'Fatigue générale'],
    nombreConnaissances: 8,
    nombreEtudesScientifiques: 9,
  ),
  const PlanteSommaireModel(
    id: 3,
    nomScientifique: 'Azadirachta indica',
    description:
        'Arbre protecteur ancestral aux vertus antiparasitaires et fébrifuges.',
    nomsVernaculaires: ['Neem', 'Kingoba', 'Nîm'],
    maladies: ['Paludisme', 'Gale & Dermatoses', 'Infections cutanées'],
    nombreConnaissances: 7,
    nombreEtudesScientifiques: 5,
  ),
  const PlanteSommaireModel(
    id: 4,
    nomScientifique: 'Artemisia annua',
    description:
        'Plante aromatique reconnue internationalement contre les fièvres palustres.',
    nomsVernaculaires: ['Armoise annuelle', 'Artemisia'],
    maladies: ['Paludisme', 'Fièvre palustre', 'Inflammations'],
    nombreConnaissances: 5,
    nombreEtudesScientifiques: 12,
  ),
  const PlanteSommaireModel(
    id: 5,
    nomScientifique: 'Parkia biglobosa',
    description:
        'Arbre nourricier produisant la pulpe jaune et le néré pour le soumbala.',
    nomsVernaculaires: ['Néré', 'Netetu'],
    maladies: ['Hypertension artérielle', 'Constipation'],
    nombreConnaissances: 4,
    nombreEtudesScientifiques: 3,
  ),
];

/// Provider pour les coordonnées de l'utilisateur (GPS ou Bamako par défaut)
final userLocationProvider = FutureProvider<GeoCoordinates?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  try {
    return await locationService.getCurrentPosition();
  } catch (_) {
    return GeoCoordinates.bamako;
  }
});

/// Provider pour les pharmacopées les plus proches du visiteur ou citoyen
final nearbyPharmacopeesProvider =
    FutureProvider<List<PharmacopeeModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final userLocation = await ref.watch(userLocationProvider.future);

  try {
    final response =
        await dio.get('/population/pharmacopees', queryParameters: {
      'page': 0,
      'size': 10,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);

      if (items.isNotEmpty) {
        final list = items.map((e) => PharmacopeeModel.fromJson(e)).toList();
        // Tri par distance croissante
        list.sort((a, b) => a
            .distanceToKm(userLocation)
            .compareTo(b.distanceToKm(userLocation)));
        return list;
      }
    }
  } catch (_) {
    // Repli local en cas d'indisponibilité réseau
  }

  // Utilisation des données de secours triées par proximité
  final list = List<PharmacopeeModel>.from(_fallbackPharmacopees);
  list.sort((a, b) =>
      a.distanceToKm(userLocation).compareTo(b.distanceToKm(userLocation)));
  return list;
});

/// Provider pour les médicaments traditionnels (Fura) les plus populaires
final popularProduitsProvider = FutureProvider<List<ProduitModel>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/population/produits', queryParameters: {
      'page': 0,
      'size': 10,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);

      if (items.isNotEmpty) {
        return items.map((e) => ProduitModel.fromJson(e)).toList();
      }
    }
  } catch (_) {
    // Repli local gracieux
  }

  return _fallbackProduits;
});

/// Provider pour les plantes médicinales les plus consultées
final popularPlantesProvider =
    FutureProvider<List<PlanteSommaireModel>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('/population/plantes', queryParameters: {
      'page': 0,
      'size': 10,
    });

    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);

      if (items.isNotEmpty) {
        return items.map((e) => PlanteSommaireModel.fromJson(e)).toList();
      }
    }
  } catch (_) {
    // Repli local gracieux
  }

  return _fallbackPlantes;
});
