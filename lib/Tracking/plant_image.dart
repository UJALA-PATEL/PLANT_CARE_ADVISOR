import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<void> _saveImageLocally(String imagePath) async {
  try {
    // Get the application's document directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a folder named 'plant_images' inside the documents directory
    final plantImagesDirectory = Directory('${directory.path}/plant_images');

    // Check if the directory exists, if not, create it
    if (!await plantImagesDirectory.exists()) {
      await plantImagesDirectory.create(recursive: true);
    }

    // Extract the image name (e.g., 'image.jpg')
    final imageName = basename(imagePath);

    // Create the full local path where the image will be saved
    final localImagePath = '${plantImagesDirectory.path}/$imageName';

    // Create a File instance and copy the image to the new path
    final File imageFile = File(imagePath);
    await imageFile.copy(localImagePath); // Save image locally

    print("Image saved locally at: $localImagePath");
  } catch (e) {
    print("Error saving image locally: $e");
  }
}
