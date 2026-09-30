// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageServiceHash() => r'c3d862ea6a119a57768b09bb3f734486a4f2fc77';

/// Fournisseur Riverpod pour le stockage persistant (préférences, tokens de session).
///
/// Copied from [storageService].
@ProviderFor(storageService)
final storageServiceProvider = Provider<StorageService>.internal(
  storageService,
  name: r'storageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageServiceRef = ProviderRef<StorageService>;
String _$locationServiceHash() => r'656c951c27c11890bb58727952ecb6cde8a2100e';

/// Fournisseur Riverpod pour le service de localisation GPS (US-05 & US-16).
///
/// Copied from [locationService].
@ProviderFor(locationService)
final locationServiceProvider = Provider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = ProviderRef<LocationService>;
String _$audioRecorderServiceHash() =>
    r'd6f8359b86817f55fb448354b903d192b17ca126';

/// Fournisseur Riverpod pour l'enregistreur audio des récits traditionnels (US-15).
///
/// Copied from [audioRecorderService].
@ProviderFor(audioRecorderService)
final audioRecorderServiceProvider = Provider<AudioRecorderService>.internal(
  audioRecorderService,
  name: r'audioRecorderServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioRecorderServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioRecorderServiceRef = ProviderRef<AudioRecorderService>;
String _$notificationServiceHash() =>
    r'a7988432bef9793579e491e5f351967e1afd33e3';

/// Fournisseur Riverpod pour le service de notifications in-app et alertes (EF32).
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = ProviderRef<NotificationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
