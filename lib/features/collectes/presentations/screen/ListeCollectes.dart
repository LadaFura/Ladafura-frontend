import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/features/collectes/providers/collect_provider.dart';

class ListeCollectes extends ConsumerWidget {
  const ListeCollectes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listeCollect = ref.watch(collectListProvider);

    return Scaffold(
      body: SafeArea(
        child: listeCollect.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),

          error: (error, stackTrace) => Center(
            child: Text(
              'Échec de récupération des collectes : $error',
              textAlign: TextAlign.center,
            ),
          ),

          data: (collects) {
            // Aucune collecte
            if (collects.isEmpty) {
              return const Center(
                child: Text(
                  "L'agent n'a effectué aucune collecte.",
                  textAlign: TextAlign.center,
                ),
              );
            }

            // Liste des collectes
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: collects.length,
              itemBuilder: (context, index) {
                final collect = collects[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      collect.description ?? "Aucune description",
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}