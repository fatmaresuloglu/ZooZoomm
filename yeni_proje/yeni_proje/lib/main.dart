import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List? _image;
  String _animalCount = "";
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.37.82.36:5000/process_image'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var jsonResponse = jsonDecode(utf8.decode(responseData));

          setState(() {
            _image = base64Decode(jsonResponse['image']);
            _animalCount =
                "Tespit Edilen Hayvan Sayısı: ${jsonResponse['animal_count']}";
          });
        } else {}
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 234, 235, 204),
            title: const Row(
              children: [
                Icon(Icons.pets,
                    color: Color.fromARGB(255, 20, 59, 21), size: 40),
                SizedBox(width: 15),
                Text(
                  'ZooZoom',
                  style: TextStyle(
                    color: Color.fromARGB(255, 20, 59, 21),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 147, 173, 148),
                  Color.fromARGB(255, 234, 235, 204),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image != null
                      ? Column(
                          children: [
                            Image.memory(_image!),
                            const SizedBox(height: 20),
                            Text(
                              _animalCount,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.insert_photo,
                                  size: 40,
                                  color: Color.fromARGB(255, 20, 59, 21)),
                              label: const Text("+",
                                  style: TextStyle(
                                      fontSize: 40,
                                      color: Color.fromARGB(255, 20, 59, 21))),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera,
                                  size: 40,
                                  color: Color.fromARGB(255, 20, 59, 21)),
                              label: const Text("+",
                                  style: TextStyle(
                                      fontSize: 40,
                                      color: Color.fromARGB(255, 20, 59, 21))),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
