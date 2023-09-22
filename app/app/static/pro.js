// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
    apiKey: "AIzaSyC90kFg06FbSIuBSxmgAidRB770NDoUYmY",
    authDomain: "les-plantes-du-225.firebaseapp.com",
    databaseURL: "https://les-plantes-du-225.firebaseio.com",
    projectId: "les-plantes-du-225",
    storageBucket: "les-plantes-du-225.appspot.com",
    messagingSenderId: "686922357935",
    appId: "1:686922357935:web:d45aa8c4c7d68cc718485a",
    measurementId: "G-GBCM2VFXHY"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);




var Charger = function(){
        var image = document.getElementById('affichage');
        image.src = URL.createObjectURL(event.target.files[0]);
    };

function readURL(input) {
    if (input.files && input.files[0]) {

        var reader = new FileReader();

        reader.onload = function (e) {
            $('.image-upload-wrap').hide();

            $('.file-upload-image').attr('src', e.target.result);
            $('.file-upload-content').show();

            $('.image-title').html(input.files[0].name);
        };

        reader.readAsDataURL(input.files[0]);

    } else {
        removeUpload();
    }
}

function removeUpload() {
    $('.file-upload-input').replaceWith($('.file-upload-input').clone());
    $('.file-upload-content').hide();
    $('.image-upload-wrap').show();
}
$('.image-upload-wrap').bind('dragover', function () {
    $('.image-upload-wrap').addClass('image-dropping');
});
$('.image-upload-wrap').bind('dragleave', function () {
    $('.image-upload-wrap').removeClass('image-dropping');
});


