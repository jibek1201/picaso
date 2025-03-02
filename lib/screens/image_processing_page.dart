import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:picaso_app1/screens/saved_images_page.dart';
import 'utils/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ImageProcessing extends StatefulWidget {
  final String? initialImagePath;

  const ImageProcessing({Key? key, this.initialImagePath}) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ImageProcessing> {
  bool _isSectionVisible = false;
  bool _isArrowPressed = false;
  double _selectedScale = 1.0;
  bool isSaved = false;
  String? _imagePath;
  String? _contourImagePath;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _imagePath = widget.initialImagePath;
    }
  }

  void toggleSave() async {
    if (_contourImagePath != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFilename = 'contour_image_$timestamp.png';
      final directory = await getApplicationDocumentsDirectory();
      final uniqueFilePath = '${directory.path}/$uniqueFilename';

      final contourFile = File(_contourImagePath!);
      await contourFile.copy(uniqueFilePath);

      await DatabaseHelper().insertImage(uniqueFilePath);

      setState(() {
        isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contour image saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contour image to save.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });

      await _generateContourImage();
    }
  }

  Future<void> _generateContourImage() async {
    if (_imagePath == null) {

      return;
    }

    try {
      final imageBytes = await File(_imagePath!).readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception("Failed to decode image.");
      }


      final grayImage = img.grayscale(decodedImage);


      final edgeImage = img.sobel(grayImage);


      final invertedImage = img.invert(edgeImage);


      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final contourFile = File('${tempDir.path}/contour_image_$timestamp.png')
        ..writeAsBytesSync(img.encodePng(invertedImage));

      setState(() {
        _contourImagePath = contourFile.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contour image generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process the image: $e')),
      );
    }
  }


  Future<void> _generateAIImage(String prompt) async {
    try {
      final aiImageResponse = await generateAIImage(prompt);

      if (aiImageResponse != null && aiImageResponse['image_url'] != null) {
        final imageUrl = aiImageResponse['image_url'];


        final response = await http.get(Uri.parse(imageUrl));


        if (response.statusCode == 200) {
          final contentType = response.headers['content-type'];

          if (contentType != null && (contentType.contains('image') || contentType.contains('png') || contentType.contains('jpeg'))) {
            final bytes = response.bodyBytes;


            final tempDir = await getTemporaryDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final aiImageFile = File('${tempDir.path}/ai_image_$timestamp.png');


            await aiImageFile.writeAsBytes(bytes);

            setState(() {
              _contourImagePath = aiImageFile.path;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI image generated successfully!')),
            );
          } else {
            throw Exception('The response is not an image.');
          }
        } else {
          throw Exception('Failed to fetch the image. Status code: ${response.statusCode}');
        }
      } else {
        throw Exception('Failed to generate AI image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate AI image: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> generateAIImage(String prompt) async {
    final url = Uri.parse('https://api.stability.ai/v2beta/stable-image/generate/sd3');


    final headers = {
      'Authorization': 'Bearer sk-gOp9iwamUFAoEzT7YlJNkqXgHwflSzznYRNe4cM9kOhl7h8b',  // Use 'Bearer' before the API key
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'prompt': prompt,
      'width': 300,
      'height': 400,
      'samples': 1,
      'cfg_scale': 7.5,

    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      print(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);


        final artifacts = responseData['artifacts'];
        if (artifacts != null && artifacts.isNotEmpty) {
          final imageUrl = artifacts[0]['url'];  // Extract URL from the first artifact
          return {'image_url': imageUrl};
        } else {
          throw Exception('No artifacts found in the response.');
        }
      } else {
        throw Exception('Failed to generate AI image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }





  void _clearAction() {
    setState(() {
      _controller.clear();
      _imagePath = null;
      _contourImagePath = null;
      isSaved = false; // Reset save state
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedImages()),
                ).then((imagePath) {
                  if (imagePath != null) {
                    setState(() {
                      _imagePath = imagePath;
                    });
                  }
                });
              },
              child: Image.asset(
                'images/vector.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: _contourImagePath != null
                    ? Image.file(File(_contourImagePath!))
                    : _imagePath != null
                    ? Image.file(File(_imagePath!))
                    : const Center(child: Text('No image selected')),
              ),
            ),
          ),
          if (_isSectionVisible)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 46, right: 20),
                        child: Text(
                          'dimension',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildSquareInputField(''),
                          const SizedBox(width: 6),
                          _buildSquareInputField(''),
                          const SizedBox(width: 6),
                          const Text(
                            'mm',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 46, right: 20),
                        child: Text(
                          'scale',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildScaleButton(0.5),
                          const SizedBox(width: 10),
                          _buildScaleButton(1.0),
                          const SizedBox(width: 10),
                          _buildScaleButton(2.0),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 50),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        if (!_isArrowPressed)
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up,
                                color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _isArrowPressed = true;
                                _isSectionVisible = true;
                              });
                            },
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _isArrowPressed = false;
                                _isSectionVisible = false;
                              });
                            },
                          ),
                        if (_isArrowPressed)
                          Expanded(
                            child: Container(),
                          ),
                        if (_isArrowPressed)
                          Padding(
                            padding: const EdgeInsets.only(right: 50),
                            child: IconButton(
                              icon: const Icon(Icons.download_rounded,
                                  color: Colors.black),
                              onPressed: _pickImage,
                            ),
                          ),
                        Text(
                          !_isArrowPressed ? 'more options' : '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  height: 40,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'type your prompt',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _generateAIImage(_controller.text);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a prompt to generate the image.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      ),
                      child: const Text('Generate'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: toggleSave,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _clearAction,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareInputField(String hint) {
    return Container(
      width: 56,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            hintStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildScaleButton(double value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedScale = value;
        });
      },
      child: Container(
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          color: _selectedScale == value ? Colors.grey : Colors.grey[200],
          border: Border.all(
            width: 1,
            color: _selectedScale == value
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: TextStyle(
              color: _selectedScale == value ? Colors.black : Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
