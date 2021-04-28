import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final String testImageName;
  final CameraDescription camera;
  DisplayPictureScreen(
      {Key key,
      this.imagePath,
      @required this.testImageName,
      @required this.camera})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Future<String> resizedImagePath;

  // Cropp image as square function
  Future<String> _resizePhoto(String filePath) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(filePath);

    int width = properties.width;
    var offset = (properties.height - properties.width) / 2;

    File croppedFile = await FlutterNativeImage.cropImage(
        filePath, 0, offset.round(), width, width);

    return croppedFile.path;
  }

  @override
  void initState() {
    super.initState();
    resizedImagePath = _resizePhoto(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // wait for the image to be cropped=> FutrueBuilder
      body: FutureBuilder(
          future: resizedImagePath,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      child: Image.file(File(snapshot.data)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
                      child: Row(
                        children: [
                          // retake picture button
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 30,
                              width: 70,
                              child: Center(
                                child: Text(
                                  "Retake",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),

                          // use picture button
                          GestureDetector(
                            onTap: () async {
                              File img = File(snapshot.data);
                              // resize image to send it more quickly (image input for the network is 224x224)
                              // File resizedFile =
                              //     await FlutterNativeImage.compressImage(
                              //         img.path,
                              //         quality: 100,
                              //         targetWidth: 500,
                              //         targetHeight: 500);
                              // parse cropped and resized image when popping
                              Navigator.pop(context, img);
                            },
                            child: Container(
                              height: 30,
                              width: 70,
                              child: Center(
                                child: Text(
                                  "Use",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
