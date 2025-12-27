import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePrise extends StatefulWidget {
  const ImagePrise({super.key, required this.onphotoselectionne, this.initialImage});

  final void Function(File image) onphotoselectionne;
  final File? initialImage;

  @override
  State<ImagePrise> createState() {
    return _ImagePriseState();
  }
}

class _ImagePriseState extends State<ImagePrise> {
  File? _photoselectionne;

  @override
  void initState() {
    super.initState();
    _photoselectionne = widget.initialImage;
  }

  @override
  void didUpdateWidget(ImagePrise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImage != oldWidget.initialImage) {
      setState(() {
        _photoselectionne = widget.initialImage;
      });
    }
  }

  void _prendrePhoto() async {
    final imagePicker = ImagePicker();
    final photoprise =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);

    if (photoprise == null) {
      return;
    }

    final imageFichier = File(photoprise.path);

    // On vérifie si le widget est toujours à l'écran AVANT d'appeler setState.
    if (!mounted) {
      return;
    }

    // On notifie le widget parent.
    widget.onphotoselectionne(imageFichier);
    
    // On met à jour l'état local pour afficher l'image.
    setState(() {
      _photoselectionne = imageFichier;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera),
      label: const Text('Prendre photo'),
      onPressed: _prendrePhoto,
    );

    if (_photoselectionne != null) {
      content = GestureDetector(
        onTap: _prendrePhoto,
        child: Image.file(
          _photoselectionne!,
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
          color: Theme.of(context).colorScheme.primary.withAlpha(51),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias, // Assure que l'enfant (l'image) est coupé pour suivre les bords arrondis
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
