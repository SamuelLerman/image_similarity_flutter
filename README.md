# image_similarity_flutter

This project is the implementation of a deep-ranking based image similarity model into a flutter app prototype. 

## Introduction

The aim is to be able to assert that an image taken by the user belong to the same class as some reference images. 
As an example, let's say that we have three reference images of the Joconde shot at different angles (it is import to mention that we know we want to recognize this particular class). We want to be able to:

- take a picture of the Joconde (with different contrasts, shot angles, lighting, etc) and assert that it is indeed the Joconde (these pictures will be called positive images in the rest of the README);
- take a picture of another portrait painting and assert that it is not the Joconde (these pictures will be called negative images).

The implementation of the deep-ranking image similarity model is based on this [repository](https://github.com/akarshzingade/image-similarity-deep-ranking). The weights can be found in this [repository](https://github.com/USCDataScience/Image-Similarity-Deep-Ranking) (the `deepranking.h5` file).

I used flutter framework on channel stable 2.0.5 and Xcode 12.4. As the deep-ranking model is quite complex, I didn't use the tflite flutter package to run ML models but created an API with python and flask which can be accessed via the application.

This respository is composed of three sections :
- The API directory which contains the files to launch the API on a server;
- A directory where you can find functions to plot the accuracy of the model for different thresholds;
- The flutter app directory.


## The API

I used python and flask to create the API. It is located in this [folder](). 

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
Type in the terminal window. the following command to launch the Flask server at the address http://localhost:5000 on your machine:
```console
$ python api.py
```

In order to access the server from a different device connected to the same wifi, you will have to get the IP address of the computer you are running the api on. The server will be located at http://your_IP_address:5000.

### deepranking_model.py

The file `deeprabking_model.py` contains the functions that define the deep-ranking model (see the [repository]() mentionned above) and two other functions :
```dart
num compare_images(String img1_path, String im2_path, TensorflowModel model)
```
```dart
Boolean are_images_similar(String image_path, String ref_images_directory_path, TensorflowModel model, num threshold)
```

The function ```compare_images``` returns the distance between two images. 

In order to assert that they are similar or not, we have to define a threshold. The threshold needs to be set in regard of the use of the app (either recognizing positive images very well or recognizing negative images very well). In order to determine the threshold that corresponds to your use, you can plot the accuracy of the model with the `plot_accuracy_model.py` file.

The function ```are_images_similar``` iterates over the reference images of the class we selected and if it finds out that one of the distances between the image. to compare and the reference images is below the threshold, it returns True (the images are similar), else it returns False.

### api.py

The http request sent to the server msut hold the two following arguments: class and thres.
**The class argument name must be the same as the reference images directory of the class you are trying to identify**.
The thres argument is the threshold you have chosen for the model.

The `upload_image` method parse the arguments given in the request, call the `are_images_similar` in the `deepranking-model.py` file and returns the boolean in the following json format:
```python
{"result": boolean}
```

In the last line:
```python
app.run(host: "0.0.0.0")
```
the extension `.host("0.0.0.0)` allows other devices connected to the same wifi to connect to the server.


## Ploting the accuracy of the model

- The function 
```dart
generate_accuracies(String positive_images_dir_path, String negative_images_dir_path, String ref_images_dir_path TensorflowModel model)
```
generates, for a range of thresholds to define in the function, the accuracies for positive image recognition and negative image recognition.
- The function 
```dart
plot_accuracies(String positive_images_dir_path, String negative_images_dir_path, String ref_images_dir_path TensorflowModel model)
```
plots the results as a function of the threshold.


## Flutter app

### Setup

First you have to import your images into the images directory located in the assets folder which is at the root of the project. The structure of assets should be as follows:
```
assets/
|__ images/
|   |__ref_images_1/
|   |   |__ ref_image_1_1.png
|   |   |__ ref_image_1_2.png
|   |   |__ ref_image_1_3.png
|   |   |__ ...
|   |__ref_images_2/
|   |   |__ ref_image_2_1.png
|   |   |__ ref_image_2_2.png
|   |   |__ ref_image_2_3.png
|   |   |__ ...
|   |__ ...
```

Then update your `pubspec.yaml` file as so: 
```yaml
- assets:
  - images/ref_images_1/
  - images/ref_images_2/
  - ...
```

NB: The `Info.plist`, `AndroidManifest.xml` and `android/app/build.gradle` files have already been configured to allow access to the photo gallery and the camera.

### Configure the server address

Once you have imported all your images. You will need to configure the `upload` method located in the `runModelScreen.dart` file. If you are running the api on a local server, you should have the line:
```dart
var uri = Uri.parse("http://YOUR_IP_ADDRESS:5000/?class=${widget.testImageName}&thres=${thres}");
```
Notice that the class argument is widget.testImageName. Therefore, your reference images directory relative to this class must have the same name.



## You are all set !



