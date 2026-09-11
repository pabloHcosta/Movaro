import 'package:flutter/material.dart';
import 'package:mudavi_app/core/widgets/frosted_panel.dart';
import 'package:mudavi_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';

class GuideWaitingCard extends StatelessWidget {
  const GuideWaitingCard({
    super.key,
    required this.waitingItems,
    required this.alternatives,
    required this.onSelect,
  });

  final List<GuideActionItem> waitingItems;
  final List<GuideActionItem> alternatives;
  final Future<void> Function(GuideActionItem) onSelect;

  @override
  Widget build(BuildContext context) {
    String text(String pt, String es, String en) =>
        switch (Localizations.localeOf(context).languageCode) {
          'pt' => pt,
          'es' => es,
          _ => en,
        };
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text(
              'Aguardando resposta',
              'Esperando respuesta',
              'Waiting for a response',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            text(
              'Esperar também faz parte. Estas etapas continuam pendentes; retome quando tiver uma resposta.',
              'Esperar también es parte del proceso. Estos pasos siguen pendientes; retomá cuando tengas una respuesta.',
              'Waiting is part of the process. These steps remain pending; return when you have a response.',
            ),
          ),
          for (final item in waitingItems)
            TextButton.icon(
              key: ValueKey('waiting-${item.id}'),
              onPressed: () => onSelect(item),
              icon: const Icon(Icons.schedule_rounded),
              label: Text(item.title),
            ),
          if (alternatives.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              text(
                'Enquanto isso, você pode avançar:',
                'Mientras tanto, podés avanzar:',
                'Meanwhile, you can make progress:',
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final item in alternatives)
              OutlinedButton.icon(
                key: ValueKey('alternative-${item.id}'),
                onPressed: () => onSelect(item),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(item.title),
              ),
          ],
        ],
      ),
    );
  }
}
