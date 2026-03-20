import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpStep {
  const HelpStep({required this.title, required this.body});

  final String title;
  final String body;
}

class HelpBottomSheet extends StatefulWidget {
  const HelpBottomSheet({
    required this.contextLabel,
    required this.contextIcon,
    required this.title,
    required this.description,
    required this.steps,
    required this.preferenceKey,
    this.dismissLabel = 'Agora nao',
    this.confirmLabel = 'Entendi',
    super.key,
  });

  final String contextLabel;
  final IconData contextIcon;
  final String title;
  final String description;
  final List<HelpStep> steps;
  final String preferenceKey;
  final String dismissLabel;
  final String confirmLabel;

  @override
  State<HelpBottomSheet> createState() => _HelpBottomSheetState();
}

class _HelpBottomSheetState extends State<HelpBottomSheet> {
  bool _doNotShowAgain = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          unawaited(_persistPreferenceIfNeeded());
        }
      },
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  top: BorderSide(color: Color(0xFF1E2636)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D333B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D2137),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Icon(
                                    widget.contextIcon,
                                    size: 12,
                                    color: const Color(0xFF58A6FF),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.contextLabel.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF58A6FF),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(right: 28),
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF0F6FC),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 12,
                        child: InkWell(
                          onTap: _isSaving ? null : _dismiss,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2128),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2D333B)),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF0D1117),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.description,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8B949E),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (var index = 0; index < widget.steps.length; index++)
                            _HelpStepRow(
                              index: index,
                              step: widget.steps[index],
                              isLast: index == widget.steps.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF0D1117),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 18 + safeBottom),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _isSaving
                              ? null
                              : () => setState(() {
                                    _doNotShowAgain = !_doNotShowAgain;
                                  }),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D2137),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFF1D4A70),
                                    ),
                                  ),
                                  child: _doNotShowAgain
                                      ? const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Color(0xFF58A6FF),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Nao mostrar novamente',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF6B7280),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving ? null : _dismiss,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1C2128),
                                  foregroundColor: const Color(0xFF9CA3AF),
                                  side: const BorderSide(color: Color(0xFF2D333B)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  textStyle: const TextStyle(fontSize: 9),
                                ),
                                child: Text(widget.dismissLabel),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: _isSaving ? null : _confirm,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F6FEB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  textStyle: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.check, size: 16),
                                label: Text(widget.confirmLabel),
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
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    await _persistPreferenceIfNeeded();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _dismiss() async {
    await _persistPreferenceIfNeeded();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _persistPreferenceIfNeeded() async {
    if (!_doNotShowAgain || _isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('help_${widget.preferenceKey}', true);
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

class _HelpStepRow extends StatelessWidget {
  const _HelpStepRow({
    required this.index,
    required this.step,
    required this.isLast,
  });

  final int index;
  final HelpStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2137),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1D4A70)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF58A6FF),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFF1E2636),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF0F6FC),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.body,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
