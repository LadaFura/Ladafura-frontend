import 'package:flutter/foundation.dart';

/// Structure générique et type-safe encapsulant le résultat de toute requête API LADAFURA.
///
/// Conforme à l'architecture frontend officielle :
/// - [success] : Booléen indiquant si l'opération a réussi.
/// - [data] : Données typées [T] retournées en cas de succès.
/// - [message] : Message informatif ou d'erreur lisible par l'utilisateur.
/// - [statusCode] : Code HTTP retourné par le serveur Spring Boot.
/// - [validationErrors] : Dictionnaire des erreurs de validation par champ (ex: `{"telephone": "Numéro invalide"}`).
@immutable
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, String>? validationErrors;
  final dynamic rawResponse;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.validationErrors,
    this.rawResponse,
  });

  /// Crée une réponse réussie avec les données retournées.
  const ApiResponse.success(
    T this.data, {
    this.message,
    this.statusCode = 200,
    this.rawResponse,
  })  : success = true,
        validationErrors = null;

  /// Crée une réponse en échec avec un message d'erreur et éventuellement les erreurs de validation.
  const ApiResponse.error(
    String this.message, {
    this.statusCode,
    this.validationErrors,
    this.data,
    this.rawResponse,
  }) : success = false;

  /// Vérifie si la réponse est un succès.
  bool get isSuccess => success;

  /// Vérifie si la réponse est un échec.
  bool get isError => !success;

  /// Vérifie si des données sont présentes.
  bool get hasData => data != null;

  /// Indique si des erreurs de validation par champ sont présentes.
  bool get hasValidationErrors =>
      validationErrors != null && validationErrors!.isNotEmpty;

  /// Récupère l'erreur d'un champ spécifique s'il existe.
  String? fieldError(String fieldName) => validationErrors?[fieldName];

  /// Pattern matching fonctionnel pour traiter les cas Succès et Échec de manière exhaustive.
  R when<R>({
    required R Function(T data, String? message) success,
    required R Function(
      String message,
      int? statusCode,
      Map<String, String>? validationErrors,
    ) error,
  }) {
    if (this.success && data != null) {
      return success(data as T, message);
    } else {
      return error(
        message ?? 'Une erreur inattendue est survenue.',
        statusCode,
        validationErrors,
      );
    }
  }

  /// Décodage générique à partir d'un objet JSON ou d'un dictionnaire Spring Boot.
  factory ApiResponse.fromJson(
    dynamic json,
    T Function(dynamic dataJson) fromJsonT, {
    int? statusCode,
  }) {
    if (json is Map<String, dynamic>) {
      // Vérification du statut de succès
      final isSuccess = (json['success'] as bool?) ??
          (statusCode != null ? statusCode >= 200 && statusCode < 300 : true);

      // Extraction des erreurs de validation (format ErrorResponse du backend Spring Boot)
      Map<String, String>? valErrors;
      if (json['validationErrors'] is Map) {
        valErrors = (json['validationErrors'] as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }

      final message = json['message']?.toString() ?? json['error']?.toString();

      if (isSuccess) {
        final content = json.containsKey('data') ? json['data'] : json;
        return ApiResponse.success(
          fromJsonT(content),
          message: message,
          statusCode: statusCode ?? (json['status'] as int?),
          rawResponse: json,
        );
      } else {
        return ApiResponse.error(
          message ?? 'Erreur lors du traitement de la requête.',
          statusCode: statusCode ?? (json['status'] as int?),
          validationErrors: valErrors,
          rawResponse: json,
        );
      }
    }

    // Données directes (ex: List, String, primitive)
    return ApiResponse.success(
      fromJsonT(json),
      statusCode: statusCode,
      rawResponse: json,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponse<T> &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          data == other.data &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode =>
      success.hashCode ^ data.hashCode ^ message.hashCode ^ statusCode.hashCode;

  @override
  String toString() {
    return 'ApiResponse<$T>(success: $success, statusCode: $statusCode, data: $data, message: $message, validationErrors: $validationErrors)';
  }
}
