import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_text_styles.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/document_checklist_adapter.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_guide_registry.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:url_launcher/url_launcher.dart';

class MigrationDocumentReadinessSection extends StatefulWidget {
  const MigrationDocumentReadinessSection({
    required this.plan,
    required this.completedItemIds,
    required this.onToggleItem,
    super.key,
  });

  final MigrationPlan plan;
  final Set<String> completedItemIds;
  final ValueChanged<String> onToggleItem;

  @override
  State<MigrationDocumentReadinessSection> createState() =>
      _MigrationDocumentReadinessSectionState();
}

class _MigrationDocumentReadinessSectionState
    extends State<MigrationDocumentReadinessSection> {
  String? _activeItemId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fallbackChecklist = MigrationDocumentReadinessBuilder.build(
      l10n: l10n,
      plan: widget.plan,
    );
    final items = DocumentChecklistAdapter.getItems(
      l10n: l10n,
      originCountry: widget.plan.originCountry,
      destinationCountry: widget.plan.destinationCountry,
      goal: widget.plan.goal,
      travelGroup: widget.plan.travelGroup,
      fallbackChecklist: fallbackChecklist,
    );
    final visibleCompletedCount = items
        .where((item) => widget.completedItemIds.contains(item.id))
        .length;

    if (_usesStructuredCorridorGuide) {
      return FrostedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sectionTitle(l10n),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _sectionSummary(l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            _ProgressRow(
              label: l10n.readinessProgressLabel(
                visibleCompletedCount,
                items.length,
              ),
              progress: items.isEmpty
                  ? 0
                  : visibleCompletedCount / items.length,
            ),
            const SizedBox(height: 18),
            _TopBanner(localeName: l10n.localeName, corridorKey: _corridorKey),
            const SizedBox(height: 14),
            _PhaseGroup(
              title: _beforeTravelTitle(l10n),
              phaseContext: _beforeTravelContext(l10n),
              accent: const Color(0xFFE24B4A).withValues(alpha: 0.70),
              items: items
                  .where((item) => item.phase == DocumentPhase.beforeTravel)
                  .toList(growable: false),
              completedItemIds: widget.completedItemIds,
              activeItemId: _activeItemId,
              onActivate: _setActiveItem,
              onToggleItem: widget.onToggleItem,
            ),
            const SizedBox(height: 16),
            _PhaseGroup(
              title: _uponArrivalTitle(l10n),
              phaseContext: _uponArrivalContext(l10n),
              accent: const Color(0xFFF59E0B).withValues(alpha: 0.70),
              items: items
                  .where((item) => item.phase == DocumentPhase.uponArrival)
                  .toList(growable: false),
              completedItemIds: widget.completedItemIds,
              activeItemId: _activeItemId,
              onActivate: _setActiveItem,
              onToggleItem: widget.onToggleItem,
            ),
          ],
        ),
      );
    }

    return _GenericDocumentReadinessSection(
      checklist: fallbackChecklist,
      completedItemIds: widget.completedItemIds,
      onToggleItem: widget.onToggleItem,
    );
  }

  bool get _usesStructuredCorridorGuide =>
      MigrationGuideRegistry.supportsCorridor(
        widget.plan.originCountry,
        widget.plan.destinationCountry,
      );

  String? get _corridorKey => MigrationGuideRegistry.corridorKey(
    widget.plan.originCountry,
    widget.plan.destinationCountry,
  );

  void _setActiveItem(String id) {
    setState(() {
      _activeItemId = _activeItemId == id ? null : id;
    });
  }

  String _sectionTitle(dynamic l10n) {
    return switch (l10n.localeName.split('_').first) {
      'pt' => 'Seus documentos para o Brasil',
      'es' => 'Tus documentos para Brasil',
      _ => 'Your documents for Brazil',
    };
  }

  String _sectionSummary(dynamic l10n) {
    if (_corridorKey == 'uruguai->brasil') {
      return switch (l10n.localeName.split('_').first) {
        'pt' =>
          'Para sair do Uruguai rumo ao Brasil, o foco inicial e alinhar documento de entrada, base Mercosul e CPF sem tratar a mudanca como turismo genérico.',
        'es' =>
          'Para salir de Uruguay hacia Brasil, el foco inicial es alinear documento de entrada, base Mercosur y CPF sin tratar la mudanza como turismo genérico.',
        _ =>
          'For someone moving from Uruguay to Brazil, the initial focus is aligning the entry document, the Mercosur basis, and CPF without treating the move as generic tourism.',
      };
    }
    return switch (l10n.localeName.split('_').first) {
      'pt' =>
        'Argentinos nao precisam de passaporte nem visto para entrar no Brasil. Veja o que voce realmente precisa.',
      'es' =>
        'Los argentinos no necesitan pasaporte ni visa para entrar a Brasil. Mira lo que realmente hace falta.',
      _ =>
        'Argentine citizens do not need a passport or visa to enter Brazil. See what you actually need.',
    };
  }

  String _beforeTravelTitle(dynamic l10n) {
    return switch (l10n.localeName.split('_').first) {
      'pt' => 'ANTES DE VIAJAR',
      'es' => 'ANTES DE VIAJAR',
      _ => 'BEFORE YOU TRAVEL',
    };
  }

  String _beforeTravelContext(dynamic l10n) {
    if (_corridorKey == 'uruguai->brasil') {
      return switch (l10n.localeName.split('_').first) {
        'pt' =>
          '✓ Antes de viajar, valide a lógica de entrada e a rota de residência. Para mudança, isso importa mais do que uma leitura turística solta.',
        'es' =>
          '✓ Antes de viajar, validá la lógica de entrada y la ruta de residencia. Para mudanza, eso importa más que una lectura turística suelta.',
        _ =>
          '✓ Before departure, validate the entry logic and the residence path. For relocation, that matters more than a loose tourism reading.',
      };
    }
    return switch (l10n.localeName.split('_').first) {
      'pt' =>
        '✓ Argentinos entram no Brasil so com o DNI. Sem passaporte e sem visto.',
      'es' =>
        '✓ Los argentinos entran a Brasil solo con el DNI. Sin pasaporte y sin visa.',
      _ =>
        '✓ Argentine citizens can enter Brazil with DNI only. No passport and no visa.',
    };
  }

  String _uponArrivalTitle(dynamic l10n) {
    return switch (l10n.localeName.split('_').first) {
      'pt' => 'AO CHEGAR NO BRASIL',
      'es' => 'AL LLEGAR A BRASIL',
      _ => 'AFTER YOU ARRIVE IN BRAZIL',
    };
  }

  String _uponArrivalContext(dynamic l10n) {
    return switch (l10n.localeName.split('_').first) {
      'pt' =>
        'Esses passos sao feitos depois da chegada. Nao precisa resolver tudo antes.',
      'es' =>
        'Estos pasos se hacen despues de llegar. No hace falta resolver todo antes.',
      _ =>
        'These steps happen after you arrive. You do not need to solve them all before traveling.',
    };
  }
}

class _TopBanner extends StatelessWidget {
  const _TopBanner({required this.localeName, this.corridorKey});

  final String localeName;
  final String? corridorKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2818),
        border: Border.all(color: const Color(0xFF1A4428)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF3FB950),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _title => switch (localeName.split('_').first) {
    'pt' =>
      corridorKey == 'uruguai->brasil'
          ? 'Mudança exige leitura diferente de turismo'
          : 'Argentinos entram no Brasil com o DNI',
    'es' =>
      corridorKey == 'uruguai->brasil'
          ? 'La mudanza exige una lectura distinta al turismo'
          : 'Los argentinos entran a Brasil con el DNI',
    _ =>
      corridorKey == 'uruguai->brasil'
          ? 'Relocation requires a different read from tourism'
          : 'Argentine citizens can enter Brazil with DNI',
  };

  String get _body => switch (localeName.split('_').first) {
    'pt' =>
      corridorKey == 'uruguai->brasil'
          ? 'Antes de embarcar, confirme documento de entrada, base Mercosul e ordem documental. Isso reduz ruído logo na chegada.'
          : 'Nada de passaporte, visto ou apostila para entrar. A regularizacao e feita depois da chegada.',
    'es' =>
      corridorKey == 'uruguai->brasil'
          ? 'Antes de viajar, confirmá documento de entrada, base Mercosur y orden documental. Eso reduce ruido apenas llegás.'
          : 'Nada de pasaporte, visa o apostilla para entrar. La regularizacion se hace despues de llegar.',
    _ =>
      corridorKey == 'uruguai->brasil'
          ? 'Before departure, confirm the entry document, the Mercosur basis, and the document order. That reduces friction right after arrival.'
          : 'No passport, visa, or apostille is required to enter. Regularization happens after arrival.',
  };
}

class _PhaseGroup extends StatelessWidget {
  const _PhaseGroup({
    required this.title,
    required this.phaseContext,
    required this.accent,
    required this.items,
    required this.completedItemIds,
    required this.activeItemId,
    required this.onActivate,
    required this.onToggleItem,
  });

  final String title;
  final String phaseContext;
  final Color accent;
  final List<DocumentItem> items;
  final Set<String> completedItemIds;
  final String? activeItemId;
  final ValueChanged<String> onActivate;
  final ValueChanged<String> onToggleItem;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(0),
      borderRadius: BorderRadius.circular(22),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  phaseContext,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          for (final item in items)
            _ChecklistItem(
              item: item,
              isActive: activeItemId == item.id,
              isCompleted: completedItemIds.contains(item.id),
              onActivate: () => onActivate(item.id),
              onToggle: () => onToggleItem(item.id),
            ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.item,
    required this.isActive,
    required this.isCompleted,
    required this.onActivate,
    required this.onToggle,
  });

  final DocumentItem item;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onActivate;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onActivate,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.all(12),
        color: isActive ? const Color(0xFF0A1828) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF0D2818)
                      : const Color(0xFF1C2128),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF1A4428)
                        : isActive
                        ? const Color(0xFF1D4A70)
                        : const Color(0xFF2D333B),
                    width: isActive && !isCompleted ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: Color(0xFF3FB950),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.title,
                          style: context.textStyles.itemTitle.copyWith(
                            color: isCompleted
                                ? const Color(0xFF4B5563)
                                : const Color(0xFFF0F6FC),
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            _doneLabel(context),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: const Color(0xFF3FB950),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? const Color(0xFF2D333B)
                          : const Color(0xFF8B949E),
                      height: 1.5,
                    ),
                  ),
                  if (!isCompleted) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 10,
                          color: Color(0xFF4B5563),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.timeEstimate,
                          style: AppTypography.compactLabel.copyWith(
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                    if (item.tip != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1200),
                          border: Border.all(color: const Color(0xFF3D2800)),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                item.tip!,
                                style: AppTypography.compactLabel.copyWith(
                                  color: const Color(0xFFF59E0B),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (isActive && item.link != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _openLink(item.link!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F6FEB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _openOfficialSiteLabel(context),
                            style: AppTypography.compactBadge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(String value) async {
    final uri = Uri.parse(value);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _openOfficialSiteLabel(BuildContext context) {
    return context.l10n.commonOpenOfficialSiteAction;
  }

  String _doneLabel(BuildContext context) {
    return context.l10n.commonDoneCheck;
  }
}

class _GenericDocumentReadinessSection extends StatelessWidget {
  const _GenericDocumentReadinessSection({
    required this.checklist,
    required this.completedItemIds,
    required this.onToggleItem,
  });

  final MigrationDocumentReadinessChecklist checklist;
  final Set<String> completedItemIds;
  final ValueChanged<String> onToggleItem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentReadinessSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            checklist.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _ProgressRow(
            label: l10n.readinessProgressLabel(
              completedItemIds.length,
              checklist.items.length,
            ),
            progress: checklist.items.isEmpty
                ? 0
                : completedItemIds.length / checklist.items.length,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 960;
              final medium = constraints.maxWidth >= 640;
              final columnWidth = wide
                  ? (constraints.maxWidth - 24) / 3
                  : medium
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: columnWidth,
                    child: _PriorityPanel(
                      title: l10n.documentReadinessPriorityCritical,
                      badge: '01',
                      accent: AppColors.warning,
                      items: checklist.itemsFor(
                        MigrationDocumentReadinessPriority.critical,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _PriorityPanel(
                      title: l10n.documentReadinessPriorityPrepare,
                      badge: '02',
                      accent: AppColors.primary,
                      items: checklist.itemsFor(
                        MigrationDocumentReadinessPriority.prepare,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _PriorityPanel(
                      title: l10n.documentReadinessPriorityArrival,
                      badge: '03',
                      accent: AppColors.success,
                      items: checklist.itemsFor(
                        MigrationDocumentReadinessPriority.arrival,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PriorityPanel extends StatelessWidget {
  const _PriorityPanel({
    required this.title,
    required this.badge,
    required this.accent,
    required this.items,
    required this.completedItemIds,
    required this.onToggleItem,
  });

  final String title;
  final String badge;
  final Color accent;
  final List<MigrationDocumentReadinessItem> items;
  final Set<String> completedItemIds;
  final ValueChanged<String> onToggleItem;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: accent),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            _DocumentItemTile(
              item: items[i],
              accent: accent,
              completed: completedItemIds.contains(items[i].id),
              onToggle: () => onToggleItem(items[i].id),
            ),
            if (i != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _DocumentItemTile extends StatelessWidget {
  const _DocumentItemTile({
    required this.item,
    required this.accent,
    required this.completed,
    required this.onToggle,
  });

  final MigrationDocumentReadinessItem item;
  final Color accent;
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(item.risk);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed
                ? AppColors.success.withValues(alpha: 0.24)
                : accent.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (completed ? AppColors.success : accent).withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                completed ? Icons.check_rounded : item.icon,
                size: 19,
                color: completed ? AppColors.success : accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      height: 1.15,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.4,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.warning_amber_rounded,
                        label: _riskLabel(context, item.risk),
                        color: riskColor,
                      ),
                      _MetaChip(
                        icon: Icons.schedule_outlined,
                        label: _reviewLabel(context, item.reviewMoment),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.documentReadinessSourceLabel(item.sourceLabel),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Checkbox.adaptive(
              value: completed,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Color _riskColor(MigrationDocumentReadinessRisk risk) {
    switch (risk) {
      case MigrationDocumentReadinessRisk.blocking:
        return AppColors.danger;
      case MigrationDocumentReadinessRisk.caution:
        return AppColors.warning;
      case MigrationDocumentReadinessRisk.review:
        return AppColors.success;
    }
  }

  String _riskLabel(BuildContext context, MigrationDocumentReadinessRisk risk) {
    switch (risk) {
      case MigrationDocumentReadinessRisk.blocking:
        return context.l10n.documentReadinessRiskBlocking;
      case MigrationDocumentReadinessRisk.caution:
        return context.l10n.documentReadinessRiskCaution;
      case MigrationDocumentReadinessRisk.review:
        return context.l10n.documentReadinessRiskReview;
    }
  }

  String _reviewLabel(
    BuildContext context,
    MigrationDocumentReadinessReviewMoment reviewMoment,
  ) {
    switch (reviewMoment) {
      case MigrationDocumentReadinessReviewMoment.beforeBooking:
        return context.l10n.documentReadinessReviewBeforeBooking;
      case MigrationDocumentReadinessReviewMoment.closeToMove:
        return context.l10n.documentReadinessReviewCloseToMove;
      case MigrationDocumentReadinessReviewMoment.onArrival:
        return context.l10n.documentReadinessReviewOnArrival;
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.progress});

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSoftFor(context),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.surfaceMutedFor(context),
          ),
        ),
      ],
    );
  }
}
