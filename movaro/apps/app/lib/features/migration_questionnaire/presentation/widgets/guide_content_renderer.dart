import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

/// Parses guide `fullContent` plain text into structured visual blocks.
///
/// Conventions detected:
/// - Lines ending with `:` → section header
/// - Lines starting with `- ` → bullet point
/// - Lines starting with a digit followed by `.` → numbered step
/// - Lines containing URLs → tappable link
/// - Lines starting with `Dica` / `Importante` / `Atenção` → callout tip
/// - Lines containing `R$` → financial highlight
class GuideContentRenderer extends StatelessWidget {
  const GuideContentRenderer({
    super.key,
    required this.content,
    required this.onLinkTap,
  });

  final String content;
  final void Function(String url, String label) onLinkTap;

  static final _urlPattern = RegExp(
    r'(https?://[^\s,)]+|www\.[^\s,)]+|\w+\.\w+\.(?:com|gov|org|net|br|ar)(?:\.\w+)?(?:/[^\s,)]*)?)',
  );

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i].trim();

      // Skip empty lines
      if (line.isEmpty) {
        i++;
        continue;
      }

      // Callout tip (Dica, Importante, Atenção)
      if (_isCallout(line)) {
        widgets.add(_buildCallout(context, line));
        i++;
        continue;
      }

      // Section header (line ends with : and is relatively short)
      if (_isSectionHeader(line)) {
        widgets.add(_buildSectionHeader(context, line));
        i++;
        continue;
      }

      // Bullet point
      if (line.startsWith('- ')) {
        final bullets = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('- ')) {
          bullets.add(lines[i].trim().substring(2));
          i++;
        }
        widgets.add(_buildBulletList(context, bullets));
        continue;
      }

      // Numbered step (e.g., "1. ...")
      if (RegExp(r'^\d+[\.\)]\s').hasMatch(line)) {
        final steps = <String>[];
        while (i < lines.length &&
            RegExp(r'^\d+[\.\)]\s').hasMatch(lines[i].trim())) {
          steps.add(lines[i].trim().replaceFirst(RegExp(r'^\d+[\.\)]\s'), ''));
          i++;
        }
        widgets.add(_buildNumberedList(context, steps));
        continue;
      }

      // Regular paragraph (may contain URLs or R$ values)
      // Collect consecutive non-special lines into one paragraph
      final paragraphLines = <String>[];
      while (i < lines.length) {
        final l = lines[i].trim();
        if (l.isEmpty ||
            _isSectionHeader(l) ||
            l.startsWith('- ') ||
            RegExp(r'^\d+[\.\)]\s').hasMatch(l) ||
            _isCallout(l)) {
          break;
        }
        paragraphLines.add(l);
        i++;
      }
      if (paragraphLines.isNotEmpty) {
        final text = paragraphLines.join(' ');
        widgets.add(_buildParagraph(context, text));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var w = 0; w < widgets.length; w++) ...[
          widgets[w],
          if (w < widgets.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  bool _isSectionHeader(String line) {
    return line.endsWith(':') && line.length < 80 && !line.startsWith('- ');
  }

  bool _isCallout(String line) {
    final lower = line.toLowerCase();
    return lower.startsWith('dica') ||
        lower.startsWith('importante') ||
        lower.startsWith('atenção') ||
        lower.startsWith('atencion') ||
        lower.startsWith('tip:') ||
        lower.startsWith('important:');
  }

  Widget _buildSectionHeader(BuildContext context, String line) {
    // Remove trailing colon for display
    final text = line.endsWith(':') ? line.substring(0, line.length - 1) : line;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> bullets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets.map((bullet) {
        return Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textSoftFor(context),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildRichText(context, bullet)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberedList(BuildContext context, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _buildRichText(context, steps[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCallout(BuildContext context, String line) {
    // Strip prefix like "Dica prática:" or "Importante:"
    final colonIndex = line.indexOf(':');
    final label = colonIndex > 0
        ? line.substring(0, colonIndex).trim()
        : 'Dica';
    final body = colonIndex > 0 ? line.substring(colonIndex + 1).trim() : line;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.warning, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildRichText(context, body),
          ],
        ],
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return _buildRichText(context, text);
  }

  /// Builds a RichText widget that highlights URLs as tappable links
  /// and R$ values with a subtle emphasis.
  Widget _buildRichText(BuildContext context, String text) {
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: 1.5);

    final spans = <InlineSpan>[];
    var lastEnd = 0;

    // Find all URLs
    for (final match in _urlPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: baseStyle,
          ),
        );
      }

      final url = match.group(0)!;
      final fullUrl = url.startsWith('http') ? url : 'https://$url';

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => onLinkTap(fullUrl, url),
            child: Text(
              url,
              style: baseStyle?.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }

    if (spans.isEmpty) {
      return Text(text, style: baseStyle);
    }

    return Text.rich(TextSpan(children: spans));
  }
}
