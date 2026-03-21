import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/info/application/gemini_chat_service.dart';

/// Opens the AI chat bottom sheet.
Future<void> showAiChatSheet(
  BuildContext context, {
  required GeminiChatService chatService,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _AiChatSheet(chatService: chatService),
  );
}

class _AiChatSheet extends StatefulWidget {
  const _AiChatSheet({required this.chatService});

  final GeminiChatService chatService;

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isStreaming = false;
  String _streamingText = '';
  StreamSubscription<String>? _streamSub;

  @override
  void dispose() {
    _streamSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isStreaming) return;

    _controller.clear();
    setState(() {
      _isStreaming = true;
      _streamingText = '';
    });

    _scrollToBottom();

    _streamSub?.cancel();
    _streamSub = widget.chatService.sendMessage(trimmed).listen(
      (chunk) {
        if (!mounted) return;
        setState(() => _streamingText += chunk);
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _isStreaming = false);
        _scrollToBottom();
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isStreaming = false);
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;
    final messages = widget.chatService.history;
    final suggestions = _suggestedQuestions(l10n);

    final sheetBackground = isDark
        ? const Color(0xFF0B1120)
        : const Color(0xFFF8FAFC);
    final messageBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    const userBubbleBg = Color(0xFF0088FF);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0088FF), Color(0xFF00BBFF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aiChatTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.aiChatSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (messages.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      widget.chatService.clearHistory();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textSoftFor(context),
                    ),
                    tooltip: l10n.aiChatClearTooltip,
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Messages area
          Expanded(
            child: messages.isEmpty && !_isStreaming
                ? _buildSuggestions(l10n, suggestions, isDark)
                : _buildMessages(messages, messageBg, userBubbleBg, isDark),
          ),

          // Input area
          Container(
            padding: EdgeInsets.fromLTRB(
              16, 12, 8,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: messageBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: l10n.aiChatInputHint,
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _isStreaming
                      ? Colors.grey
                      : const Color(0xFF0088FF),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _isStreaming
                        ? null
                        : () => _send(_controller.text),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Icon(
                        _isStreaming
                            ? Icons.more_horiz
                            : Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _suggestedQuestions(AppLocalizations l10n) => [
    l10n.aiChatSuggestPassport,
    l10n.aiChatSuggestCpf,
    l10n.aiChatSuggestSus,
    l10n.aiChatSuggestWork,
    l10n.aiChatSuggestCosts,
    l10n.aiChatSuggestLicense,
  ];

  Widget _buildSuggestions(
    AppLocalizations l10n,
    List<String> suggestions,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0088FF), Color(0xFF00BBFF)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.aiChatWelcomeTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.aiChatWelcomeBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Material(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _send(suggestions[index]),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: AppColors.textSoftFor(context),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              suggestions[index],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.textSoftFor(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(
    List<ChatMessage> messages,
    Color messageBg,
    Color userBubbleBg,
    bool isDark,
  ) {
    final allMessages = [...messages];
    final showStreamingBubble = _isStreaming && _streamingText.isNotEmpty;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: allMessages.length + (showStreamingBubble ? 1 : 0) +
          (_isStreaming && _streamingText.isEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isStreaming && _streamingText.isEmpty &&
            index == allMessages.length) {
          return _buildTypingIndicator(isDark);
        }

        if (showStreamingBubble && index == allMessages.length) {
          return _buildBubble(
            text: _streamingText,
            isUser: false,
            messageBg: messageBg,
            userBubbleBg: userBubbleBg,
            isDark: isDark,
          );
        }

        if (index >= allMessages.length) {
          return const SizedBox.shrink();
        }

        final msg = allMessages[index];
        return _buildBubble(
          text: msg.text,
          isUser: msg.role == 'user',
          messageBg: messageBg,
          userBubbleBg: userBubbleBg,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildBubble({
    required String text,
    required bool isUser,
    required Color messageBg,
    required Color userBubbleBg,
    required bool isDark,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? userBubbleBg : messageBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DotPulse(color: AppColors.textSoftFor(context)),
          ],
        ),
      ),
    );
  }
}

class _DotPulse extends StatefulWidget {
  const _DotPulse({required this.color});
  final Color color;

  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (1 - (t - 0.5).abs() * 2).clamp(0.3, 1.0);
            return Container(
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
