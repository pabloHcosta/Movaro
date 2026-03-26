import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';

enum ProtectedPlaceholderType { communityCreate }

class ProtectedPlaceholderPage extends StatelessWidget {
  const ProtectedPlaceholderPage({required this.type, super.key});

  final ProtectedPlaceholderType type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_description(l10n)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    switch (type) {
      case ProtectedPlaceholderType.communityCreate:
        return l10n.protectedCommunityCreateTitle;
    }
  }

  String _description(AppLocalizations l10n) {
    switch (type) {
      case ProtectedPlaceholderType.communityCreate:
        return l10n.protectedCommunityCreateDescription;
    }
  }
}
