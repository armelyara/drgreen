# 🧪 Guide de Test - Dr Green V4 Model

## 📝 Prérequis

Le notebook `drgreen_v4_improved.ipynb` est maintenant configuré pour **télécharger automatiquement le dataset** depuis votre Google Drive.

## 🚀 Comment tester le notebook

### Option 1 : Google Colab (Recommandé)

1. **Ouvrir le notebook dans Colab**
   - Aller sur : https://colab.research.google.com/
   - Cliquer sur `File` → `Upload notebook`
   - Ou utiliser le lien direct : https://colab.research.google.com/github/armelyara/drgreen/blob/claude/drgreen-v2-01TfLAqRxjEF2BkLLt72vJrL/drgreen_v4_improved.ipynb

2. **Activer le GPU (Important !)**
   - Menu : `Runtime` → `Change runtime type`
   - Hardware accelerator : Sélectionner **GPU** (T4 gratuit)
   - Save

3. **Exécuter le notebook**
   - Menu : `Runtime` → `Run all`
   - Ou exécuter cellule par cellule avec `Shift + Enter`

4. **Le notebook va automatiquement :**
   - ✅ Installer `gdown`
   - ✅ Télécharger le dataset depuis Google Drive (ID: `1zI5KfTtuV0BlBQnNDNq4tBJuEkxLZZBD`)
   - ✅ Extraire le dataset
   - ✅ Afficher les statistiques (nombre d'images par classe)
   - ✅ Entraîner le modèle en 2 phases
   - ✅ Sauvegarder le modèle final

### Option 2 : Jupyter Local (Si vous avez GPU)

```bash
# Cloner le repo
git clone https://github.com/armelyara/drgreen.git
cd drgreen
git checkout claude/drgreen-v2-01TfLAqRxjEF2BkLLt72vJrL

# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# Installer les dépendances
pip install tensorflow numpy matplotlib seaborn pandas scikit-learn pillow gdown

# Lancer Jupyter
jupyter notebook drgreen_v4_improved.ipynb
```

## ⏱️ Temps d'exécution estimé

| Phase | Temps (GPU T4) | Temps (CPU) |
|-------|----------------|-------------|
| Téléchargement dataset | ~1-2 min | ~1-2 min |
| Phase 1 (30 epochs) | ~15-20 min | ~2-3 heures |
| Phase 2 (20 epochs) | ~10-15 min | ~1-2 heures |
| Évaluation avec TTA | ~5 min | ~30 min |
| **Total** | **~30-40 min** | **~4-6 heures** |

## 📊 Résultats attendus

### V4 Amélioré (Target)
- **Accuracy** : >85%
- **Top-2 Accuracy** : >95%
- **Overfitting Gap** : <5%

### V3 Baseline (Pour comparaison)
- Accuracy : 82.06%
- Top-2 Accuracy : 95.96%

## 📥 Télécharger les modèles entraînés

Après l'exécution, téléchargez ces fichiers depuis Colab :

```
models/
├── drgreen_v4_improved_YYYYMMDD_HHMMSS.keras      # Modèle principal
├── drgreen_v4_improved_YYYYMMDD_HHMMSS.tflite     # Version mobile
├── drgreen_v4_improved_YYYYMMDD_HHMMSS_metadata.json  # Performances
└── class_names.json                                # Noms des classes
```

**Pour télécharger depuis Colab :**
```python
from google.colab import files

# Télécharger le modèle Keras
files.download('models/drgreen_v4_improved_YYYYMMDD_HHMMSS.keras')

# Télécharger les métadonnées
files.download('models/drgreen_v4_improved_YYYYMMDD_HHMMSS_metadata.json')

# Télécharger class_names.json
files.download('models/class_names.json')
```

## 🔍 Vérification du modèle

Après l'entraînement, le notebook affiche :

1. **Courbes d'apprentissage** : Accuracy et Loss pour les 2 phases
2. **Matrice de confusion** : Performance par classe
3. **Rapport de classification** : Precision, Recall, F1-score
4. **Accuracy par classe** : Détails pour chaque plante

## 🐛 Résolution de problèmes

### Erreur : "Dataset not found"
- Vérifiez que le lien Google Drive est accessible publiquement
- Le fichier ID dans la cellule 4 doit être : `1zI5KfTtuV0BlBQnNDNq4tBJuEkxLZZBD`

### Erreur : "Out of memory"
- Réduire `batch_size` de 16 à 8 dans la cellule de configuration
- Utiliser EfficientNetB0 au lieu de B3 (changer `'base_model': 'EfficientNetB0'`)

### Entraînement trop lent
- Vérifier que le GPU est activé dans Colab
- Vérifier : `print(tf.config.list_physical_devices('GPU'))`

### Faible accuracy (<70%)
- Vérifier que le dataset est bien structuré : `rename/[classe]/images.jpg`
- Augmenter le nombre d'epochs
- Désactiver MixUp si les résultats sont mauvais : `'use_mixup': False`

## 📧 Support

Si vous rencontrez des problèmes :
1. Vérifier les logs dans le notebook
2. Capturer l'erreur et me la communiquer
3. Vérifier la structure du dataset

## ✅ Checklist avant déploiement

- [ ] Modèle entraîné avec accuracy >80%
- [ ] Fichier `.keras` téléchargé
- [ ] Fichier `class_names.json` téléchargé
- [ ] Métadonnées sauvegardées
- [ ] Testé les prédictions sur quelques images
- [ ] Prêt pour copier dans `api/models/`

---

**Bon entraînement ! 🚀🌿**
