import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

void main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get a list of available cameras
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile; // To store the captured image

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high, // Set resolution quality
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose the controller when no longer needed
    _controller.dispose();
    super.dispose();
  }

  // Function to take a picture
  Future<void> _takePicture() async {
    try {
      // Ensure the controller is initialized before taking the picture
      await _initializeControllerFuture;

      final image = await _controller.takePicture();
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Camera preview
                Container(
                  height: 300,
                  width: double.infinity,
                  child: CameraPreview(_controller),
                ),
                const SizedBox(height: 20),
                // Capture button
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Take Picture'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.blue, // Button color
                  ),
                ),
                const SizedBox(height: 20),
                // Display captured image
                if (_imageFile != null)
                  Column(
                    children: [
                      Image.file(
                        File(_imageFile!.path),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _imageFile = null; // Clear the captured image
                          });
                        },
                        child: Text('Retake Picture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
