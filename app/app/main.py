import base64
from google.cloud import aiplatform
from google.cloud.aiplatform.gapic.schema import predict
import os
from flask import Flask, render_template, request, send_from_directory, redirect
from app import app
from werkzeug.utils import secure_filename


#credential_path = "/root/dr Green-20220425T160012Z-001/app/app/dr-green-330509-037bf21e37c1.json"
#os.environ["GOOGLE_APPLICATION_CREDENTIALS"]= credential_path


#project: str="dr-green-330509"
#endpoint_id: str="3202314421758066688"
#filename: str="/root/dr Green-20220425T160012Z-001/dr Green/feuilles-de-papayer.jpg"
#location: str= "us-central1"
#api_endpoint: str= "us-central1-aiplatform.googleapis.com"

UPLOAD_FOLDER = os.path.basename('./static')
app.config['UPLOAD_FOLDER']= UPLOAD_FOLDER

ALLOWED_EXTENSIONS = set(['JPG', 'jpeg'])

def allowed_file(filename):
    return '.' in filename  and  \
    filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def index():
    return render_template('pro.html')

 

@app.route('/', methods=['GET', 'POST'])
def pred():
    
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "D:/python tuto/dr Green-20220425T160012Z-001/app/traffic-day-d7d89113f8b7.json"


    project: str="traffic-day"
    endpoint_id: str="2810980641246543872"
    filename: str= "D:/python tuto/dr Green-20220425T160012Z-001/app/app/artemisia.jpg"
    location: str= "us-central1"
    api_endpoint: str= "us-central1-aiplatform.googleapis.com"


    # The AI Platform services require regional API endpoints.
    client_options = {"api_endpoint": api_endpoint}
    # Initialize client that will be used to create and send requests.
    # This client only needs to be created once, and can be reused for multiple requests.
    client = aiplatform.gapic.PredictionServiceClient(client_options=client_options)
    with open(filename, "rb") as f:
        file_content = f.read()
    
    

    # The format of each instance should conform to the deployed model's prediction input schema.
    encoded_content = base64.b64encode(file_content).decode("utf-8")
    instance = predict.instance.ImageClassificationPredictionInstance(
        content=encoded_content,
    ).to_value()
    instances = [instance]

    # See gs://google-cloud-aiplatform/schema/predict/params/image_classification_1.0.0.yaml for the format of the parameters.
    parameters = predict.params.ImageClassificationPredictionParams(
        confidence_threshold=0.5, max_predictions=5,
    ).to_value()
    endpoint = client.endpoint_path(
        project=project, location=location, endpoint=endpoint_id
    )
    response = client.predict(
        endpoint=endpoint, instances=instances, parameters=parameters
    )
    print("response")
    print(" deployed_model_id:", response.deployed_model_id)
    # See gs://google-cloud-aiplatform/schema/predict/prediction/image_classification_1.0.0.yaml for the format of the predictions.
    predictions = response.predictions
    #for prediction in predictions:
    #    print(dict(prediction))
    #print (list(dict(predictions.items())))
    prediction = [dict(prediction) for prediction in predictions]
    print(prediction [0]['ids'][0])
    return render_template('pro.html', prediction = prediction)
    
    