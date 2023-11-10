# Dr Green
Dr Green is a Machine Learning model which recognize medical plant for traditionnal medicine. I built a flask web app to allow plant recognition with 0.99% of accuracy. Google ML Developer Programs team supported this work by providing Google Cloud Credit.
![002-removebg-preview.png](https://github.com/armelyara/drgreen/blob/main/002-removebg-preview.png)

# Description
Using the medicinal plants in the desease heal process take a particular place into africans habits. This habit is transmited throught generations by the elders. The traditionnal medicine is so important such as we need to save his process of use the medicinal plants for the next generations. **Dr Green** aims to recognize the whole plants used in the desease heal process by the traditionnal medicine and work as a big digital librairie for research and educational.   

# Dataset
The current dataset contain 1107 images sharing in four class of medicinal plants. The class are labeled like this: 
- Artemisia
- Carica(Papaya Leaf)
- Combrethum micranthum(Kinkeliba)
- Psidium guajava(Goyave)
  ![app/app/static/Confusion matrix.png](https://github.com/armelyara/drgreen/blob/main/app/app/static/dataset.png)

# ML model
ML model is about regression logistic for multi-class classification problem. So, our ML model are built, trained and deployed on **Vertex AI**. For online prediction, Ml Model have an endpoint using in the **Flask API** . 
![app/app/static/Confusion matrix.png](https://github.com/armelyara/drgreen/blob/main/app/app/static/Confusion%20matrix.png)
![app/app/static/ROC.png](https://github.com/armelyara/drgreen/blob/main/app/app/static/ROC.png)

# Dr Green web app
Dr green web app allow to recognize medicinal plants image throught the ML model endpoint in backend. It deployed on [**cloud run**](https://drgreen-ig2xjsbbea-uc.a.run.app)
![app/app/static/Capture d’écran (21).png](https://github.com/armelyara/drgreen/blob/main/app/app/static/Capture%20d%E2%80%99%C3%A9cran%20(21).png)
