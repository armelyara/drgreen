# Dr Green API

API FastAPI pour l'identification de plantes médicinales africaines.

## Déploiement sur Google Cloud Run

### Prérequis
- Google Cloud SDK installé
- Projet GCP configuré
- Modèle TensorFlow entraîné

### Étapes de déploiement

1. **Ajouter votre modèle**
   ```bash
   # Copiez votre modèle .keras dans le dossier models/
   cp /path/to/your/model.keras models/
   cp /path/to/class_names.json models/
   ```

2. **Build l'image Docker**
   ```bash
   gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/drgreen-api
   ```

3. **Déployer sur Cloud Run**
   ```bash
   gcloud run deploy drgreen-api \
     --image gcr.io/YOUR_PROJECT_ID/drgreen-api \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --memory 2Gi \
     --cpu 2 \
     --timeout 300
   ```

### Test local

1. **Installer les dépendances**
   ```bash
   pip install -r requirements.txt
   ```

2. **Lancer le serveur**
   ```bash
   python main.py
   ```

3. **Tester l'API**
   ```bash
   # Health check
   curl http://localhost:8080/health

   # Identifier une plante
   curl -X POST -F "file=@plant_image.jpg" http://localhost:8080/api/v1/identify
   ```

## Endpoints

### `POST /api/v1/identify`
Identifie une plante à partir d'une image.

**Request:**
- `file`: Image (multipart/form-data)
- `use_tta`: Boolean (optionnel, défaut: true)

**Response:**
```json
{
  "success": true,
  "prediction": {
    "class": "artemisia",
    "confidence": 0.95,
    "all_probabilities": {...},
    "top_3": [...]
  },
  "plant_info": {
    "nom_scientifique": "Artemisia annua",
    "noms_communs": {...},
    "usages_traditionnels": {...}
  }
}
```

### `GET /api/v1/plants`
Retourne toutes les informations sur les plantes.

### `GET /api/v1/plant/{plant_name}`
Retourne les informations d'une plante spécifique.

## Budget Cloud Run

Pour optimiser les coûts :
- Utiliser l'option `--min-instances 0` (scale to zero)
- Limiter la mémoire à 2Gi
- Utiliser 1-2 CPU max
- Activer le caching si nécessaire

Coût estimé : ~$5-10/mois pour un trafic modéré
