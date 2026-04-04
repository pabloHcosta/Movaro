import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_event_suggestion.dart';

enum GuideEventSuggestionAction { added, later, skipped }

class GuideEventSuggestionResult {
  const GuideEventSuggestionResult({
    required this.action,
    required this.suggestion,
    required this.reminderOption,
    this.notes,
  });

  final GuideEventSuggestionAction action;
  final GuideEventSuggestion suggestion;
  final GuideEventReminderOption reminderOption;
  final String? notes;
}

Future<GuideEventSuggestionResult?> showGuideEventSuggestionSheet(
  BuildContext context, {
  required GuideEventSuggestion suggestion,
  required Future<bool> Function(
    GuideEventSuggestion suggestion,
    GuideEventReminderOption reminderOption,
    String? notes,
  )
  onAddToCalendar,
}) {
  return showModalBottomSheet<GuideEventSuggestionResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _GuideEventSuggestionSheet(
      suggestion: suggestion,
      onAddToCalendar: onAddToCalendar,
    ),
  );
}

class _GuideEventSuggestionSheet extends StatefulWidget {
  const _GuideEventSuggestionSheet({
    required this.suggestion,
    required this.onAddToCalendar,
  });

  final GuideEventSuggestion suggestion;
  final Future<bool> Function(
    GuideEventSuggestion suggestion,
    GuideEventReminderOption reminderOption,
    String? notes,
  )
  onAddToCalendar;

  @override
  State<_GuideEventSuggestionSheet> createState() =>
      _GuideEventSuggestionSheetState();
}

class _GuideEventSuggestionSheetState
    extends State<_GuideEventSuggestionSheet> {
  late GuideEventSuggestion _draft;
  late GuideEventReminderOption _reminderOption;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.suggestion;
    _reminderOption = widget.suggestion.defaultReminderOption;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.MMMEd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final timeOfDay = TimeOfDay.fromDateTime(_draft.startAt);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: FrostedPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _text(
                          context,
                          pt: 'Assistente de calendário',
                          es: 'Asistente de calendario',
                          en: 'Calendar assistant',
                        ),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _draft.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _draft.assistantCopy,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  icon: Icons.info_outline_rounded,
                  title: _text(
                    context,
                    pt: 'Por que sugerimos isso',
                    es: 'Por qué sugerimos esto',
                    en: 'Why we suggest this',
                  ),
                  body: _draft.description,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickEditButton(
                        icon: Icons.calendar_today_rounded,
                        label: dateFormat.format(_draft.startAt),
                        onTap: _isSubmitting ? null : _pickDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickEditButton(
                        icon: Icons.schedule_rounded,
                        label: timeOfDay.format(context),
                        onTap: _isSubmitting ? null : _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.timelapse_rounded,
                  title: _text(
                    context,
                    pt: 'Duração sugerida',
                    es: 'Duración sugerida',
                    en: 'Suggested duration',
                  ),
                  body: _durationLabel(
                    context,
                    _draft.suggestedDurationMinutes,
                  ),
                  trailing: _draft.locationLabel,
                ),
                if (_draft.hardDeadline != null) ...[
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.priority_high_rounded,
                    title: _text(
                      context,
                      pt: 'Prazo importante',
                      es: 'Plazo importante',
                      en: 'Important deadline',
                    ),
                    body: DateFormat.yMMMd(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(_draft.hardDeadline!),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  _text(
                    context,
                    pt: 'Lembretes',
                    es: 'Recordatorios',
                    en: 'Reminders',
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GuideEventReminderOption.values
                      .map(
                        (option) => ChoiceChip(
                          label: Text(_reminderLabel(context, option)),
                          selected: _reminderOption == option,
                          onSelected: _isSubmitting
                              ? null
                              : (_) {
                                  setState(() {
                                    _reminderOption = option;
                                  });
                                },
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: _text(
                      context,
                      pt: 'Nota opcional',
                      es: 'Nota opcional',
                      en: 'Optional note',
                    ),
                    hintText: _text(
                      context,
                      pt: 'Ex.: levar passaporte e comprovante',
                      es: 'Ej.: llevar pasaporte y comprobante',
                      en: 'E.g. bring passport and proof of address',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _handleAdd,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.event_available_rounded, size: 18),
                    label: Text(
                      _text(
                        context,
                        pt: 'Adicionar ao calendário',
                        es: 'Agregar al calendario',
                        en: 'Add to calendar',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(
                                GuideEventSuggestionResult(
                                  action: GuideEventSuggestionAction.later,
                                  suggestion: _draft,
                                  reminderOption: _reminderOption,
                                  notes: _trimmedNotes,
                                ),
                              ),
                        child: Text(
                          _text(
                            context,
                            pt: 'Lembrar depois',
                            es: 'Recordarme después',
                            en: 'Remind me later',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(
                                GuideEventSuggestionResult(
                                  action: GuideEventSuggestionAction.skipped,
                                  suggestion: _draft,
                                  reminderOption: _reminderOption,
                                  notes: _trimmedNotes,
                                ),
                              ),
                        child: Text(
                          _text(context, pt: 'Pular', es: 'Omitir', en: 'Skip'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _trimmedNotes {
    final value = _notesController.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) {
      return;
    }

    final updatedStart = DateTime(
      picked.year,
      picked.month,
      picked.day,
      _draft.startAt.hour,
      _draft.startAt.minute,
    );
    setState(() {
      _draft = _draft.copyWith(
        startAt: updatedStart,
        endAt: updatedStart.add(
          Duration(minutes: _draft.suggestedDurationMinutes),
        ),
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_draft.startAt),
    );
    if (picked == null) {
      return;
    }

    final updatedStart = DateTime(
      _draft.startAt.year,
      _draft.startAt.month,
      _draft.startAt.day,
      picked.hour,
      picked.minute,
    );
    setState(() {
      _draft = _draft.copyWith(
        startAt: updatedStart,
        endAt: updatedStart.add(
          Duration(minutes: _draft.suggestedDurationMinutes),
        ),
      );
    });
  }

  Future<void> _handleAdd() async {
    setState(() {
      _isSubmitting = true;
    });
    final added = await widget.onAddToCalendar(
      _draft,
      _reminderOption,
      _trimmedNotes,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });
    if (!added) {
      return;
    }
    Navigator.of(context).pop(
      GuideEventSuggestionResult(
        action: GuideEventSuggestionAction.added,
        suggestion: _draft,
        reminderOption: _reminderOption,
        notes: _trimmedNotes,
      ),
    );
  }

  String _durationLabel(BuildContext context, int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainder = minutes % 60;
      if (remainder == 0) {
        return _text(context, pt: '$hours h', es: '$hours h', en: '$hours h');
      }
      return _text(
        context,
        pt: '$hours h $remainder min',
        es: '$hours h $remainder min',
        en: '$hours h $remainder min',
      );
    }
    return _text(
      context,
      pt: '$minutes min',
      es: '$minutes min',
      en: '$minutes min',
    );
  }

  String _reminderLabel(BuildContext context, GuideEventReminderOption option) {
    return switch (option) {
      GuideEventReminderOption.none => _text(
        context,
        pt: 'Sem lembrete',
        es: 'Sin recordatorio',
        en: 'No reminder',
      ),
      GuideEventReminderOption.twoHoursBefore => _text(
        context,
        pt: '2h antes',
        es: '2h antes',
        en: '2h before',
      ),
      GuideEventReminderOption.oneDayBefore => _text(
        context,
        pt: '1 dia antes',
        es: '1 día antes',
        en: '1 day before',
      ),
      GuideEventReminderOption.oneDayAndTwoHoursBefore => _text(
        context,
        pt: '1 dia + 2h',
        es: '1 día + 2h',
        en: '1 day + 2h',
      ),
    };
  }

  String _text(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    return switch (code) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    trailing!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickEditButton extends StatelessWidget {
  const _QuickEditButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
