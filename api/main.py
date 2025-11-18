"""
Dr Green API - FastAPI backend for medicinal plant identification
Deployed on Google Cloud Run
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import json
from pathlib import Path
from typing import Dict, List, Optional
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Dr Green API",
    description="Medicinal Plant Identification API for African Botany",
    version="2.0.0"
)

# CORS configuration for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables
MODEL = None
CLASS_NAMES = None
IMG_HEIGHT = 300
IMG_WIDTH = 300

# Plant information database (to be moved to Firestore later)
PLANT_INFO = {
    "artemisia": {
        "nom_scientifique": "Artemisia annua",
        "noms_communs": {
            "fr": "Armoise annuelle",
            "en": "Sweet wormwood",
            "baoulé": "N'tran",
            "dioula": "N'tran"
        },
        "regions_ci": ["Abidjan", "Yamoussoukro", "Bouaké", "Korhogo"],
        "usages_traditionnels": {
            "maladies": ["Paludisme", "Fièvre", "Infections parasitaires"],
            "preparation": "Infusion de feuilles séchées (5-10g dans 1L d'eau bouillante)",
            "posologie": "Boire 3 tasses par jour pendant 7 jours",
            "precautions": "Déconseillé aux femmes enceintes. Consulter un médecin."
        }
    },
    "carica": {
        "nom_scientifique": "Carica papaya",
        "noms_communs": {
            "fr": "Papayer",
            "en": "Papaya",
            "baoulé": "Gboman",
            "dioula": "Papaya"
        },
        "regions_ci": ["Toutes régions de Côte d'Ivoire"],
        "usages_traditionnels": {
            "maladies": ["Paludisme", "Troubles digestifs", "Constipation", "Vers intestinaux"],
            "preparation": "Décoction de feuilles fraîches (10-15 feuilles dans 2L d'eau)",
            "posologie": "Boire 1 verre 2 fois par jour avant les repas",
            "precautions": "Usage traditionnel. Consulter un professionnel de santé."
        }
    },
    "goyavier": {
        "nom_scientifique": "Psidium guajava",
        "noms_communs": {
            "fr": "Goyavier",
            "en": "Guava",
            "baoulé": "Goyave",
            "dioula": "Goyave"
        },
        "regions_ci": ["Sud forestier", "Centre", "Abidjan"],
        "usages_traditionnels": {
            "maladies": ["Diarrhée", "Dysenterie", "Maux de ventre", "Plaies"],
            "preparation": "Décoction de feuilles ou écorce (20g dans 1L d'eau, bouillir 10 min)",
            "posologie": "Boire 1 verre 3 fois par jour. Usage externe: laver les plaies",
            "precautions": "Usage traditionnel. Propriétés antiseptiques reconnues."
        }
    },
    "kinkeliba": {
        "nom_scientifique": "Combretum micranthum",
        "noms_communs": {
            "fr": "Quinquéliba",
            "en": "Kinkeliba",
            "baoulé": "Kinkéliba",
            "dioula": "Sana sana"
        },
        "regions_ci": ["Nord", "Savanes", "Korhogo"],
        "usages_traditionnels": {
            "maladies": ["Paludisme", "Fièvre", "Troubles hépatiques", "Détoxification"],
            "preparation": "Infusion de feuilles séchées (10g dans 1L d'eau bouillante)",
            "posologie": "Boire comme du thé, 2-3 tasses par jour",
            "precautions": "Généralement bien toléré. Usage traditionnel répandu en Afrique de l'Ouest."
        }
    }
}


@app.on_event("startup")
async def load_model():
    """Load the TensorFlow model on startup"""
    global MODEL, CLASS_NAMES

    try:
        # Look for the model in the models directory
        model_dir = Path("models")

        # Try to find the latest .keras model
        keras_models = list(model_dir.glob("*.keras"))
        if keras_models:
            model_path = sorted(keras_models)[-1]  # Get most recent
            logger.info(f"Loading model from: {model_path}")
            MODEL = tf.keras.models.load_model(model_path)
            logger.info("Model loaded successfully!")
        else:
            logger.warning("No model found! Please add a model to the models/ directory")

        # Load class names
        class_names_path = model_dir / "class_names.json"
        if class_names_path.exists():
            with open(class_names_path, 'r') as f:
                CLASS_NAMES = json.load(f)
            logger.info(f"Class names loaded: {CLASS_NAMES}")
        else:
            CLASS_NAMES = ["artemisia", "carica", "goyavier", "kinkeliba"]
            logger.warning(f"Using default class names: {CLASS_NAMES}")

    except Exception as e:
        logger.error(f"Error loading model: {e}")
        MODEL = None


def preprocess_image(image: Image.Image) -> np.ndarray:
    """
    Preprocess image for model inference

    Args:
        image: PIL Image

    Returns:
        Preprocessed numpy array
    """
    # Resize image
    image = image.resize((IMG_WIDTH, IMG_HEIGHT))

    # Convert to RGB if necessary
    if image.mode != 'RGB':
        image = image.convert('RGB')

    # Convert to array
    img_array = tf.keras.utils.img_to_array(image)

    # Preprocess for EfficientNet
    img_array = tf.keras.applications.efficientnet.preprocess_input(img_array)

    # Add batch dimension
    img_array = tf.expand_dims(img_array, 0)

    return img_array


def predict_with_tta(image_array: np.ndarray, num_augmentations: int = 3) -> np.ndarray:
    """
    Test-Time Augmentation for better predictions

    Args:
        image_array: Preprocessed image array
        num_augmentations: Number of augmentations to apply

    Returns:
        Averaged predictions
    """
    if MODEL is None:
        raise ValueError("Model not loaded")

    predictions = []

    # Original prediction
    pred = MODEL.predict(image_array, verbose=0)
    predictions.append(pred)

    # Augmented predictions (flip horizontal, flip vertical)
    for _ in range(num_augmentations - 1):
        # Random horizontal flip
        augmented = tf.image.flip_left_right(image_array)
        pred = MODEL.predict(augmented, verbose=0)
        predictions.append(pred)

    # Average predictions
    avg_pred = np.mean(predictions, axis=0)

    return avg_pred


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "service": "Dr Green API",
        "version": "2.0.0",
        "status": "running",
        "model_loaded": MODEL is not None
    }


@app.get("/health")
async def health():
    """Health check for Cloud Run"""
    if MODEL is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "healthy"}


@app.post("/api/v1/identify")
async def identify_plant(
    file: UploadFile = File(...),
    use_tta: bool = True
) -> Dict:
    """
    Identify a medicinal plant from an image

    Args:
        file: Uploaded image file
        use_tta: Whether to use test-time augmentation (default: True)

    Returns:
        JSON response with prediction results
    """
    if MODEL is None:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Please contact administrator."
        )

    # Validate file type
    if not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400,
            detail="File must be an image (JPEG, PNG, etc.)"
        )

    try:
        # Read image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))

        # Preprocess image
        img_array = preprocess_image(image)

        # Make prediction
        if use_tta:
            predictions = predict_with_tta(img_array, num_augmentations=3)
        else:
            predictions = MODEL.predict(img_array, verbose=0)

        # Get results
        predicted_idx = int(np.argmax(predictions[0]))
        predicted_class = CLASS_NAMES[predicted_idx]
        confidence = float(predictions[0][predicted_idx])

        # Get all probabilities
        all_probabilities = {
            CLASS_NAMES[i]: float(predictions[0][i])
            for i in range(len(CLASS_NAMES))
        }

        # Sort by probability
        sorted_predictions = sorted(
            all_probabilities.items(),
            key=lambda x: x[1],
            reverse=True
        )

        # Get plant information
        plant_info = PLANT_INFO.get(predicted_class, {})

        # Build response
        response = {
            "success": True,
            "prediction": {
                "class": predicted_class,
                "confidence": confidence,
                "all_probabilities": all_probabilities,
                "top_3": [
                    {"class": cls, "confidence": conf}
                    for cls, conf in sorted_predictions[:3]
                ]
            },
            "plant_info": plant_info,
            "metadata": {
                "model_version": "4.0",
                "tta_used": use_tta,
                "image_size": f"{IMG_WIDTH}x{IMG_HEIGHT}"
            }
        }

        logger.info(f"Prediction: {predicted_class} ({confidence:.2%})")

        return response

    except Exception as e:
        logger.error(f"Error during prediction: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error processing image: {str(e)}"
        )


@app.get("/api/v1/classes")
async def get_classes():
    """Get all available plant classes"""
    return {
        "classes": CLASS_NAMES,
        "total": len(CLASS_NAMES)
    }


@app.get("/api/v1/plant/{plant_name}")
async def get_plant_info(plant_name: str):
    """
    Get detailed information about a specific plant

    Args:
        plant_name: Name of the plant (e.g., 'artemisia')

    Returns:
        Plant information
    """
    plant_name = plant_name.lower()

    if plant_name not in PLANT_INFO:
        raise HTTPException(
            status_code=404,
            detail=f"Plant '{plant_name}' not found. Available: {list(PLANT_INFO.keys())}"
        )

    return {
        "plant": plant_name,
        "info": PLANT_INFO[plant_name]
    }


@app.get("/api/v1/plants")
async def get_all_plants():
    """Get information about all plants"""
    return {
        "total": len(PLANT_INFO),
        "plants": PLANT_INFO
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
