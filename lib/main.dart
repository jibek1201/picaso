import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../database/database_helper.dart'; // Import your database helper here






void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Optional: Hides debug banner
      home: HomePage(),
    );
  }
}


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"), // Path to your image
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        child: Stack(
          children: [
            // Text aligned to center-left
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20), // Optional padding
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                    mainAxisSize: MainAxisSize.min, // Wrap the content vertically
                    children: <Widget>[
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 30, // Larger font size
                          color: Colors.black,
                        ),
                      ),
                      SelectionContainer.disabled(
                        child: Text(
                          'to Picasso:',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        "Let's transform",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Your Space!',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Button positioned at the center-bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40), // Add spacing from the bottom
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to SecondPage when button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecondPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Text color
                    backgroundColor: Colors.black, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      side: const BorderSide(
                        color: Colors.white, // Border color
                        width: 1.0,       // Border width
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60, // Adjust width
                      vertical: 10,   // Adjust height
                    ),
                  ),

                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontSize: 20, // Button text size
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Define the second page with a custom background color and button
class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/bg.jpg'), // Path to your image
                fit: BoxFit.cover, // Cover the entire background
              ),
            ),
          ),

          // Centered Text
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Please connect the Bluetooth\n'
                    'and do connection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Text color for contrast
                ),
                textAlign: TextAlign.center, // Center align the text
              ),
            ),
          ),

          // Button at the center-bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40), // Space from the bottom
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to ThirdPage when button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ThirdPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                  backgroundColor: Colors.black, // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    side: const BorderSide(
                      color: Colors.white, // Border color
                      width: 1.0,       // Border width
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50, // Adjust width
                    vertical: 10,   // Adjust height
                  ),
                ),
                child: const Text(
                  'Connect to HC-5',
                  style: TextStyle(
                    fontSize: 16, // Button text size
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key}) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  bool _isSectionVisible = false;
  bool _isArrowPressed = false;
  double _selectedScale = 1.0;
  bool isSaved = false;
  String? _imagePath;
  String? _contourImagePath;
  final TextEditingController _controller = TextEditingController();

  void toggleSave() async {
    if (_contourImagePath != null) {
      // Generate a unique filename using the current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFilename = 'contour_image_$timestamp.png';

      final directory = await getApplicationDocumentsDirectory(); // Get app directory to save the image
      final uniqueFilePath = '${directory.path}/$uniqueFilename';

      // Copy the contour image to the new file path
      final contourFile = File(_contourImagePath!);
      await contourFile.copy(uniqueFilePath);

      // Insert the new file path into the database
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
        _contourImagePath = null; // Clear previous contour image if any
      });
    }
  }

  Future<void> _generateContourImage() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
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
      final contourFile = File('${tempDir.path}/contour_image.png')
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

  void _clearAction() {
    setState(() {
      _controller.clear();
      _imagePath = null;
      _contourImagePath = null;
      isSaved = false;  // Reset save state
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
                  MaterialPageRoute(builder: (context) => const FourthPage()),
                );
              },
              child: Image.asset(
                'images/vector.png', // Replace with your image path
                width: 24, // Set the size you want for the image
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
                      onPressed: _generateContourImage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 16),
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












class FourthPage extends StatefulWidget {
  const FourthPage({Key? key}) : super(key: key);

  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  List<String> _savedImages = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final images = await DatabaseHelper().getImages();
    setState(() {
      _savedImages = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Images', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _savedImages.isNotEmpty
          ? GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _savedImages.length,
        itemBuilder: (context, index) {
          String imagePath = _savedImages[index];
          print("Loading image from path: $imagePath"); // Debugging line

          File imageFile = File(imagePath);
          if (!imageFile.existsSync()) {
            return Center(
              child: Text("Image not found", style: TextStyle(color: Colors.red)),
            );
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      )
          : const Center(
        child: Text(
          'No contour images saved.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}