import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera, 
      maxWidth: 600
    );
    
    if (pickedImage == null) {
      return;
    }
    
    // Copy file immediately to prevent deletion
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedImage.path);
    // Use timestamp to make filename unique
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(fileName);
    final permanentPath = '${appDir.path}/temp_${timestamp}$extension';
    
    // Read bytes from temp file and save to permanent location
    final bytes = await File(pickedImage.path).readAsBytes();
    final permanentFile = File(permanentPath);
    await permanentFile.writeAsBytes(bytes);
    
    setState(() {
      _selectedImage = permanentFile;
    });

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: _takePicture,
      icon: const Icon(Icons.camera), 
      label: const Text('Take Picture'),
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }


    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1, 
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}