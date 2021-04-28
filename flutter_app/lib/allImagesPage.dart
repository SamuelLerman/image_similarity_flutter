import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_similarity/runModelScreen.dart';
import 'package:image_similarity/globals.dart';

extension CapExtension on String {
  String get inCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}

class AllImagesPage extends StatefulWidget {
  final CameraDescription camera;

  const AllImagesPage({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _AllImagesPageState createState() => _AllImagesPageState();
}

class _AllImagesPageState extends State<AllImagesPage> {
  // Get all images path
  Future<List<String>> _initImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .toList();
    return imagePaths;
  }

  // Create a dictionnary with the following structure
  // {"class1": ["im_path_1", "im_path_2", "im_path3"], "class2": ["im_path_1", ...], ...}
  // and assign it to global variable
  // in order to build the horizontal listview containing ref images
  Map<String, List> createRefImagesDict(List<String> imagesPath) {
    Map<String, List> dict = Map<String, List>();
    imagesPath.forEach((element) {
      var keys = dict.keys;

      // Capitalize the text and replace _ with spaces
      String class1 = element.split('/').elementAt(2);
      var replacedClass = class1.replaceAll('_', ' ');
      var _class = replacedClass.capitalizeFirstofEach;

      if (keys.contains(_class)) {
        List list = dict[_class];
        list.add(element);
        dict[_class] = list;
      } else {
        List list = [];
        list.add(element);
        dict[_class] = list;
      }
    });
    return dict;
  }

  @override
  void initState() {
    // Necessary to avoid calling setState before the future builder finishes the build
    _initImages().then((imagePaths) {
      Map<String, List> dict = createRefImagesDict(imagePaths);
      List labels = dict.keys.toList();
      // global variables (see globals.dart file)
      refImgDict = dict;
      refImgLabels = labels;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: _initImages(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding:
                  EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 36,
                    child: Text(
                      "Image Similarity",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          RunModelScreen(
                                              testImageName:
                                                  refImgLabels.elementAt(index),
                                              camera: widget.camera)));
                            },
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 12, color: Colors.black),
                            title: Text(
                              refImgLabels[index],
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 17,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(indent: 10, endIndent: 10),
                        itemCount: refImgLabels.length),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
