import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List? convertToContour(Uint8List imageBytes) {

  img.Image? image = img.decodeImage(imageBytes);
  if (image == null) return null;

  img.Image edgeImage = img.sobel(image);

  return Uint8List.fromList(img.encodePng(edgeImage));
}
