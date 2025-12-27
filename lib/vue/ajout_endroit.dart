import 'dart:io';

import 'package:dclicactivite2avance/modele/endroit.dart';
import 'package:dclicactivite2avance/modele/location.dart';
import 'package:dclicactivite2avance/providers/endroits_utilisateurs.dart';
import 'package:dclicactivite2avance/widgets/image_prise.dart';
import 'package:dclicactivite2avance/widgets/location_prise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AjoutEndroit extends ConsumerStatefulWidget {
  const AjoutEndroit({super.key, this.endroit});

  final Endroit? endroit;

  @override
  ConsumerState<AjoutEndroit> createState() => _AjoutEndroitState();
}

class _AjoutEndroitState extends ConsumerState<AjoutEndroit> {
  final _nomController = TextEditingController();
  File? _photoSelectionne;
  EndroitLocation? _locationSelectionne;

  bool get _isEditing => widget.endroit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nomController.text = widget.endroit!.nom;
      _photoSelectionne = File(widget.endroit!.image);
      _locationSelectionne = widget.endroit!.location;
    }
  }

  void _sauvegarderLieu() async {
    final nomsaisi = _nomController.text;

    if (nomsaisi.isEmpty ||
        _photoSelectionne == null ||
        _locationSelectionne == null) {
      // Optionnel : Afficher un message d'erreur
      return;
    }

    if (_isEditing) {
      await ref.read(endroitsProvider.notifier).modifierEndroit(
            widget.endroit!.id,
            nomsaisi,
            _photoSelectionne!,
            _locationSelectionne!,
          );
    } else {
      await ref.read(endroitsProvider.notifier).ajoutendroit(
            nomsaisi,
            _photoSelectionne!,
            _locationSelectionne!,
          );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le lieu' : 'Ajouter un lieu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nom'),
                controller: _nomController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              ImagePrise(
                onphotoselectionne: (image) {
                  _photoSelectionne = image;
                },
                initialImage: _photoSelectionne,
              ),
              const SizedBox(height: 10),
              LocationPrise(
                onLocationSelected: (location) {
                  _locationSelectionne = location;
                },
                initialLocation: _locationSelectionne,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _sauvegarderLieu,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
