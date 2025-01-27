import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;




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
  bool _isSectionVisible = false; // Controls the visibility of the section
  bool _isArrowPressed = false; // To toggle between buttons
  double _selectedScale = 1.0; // To track the selected scale
  bool isSaved = false; // Tracks the save state for the flag icon
  String? _imagePath; // Store selected image path
  String? _contourImagePath; // Store path for the contour image
  final TextEditingController _controller = TextEditingController();

  // Function to toggle the save state
  void toggleSave() {
    setState(() {
      isSaved = !isSaved; // Toggle the save state
    });
  }

  // Function to pick an image using image_picker
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path; // Set the image path
        _contourImagePath = null; // Clear contour image when a new image is picked
      });
    }
  }

  // Function to process the image and generate a white image with a black contour
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

      // Convert the image to grayscale
      final grayImage = img.grayscale(decodedImage);

      // Apply edge detection to create contours
      final edgeImage = img.sobel(grayImage);

      // Invert the image to make the background white and contours black
      final invertedImage = img.invert(edgeImage);

      // Save the processed image as a temporary file
      final tempDir = Directory.systemTemp;
      final contourFile = File('${tempDir.path}/contour_image.png')
        ..writeAsBytesSync(img.encodePng(invertedImage));

      setState(() {
        _contourImagePath = contourFile.path; // Set the contour image path
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

  // Function to handle Clear button press
  void _clearAction() {
    setState(() {
      _controller.clear(); // Clear text input
      _imagePath = null; // Clear image
      _contourImagePath = null; // Clear contour image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background color
      appBar: AppBar(
        backgroundColor: Colors.white, // White background for the app bar
        elevation: 0, // Removes shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Back arrow
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.flag : Icons.outlined_flag, // Dynamic icon
              color: isSaved ? Colors.red : Colors.black, // Dynamic color
            ),
            onPressed: toggleSave, // Toggle save state on press
            tooltip: isSaved ? 'Unsave' : 'Save', // Dynamic tooltip
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 300, // Width of the frame
                height: 400, // Height of the frame
                decoration: BoxDecoration(
                  color: Colors.white, // Frame color
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2), // Border color
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                ),
                child: _contourImagePath != null
                    ? Image.file(
                    File(_contourImagePath!)) // Display contour image
                    : _imagePath != null
                    ? Image.file(File(_imagePath!)) // Display original image
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
                  // Dimension Section
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
                          const SizedBox(width: 6), // Space between the fields
                          _buildSquareInputField(''),
                          const SizedBox(width: 6), // Space before 'mm'
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
                  // Space between 'dimension' and 'scale'

                  // Scale Section
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

          // Input and Button Section
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                // Toggle Buttons Section
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
                            child: Container(), // To take up space and push the Download button to the right
                          ),
                        if (_isArrowPressed)
                          Padding(
                            padding: const EdgeInsets.only(right: 50),
                            // 20px space to the right
                            child: IconButton(
                              icon: const Icon(
                                  Icons.download_rounded, color: Colors.black),
                              // Download icon with arrow down
                              onPressed: _pickImage, // Trigger image picker
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
                // Text Input Section
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

                // Generate and Clear Buttons
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
                            horizontal: 70, vertical: 16),
                      ),
                      child: const Text('Generate'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _clearAction,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
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
  // Helper Method for Square Input Fields
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

  // Helper Method for Scale Buttons
  Widget _buildScaleButton(double value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedScale = value; // Set the selected scale
        });
      },
      child: Container(
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          color: _selectedScale == value ? Colors.grey : Colors.grey[200],
          // Selected color
          border: Border.all(
            width: 1,
            color: _selectedScale == value
                ? Colors.black.withOpacity(0.6) // Slightly darker border for selected
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
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}