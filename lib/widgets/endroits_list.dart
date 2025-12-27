import 'dart:io';

import 'package:dclicactivite2avance/modele/endroit.dart';
import 'package:dclicactivite2avance/providers/endroits_utilisateurs.dart';
import 'package:dclicactivite2avance/vue/ajout_endroit.dart';
import 'package:dclicactivite2avance/vue/endroit_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EndroitsList extends ConsumerWidget {
  const EndroitsList({super.key, required this.endroits});

  final List<Endroit> endroits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (endroits.isEmpty) {
      return Center(
        child: Text(
          'Il n\'y a pas d\'endroits favoris pour le moment',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: endroits.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(endroits[index].id),
        onDismissed: (direction) {
          ref.read(endroitsProvider.notifier).supprimerEndroit(endroits[index]);
        },
        background: Container(
          color: Theme.of(context).colorScheme.error.withAlpha(191),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
        ),
        child: ListTile(
          leading: Hero(
            tag: endroits[index].id, // Tag pour l'animation
            child: CircleAvatar(
              radius: 26,
              backgroundImage: FileImage(File(endroits[index].image)),
            ),
          ),
          title: Text(
            endroits[index].nom,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AjoutEndroit(endroit: endroits[index]),
                ),
              );
            },
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => EndroitDetail(endroit: endroits[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
