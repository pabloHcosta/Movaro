import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';

class ExploreEntryCard extends StatelessWidget {
  const ExploreEntryCard({
    required this.cityName,
    required this.onTap,
    this.title,
    this.body,
    this.leadingIcon,
    super.key,
  });

  final String cityName;
  final VoidCallback onTap;
  final String? title;
  final String? body;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1F38),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1D3A5E)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  leadingIcon ?? Icons.play_circle_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? context.l10n.cityExploreEntryTitle(cityName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body ?? context.l10n.cityExploreEntryBody(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
