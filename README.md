# LADAFURA Flutter

## Connexion à l'API locale

Démarrez le backend Spring Boot sur le port `8080` et vérifiez que le téléphone
et l'ordinateur sont connectés au même réseau Wi-Fi.

Sur un téléphone Android physique, configurez l'adresse IPv4 Wi-Fi de
l'ordinateur qui exécute le backend :

```powershell
flutter run --dart-define=API_HOST=192.168.11.160
```

Remplacez cette adresse par l'adresse IPv4 actuelle de l'ordinateur si elle
change. Elle peut être vérifiée avec `ipconfig`. Autorisez également le port
`8080` dans le pare-feu Windows si nécessaire.

Pour l'émulateur Android, utilisez l'adresse spéciale de l'hôte :

```powershell
flutter run --dart-define=API_HOST=10.0.2.2
```

Pour les plateformes desktop et Web, l'adresse par défaut est
`http://localhost:8080`. `API_URL` peut remplacer l'URL complète de base,
y compris `/api/v1`, si nécessaire.
