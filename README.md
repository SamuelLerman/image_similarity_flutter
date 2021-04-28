# image_similarity_flutter

This project is the implementation of a deep-ranking based image similarity model into a flutter app prototype. 

## Introduction

The aim is to be able to assert that an image taken by the user belong to the same class as some reference images. As an example, let's say that we have three reference images of the Joconde shot at different angles. We want to be able to:

- take a picture of the Joconde (with different contrasts, shot angles, lighting, etc) and assert that it is indeed the Joconde;
- take a picture of another portrait painting and assert that it is not the Joconde.

The implementation of the deep-ranking image similarity model is based on this [repository](https://github.com/akarshzingade/image-similarity-deep-ranking). The weights can be found in this [repository](https://github.com/USCDataScience/Image-Similarity-Deep-Ranking) (the "deepranking.h5" file).

I used flutter framework on channel stable 2.0.5 and Xcode 12.4. As the deep-ranking model is quite complex, I didn't use the tflite flutter package to run ML models but created an API with python and flask which is accessed via the application.

## The API

I used python and flask to create the API. It is located at this [folder](). 

### Setup

#### First step
Create a virtual environment in the ```python_backend``` directory and activate it. In terminal type the following commands:
```
cd python_bakcend
virtualenv env
source env/bin/activate
```

#### Second step
Install all the dependencies by typing in terminal:
```
pip install -r requirements.txt
```

#### Third step
Add the model weights file and the reference images to the directory.
As the application is only a prototype, I didn't link the Flask server to a database. The model weights file and the reference images are thus stored in the ```python_bakcend``` directory. The reference images are located in the directory ```images``` at the root of the ```python_backend``` directory. The structure is as follows:

```
python_backend/
|__ api.py
|__ deepranking.h5
|__ requirements.txt
|__ images/
|   |__reference_images_1/
|   |   |__ ref_img_1_1.jpg
|   |   |__ ref_img_1_2.jpg
|   |   |__ ref_img_1_3.jpg
|   |   |__ ...
|   |__reference_images_2/
|   |   |__ ref_img_2_1.jpg
|   |   |__ ref_img_2_2.jpg
|   |   |__ ref_img_2_3.jpg
|   |   |__ ...
|   |__ ...

```

#### Last step
To launch the Falsk server on http://localhost:5000, you then have to type in the terminal window:
```
python api.py
```

In order to access the server from a different device connected to the same wifi, you will have to get the IP address of the computer you are running the api on. The server will be located at http://your_IP_address:5000



