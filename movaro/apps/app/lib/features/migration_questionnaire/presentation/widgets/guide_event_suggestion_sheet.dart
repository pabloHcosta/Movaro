import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
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
  bool _showNotes = false;
  String? _errorMessage;

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
    final deadlineFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.74,
        child: Container(
          margin: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _text(
                          context,
                          pt: 'Adicionar ao calendário',
                          es: 'Agregar al calendario',
                          en: 'Add to calendar',
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
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
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    Text(
                      _draft.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _draft.assistantCopy,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoftFor(context),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaPill(
                          icon: Icons.calendar_today_rounded,
                          label: dateFormat.format(_draft.startAt),
                        ),
                        _MetaPill(
                          icon: Icons.schedule_rounded,
                          label: timeOfDay.format(context),
                        ),
                        _MetaPill(
                          icon: Icons.timelapse_rounded,
                          label: _durationLabel(
                            context,
                            _draft.suggestedDurationMinutes,
                          ),
                        ),
                        if (_draft.locationLabel case final location?)
                          _MetaPill(
                            icon: Icons.place_outlined,
                            label: location,
                          ),
                        if (_draft.hardDeadline != null)
                          _MetaPill(
                            icon: Icons.priority_high_rounded,
                            label: _text(
                              context,
                              pt: 'Prazo ${deadlineFormat.format(_draft.hardDeadline!)}',
                              es: 'Plazo ${deadlineFormat.format(_draft.hardDeadline!)}',
                              en: 'Deadline ${deadlineFormat.format(_draft.hardDeadline!)}',
                            ),
                            tone: _MetaPillTone.warning,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 14),
                    Text(
                      _text(
                        context,
                        pt: 'Lembrete',
                        es: 'Recordatorio',
                        en: 'Reminder',
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _showNotes = !_showNotes;
                                });
                              },
                        icon: Icon(
                          _showNotes
                              ? Icons.notes_rounded
                              : Icons.add_comment_outlined,
                          size: 18,
                        ),
                        label: Text(
                          _text(
                            context,
                            pt: _showNotes ? 'Esconder nota' : 'Adicionar nota',
                            es: _showNotes ? 'Ocultar nota' : 'Agregar nota',
                            en: _showNotes ? 'Hide note' : 'Add note',
                          ),
                        ),
                      ),
                    ),
                    if (_showNotes) ...[
                      const SizedBox(height: 4),
                      TextField(
                        controller: _notesController,
                        minLines: 1,
                        maxLines: 2,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: _text(
                            context,
                            pt: 'Nota opcional',
                            es: 'Nota opcional',
                            en: 'Optional note',
                          ),
                          hintText: _text(
                            context,
                            pt: 'Passaporte, comprovante, protocolo...',
                            es: 'Pasaporte, comprobante, constancia...',
                            en: 'Passport, receipt, protocol...',
                          ),
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : _handleAdd,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.event_available_rounded,
                                size: 18,
                              ),
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
                                pt: 'Depois',
                                es: 'Después',
                                en: 'Later',
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
                                      action:
                                          GuideEventSuggestionAction.skipped,
                                      suggestion: _draft,
                                      reminderOption: _reminderOption,
                                      notes: _trimmedNotes,
                                    ),
                                  ),
                            child: Text(
                              _text(
                                context,
                                pt: 'Pular',
                                es: 'Omitir',
                                en: 'Skip',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
    if (picked == null || !mounted) {
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
    if (picked == null || !mounted) {
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
      _errorMessage = null;
    });
    try {
      final added = await widget.onAddToCalendar(
        _draft,
        _reminderOption,
        _trimmedNotes,
      );
      if (!mounted) {
        return;
      }
      if (!added) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = _text(
            context,
            pt: 'Não foi possível abrir o calendário agora. Tente novamente em alguns segundos.',
            es: 'No fue posible abrir el calendario ahora. Inténtalo otra vez en unos segundos.',
            en: 'Could not open the calendar right now. Try again in a few seconds.',
          );
        });
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
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorMessage = _text(
          context,
          pt: 'O calendário do aparelho não respondeu. Feche e tente de novo.',
          es: 'El calendario del dispositivo no respondió. Cierra e inténtalo otra vez.',
          en: 'The device calendar did not respond. Close it and try again.',
        );
      });
    }
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.tone = _MetaPillTone.neutral,
  });

  final IconData icon;
  final String label;
  final _MetaPillTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (tone) {
      _MetaPillTone.neutral => scheme.surfaceContainerHighest,
      _MetaPillTone.warning => scheme.errorContainer,
    };
    final foreground = switch (tone) {
      _MetaPillTone.neutral => scheme.onSurfaceVariant,
      _MetaPillTone.warning => scheme.onErrorContainer,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MetaPillTone { neutral, warning }

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
