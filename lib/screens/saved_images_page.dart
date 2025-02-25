import 'dart:io';
import 'package:flutter/material.dart';
import 'utils/database_helper.dart';

class SavedImages extends StatefulWidget {
  const SavedImages({Key? key}) : super(key: key);

  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<SavedImages> {
  List<String> _savedImages = [];
  Set<String> _selectedImages = {};

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final images = await DatabaseHelper().getImages();
    setState(() {
      _savedImages = images.reversed.toList(); // Show new images first
    });
  }

  void _toggleSelection(String imagePath) {
    setState(() {
      if (_selectedImages.contains(imagePath)) {
        _selectedImages.remove(imagePath);
      } else {
        _selectedImages.add(imagePath);
      }
    });
  }

  Future<void> _deleteSelectedImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images selected to delete.')),
      );
      return;
    }

    try {
      for (String imagePath in _selectedImages) {
        await DatabaseHelper().deleteImage(imagePath);

        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _savedImages.removeWhere((image) => _selectedImages.contains(image));
        _selectedImages.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected images deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete images: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Images (${_selectedImages.length} selected)',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: _deleteSelectedImages,
            ),
        ],
      ),
      body: _savedImages.isNotEmpty
          ? GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1, // Keeps images square
        ),
        itemCount: _savedImages.length,
        itemBuilder: (context, index) {
          String imagePath = _savedImages[index];
          File imageFile = File(imagePath);
          if (!imageFile.existsSync()) {
            return const Center(
              child: Text(
                "Image not found",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          bool isSelected = _selectedImages.contains(imagePath);

          return GestureDetector(
            onLongPress: () => _toggleSelection(imagePath),
            onTap: () {
              if (_selectedImages.isNotEmpty) {
                _toggleSelection(imagePath);
              } else {
                Navigator.pop(context, imagePath);
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 5,
                    right: 5,
                    child: Icon(Icons.check_circle, color: Colors.blue),
                  ),
              ],
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
