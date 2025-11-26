# 🚀 Guide de Déploiement API - Dr Green

Ce guide détaille les étapes pour déployer l'API Dr Green sur Google Cloud Run.

## 📋 Prérequis

1.  **Compte Google Cloud** : Avoir un projet actif avec la facturation activée.
2.  **Modèle entraîné** : Avoir le fichier `.keras` de votre modèle (téléchargé depuis Colab).

## 🛠️ Installation des Outils

Vous devez installer le Google Cloud SDK (`gcloud`) sur votre machine.

### macOS
```bash
# Télécharger et installer
brew install --cask google-cloud-sdk

# Initialiser
gcloud init
```

### Windows
Télécharger l'installateur depuis : https://cloud.google.com/sdk/docs/install

## 📂 Préparation des Fichiers

1.  **Placer le modèle** :
    Copiez votre fichier modèle (ex: `drgreen_v4.keras`) dans le dossier `api/models/`.

    ```bash
    cp /chemin/vers/votre/modele.keras api/models/
    ```

2.  **Vérifier la structure** :
    Votre dossier `api` doit ressembler à ceci :
    ```
    api/
    ├── Dockerfile
    ├── main.py
    ├── requirements.txt
    └── models/
        ├── class_names.json
        └── votre_modele.keras  <-- Important !
    ```

## ☁️ Déploiement sur Cloud Run

Exécutez ces commandes depuis le dossier racine du projet (`Dr-Green/`).

### 1. Activer les services nécessaires
```bash
gcloud services enable artifactregistry.googleapis.com cloudbuild.googleapis.com run.googleapis.com
```

### 2. Configurer la région (ex: europe-west1 pour Belgique)
```bash
gcloud config set run/region europe-west1
```

### 3. Déployer
Cette commande va construire l'image Docker, l'envoyer sur Google Cloud, et lancer le service.

```bash
# Remplacer PROJECT_ID par l'ID de votre projet Google Cloud
gcloud builds submit --tag gcr.io/PROJECT_ID/drgreen-api api/

gcloud run deploy drgreen-api \
  --image gcr.io/PROJECT_ID/drgreen-api \
  --platform managed \
  --allow-unauthenticated \
  --memory 2Gi
```

## 🔗 Connexion avec l'Application Flutter

Une fois le déploiement terminé, Google Cloud vous donnera une URL (ex: `https://drgreen-api-xyz.a.run.app`).

1.  Ouvrez `flutter_app/lib/services/api_service.dart`.
2.  Mettez à jour la variable `baseUrl` :

```dart
static const String baseUrl = 'https://drgreen-api-xyz.a.run.app';
```

3.  Dans `flutter_app/lib/main.dart`, assurez-vous d'utiliser le vrai `ApiService` :

```dart
// Remplacer MockApiService par ApiService
Provider<ApiService>(create: (_) => ApiService()),
```

## 🔍 Vérification

Pour vérifier que l'API fonctionne :
1.  Allez sur `https://VOTRE_URL_API/` -> Doit afficher `{"status": "running"}`.
2.  Allez sur `https://VOTRE_URL_API/docs` -> Affiche l'interface Swagger pour tester les endpoints.

---
**Besoin d'aide ?** Consultez la documentation Cloud Run : https://cloud.google.com/run/docs
