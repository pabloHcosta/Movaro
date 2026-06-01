import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:movaro_app/features/language/application/portuguese_phrasebook.dart';

/// Browsable, situation-based Portuguese phrasebook. Attacks the #1 pain
/// (Portuguese) directly: practical phrases to say at the Federal Police, bank,
/// rental office, health clinic, job interview and everyday life — with the
/// translation in the user's language. Works fully offline.
class PortuguesePhrasebookPage extends StatelessWidget {
  const PortuguesePhrasebookPage({super.key});

  String _t(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'es':
        return es;
      case 'en':
        return en;
      default:
        return pt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(
            context,
            pt: 'Português essencial',
            es: 'Portugués esencial',
            en: 'Essential Portuguese',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            _t(
              context,
              pt: 'Frases prontas para usar nos trâmites e no dia a dia. Toque para copiar.',
              es: 'Frases listas para usar en los trámites y el día a día. Tocá para copiar.',
              en: 'Ready-to-use phrases for paperwork and daily life. Tap to copy.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final group in PortuguesePhrasebook.groups) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Row(
                children: [
                  Icon(group.icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.title(locale),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final phrase in group.phrases)
              _PhraseCard(phrase: phrase, locale: locale),
          ],
        ],
      ),
    );
  }
}

class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.phrase, required this.locale});

  final PortuguesePhrase phrase;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = phrase.note(locale);
    // For Portuguese-locale users the translation equals the phrase, so the
    // secondary line would be redundant — hide it in that case.
    final showTranslation = !locale.toLowerCase().startsWith('pt');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: phrase.pt));
          if (!context.mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                _copiedLabel(locale),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase.pt,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (showTranslation) ...[
                      const SizedBox(height: 4),
                      Text(
                        phrase.translation(locale),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (note != null && note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.copy_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _copiedLabel(String locale) {
    final l = locale.toLowerCase();
    if (l.startsWith('es')) return 'Frase copiada';
    if (l.startsWith('en')) return 'Phrase copied';
    return 'Frase copiada';
  }
}
