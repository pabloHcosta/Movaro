import 'package:flutter/material.dart';
import 'package:movaro_app/app/router/app_routes.dart';

/// A compact, non-expandable entry strip anchored above the navigation bar.
///
/// Shows:
/// - Header row: sparkles icon + title + subtitle + "Abrir ↑" link
/// - A horizontal row of 3 quick-question chips
/// - A text input that navigates to [AppRoutes.info] (AssistantTab) on submit
///
/// All chat logic lives in [AssistantPage]; this widget is only a gateway.
class AssistantBottomSheet extends StatefulWidget {
  const AssistantBottomSheet({super.key});

  @override
  State<AssistantBottomSheet> createState() => _AssistantBottomSheetState();
}

class _AssistantBottomSheetState extends State<AssistantBottomSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate(String? message) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.info,
      arguments: message?.trim().isNotEmpty == true ? message!.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    final title = switch (lang) {
      'pt' => 'Assistente Movaro',
      'es' => 'Asistente Movaro',
      _ => 'Movaro Assistant',
    };
    final subtitle = switch (lang) {
      'pt' => 'Tire dúvidas sobre sua mudança',
      'es' => 'Resuelve dudas sobre tu mudanza',
      _ => 'Get answers about your move',
    };
    final openLabel = switch (lang) {
      'pt' => 'Abrir ↑',
      'es' => 'Abrir ↑',
      _ => 'Open ↑',
    };
    final inputHint = switch (lang) {
      'pt' => 'Ou digite sua pergunta...',
      'es' => 'O escribe tu pregunta...',
      _ => 'Or type your question...',
    };

    final chips = switch (lang) {
      'pt' => ['Preciso de visto?', 'Melhor época para ir?', 'Como tirar CPF?'],
      'es' => ['¿Necesito visa?', '¿Mejor época para ir?', '¿Cómo obtener el CPF?'],
      _ => ['Do I need a visa?', 'Best time to go?', 'How to get CPF?'],
    };

    return _SheetSurface(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14, 10, 14,
          MediaQuery.of(context).padding.bottom + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                _SparklesAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigate(null),
                  child: Text(
                    openLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF4FC3F7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quick chips
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => _QuickChip(
                  label: chips[i],
                  onTap: () => _navigate(chips[i]),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Input row
            _InputRow(
              controller: _controller,
              placeholder: inputHint,
              onSend: () => _navigate(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet surface ────────────────────────────────────────────────────────────

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: const Color(0xF00E1D33))),
          child,
          // Top accent line
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _SparklesAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
    );
  }
}

// ─── Quick chip ───────────────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF4FC3F7).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4FC3F7),
          ),
        ),
      ),
    );
  }
}

// ─── Input row ────────────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.placeholder,
    required this.onSend,
  });

  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF0288D1),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
