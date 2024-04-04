import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Select Image'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _imageFile;
  String? _predictionResult;

  Future<void> _selectImageFromCamera(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _imageFile = pickedFile;
      _predictionResult =
          null; // Reset prediction result when a new image is selected
    });
  }

  Future<void> _selectImageFromGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
      _predictionResult =
          null; // Reset prediction result when a new image is selected
    });
  }

  Future<void> _predictImage() async {
    if (_imageFile == null) {
      // Handle case where no image is selected
      return;
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:5000/predict'));
    request.files
        .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var jsonResponse = await response.stream.bytesToString();
        var predictionResult = json.decode(jsonResponse)['result'];
        setState(() {
          _predictionResult = predictionResult;
        });
      } else {
        print('Failed to make prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making prediction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _selectImageFromCamera(context),
                child: Text('From Camera'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectImageFromGallery(context),
                child: Text('From Gallery'),
              ),
              SizedBox(height: 20),
              if (_imageFile != null) // Display the picked image if available
                Image.file(File(_imageFile!.path)),
              SizedBox(height: 20),
              if (_predictionResult !=
                  null) // Show prediction result if available
                Text('Prediction Result: $_predictionResult'),
              SizedBox(height: 20),
              if (_imageFile != null && _predictionResult == null)
                ElevatedButton(
                  onPressed: _predictImage,
                  child: Text('Predict'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
