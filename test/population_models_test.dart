import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/features/population/data/models/population_models.dart';
import 'package:ladafura_frontend_flutter/shared/enums/statut_commande.dart';

void main() {
  group('Population Models Tests', () {
    test('PlanteModel serialization and conversion', () {
      final json = {
        'id': 1,
        'nomScientifique': 'Combretum micranthum',
        'description': 'Arbuste médicinal traditionnel.',
        'photoUrl': 'https://storage.ladafura.ml/plantes/kinkeliba.jpg',
        'avertissementMedical': 'Notice légale ENF11',
        'nomsVernaculaires': [
          {'id': 1, 'nom': 'Kinkéliba', 'langue': 'Bambara', 'pays': 'Mali'},
        ],
        'connaissancesTraditionnelles': [
          {
            'id': 10,
            'usageRapporte': 'Décoction pour la digestion',
            'partieUtilisee': 'Feuilles',
          }
        ],
        'etudesScientifiques': [
          {
            'id': 20,
            'titre': 'Propriétés antioxydantes du Kinkéliba',
            'auteurs': 'Dr. Sanogo et al.',
          }
        ],
        'maladiesAssociees': [
          {'id': 3, 'nom': 'Troubles digestifs'},
        ],
        'medias': [
          {'id': 5, 'url': 'https://photo.jpg', 'typeMedia': 'IMAGE'},
        ],
        'localites': [
          {'id': 7, 'region': 'Koulikoro', 'cercle': 'Kati'},
        ],
      };

      final plante = PopulationPlanteDetailModel.fromJson(json);
      expect(plante.id, 1);
      expect(plante.nomScientifique, 'Combretum micranthum');
      expect(plante.nomsVernaculaires.first.nom, 'Kinkéliba');
      expect(plante.nomsVernaculairesConcat, 'Kinkéliba (Bambara)');
      expect(plante.connaissancesTraditionnelles.length, 1);
      expect(plante.etudesScientifiques.length, 1);

      final sommaire = plante.toSommaire();
      expect(sommaire.id, 1);
      expect(sommaire.nomScientifique, 'Combretum micranthum');
      expect(sommaire.nombreConnaissances, 1);
      expect(sommaire.nombreEtudesScientifiques, 1);

      final reserialized = plante.toJson();
      expect(reserialized['id'], 1);
      expect(reserialized['nomScientifique'], 'Combretum micranthum');
    });

    test('ProduitModel serialization and stock calculation', () {
      final json = {
        'id': 5,
        'nom': 'Tisane Kinkéliba Bio',
        'description': 'Infusion 100% naturelle',
        'forme': 'Sachet 100g',
        'compositionTexte': 'Feuilles séchées',
        'prixIndicatif': 2500.0,
        'photoUrl': 'https://photo.jpg',
        'categorieId': 1,
        'categorieNom': 'Tisanes',
        'noteMoyenne': 4.8,
        'nombreAvis': 15,
        'compositions': [
          {
            'planteId': 1,
            'nomScientifique': 'Combretum micranthum',
            'quantite': 50.0,
            'unite': 'g',
          }
        ],
        'maladies': ['Digestion'],
        'offresPharmacopees': [
          {
            'pharmacopeeId': 3,
            'nomPharmacopee': 'Pharmacie Mandé',
            'prix': 2400.0,
            'disponible': true,
            'quantiteStock': 10,
            'modesRetrait': [
              {'id': 1, 'type': 'PICKUP', 'frais': 0.0},
              {'id': 2, 'type': 'LIVRAISON', 'frais': 1500.0},
            ]
          }
        ],
      };

      final produit = PopulationProduitDetailModel.fromJson(json);
      expect(produit.id, 5);
      expect(produit.enStock, isTrue);
      expect(produit.prixMinimum, 2400.0);
      expect(produit.offresPharmacopees.first.modesRetrait.length, 2);
      expect(
          produit.offresPharmacopees.first.modesRetrait.first.isPickup, isTrue);
      expect(produit.offresPharmacopees.first.modesRetrait.last.isLivraison,
          isTrue);

      final sommaire = produit.toSommaire();
      expect(sommaire.id, 5);
      expect(sommaire.nom, 'Tisane Kinkéliba Bio');
      expect(sommaire.isDisponible, isTrue);
    });

    test('PanierModel line calculation and emptiness', () {
      final json = {
        'panierId': 12,
        'nombreArticles': 3,
        'montantTotal': 7500.0,
        'lignes': [
          {
            'ligneId': 101,
            'produitId': 5,
            'nomProduit': 'Tisane Kinkéliba',
            'prixUnitaire': 2500.0,
            'quantite': 3,
            'sousTotal': 7500.0,
            'disponible': true,
          }
        ],
      };

      final panier = PopulationPanierModel.fromJson(json);
      expect(panier.panierId, 12);
      expect(panier.nombreArticles, 3);
      expect(panier.montantTotal, 7500.0);
      expect(panier.isNotEmpty, isTrue);
      expect(panier.lignes.first.nomProduit, 'Tisane Kinkéliba');

      final emptyPanier = PopulationPanierModel.empty();
      expect(emptyPanier.isEmpty, isTrue);
    });

    test('CommandeModel lifecycle and status tracking', () {
      final json = {
        'id': 42,
        'numero': 'CMD-20260928-ABC12',
        'dateCommande': '2026-09-28T14:30:00',
        'statut': 'EN_ATTENTE',
        'pharmacopeeId': 1,
        'nomPharmacopee': 'Pharmacie Mandé',
        'modeRetrait': 'LIVRAISON',
        'montantLivraison': 1500.0,
        'totalProduit': 5000.0,
        'montantTotal': 6500.0,
        'annulable': true,
        'lignes': [
          {
            'id': 1,
            'produitId': 5,
            'nomProduit': 'Tisane',
            'prixUnitaire': 2500.0,
            'quantite': 2,
            'sousTotal': 5000.0,
          }
        ],
      };

      final commande = PopulationCommandeDetailModel.fromJson(json);
      expect(commande.id, 42);
      expect(commande.numero, 'CMD-20260928-ABC12');
      expect(commande.statut, StatutCommande.enAttente);
      expect(commande.annulable, isTrue);
      expect(commande.montantTotal, 6500.0);

      final statutModel = PopulationCommandeStatutModel.fromJson({
        'id': 42,
        'numero': 'CMD-20260928-ABC12',
        'statut': 'PREPAREE',
        'dateCommande': '2026-09-28T14:30:00',
        'modeRetrait': 'PICKUP',
        'annulable': false,
        'message': 'Votre commande est prête.',
      });
      expect(statutModel.statut, StatutCommande.preparee);
      expect(statutModel.message, 'Votre commande est prête.');
    });

    test('AvisModel creation and eligibility', () {
      final json = {
        'id': 12,
        'produitId': 5,
        'nomProduit': 'Tisane Kinkéliba',
        'note': 5,
        'commentaire': 'Très efficace !',
        'dateAvis': '2026-09-29T10:00:00',
        'statut': 'PUBLIE',
        'statutLibelle': 'Publié',
      };

      final avis = PopulationAvisModel.fromJson(json);
      expect(avis.id, 12);
      expect(avis.note, 5);
      expect(avis.isPublie, isTrue);
      expect(avis.isEnAttente, isFalse);

      final eligibilite = PopulationEligibiliteAvisModel.fromJson({
        'produitId': 5,
        'nomProduit': 'Tisane',
        'eligible': true,
        'dejaEvalue': false,
        'message': 'Vous pouvez déposer un avis.',
      });
      expect(eligibilite.eligible, isTrue);
      expect(eligibilite.dejaEvalue, isFalse);
    });
  });
}
