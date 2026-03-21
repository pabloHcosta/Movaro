import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/core/config/api_keys.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/features/info/application/chat_context_remote_service.dart';
import 'package:movaro_app/features/info/application/gemini_chat_service.dart';
import 'package:movaro_app/features/info/presentation/widgets/ai_chat_sheet.dart';

/// A persistent bottom sheet anchored above the navigation bar that gives
/// the user a quick gateway to the Gemini-powered assistant.
///
/// Collapsed state (~170 px): handle + header + tip card + input.
/// Expanded state (~80 % screen): header + welcome + chips + category grid + input.
class AssistantBottomSheet extends StatefulWidget {
  const AssistantBottomSheet({
    required this.destination,
    required this.originCountry,
    required this.destinationCountry,
    required this.environment,
    this.userContext = const UserMigrationContext(),
    super.key,
  });

  /// Human-readable city / destination name shown in the welcome message.
  final String destination;

  /// Raw country IDs used when initialising the chat service.
  final String originCountry;
  final String destinationCountry;

  /// App environment used to build the NetworkClient for the context API call.
  final AppEnvironment environment;

  /// Migration context injected into the AI system prompt.
  final UserMigrationContext userContext;

  @override
  State<AssistantBottomSheet> createState() => _AssistantBottomSheetState();
}

class _AssistantBottomSheetState extends State<AssistantBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  double _dragDelta = 0;
  GeminiChatService? _chatService;
  bool _isInitializing = false;
  bool _chatInitStarted = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context.l10n / Localizations requires an inherited widget — safe here.
    if (!_chatInitStarted && ApiKeys.hasGeminiApiKey) {
      _chatInitStarted = true;
      _isInitializing = true;
      _initChatService();
    }
  }

  Future<void> _initChatService() async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

    // Fetch real app data from the backend (city metrics + guide phase items).
    // Falls back to empty string on network error — chat still works.
    final contextService = ChatContextRemoteService(
      networkClient: NetworkClient(environment: widget.environment),
    );
    final contextResult = await contextService.fetchContext(
      originCountry: widget.originCountry,
      destinationCountry: widget.destinationCountry,
      userContext: widget.userContext,
      locale: locale,
    );

    if (!mounted) return;

    _chatService = GeminiChatService(apiKey: ApiKeys.geminiApiKey);
    _chatService!.initialize(
      curatedContent: contextResult?.appDataBlock ?? '',
      originCountry: widget.originCountry,
      destinationCountry: widget.destinationCountry,
      locale: locale,
      userContext: widget.userContext,
      errorMessages: ChatErrorMessages(
        notInitialized: l10n.aiChatNotInitialized,
        rateLimit: l10n.aiChatErrorRateLimit,
        apiLimit: l10n.aiChatErrorApiLimit,
        generic: l10n.aiChatErrorGeneric,
      ),
    );
    if (mounted) setState(() => _isInitializing = false);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    _animController.forward();
  }

  void _collapse() {
    setState(() => _expanded = false);
    _animController.reverse();
  }

  void _toggle() => _expanded ? _collapse() : _expand();

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    _dragDelta += d.primaryDelta ?? 0;
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (!_expanded && (velocity < -200 || _dragDelta < -30)) {
      _expand();
    } else if (_expanded && (velocity > 200 || _dragDelta > 30)) {
      _collapse();
    }
    _dragDelta = 0;
  }

  void _openChat(String message) {
    if (_isInitializing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.aiChatRetry),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_chatService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.aiChatUnavailable),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showAiChatSheet(
      context,
      chatService: _chatService!,
      initialMessage: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _expandAnim,
      builder: (context, child) {
        const collapsedH = 200.0;
        // Available viewport above the nav bar pill, excluding the status bar.
        // Scaffold(extendBody:true) removed padding.bottom from the body's
        // MediaQuery, so the Stack extends to the screen bottom. Use
        // viewPadding.bottom (never consumed) + pill offset to match the
        // Positioned(bottom:) value in PublicHomePage.
        final safeBottom = MediaQuery.of(context).viewPadding.bottom;
        final sheetBottomOffset = safeBottom + 14.0 + 73.0;
        final topPad = MediaQuery.of(context).padding.top;
        final usableH = screenHeight - topPad - sheetBottomOffset;
        final expandedH = usableH * 0.90;
        final height = collapsedH + (expandedH - collapsedH) * _expandAnim.value;

        return GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: SizedBox(
            height: height,
            child: _SheetSurface(
              child: Column(
                children: [
                  _Handle(onTap: _toggle),
                  _Header(
                    expanded: _expanded,
                    expandAnim: _expandAnim,
                    l10n: l10n,
                    destination: widget.destination,
                  ),
                  Expanded(
                    child: _expanded
                        ? _ExpandedContent(
                            l10n: l10n,
                            destination: widget.destination,
                            onChip: _openChat,
                            chatService: _chatService,
                            isInitializing: _isInitializing,
                          )
                        : _CollapsedContent(
                            l10n: l10n,
                            chatService: _chatService,
                            isInitializing: _isInitializing,
                            onNotReady: _openChat,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Surface ─────────────────────────────────────────────────────────────────

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        children: [
          // Background fill
          Positioned.fill(child: ColoredBox(color: const Color(0xF00E1D33))),
          // Content
          child,
          // Top accent border (blue)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            ),
          ),
          // Left edge border
          Positioned(
            top: 0, left: 0, bottom: 0,
            child: Container(
              width: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          // Right edge border
          Positioned(
            top: 0, right: 0, bottom: 0,
            child: Container(
              width: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Handle ──────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.expanded,
    required this.expandAnim,
    required this.l10n,
    required this.destination,
  });

  final bool expanded;
  final Animation<double> expandAnim;
  final dynamic l10n;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _Avatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeAssistantTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: expanded
                      ? Text(
                          l10n.homeAssistantSubtitle,
                          key: const ValueKey('sub'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                        )
                      : const SizedBox.shrink(key: ValueKey('nosub')),
                ),
              ],
            ),
          ),
          if (!expanded)
            Text(
              l10n.homeAssistantSwipeHint,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF4FC3F7).withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
    );
  }
}

// ─── Collapsed content ───────────────────────────────────────────────────────

class _CollapsedContent extends StatefulWidget {
  const _CollapsedContent({
    required this.l10n,
    required this.chatService,
    required this.isInitializing,
    required this.onNotReady,
  });
  final dynamic l10n;
  final GeminiChatService? chatService;
  final bool isInitializing;
  final void Function(String) onNotReady;

  @override
  State<_CollapsedContent> createState() => _CollapsedContentState();
}

class _CollapsedContentState extends State<_CollapsedContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Delegate to parent which handles loading/unavailable feedback
    widget.onNotReady(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          _TipCard(l10n: widget.l10n),
          const SizedBox(height: 10),
          _InputRow(
            controller: _controller,
            placeholder: widget.isInitializing
                ? context.l10n.aiChatLoading
                : widget.chatService != null
                    ? widget.l10n.homeAssistantInputPlaceholder
                    : context.l10n.aiChatUnavailable,
            onSend: _send,
            enabled: true, // always tappable — feedback shown by parent
            isLoading: widget.isInitializing,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.l10n});
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4FC3F7).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              size: 16, color: Color(0xFF4FC3F7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loco(context, l10n),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String loco(BuildContext context, dynamic l10n) {
    final lang = Localizations.localeOf(context).languageCode;
    return switch (lang) {
      'pt' => 'Dica do dia: O CPF é o documento mais importante para se estabelecer no Brasil.',
      'es' => 'Consejo del día: El CPF es el documento más importante para establecerte en Brasil.',
      _ => 'Tip of the day: The CPF is the most important document to settle in Brazil.',
    };
  }
}

// ─── Expanded content ─────────────────────────────────────────────────────────

class _ExpandedContent extends StatefulWidget {
  const _ExpandedContent({
    required this.l10n,
    required this.destination,
    required this.onChip,
    required this.chatService,
    required this.isInitializing,
  });

  final dynamic l10n;
  final String destination;
  final void Function(String) onChip;
  final GeminiChatService? chatService;
  final bool isInitializing;

  @override
  State<_ExpandedContent> createState() => _ExpandedContentState();
}

class _ExpandedContentState extends State<_ExpandedContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onChip(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final dest = widget.destination;

    final chips = [
      l10n.homeAssistantChipVisa,
      l10n.homeAssistantChipBestTime,
      l10n.homeAssistantChipPacking,
      l10n.homeAssistantChipSafety,
      l10n.homeAssistantChipHowToGet,
    ];

    final categories = [
      (emoji: '🛂', label: l10n.homeAssistantCategoryDocuments,
        message: l10n.homeAssistantMessageDocuments(dest)),
      (emoji: '💰', label: l10n.homeAssistantCategoryCosts,
        message: l10n.homeAssistantMessageCosts(dest)),
      (emoji: '🏖️', label: l10n.homeAssistantCategoryActivities,
        message: l10n.homeAssistantMessageActivities(dest)),
      (emoji: '🏨', label: l10n.homeAssistantCategoryStay,
        message: l10n.homeAssistantMessageStay(dest)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome bubble
          _WelcomeBubble(l10n: l10n, destination: dest),
          const SizedBox(height: 16),

          // Quick questions chips
          _SectionLabel(l10n.homeAssistantSectionQuickQuestions),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _Chip(
                label: chips[i],
                onTap: () => widget.onChip(chips[i]),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Divider(color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 12),

          // Explore by topic 2x2 grid
          _SectionLabel(l10n.homeAssistantSectionExploreTopics),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: categories
                .map(
                  (c) => _CategoryCard(
                    emoji: c.emoji,
                    label: c.label,
                    onTap: () => widget.onChip(c.message),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Input
          _InputRow(
            controller: _controller,
            placeholder: widget.isInitializing
                ? context.l10n.aiChatLoading
                : l10n.homeAssistantInputPlaceholderExpanded,
            onSend: _send,
            enabled: true,
            isLoading: widget.isInitializing,
          ),
        ],
      ),
    );
  }
}

class _WelcomeBubble extends StatelessWidget {
  const _WelcomeBubble({required this.l10n, required this.destination});
  final dynamic l10n;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4FC3F7).withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(
          color: const Color(0xFF4FC3F7).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.homeAssistantWelcome(destination),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.35),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
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
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared input row ─────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.placeholder,
    required this.onSend,
    required this.enabled,
    this.isLoading = false,
  });

  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onSend;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
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
                  horizontal: 16,
                  vertical: 11,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: isLoading
              ? Colors.grey.shade700
              : enabled
                  ? const Color(0xFF0288D1)
                  : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: isLoading ? null : (enabled ? onSend : null),
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 40,
              height: 40,
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
