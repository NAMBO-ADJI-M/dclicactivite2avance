import 'package:dclicactivite2avance/providers/endroits_utilisateurs.dart';
import 'package:dclicactivite2avance/vue/ajout_endroit.dart';
import 'package:dclicactivite2avance/widgets/endroits_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EndroitsInterface extends ConsumerStatefulWidget {
  const EndroitsInterface({super.key});

  @override
  ConsumerState<EndroitsInterface> createState() {
    return _EndroitsInterfaceState();
  }
}

class _EndroitsInterfaceState extends ConsumerState<EndroitsInterface> {
  late Future<void> _endroitsFuture;

  @override
  void initState() {
    super.initState();
    _endroitsFuture = ref.read(endroitsProvider.notifier).loadEndroits();
  }

  @override
  Widget build(BuildContext context) {
    final endroitsUtilisateur = ref.watch(endroitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes endroits préférés'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AjoutEndroit(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _endroitsFuture,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : EndroitsList(
                      endroits: endroitsUtilisateur,
                    ),
        ),
      ),
    );
  }
}
