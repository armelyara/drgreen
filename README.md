# 🌿 Dr Green - Bibliothèque Collaborative de la Botanique Africaine

Application mobile d'identification de plantes médicinales intégrant les méthodes de guérison traditionnelle africaine.

![Dr Green Logo](002-removebg-preview.png)

## 📋 Vue d'ensemble

Dr Green est une solution complète comprenant :
- **Application Mobile Flutter** - Interface utilisateur moderne avec identification par IA
- **API FastAPI** - Backend pour l'inférence du modèle ML
- **Modèle IA** - Classification de plantes médicinales avec >82% d'accuracy
- **Firebase** - Base de données, authentification et stockage

## 🎯 Fonctionnalités

### MVP (Version 2.0)

✅ **Identification par Image**
- Scan en temps réel ou depuis la galerie
- Prédiction avec confiance et top 3 résultats
- Test-Time Augmentation pour meilleure précision

✅ **Base de Données Enrichie**
- Nom scientifique et noms communs multilingues (FR, EN, Baoulé, Dioula)
- Localisation en Côte d'Ivoire
- Usages traditionnels détaillés
- Préparation et posologie
- Précautions d'usage

✅ **Contribution Utilisateur**
- Ajout de nouvelles plantes
- Upload de photos multiples
- Soumission avec modération

✅ **Modération**
- Validation des contributions
- Panel admin (à venir)

## 🏗️ Architecture Technique

```
drgreen/
├── flutter_app/              # Application mobile Flutter
│   ├── lib/
│   │   ├── models/          # Modèles de données
│   │   ├── screens/         # Écrans de l'app
│   │   ├── services/        # Services (API, Firebase)
│   │   ├── widgets/         # Widgets réutilisables
│   │   └── utils/           # Utilitaires et thème
│   └── pubspec.yaml
│
├── api/                      # API FastAPI
│   ├── main.py              # Serveur FastAPI
│   ├── requirements.txt     # Dépendances Python
│   ├── Dockerfile           # Container pour Cloud Run
│   └── models/              # Modèles ML (.keras)
│
├── drgreen_v4_improved.ipynb # Notebook d'entraînement ML (V4)
└── drgreen_v3_optimized.ipynb # Notebook ML (V3)
```

## 🎨 Design

### Palette de Couleurs Africaines

- **Primaire** : Vert Forêt `#408635` - Nature, croissance
- **Secondaire** : Jaune Soleil `#FFB300` - Richesse des savoirs
- **Accent** : Terre Cuite `#D84315` - Actions importantes

### Typographie

- Police : **Poppins** (moderne et claire)
- Style : **Outlined** icons de Material Design

## 🚀 Installation & Déploiement

### 1. Entraîner le Modèle IA

```bash
# Ouvrir le notebook dans Google Colab
# Exécuter drgreen_v4_improved.ipynb
# Télécharger le modèle .keras généré
```

### 2. Déployer l'API sur Cloud Run

```bash
cd api/

# Copier le modèle entraîné
cp path/to/drgreen_v4_improved.keras models/
cp path/to/class_names.json models/

# Build et déployer
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/drgreen-api
gcloud run deploy drgreen-api \
  --image gcr.io/YOUR_PROJECT_ID/drgreen-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2
```

### 3. Configurer Firebase

1. Créer un projet Firebase
2. Activer Authentication (Email/Password)
3. Activer Firestore Database
4. Activer Storage
5. Télécharger les fichiers de config :
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

### 4. Lancer l'Application Flutter

```bash
cd flutter_app/

# Installer les dépendances
flutter pub get

# Mettre à jour l'URL de l'API dans lib/services/api_service.dart
# Ajouter les fichiers Firebase

# Lancer en mode debug
flutter run

# Build pour production
flutter build apk  # Android
flutter build ios  # iOS
```

## 📊 Modèle IA - Performances

### Version 4 (Améliorée)

- **Architecture** : EfficientNetB3
- **Stratégie** : Two-phase training (frozen base → fine-tuning)
- **Techniques** : MixUp, TTA, Focal Loss
- **Accuracy visée** : >85%
- **Classes** : 4 plantes (Artemisia, Carica, Goyavier, Kinkeliba)

### Version 3 (Baseline)

- **Architecture** : EfficientNetB0
- **Accuracy** : 82.06%
- **Top-2 Accuracy** : 95.96%

## 🌱 Plantes Médicinales

1. **Artemisia (Armoise)** - Antipaludique
2. **Carica (Papaye)** - Troubles digestifs
3. **Goyavier** - Antiseptique
4. **Kinkeliba** - Détoxifiant

## 💾 Structure Firestore

### Collection `plants`

```javascript
{
  nom_scientifique: "Artemisia annua",
  noms_communs: {
    fr: "Armoise annuelle",
    en: "Sweet wormwood",
    baoulé: "N'tran",
    dioula: "N'tran"
  },
  regions_ci: ["Abidjan", "Yamoussoukro"],
  usages_traditionnels: {
    maladies: ["Paludisme", "Fièvre"],
    preparation: "Infusion de feuilles...",
    posologie: "3 tasses par jour...",
    precautions: "Déconseillé aux femmes enceintes..."
  },
  images_urls: ["https://..."],
  date_ajout: Timestamp,
  auteur_id: "user123",
  statut: "approuve"
}
```

## 🔐 Règles de Sécurité

### Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /plants/{plantId} {
      allow read: if resource.data.statut == 'approuve';
      allow write: if request.auth != null &&
                     request.auth.token.role == 'moderator';
    }

    match /contributions/{contributionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                      request.auth.token.role == 'moderator';
    }
  }
}
```

## 💰 Budget Cloud

### Cloud Run (API)

- Configuration : 2Gi RAM, 2 CPU
- Scale to zero activé
- Coût estimé : **$5-10/mois** (trafic modéré)

### Firebase

- Plan Spark (gratuit) : suffisant pour MVP
- Plan Blaze (pay-as-you-go) : pour production

## 📈 Roadmap

### Phase 1 : Infrastructure & MVP ✅
- [x] Modèle IA v3 (82% accuracy)
- [x] Modèle IA v4 amélioré
- [x] API FastAPI
- [x] Application Flutter
- [x] Firebase integration

### Phase 2 : Contribution & Modération
- [ ] Panel modérateur web
- [ ] Notifications push
- [ ] Système de validation collaboratif

### Phase 3 : Amélioration IA
- [ ] Collecte de données utilisateurs
- [ ] Ré-entraînement continu
- [ ] Augmentation du dataset (500+ images/classe)

### Phase 4 : Production
- [ ] Tests utilisateurs
- [ ] Publication sur stores
- [ ] Campagne de lancement

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## ⚠️ Avertissement

Les informations médicinales présentées dans cette application sont basées sur des usages traditionnels.
Elles ne remplacent pas un avis médical professionnel.
Consultez toujours un professionnel de santé avant utilisation.

## 📄 Licence

MIT License

## 👥 Auteurs

Projet Dr Green - Bibliothèque Collaborative de la Botanique Africaine

---

**Fait avec 💚 pour préserver les savoirs traditionnels africains**
