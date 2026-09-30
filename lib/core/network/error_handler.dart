import 'package:dio/dio.dart';

/// Hiérarchie des exceptions techniques et métiers de LADAFURA.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String>? validationErrors;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.statusCode,
    this.validationErrors,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Erreur de connectivité ou de latence réseau (adaptée aux réseaux mobiles 3G/4G du Mali).
class NetworkException extends AppException {
  const NetworkException({
    super.message =
        'Impossible de joindre le serveur. Vérifiez votre connexion Internet (3G/4G/Wi-Fi).',
    super.statusCode,
    super.originalError,
  });
}

/// Erreur 400 : Paramètres invalides ou formulaire incomplet.
class BadRequestException extends AppException {
  const BadRequestException({
    super.message = 'Les données envoyées sont invalides ou incomplètes.',
    super.statusCode = 400,
    super.validationErrors,
    super.originalError,
  });
}

/// Erreur 401 : Non authentifié ou jeton Firebase expiré.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Votre session a expiré. Veuillez vous reconnecter.',
    super.statusCode = 401,
    super.originalError,
  });
}

/// Erreur 403 : Accès interdit ou rôle insuffisant (ex: Citoyen accédant à une route Agent).
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Accès non autorisé pour votre profil d\'utilisateur.',
    super.statusCode = 403,
    super.originalError,
  });
}

/// Erreur 404 : Ressource non trouvée (Plante, Produit, Commande, etc.).
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'La ressource demandée n\'existe pas ou a été déplacée.',
    super.statusCode = 404,
    super.originalError,
  });
}

/// Erreur 409 : Conflit de données (ex: compte ou référence déjà existante).
class ConflictException extends AppException {
  const ConflictException({
    super.message = 'Un conflit est survenu avec une ressource déjà existante.',
    super.statusCode = 409,
    super.originalError,
  });
}

/// Erreur 500 / 502 / 503 / 504 : Panne ou maintenance serveur.
class ServerException extends AppException {
  const ServerException({
    super.message =
        'Le service LADAFURA est temporairement indisponible. Veuillez réessayer plus tard.',
    super.statusCode = 500,
    super.originalError,
  });
}

/// Erreur inattendue ou inconnue.
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Une erreur inattendue est survenue.',
    super.statusCode,
    super.originalError,
  });
}

/// Gestionnaire centralisé de décodage des erreurs HTTP et Dio.
///
/// Décode fidèlement le schéma [ErrorResponse] du backend Spring Boot :
/// `{ "timestamp": "...", "status": 400, "error": "Bad Request", "message": "...", "validationErrors": {...} }`
class ErrorHandler {
  ErrorHandler._();

  /// Transforme n'importe quelle exception ou erreur Dio en une [AppException] explicite.
  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    return UnknownException(
      message: error?.toString() ?? 'Une erreur inattendue est survenue.',
      originalError: error,
    );
  }

  /// Extrait le message compréhensible et bienveillant pour l'utilisateur.
  static String getUserMessage(dynamic error) {
    return handle(error).message;
  }

  /// Extrait les erreurs de validation par champ si elles existent.
  static Map<String, String>? getValidationErrors(dynamic error) {
    return handle(error).validationErrors;
  }

  static AppException _handleDioException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message:
              'Le délai de connexion au serveur a expiré (15s). Vérifiez votre connexion Internet.',
          originalError: dioError,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          message:
              'Le délai d\'envoi de la requête a expiré. Votre connexion réseau semble instable.',
          originalError: dioError,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message:
              'Le serveur met trop de temps à répondre. Veuillez réessayer dans quelques instants.',
          originalError: dioError,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'Impossible de contacter le serveur LADAFURA. Vérifiez votre connexion Internet.',
          originalError: dioError,
        );

      case DioExceptionType.badCertificate:
        return ServerException(
          message: 'Erreur de certificat de sécurité SSL sécurisé.',
          originalError: dioError,
        );

      case DioExceptionType.cancel:
        return const UnknownException(
          message: 'La requête a été annulée.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(dioError.response, dioError);

      case DioExceptionType.unknown:
      default:
        return UnknownException(
          message:
              'Une anomalie réseau est survenue. Vérifiez votre connexion Internet.',
          originalError: dioError,
        );
    }
  }

  static AppException _handleBadResponse(
    Response<dynamic>? response,
    DioException originalError,
  ) {
    final statusCode = response?.statusCode ?? 500;
    final responseData = response?.data;

    String? serverMessage;
    Map<String, String>? validationErrors;

    if (responseData is Map<String, dynamic>) {
      // Décodage du format ErrorResponse de Spring Boot
      serverMessage = responseData['message']?.toString();
      if (serverMessage == null || serverMessage.isEmpty) {
        serverMessage = responseData['error']?.toString();
      }

      if (responseData['validationErrors'] is Map) {
        validationErrors = (responseData['validationErrors'] as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      serverMessage = responseData;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: serverMessage ?? 'Données de la requête invalides.',
          statusCode: statusCode,
          validationErrors: validationErrors,
          originalError: originalError,
        );

      case 401:
        return UnauthorizedException(
          message: serverMessage ??
              'Votre session a expiré. Veuillez vous reconnecter.',
          statusCode: statusCode,
          originalError: originalError,
        );

      case 403:
        return ForbiddenException(
          message: serverMessage ??
              'Vous n\'avez pas les droits nécessaires pour accéder à cette fonctionnalité.',
          statusCode: statusCode,
          originalError: originalError,
        );

      case 404:
        return NotFoundException(
          message:
              serverMessage ?? 'La ressource demandée n\'a pas été trouvée.',
          statusCode: statusCode,
          originalError: originalError,
        );

      case 409:
        return ConflictException(
          message: serverMessage ??
              'Un conflit est survenu avec une ressource déjà existante.',
          statusCode: statusCode,
          originalError: originalError,
        );

      case 500:
        return ServerException(
          message: serverMessage ??
              'Une erreur interne est survenue sur le serveur LADAFURA.',
          statusCode: statusCode,
          originalError: originalError,
        );

      case 502:
      case 503:
      case 504:
        return ServerException(
          message:
              'Le serveur LADAFURA est temporairement indisponible ou en maintenance. Veuillez patienter.',
          statusCode: statusCode,
          originalError: originalError,
        );

      default:
        return UnknownException(
          message: serverMessage ??
              'Erreur $statusCode : Une réponse inattendue a été reçue du serveur.',
          statusCode: statusCode,
          originalError: originalError,
        );
    }
  }
}
