import 'package:flutter_test/flutter_test.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:ladafura_frontend_flutter/shared/models/models.dart';

void main() {
  group('Shared Models Tests - LADAFURA (Périmètre 2 Rôles)', () {
    // =========================================================================
    // 1. UTILISATEUR MODEL TESTS
    // =========================================================================
    test(
        'UtilisateurModel parses Spring Boot User DTOs and provides convenience getters',
        () {
      final json = {
        'id': 15,
        'nom': 'Diarra',
        'prenom': 'Fatoumata',
        'email': 'fatoumata.diarra@gmail.com',
        'firebaseUid': 'uid-fb-12345',
        'telephone': '+223 70 12 34 56',
        'role': 'POPULATION',
        'statut': 'ACTIF',
        'dateCreation': '2026-09-28T14:00:00',
      };

      final user = UtilisateurModel.fromJson(json);

      expect(user.id, 15);
      expect(user.nomComplet, 'Fatoumata Diarra');
      expect(user.initiales, 'FD');
      expect(user.email, 'fatoumata.diarra@gmail.com');
      expect(user.firebaseUid, 'uid-fb-12345');
      expect(user.role, UserRole.population);
      expect(user.isActif, isTrue);
      expect(user.isCitizen, isTrue);
      expect(user.isAgent, isFalse);

      final serialized = user.toJson();
      expect(serialized['role'], 'POPULATION');
      expect(serialized['nom'], 'Diarra');
    });

    test('UtilisateurModel handles Agent role with matricule', () {
      const user = UtilisateurModel(
        id: 4,
        nom: 'Coulibaly',
        prenom: 'Oumar',
        email: 'oumar.coulibaly@ladafura.ml',
        role: UserRole.agentCollecte,
        matricule: 'AGT-2026-004',
        zoneCouverture: 'Région de Sikasso',
      );

      expect(user.isAgent, isTrue);
      expect(user.isCitizen, isFalse);
      expect(user.matricule, 'AGT-2026-004');
      expect(user.zoneCouverture, 'Région de Sikasso');
    });

    // =========================================================================
    // 2. LOCALISATION MALI MODEL TESTS
    // =========================================================================
    test(
        'LocalisationMaliModel handles administrative hierarchy and GPS formatting',
        () {
      final json = {
        'id': 10,
        'region': 'Sikasso',
        'cercle': 'Koutiala',
        'commune': 'Commune Urbaine de Koutiala',
        'localite': 'Quartier Wolobougou',
        'latitude': 12.3917,
        'longitude': -5.4642,
      };

      final loc = LocalisationMaliModel.fromJson(json);

      expect(loc.region, 'Sikasso');
      expect(loc.cercle, 'Koutiala');
      expect(loc.libelleComplet,
          'Quartier Wolobougou, Commune Urbaine de Koutiala, Koutiala (Sikasso)');
      expect(loc.hasGps, isTrue);
      expect(loc.gpsFormatted, contains('12.3917° N'));
      expect(loc.gpsFormatted, contains('5.4642° W'));
      expect(LocalisationMaliModel.regionsMali.contains('Sikasso'), isTrue);
    });

    // =========================================================================
    // 3. PLANTE SOMMAIRE MODEL TESTS
    // =========================================================================
    test(
        'PlanteSommaireModel decodes summary data and resolves vernacular names',
        () {
      final json = {
        'id': 1,
        'nomScientifique': 'Combretum micranthum',
        'description': 'Arbuste sahélien',
        'photoUrl': 'https://ladafura.ml/uploads/plantes/kinkeliba.jpg',
        'nomsVernaculaires': ['Kinkéliba', 'Kinkeliba'],
        'maladies': ['Paludisme', 'Hypertension'],
        'nombreConnaissances': 3,
        'nombreEtudesScientifiques': 2,
      };

      final plante = PlanteSommaireModel.fromJson(json);

      expect(plante.id, 1);
      expect(plante.nomScientifique, 'Combretum micranthum');
      expect(plante.nomVernaculairePrincipal, 'Kinkéliba');
      expect(plante.hasPhoto, isTrue);
      expect(plante.hasSavoirsTraditionnels, isTrue);
      expect(plante.hasEtudesScientifiques, isTrue);
      expect(plante.maladies.length, 2);
    });

    // =========================================================================
    // 4. PAGE RESPONSE TESTS (SPRING DATA PAGINATION)
    // =========================================================================
    test('PageResponse parses Spring Data Page JSON wrapper', () {
      final springPageJson = {
        'content': [
          {'id': 1, 'nom': 'Kinkéliba'},
          {'id': 2, 'nom': 'N\'Golo'},
        ],
        'number': 0,
        'size': 20,
        'totalElements': 45,
        'totalPages': 3,
        'numberOfElements': 2,
        'first': true,
        'last': false,
        'empty': false,
      };

      final page = PageResponse<String>.fromJson(
        springPageJson,
        (json) => json['nom'] as String,
      );

      expect(page.content.length, 2);
      expect(page.content.first, 'Kinkéliba');
      expect(page.pageNumber, 0);
      expect(page.pageSize, 20);
      expect(page.totalElements, 45);
      expect(page.totalPages, 3);
      expect(page.isFirst, isTrue);
      expect(page.isLast, isFalse);
      expect(page.hasNext, isTrue);
      expect(page.hasPrevious, isFalse);
      expect(page.nextPageNumber, 1);
    });
  });
}
