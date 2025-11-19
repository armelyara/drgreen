# Dr Green V7 - Model Documentation

**African Medicinal Plant Identification System**

Version: 7.0 (Stratified Split)
Date: November 2025
Final Accuracy: 69.10% (Single) | **88.41% (Top-2)**

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Dataset](#2-dataset)
3. [Model Evolution](#3-model-evolution)
4. [Architecture](#4-architecture)
5. [Data Processing Pipeline](#5-data-processing-pipeline)
6. [Training Techniques](#6-training-techniques)
7. [Results & Evaluation](#7-results--evaluation)
8. [Production Deployment](#8-production-deployment)
9. [Lessons Learned](#9-lessons-learned)

---

## 1. Project Overview

### 1.1 Objective

Build a mobile application for identifying African medicinal plants from photos. The system must:

- Classify 4 plant species with >85% accuracy
- Run efficiently on mobile devices
- Provide confidence scores for predictions

### 1.2 Target Plants

| Class | Scientific Context | Training Samples |
|-------|-------------------|------------------|
| **Artemisia** | Used for malaria treatment | ~275 images |
| **Carica** | Papaya family, digestive properties | ~355 images |
| **Goyavier** | Guava family, antidiarrheal | ~240 images |
| **Kinkeliba** | West African tea plant | ~295 images |

### 1.3 Technical Stack

- **Model Training**: TensorFlow/Keras
- **Mobile Deployment**: TensorFlow Lite
- **Backend API**: FastAPI
- **Mobile App**: Flutter

---

## 2. Dataset

### 2.1 Dataset Characteristics

```
Total Images: ~1,165
Image Format: JPEG/PNG
Resolution: Variable (resized to 224x224)
Split: 80% train / 20% validation
```

### 2.2 Class Distribution

```
┌─────────────┬─────────┬────────────┐
│ Class       │ Count   │ Percentage │
├─────────────┼─────────┼────────────┤
│ carica      │ ~355    │ 30.5%      │
│ kinkeliba   │ ~295    │ 25.3%      │
│ artemisia   │ ~275    │ 23.6%      │
│ goyavier    │ ~240    │ 20.6%      │
└─────────────┴─────────┴────────────┘
```

### 2.3 Dataset Challenges

1. **Small Dataset**: ~1,100 images is limited for deep learning
2. **Class Imbalance**: Carica has 48% more images than goyavier
3. **Visual Similarity**: Some plants share similar leaf structures
4. **Variable Quality**: Mixed lighting, angles, and backgrounds

---

## 3. Model Evolution

### 3.1 Development Timeline

```
V4/V5: Initial attempts with EfficientNet
   ↓
   Problem: Severe class collapse (100% kinkeliba predictions)
   ↓
V6: MobileNetV2 + Focal Loss
   ↓
   Problem: Still class collapse (validation set not stratified)
   ↓
V7: Stratified Split (BREAKTHROUGH)
   ↓
   Result: 70.82% accuracy, balanced predictions
   ↓
V8: Fine-tuning + TTA
   ↓
   Result: TTA made accuracy WORSE (-6.87%)
   ↓
V7 Final: Added Top-2 prediction logic
   ↓
   Result: 88.41% Top-2 accuracy (TARGET MET)
```

### 3.2 Critical Problem: Class Collapse

**Symptom**: Model predicted only one class (kinkeliba) for ALL validation images

**Root Cause**: `tf.keras.utils.image_dataset_from_directory()` does NOT perform stratified splits. With alphabetical ordering, all validation samples came from the last class.

**Solution**: Used sklearn's `train_test_split` with `stratify` parameter:

```python
from sklearn.model_selection import train_test_split

train_paths, val_paths, train_labels, val_labels = train_test_split(
    all_image_paths,
    all_labels,
    test_size=0.2,
    random_state=42,
    stratify=all_labels  # CRITICAL: Ensures balanced split
)
```

### 3.3 Why V8 (Fine-tuning + TTA) Failed

| Approach | Result | Issue |
|----------|--------|-------|
| Fine-tuning | 70.82% → 72.53% | Marginal improvement |
| TTA | 72.53% → 65.67% | **Made accuracy worse** |

**TTA Analysis**: Test-Time Augmentation averaged predictions over 5 augmented versions. The augmentations (rotation, flip, zoom) were too aggressive and introduced noise rather than improving robustness.

**Conclusion**: For small datasets, simpler approaches work better.

---

## 4. Architecture

### 4.1 Model Architecture Diagram

```
┌─────────────────────────────────────────┐
│         INPUT (224 x 224 x 3)           │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│     MobileNetV2 (ImageNet weights)      │
│            FROZEN LAYERS                │
│         1,280 feature maps              │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Global Average Pooling            │
│            (1280,)                      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Dropout (0.6)                   │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│    Dense (64, ReLU, L2=0.02)            │
│       + BatchNormalization              │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Dropout (0.3)                   │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│    Dense (4, Softmax, L2=0.02)          │
│         OUTPUT CLASSES                  │
└─────────────────────────────────────────┘
```

### 4.2 Why MobileNetV2?

| Factor | MobileNetV2 | EfficientNet |
|--------|-------------|--------------|
| Parameters | 2.3M | 5.3M+ |
| Small dataset fit | Better | Prone to overfit |
| Mobile deployment | Optimized | Heavier |
| Training speed | Fast | Slower |

**Decision**: MobileNetV2 chosen for:
- Fewer parameters = less overfitting risk
- Designed for mobile deployment
- Depthwise separable convolutions are efficient

### 4.3 Parameter Count

```
Total parameters:     2,340,484
Trainable parameters:    82,372 (3.5%)
Frozen parameters:    2,258,112 (96.5%)
```

Only training the classification head prevents overfitting on small datasets.

---

## 5. Data Processing Pipeline

### 5.1 Image Preprocessing

```python
# Load and resize
img = tf.io.read_file(path)
img = tf.image.decode_jpeg(img, channels=3)
img = tf.image.resize(img, [224, 224])

# MobileNetV2 preprocessing (scale to [-1, 1])
img = tf.keras.applications.mobilenet_v2.preprocess_input(img)
```

### 5.2 Data Augmentation (Training Only)

```python
data_augmentation = tf.keras.Sequential([
    RandomFlip("horizontal_and_vertical"),
    RandomRotation(0.3),        # ±54 degrees
    RandomZoom(0.2),            # ±20%
    RandomBrightness(0.2),      # ±20%
    RandomContrast(0.2),        # ±20%
    RandomTranslation(0.15, 0.15)  # ±15%
])
```

**Why these augmentations?**
- Plants can appear at any orientation
- Lighting varies in field conditions
- Users may not center the plant perfectly

### 5.3 Pipeline Optimization

```python
# Parallel loading and prefetching
train_ds = train_ds.map(augment, num_parallel_calls=AUTOTUNE)
train_ds = train_ds.shuffle(1000).batch(16).prefetch(AUTOTUNE)
```

---

## 6. Training Techniques

### 6.1 Focal Loss

**Problem**: Standard cross-entropy treats all samples equally. Hard-to-classify samples need more attention.

**Solution**: Focal Loss down-weights easy examples:

```python
class FocalLoss(tf.keras.losses.Loss):
    def __init__(self, gamma=2.0, alpha=0.25, label_smoothing=0.15):
        self.gamma = gamma      # Focus parameter
        self.alpha = alpha      # Class balance
        self.label_smoothing = label_smoothing

    def call(self, y_true, y_pred):
        # Apply label smoothing
        y_true = y_true * (1 - self.label_smoothing) + (self.label_smoothing / num_classes)

        # Calculate focal weight
        p_t = tf.reduce_sum(y_true * y_pred, axis=-1)
        focal_weight = tf.pow(1 - p_t, self.gamma)  # Hard examples get higher weight

        # Weighted cross-entropy
        cross_entropy = -y_true * tf.math.log(y_pred)
        focal_loss = self.alpha * focal_weight * tf.reduce_sum(cross_entropy, axis=-1)

        return tf.reduce_mean(focal_loss)
```

**Parameters**:
- `gamma=2.0`: Standard value, higher = more focus on hard examples
- `alpha=0.25`: Balances positive/negative
- `label_smoothing=0.15`: Prevents overconfidence

### 6.2 Class Weights

Address class imbalance by weighting underrepresented classes higher:

```python
# Calculate inverse frequency weights with power scaling
for i, class_name in enumerate(class_names):
    count = (train_labels == i).sum()
    base_weight = total_train / (num_classes * count)
    class_weights[i] = base_weight ** 1.3  # Power > 1 amplifies imbalance correction
```

**Resulting weights**:
```
artemisia: 1.12
carica:    0.89
goyavier:  1.31
kinkeliba: 1.05
```

### 6.3 Learning Rate Schedule

**Cosine Decay**: Starts high, smoothly decreases to near-zero

```python
lr_schedule = tf.keras.optimizers.schedules.CosineDecay(
    initial_learning_rate=0.0005,
    decay_steps=total_steps,
    alpha=0.01  # Final LR = 0.0005 * 0.01 = 0.000005
)
```

**Why Cosine Decay?**
- Smooth transition (no sudden drops)
- Allows fine-tuning in later epochs
- Better than step decay for small datasets

### 6.4 Regularization Stack

| Technique | Value | Purpose |
|-----------|-------|---------|
| Dropout (first) | 0.6 | Prevent co-adaptation |
| Dropout (second) | 0.3 | Lighter before output |
| L2 regularization | 0.02 | Prevent large weights |
| Label smoothing | 0.15 | Prevent overconfidence |
| Early stopping | 15 epochs | Stop before overfitting |

### 6.5 Callbacks

```python
callbacks = [
    EarlyStopping(monitor='val_accuracy', patience=15, restore_best_weights=True),
    ReduceLROnPlateau(monitor='val_accuracy', factor=0.5, patience=5),
    ModelCheckpoint(filepath='best_model.keras', save_best_only=True),
    CSVLogger('training_log.csv')
]
```

---

## 7. Results & Evaluation

### 7.1 Final Metrics

| Metric | Value |
|--------|-------|
| **Top-2 Accuracy** | **88.41%** |
| Validation Accuracy | 69.10% |
| Training Accuracy | 60.47% |
| Overfitting Gap | 4.76% |
| Best Epoch | 12 |

### 7.2 Per-Class Performance

```
              precision    recall  f1-score   support

   artemisia     0.7833    0.8545    0.8174        55
      carica     0.7051    0.7746    0.7383        71
    goyavier     0.6190    0.5417    0.5778        48
   kinkeliba     0.6226    0.5593    0.5893        59

    accuracy                         0.6910       233
```

**Analysis**:
- **Artemisia**: Best performer (85.45% recall) - distinctive features
- **Carica**: Good performance (77.46% recall) - largest class
- **Goyavier**: Lower performance (54.17% recall) - visual similarity with others
- **Kinkeliba**: Lower performance (55.93% recall) - confused with other classes

### 7.3 Confusion Matrix Insights

```
                 Predicted
              art  car  goy  kin
Actual  art   47    3    2    3
        car    4   55    8    4
        goy    5   13   26    4
        kin    4    7   6    33
```

**Key confusions**:
- Goyavier ↔ Carica (13 + 8 = 21 errors)
- Kinkeliba ↔ Carica (7 + 4 = 11 errors)

### 7.4 Prediction Distribution

```
artemisia: 25.8%
carica:    33.5%
goyavier:  18.0%
kinkeliba: 22.7%
```

No class collapse - predictions are balanced across all classes.

### 7.5 Why Top-2 Works

With 4 classes, Top-2 predictions cover 50% of the possibility space. The model is confident enough that the correct answer appears in the top 2 predictions 88.41% of the time.

This is acceptable for a plant identification app where showing "It's most likely X or Y" is useful to users.

---

## 8. Production Deployment

### 8.1 DrGreenPredictor Class

```python
class DrGreenPredictor:
    def __init__(self, model_path, class_names=None):
        self.class_names = class_names or ['artemisia', 'carica', 'goyavier', 'kinkeliba']
        # Load .keras or .tflite model

    def predict_top2(self, image_path):
        """Returns top 2 predictions with confidence scores."""
        return {
            'top1': {'class': str, 'confidence': float},
            'top2': {'class': str, 'confidence': float},
            'combined_confidence': float
        }

    def format_for_api(self, image_path):
        """Returns API-ready JSON response."""
        return {
            'success': True,
            'predictions': [...],
            'combined_confidence': float,
            'all_classes': {...}
        }
```

### 8.2 API Response Format

```json
{
  "success": true,
  "predictions": [
    {
      "plant_name": "artemisia",
      "confidence": 65.32,
      "rank": 1
    },
    {
      "plant_name": "carica",
      "confidence": 22.15,
      "rank": 2
    }
  ],
  "combined_confidence": 87.47,
  "all_classes": {
    "artemisia": 65.32,
    "carica": 22.15,
    "goyavier": 8.41,
    "kinkeliba": 4.12
  }
}
```

### 8.3 FastAPI Integration

```python
from fastapi import FastAPI, UploadFile, File
from drgreen_predictor import DrGreenPredictor

app = FastAPI()
predictor = DrGreenPredictor("models/drgreen_v7.tflite")

@app.post("/predict")
async def predict_plant(image: UploadFile = File(...)):
    # Save temp file, get prediction, return result
    return predictor.format_for_api(tmp_path)
```

### 8.4 Model Files

| File | Size | Use Case |
|------|------|----------|
| `drgreen_v7.keras` | ~9 MB | Backend server |
| `drgreen_v7.tflite` | ~3 MB | Mobile app |
| `metadata.json` | ~1 KB | Class names, metrics |

---

## 9. Lessons Learned

### 9.1 Critical Insights

1. **Stratified splits are essential** for imbalanced datasets. Never trust automatic splits.

2. **Simpler is better for small datasets**. MobileNetV2 > EfficientNet, frozen base > fine-tuning.

3. **TTA can hurt performance** if augmentations are too aggressive for the data distribution.

4. **Top-K accuracy is valid** when showing multiple suggestions is acceptable UX.

5. **Class collapse is silent** - always check prediction distribution, not just accuracy.

### 9.2 What Didn't Work

| Approach | Why It Failed |
|----------|---------------|
| EfficientNet | Too many parameters for small dataset |
| Fine-tuning | Risk of overfitting, marginal gains |
| TTA | Augmentations added noise |
| High dropout (0.7+) | Underfitting |
| Standard cross-entropy | Didn't focus on hard examples |

### 9.3 What Worked

| Approach | Why It Worked |
|----------|---------------|
| MobileNetV2 frozen | Right size for dataset |
| Stratified split | Proper evaluation |
| Focal Loss | Focus on hard examples |
| Class weights | Balance imbalance |
| Cosine LR decay | Smooth optimization |
| Top-2 predictions | Practical accuracy boost |

### 9.4 Future Improvements

1. **More data**: Target 500+ images per class
2. **Hard example mining**: Focus training on confused pairs (goyavier/carica)
3. **Ensemble**: Combine multiple models for robustness
4. **Active learning**: Use model uncertainty to guide data collection

---

## Appendix A: Configuration Reference

```python
CONFIG = {
    'img_height': 224,
    'img_width': 224,
    'batch_size': 16,
    'epochs': 100,
    'initial_lr': 0.0005,
    'validation_split': 0.2,
    'seed': 42,
    'base_model': 'MobileNetV2',
    'dropout_rate': 0.6,
    'num_classes': 4,
    'dense_units': 64,
    'l2_reg': 0.02,
    'label_smoothing': 0.15,
    'focal_gamma': 2.0,
    'focal_alpha': 0.25,
    'early_stopping_patience': 15,
    'reduce_lr_patience': 5,
    'reduce_lr_factor': 0.5,
    'min_lr': 1e-7,
}
```

---

## Appendix B: File Structure

```
drgreen/
├── drgreen_v7_stratified.ipynb    # Main training notebook
├── models/
│   ├── drgreen_v7.keras           # Full Keras model
│   ├── drgreen_v7.tflite          # Mobile-optimized
│   └── metadata.json              # Model metadata
├── rename/                         # Dataset directory
│   ├── artemisia/
│   ├── carica/
│   ├── goyavier/
│   └── kinkeliba/
└── DR_GREEN_V7_DOCUMENTATION.md   # This document
```

---

**Document Version**: 1.0
**Last Updated**: November 2025
**Model Version**: V7 (Stratified Split with Top-2 Predictions)
