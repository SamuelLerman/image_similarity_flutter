import flask
from flask import request, jsonify, Flask, flash, redirect, url_for, render_template
from deepranking_model import are_images_similar, deep_rank_model
from keras.layers import *
from PIL import Image
import os

app = flask.Flask(__name__)
app.config["DEBUG"] = True
app.secret_key = 'YOUR_SECRET_KEY'
app.config['SESSION_TYPE'] = 'filesystem'
	

@app.route('/', methods=['POST'])
def upload_image():
	if 'file' not in request.files:
		flash('No file part')
		return redirect(request.url)
	file = request.files['file']
	if file.filename == '':
		flash('No image selected for uploading')
		return redirect(request.url)
	if 'class' in request.args and 'thres' in request.args:
        # Load model
        model = deep_rank_model()
        model_file = "deepranking.h5"
        model.load_weights(model_file)
        
        # Load file and save it to use it
        image_path = file.filename
        file.save(image_path)

        # Select ref images associated to the corresponding class
        _class = request.args['class']
        thres = float(request.args['thres'])
        print(_class, thres)
        images = os.listdir(_class)
        ref_images_directory_path = [os.path.join(_class, im) for im in images]

        # Run model
        value = are_images_similar(image_path, ref_images_directory_path, model, thres)

        # Remove the file uploaded after it has been treated
        os.remove(image_path)
        return jsonify({"result": value})
    else:
        return "Error: No class field provided. Please specify a class."
		

# Show that you are connected to the server  when typing uri in the navigator
@app.route('/', methods=['GET'])
def home():
    return "<h1> Image similarity test </h1>"


app.run(host="0.0.0.0")