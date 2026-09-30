import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'audio_recorder_service.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

part 'services_providers.g.dart';

/// Fournisseur Riverpod pour le stockage persistant (préférences, tokens de session).
@Riverpod(keepAlive: true)
StorageService storageService(StorageServiceRef ref) {
  return StorageService.instance;
}

/// Fournisseur Riverpod pour le service de localisation GPS (US-05 & US-16).
@Riverpod(keepAlive: true)
LocationService locationService(LocationServiceRef ref) {
  return LocationService();
}

/// Fournisseur Riverpod pour l'enregistreur audio des récits traditionnels (US-15).
@Riverpod(keepAlive: true)
AudioRecorderService audioRecorderService(AudioRecorderServiceRef ref) {
  final service = AudioRecorderService();
  ref.onDispose(service.dispose);
  return service;
}

/// Fournisseur Riverpod pour le service de notifications in-app et alertes (EF32).
@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  final service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
}
