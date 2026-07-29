import 'package:flutter/material.dart';

/// Reusable "orientation, not advice" note for liability-sensitive surfaces
/// (assistant, practical guide, affordability, generated plan).
///
/// Movaro is an **assistant** that organizes information and points to official
/// sources — it is **not** a legal or financial advisor. Showing this wherever
/// the app surfaces procedural, legal or money-related content keeps that line
/// clear for users (and reduces liability exposure).
class PracticalInfoDisclaimer extends StatelessWidget {
  const PracticalInfoDisclaimer({this.compact = false, super.key});

  /// Slightly tighter padding/spacing for dense surfaces.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: onSurface.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _text(Localizations.localeOf(context).languageCode),
              style: theme.textTheme.bodySmall?.copyWith(
                color: onSurface.withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _text(String locale) {
    final l = locale.toLowerCase();
    if (l.startsWith('es')) {
      return 'La información de Movaro es de carácter informativo y sirve únicamente como orientación. No constituye asesoramiento legal ni financiero. Las normas y los procedimientos pueden cambiar, por eso, verificá siempre la información en las fuentes oficiales';
    }
    if (l.startsWith('en')) {
      return 'The information provided by Movaro is for informational and guidance purposes only. It does not constitute legal or financial advice. Rules and procedures may change, so always verify the information with official sources.';
    }
    return 'As informações do Movaro têm caráter informativo e servem apenas como orientação. Não constituem aconselhamento jurídico ou financeiro. Regras e procedimentos podem mudar, por isso, confirme sempre as informações nas fontes oficiais.';
  }
}
