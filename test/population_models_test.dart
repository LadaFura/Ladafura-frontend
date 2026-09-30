import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/features/population/data/models/population_models.dart';

void main() {
  group('Population Models Tests (Flore & Santé)', () {
    test('PlanteModel serialization and conversion to sommaire', () {
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

    test('MaladieModel serialization and properties', () {
      final json = {
        'id': 4,
        'nom': 'Paludisme',
        'description': 'Fièvre aiguë provoquée par Plasmodium falciparum.',
        'nombrePlantesAssociees': 7,
      };

      final maladie = PopulationMaladieModel.fromJson(json);
      expect(maladie.id, 4);
      expect(maladie.nom, 'Paludisme');
      expect(maladie.description, contains('Plasmodium'));
      expect(maladie.nombrePlantesAssociees, 7);

      final reserialized = maladie.toJson();
      expect(reserialized['id'], 4);
      expect(reserialized['nom'], 'Paludisme');
      expect(reserialized['nombrePlantesAssociees'], 7);
    });
  });
}
