# Dr Green - Application Mobile

Application Flutter pour l'identification de plantes médicinales africaines.

## Caractéristiques

- 🌿 Identification de plantes par IA
- 📚 Bibliothèque collaborative
- 🔍 Recherche et filtrage
- ➕ Contribution utilisateur
- 🔐 Authentification Firebase
- ☁️ Stockage cloud Firebase

## Architecture

```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
│   └── plant.dart
├── screens/                  # Écrans
│   ├── home_screen.dart
│   ├── camera_screen.dart
│   ├── library_screen.dart
│   ├── detail_screen.dart
│   ├── contribute_screen.dart
│   ├── result_screen.dart
│   └── settings_screen.dart
├── services/                 # Services
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── firestore_service.dart
├── widgets/                  # Widgets réutilisables
│   └── plant_card.dart
└── utils/                    # Utilitaires
    └── theme.dart           # Thème et couleurs
```

## Configuration

### 1. Firebase

1. Créer un projet Firebase
2. Ajouter les applications Android et iOS
3. Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
4. Activer Authentication, Firestore et Storage

### 2. API

Mettre à jour l'URL de l'API dans `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'YOUR_CLOUD_RUN_URL';
```

### 3. Dépendances

```bash
flutter pub get
```

## Lancer l'application

```bash
# Debug
flutter run

# Release
flutter build apk  # Android
flutter build ios  # iOS
```

## Design

### Palette de couleurs africaines

- **Primaire** : Vert Forêt `#408635`
- **Secondaire** : Jaune Soleil `#FFB300`
- **Accent** : Terre Cuite `#D84315`

### Typographie

- Police : **Poppins** (via Google Fonts)

## Structure Firestore

### Collection `plants`

```json
{
  "nom_scientifique": "Artemisia annua",
  "noms_communs": {
    "fr": "Armoise annuelle",
    "en": "Sweet wormwood",
    "baoulé": "N'tran",
    "dioula": "N'tran"
  },
  "regions_ci": ["Abidjan", "Yamoussoukro"],
  "usages_traditionnels": {
    "maladies": ["Paludisme", "Fièvre"],
    "preparation": "...",
    "posologie": "...",
    "precautions": "..."
  },
  "images_urls": ["https://..."],
  "date_ajout": "2024-01-01T00:00:00Z",
  "auteur_id": "user123",
  "statut": "approuve"
}
```

### Collection `contributions`

Même structure que `plants`, avec `statut: "en_attente"`

## Règles de sécurité Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Plants (lecture publique)
    match /plants/{plantId} {
      allow read: if resource.data.statut == 'approuve';
      allow write: if request.auth != null &&
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'moderator';
    }

    // Contributions (lecture/écriture authentifiée)
    match /contributions/{contributionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'moderator';
    }
  }
}
```

## Licence

MIT License
