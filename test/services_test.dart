import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/services/services.dart';
import 'package:ladafura_frontend_flutter/core/theme/theme_provider.dart';
import 'package:ladafura_frontend_flutter/shared/enums/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Services Layer Tests - LADAFURA', () {
    // =========================================================================
    // 1. STORAGE SERVICE TESTS
    // =========================================================================
    group('StorageService Tests', () {
      late StorageService storageService;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        storageService = StorageService(prefs);
      });

      test('Auth token and session management', () async {
        expect(storageService.hasAuthToken(), isFalse);
        expect(storageService.getAuthToken(), isNull);

        // Enregistrement session complète
        await storageService.saveUserSession(
          token: 'firebase_jwt_abc_123',
          role: UserRole.agentCollecte,
          refreshToken: 'refresh_token_xyz',
          userId: 'usr-42',
          email: 'moussa.diarra@gmail.com',
          firebaseUid: 'fb-uid-99',
          phone: '+22370000000',
          name: 'Moussa Diarra',
        );

        expect(storageService.hasAuthToken(), isTrue);
        expect(storageService.getAuthToken(), 'firebase_jwt_abc_123');
        expect(storageService.getRefreshToken(), 'refresh_token_xyz');
        expect(storageService.getUserRole(), UserRole.agentCollecte);
        expect(storageService.getUserId(), 'usr-42');
        expect(storageService.getUserEmail(), 'moussa.diarra@gmail.com');
        expect(storageService.getFirebaseUid(), 'fb-uid-99');
        expect(storageService.getUserPhone(), '+22370000000');
        expect(storageService.getUserName(), 'Moussa Diarra');

        // Déconnexion
        await storageService.clearAuth();
        expect(storageService.hasAuthToken(), isFalse);
        expect(storageService.getAuthToken(), isNull);
        expect(storageService.getUserRole(), isNull);
        expect(storageService.getUserId(), isNull);
        expect(storageService.getUserEmail(), isNull);
        expect(storageService.getFirebaseUid(), isNull);
      });

      test('Preferences: Onboarding and ThemeMode with system default',
          () async {
        expect(storageService.isOnboardingCompleted(), isFalse);
        await storageService.setOnboardingCompleted(true);
        expect(storageService.isOnboardingCompleted(), isTrue);

        // ThemeMode par défaut: ThemeMode.system
        expect(storageService.getThemeMode(), isNull);
        expect(storageService.getAppThemeMode(), ThemeMode.system);

        // Enregistrement sombre
        await storageService.saveThemeMode(ThemeMode.dark);
        expect(storageService.getThemeMode(), 'dark');
        expect(storageService.getAppThemeMode(), ThemeMode.dark);

        // Enregistrement clair
        await storageService.saveThemeMode(ThemeMode.light);
        expect(storageService.getThemeMode(), 'light');
        expect(storageService.getAppThemeMode(), ThemeMode.light);

        // Retour système
        await storageService.saveThemeMode(ThemeMode.system);
        expect(storageService.getThemeMode(), 'system');
        expect(storageService.getAppThemeMode(), ThemeMode.system);

        // Test ThemeModeNotifier avec persistance
        final notifier = ThemeModeNotifier(storageService);
        expect(notifier.state, ThemeMode.system);

        notifier.toggleTheme(currentIsDark: false);
        expect(notifier.state, ThemeMode.dark);
        expect(storageService.getAppThemeMode(), ThemeMode.dark);

        notifier.toggleTheme(currentIsDark: true);
        expect(notifier.state, ThemeMode.light);
        expect(storageService.getAppThemeMode(), ThemeMode.light);

        notifier.setThemeMode(ThemeMode.system);
        expect(notifier.state, ThemeMode.system);
        expect(storageService.getAppThemeMode(), ThemeMode.system);
      });
    });

    // =========================================================================
    // 2. LOCATION SERVICE TESTS
    // =========================================================================
    group('LocationService Tests', () {
      test('GeoCoordinates and Haversine distance calculation', () {
        const bamako = GeoCoordinates.bamako;
        expect(bamako.latitude, 12.6392);
        expect(bamako.longitude, -8.0029);

        // Coordonnées de Ségou (Mali)
        const segou = GeoCoordinates(
          latitude: 13.4317,
          longitude: -6.2157,
        );

        // Distance Bamako -> Ségou ~ 212 km à vol d'oiseau
        final distanceKm = bamako.distanceToKm(segou);
        expect(distanceKm, greaterThan(200.0));
        expect(distanceKm, lessThan(230.0));
      });

      test('Mali bounding box validation', () {
        // Points à l'intérieur du Mali
        expect(LocationService.isWithinMaliBounds(12.6392, -8.0029),
            isTrue); // Bamako
        expect(LocationService.isWithinMaliBounds(11.3176, -5.6665),
            isTrue); // Sikasso
        expect(LocationService.isWithinMaliBounds(16.7666, -3.0026),
            isTrue); // Tombouctou

        // Points hors du Mali
        expect(LocationService.isWithinMaliBounds(48.8566, 2.3522),
            isFalse); // Paris
        expect(LocationService.isWithinMaliBounds(35.6762, 139.6503),
            isFalse); // Tokyo
      });

      test('Mock mode for testing GPS positions', () async {
        final service = LocationService();
        const mockCoord = GeoCoordinates(
          latitude: 12.5,
          longitude: -8.1,
          accuracy: 5.0,
        );

        service.enableMockMode(mockCoord);
        final pos = await service.getCurrentPosition();
        expect(pos, mockCoord);
        expect(service.lastKnownPosition, mockCoord);
      });
    });

    // =========================================================================
    // 3. AUDIO RECORDER SERVICE TESTS
    // =========================================================================
    group('AudioRecorderService Tests', () {
      test('Recorder lifecycle states (start, pause, resume, cancel)',
          () async {
        final recorder = AudioRecorderService();
        addTearDown(recorder.dispose);

        expect(recorder.isIdle, isTrue);
        expect(recorder.isRecording, isFalse);

        // Démarrage
        final filePath = await recorder.startRecording(
          customFileName: 'test_recit_tradipraticien.m4a',
        );
        expect(recorder.isRecording, isTrue);
        expect(filePath, contains('test_recit_tradipraticien.m4a'));

        // Pause
        await recorder.pauseRecording();
        expect(recorder.isPaused, isTrue);
        expect(recorder.isRecording, isFalse);

        // Reprise
        await recorder.resumeRecording();
        expect(recorder.isRecording, isTrue);

        // Annulation
        await recorder.cancelRecording();
        expect(recorder.isIdle, isTrue);
      });
    });

    // =========================================================================
    // 4. NOTIFICATION SERVICE TESTS
    // =========================================================================
    group('NotificationService Tests', () {
      test('Notification dispatch, read tracking, and counters', () async {
        final notifService = NotificationService();
        addTearDown(notifService.dispose);

        expect(notifService.unreadCount, 0);
        expect(notifService.notifications, isEmpty);

        final notification = AppNotification(
          id: 'notif-1',
          title: 'Nouvelle commande #42',
          body: 'Votre commande a été préparée par l\'officine',
          type: AppNotificationType.commande,
          timestamp: DateTime.now(),
        );

        // Émission
        notifService.showNotification(notification);

        expect(notifService.unreadCount, 1);
        expect(notifService.notifications.length, 1);
        expect(notifService.unreadNotifications.first.id, 'notif-1');

        // Marquage comme lu
        notifService.markAsRead('notif-1');
        expect(notifService.unreadCount, 0);
        expect(notifService.notifications.first.isRead, isTrue);

        // Nettoyage
        notifService.clearAll();
        expect(notifService.notifications, isEmpty);
      });
    });

    // =========================================================================
    // 5. RIVERPOD PROVIDERS RESOLUTION
    // =========================================================================
    test('Riverpod services providers resolve cleanly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locService = container.read(locationServiceProvider);
      final audioService = container.read(audioRecorderServiceProvider);
      final notifService = container.read(notificationServiceProvider);

      expect(locService, isNotNull);
      expect(audioService, isNotNull);
      expect(notifService, isNotNull);
    });
  });
}
