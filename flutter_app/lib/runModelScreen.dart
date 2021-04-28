import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_similarity/globals.dart';
import 'package:image_similarity/takePictureScreen.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RunModelScreen extends StatefulWidget {
  final testImageName;
  final CameraDescription camera;

  RunModelScreen({
    Key key,
    @required this.testImageName,
    @required this.camera,
  }) : super(key: key);

  @override
  _RunModelScreenState createState() => _RunModelScreenState();
}

class _RunModelScreenState extends State<RunModelScreen> {
  // indexSelected is for the reference images selected
  int indexSelected = 0;

  String _imageString;
  // This is the image which is displayed and uploaded
  File _image;

  final picker = ImagePicker();

  // The boolean is translated into an icon (True <-> check icon, False <-> close icon)
  Icon resultIcon;

  // Whether it is a ref image which  is displayed or a gallery or camera image
  bool _isRefImg = false;

  // these booleans are for Visibility widgets (progress indicator and resultIcon)
  bool isUploadFinished = false;
  bool isProgressVisible = false;

  // picture is the resulting file from the DisplayPicture stateful widget
  File picture;

  double thres = 0.4;

  // Get image from gallery
  Future getImage() async {
    if (mounted) {
      setState(() {
        isUploadFinished = false;
      });
    }
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          isProgressVisible = true;
          _image = File(pickedFile.path);
          resultIcon = null;
          _isRefImg = false;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  // Upload image file to the server
  upload(File imageFile) async {
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    // Replace with your ip address on the network if your server is local
    var uri = Uri.parse(
        "http://YOUR_IP_ADDRESS:5000/?class=${widget.testImageName}&thres=$thres");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();

    // listen for response
    // The result is a json format dictionnary {"result": bool}
    Map<String, dynamic> res;
    await for (var value in response.stream.transform(utf8.decoder)) {
      res = jsonDecode(value);
    }
    bool isTheRightImg = res["result"];
    if (mounted) {
      setState(() {
        isUploadFinished = true;
        isProgressVisible = false;
        // set the result icon in regard of the result
        if (isTheRightImg) {
          resultIcon = Icon(Icons.check, color: Colors.green);
        } else {
          resultIcon = Icon(Icons.close, color: Colors.red);
        }
      });
    }
  }

  // Run model on gallery image
  runModel() async {
    await getImage().then((v) {
      upload(_image);
    });
  }

  // This widget builds a horizontal listview containing the reference images cards associated to the chosen class
  Widget refImages(String refImageString) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: refImgDict[refImageString].length,
      itemBuilder: (BuildContext context, int index) => refImageCard(
        refImageString: refImgDict[refImageString].elementAt(index),
        index: index,
      ),
    );
  }

  Widget refImageCard({String refImageString, int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          indexSelected = index;
          _imageString = refImageString;
          _isRefImg = true;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(refImageString), fit: BoxFit.cover),
            border: Border.all(
                color: index == indexSelected ? Colors.black : Colors.white,
                width: 2.0),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  // This is the central widget which displays the images selected,
  // the progress indicators and most importantly, the result icon
  Widget showImageWithRes() {
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(18),
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 300,
          height: 300,
          // No action if a reference image is selected
          child: _isRefImg
              ? Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(_imageString),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // Image displayed
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: FileImage(_image),
                        ),
                      ),
                    ),
                    // Circular Progress Indicator
                    Center(
                      child: Visibility(
                        visible: isProgressVisible,
                        child: Container(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        // Result icon animated
                        Center(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: isUploadFinished ? 50.0 : 0.0,
                            width: isUploadFinished ? 50.0 : 0.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        resultIcon != null
                            ? Center(
                                child: Visibility(
                                    visible: isUploadFinished,
                                    child: resultIcon))
                            : Container(),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 40),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(0),
                      width: 30.0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      widget.testImageName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _image == null && _imageString == null
                      ? Text('No image selected.',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16))
                      : Center(
                          child: showImageWithRes(),
                        ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Camera button
                      RawMaterialButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              isUploadFinished = false;
                            });
                          }
                          // push to the take picture screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TakePictureScreen(
                                        camera: widget.camera,
                                        testImageName: widget.testImageName,
                                      ))).then((img) {
                            // then statement in order to wait for the file image sent from poping the display image screen
                            if (img != null) {
                              // check whether img is null so that if poping from TakePictureScreen, nothing happens
                              if (mounted) {
                                setState(() {
                                  _isRefImg = false;
                                  isProgressVisible = true;
                                  _image = img;
                                });
                              }
                              upload(img);
                            }
                          });
                        },
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: Icon(Icons.photo_camera_outlined,
                            size: 23.0, color: Colors.black),
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                      ),

                      // Select image from gallery button
                      RawMaterialButton(
                        onPressed: runModel,
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: Icon(Icons.image_outlined,
                            size: 23.0, color: Colors.black),
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Divider(
                indent: 30,
                endIndent: 30,
                color: Colors.grey[500],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10, top: 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Reference images :",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                child: refImages(widget.testImageName),
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
