# image_similarity_flutter

This project is the implementation of a deep-ranking based image similarity model into a flutter app prototype. 

## Introduction

The aim is to be able to assert that an image taken by the user belong to the same class as some reference images. 
As an example, let's say that we have three reference images of the Joconde shot at different angles (it is import to mention that we know we want to recognize this particular class). We want to be able to:

- take a picture of the Joconde (with different contrasts, shot angles, lighting, etc) and assert that it is indeed the Joconde (these pictures will be called positive images in the rest of the README);
- take a picture of another portrait painting and assert that it is not the Joconde (these pictures will be called negative images).

The implementation of the deep-ranking image similarity model is based on this [repository](https://github.com/akarshzingade/image-similarity-deep-ranking). The weights can be found in this [repository](https://github.com/USCDataScience/Image-Similarity-Deep-Ranking) (the "deepranking.h5" file).

I used flutter framework on channel stable 2.0.5 and Xcode 12.4. As the deep-ranking model is quite complex, I didn't use the tflite flutter package to run ML models but created an API with python and flask which is accessed via the application.

The respository is composed of three sections :
- The flutter a

## The API

I used python and flask to create the API. It is located at this [folder](). 

### Setup

#### First step
Create a virtual environment in the `python_backend` directory and activate it. In terminal type the following commands:
```console
$ cd python_bakcend
$ virtualenv env
$ source env/bin/activate
```

#### Second step
Install all the dependencies by typing in terminal:
```console
$ pip install -r requirements.txt
```

#### Third step
Add the model weights file and the reference images to the directory.
As the application is only a prototype, I didn't link the Flask server to a database. The model weights file and the reference images are thus stored in the `python_bakcend` directory. The reference images are located in the directory `images` at the root of the `python_backend` directory. The structure is as follows:

```
python_backend/
|__ api.py
|__ deepranking.h5
|__ requirements.txt
|__ run_model.py
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
Type in the terminal window. the following command to lauchn the Flask server at the address http://localhost:5000 on your machine:
```console
$ python api.py
```

In order to access the server from a different device connected to the same wifi, you will have to get the IP address of the computer you are running the api on. The server will be located at http://your_IP_address:5000.

### deepranking_model.py

The file `deeprabking_model.py` contains the functions that define the deep-ranking model (see the [repository]() mentionned above) and two other functions :
```c
float compare_images(string img1_path, string im2_path, TensorflowModel model)
```
```c
bool are_images_similar(string image_path, string ref_images_directory_path, TensorflowModel model, float threshold)
```

The function ```compare_images``` returns the distance between two images. 

In order to assert that they are similar or not, we have to define a threshold. The threshold needs to be set in regard of the use of the app (either recognizing positive images very well or recognizing negative images very well). In order to determine the threshold that corresponds to your use, you can plot the accuracy of the model with the `plot_accuracy_model.py` file.

The function ``` are_images_similar``` iterates over the reference images of the class we selected and if it finds out that one of the distances between the image. to compare and the reference images is below the threshold, it returns True (the images are similar), else it returns False.

### api.py




## Ploting the accuracy of the model

