import 'package:flutter/material.dart';
import 'package:picaso_app1/screens/image_processing_page.dart';




class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Text aligned to center-left
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 30,
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
                        builder: (context) => const ImageProcessing(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
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