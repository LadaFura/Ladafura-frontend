import 'dart:async';

/// Types de notifications in-app et alertes selon les exigences fonctionnelles (EF32).
enum AppNotificationType {
  /// Alerte relative au cycle de vie d'une commande (US-11 & US-23).
  commande,

  /// Notification de validation ou correction de collecte terrain (US-17).
  collecte,

  /// Alerte de seuil de stock ou rupture pour une officine (US-20).
  stock,

  /// Information institutionnelle émise par l'INRMPT.
  systeme,
}

/// Modèle immuable d'une notification LADAFURA.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? targetRoute;
  final Map<String, dynamic>? payload;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.targetRoute,
    this.payload,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    AppNotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? targetRoute,
    Map<String, dynamic>? payload,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'targetRoute': targetRoute,
        'payload': payload,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: AppNotificationType.values.byName(json['type'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: (json['isRead'] as bool?) ?? false,
        targetRoute: json['targetRoute'] as String?,
        payload: json['payload'] as Map<String, dynamic>?,
      );

  @override
  String toString() =>
      'AppNotification(id: $id, title: $title, type: $type, isRead: $isRead)';
}

/// Service centralisé de gestion et diffusion des notifications in-app et alertes (EF32).
class NotificationService {
  final List<AppNotification> _notifications = [];
  final StreamController<AppNotification> _streamController =
      StreamController<AppNotification>.broadcast();

  /// Flux continu des nouvelles notifications reçues en temps réel.
  Stream<AppNotification> get notificationStream => _streamController.stream;

  /// Historique complet des notifications reçues en session.
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Liste des notifications non encore consultées.
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Compteur de notifications non lues (pour pastille / badge dans l'UI).
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Émet et enregistre une nouvelle notification.
  void showNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _streamController.add(notification);
  }

  /// Marque une notification spécifique comme lue.
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  /// Marque l'ensemble des notifications comme lues.
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  /// Supprime une notification de l'historique.
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  /// Réinitialise l'historique des notifications.
  void clearAll() {
    _notifications.clear();
  }

  /// Libère les ressources du contrôleur de flux.
  void dispose() {
    _streamController.close();
  }
}
