import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'displayPicture.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final String testImageName;

  const TakePictureScreen({
    Key key,
    @required this.camera,
    @required this.testImageName,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      // wait for camera to be initialized
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            // get height of the camera preview
            var pHeight = width * _controller.value.aspectRatio;
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 30),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(0),
                        width: 30.0,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Take a picture",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: CameraPreview(_controller),
                ),

                // As we want squared images as inputs of the deep ranking model, 
                // we display two transparent containers delimiting the square image
                Positioned(
                  top: (height - pHeight) / 2,
                  child: Container(
                    width: width,
                    height: (pHeight - width) / 2,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: (height - pHeight) / 2,
                  child: Container(
                    width: width,
                    height: (pHeight - width) / 2,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border(
                        top: BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // take picture button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: RawMaterialButton(
                      onPressed: () async {
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller.takePicture();
                          // Navigate to display picture screen once the photo taken
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayPictureScreen(
                                imagePath: image?.path,
                                testImageName: widget.testImageName,
                                camera: widget.camera,
                              ),
                            ),
                          ).then((img) {
                            // don't forget the then statement to get file image back
                            Navigator.pop(context, img);
                          });
                        } catch (e) {
                          // catch error
                          print(e);
                        }
                      },
                      elevation: 2.0,
                      fillColor: Colors.white,
                      child: Icon(Icons.photo_camera_outlined,
                          size: 23.0, color: Colors.black),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
