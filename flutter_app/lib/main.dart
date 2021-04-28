import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_similarity/allImagesPage.dart';
import 'package:camera/camera.dart';
import 'dart:async';


Future<void> main() async {
  // Initialize camera
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({
    Key key,
    @required this.camera,
  }) : super(key: key); 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(camera: camera),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
final CameraDescription camera;

  const MyHomePage({
    Key key,
    @required this.camera,
  }) : super(key: key);



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AllImagesPage(camera: widget.camera),
    );
  }
}
