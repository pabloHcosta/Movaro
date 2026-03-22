import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/info/application/chat_service.dart';
import 'package:movaro_app/features/info/application/gemini_chat_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';

enum _AssistantMode { conversation, guides }

/// The Assistant tab page — replaces the old InfoTab (slot 3).
///
/// Contains two modes via a [SegmentedButton]:
/// - Conversation: Gemini-powered chat
/// - Guias: the existing [DocumentationGuidePage] content (embedded)
class AssistantPage extends StatefulWidget {
  const AssistantPage({
    required this.environment,
    required this.journeyContextController,
    required this.migrationQuestionnaireController,
    required this.citiesController,
    required this.exchangeRatesService,
    this.initialMessage,
    super.key,
  });

  final AppEnvironment environment;
  final JourneyContextController journeyContextController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final CitiesController citiesController;
  final CopilotExchangeRatesService exchangeRatesService;

  /// When non-null, the conversation mode auto-sends this message on mount.
  final String? initialMessage;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  _AssistantMode _mode = _AssistantMode.conversation;
  ChatService? _chatService;
  bool _chatInitStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_chatInitStarted) {
      _chatInitStarted = true;
      _initChatService();
    }
  }

  void _initChatService() {
    final locale = Localizations.localeOf(context).languageCode;
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final originCountry =
        plan?.originCountry.isNotEmpty == true
            ? plan!.originCountry
            : widget.journeyContextController.selection.origin?.name ??
                'argentina';
    final destinationCountry =
        plan?.destinationCountry.isNotEmpty == true
            ? plan!.destinationCountry
            : widget.journeyContextController.selection.destination?.name ??
                'brasil';

    try {
      _chatService = ChatService(
        networkClient: NetworkClient(environment: widget.environment),
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        locale: locale,
        recommendedCityId: plan?.recommendedCity != null
            ? _toKebabCase(plan!.recommendedCity!.name)
            : null,
      );
      dev.log('[AssistantPage] ChatService ready ✓');
    } catch (e) {
      dev.log('[AssistantPage] ChatService init failed: $e');
      _chatService = null;
    }
  }

  static String _toKebabCase(String name) {
    const accents = 'àáâãäåæçèéêëìíîïðñòóôõöùúûüýÿ'
        'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝŸ';
    const normalized = 'aaaaaaaceeeeiiiidnoooooouuuuyy'
        'aaaaaaaceeeeiiiidnoooooouuuuyy';
    var result = name.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], normalized[i]);
    }
    return result
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final city =
        plan?.isCityConfirmed == true ? plan?.recommendedCity : null;
    final subtitle = city != null
        ? '${city.name} · ${plan!.originCountry} → ${plan.destinationCountry}'
        : null;

    return Scaffold(
      extendBody: true,
      backgroundColor:
          isDark ? const Color(0xFF07090E) : const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AssistantHeader(subtitle: subtitle),
                const SizedBox(height: 8),
                _ModeSegmentedControl(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _mode == _AssistantMode.conversation
                      ? _ConversationBody(
                          key: const ValueKey('conversation'),
                          chatService: _chatService,
                          isInitializing: false,
                          initialMessage: widget.initialMessage,
                        )
                      : DocumentationGuidePage(
                          key: const ValueKey('guides'),
                          embedded: true,
                          exchangeRatesService: widget.exchangeRatesService,
                          journeyContextController:
                              widget.journeyContextController,
                          migrationQuestionnaireController:
                              widget.migrationQuestionnaireController,
                          citiesController: widget.citiesController,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 3,
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController:
            widget.migrationQuestionnaireController,
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader({this.subtitle});
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = switch (lang) {
      'pt' => 'Assistente Movaro',
      'es' => 'Asistente Movaro',
      _ => 'Movaro Assistant',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Segmented control ────────────────────────────────────────────────────────

class _ModeSegmentedControl extends StatelessWidget {
  const _ModeSegmentedControl({
    required this.mode,
    required this.onChanged,
  });

  final _AssistantMode mode;
  final ValueChanged<_AssistantMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final conversationLabel = switch (lang) {
      'pt' => '💬 Conversa',
      'es' => '💬 Conversación',
      _ => '💬 Chat',
    };
    final guidesLabel = switch (lang) {
      'pt' => '📋 Guias',
      'es' => '📋 Guías',
      _ => '📋 Guides',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<_AssistantMode>(
        segments: [
          ButtonSegment(
            value: _AssistantMode.conversation,
            label: Text(conversationLabel),
          ),
          ButtonSegment(
            value: _AssistantMode.guides,
            label: Text(guidesLabel),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (s) => onChanged(s.first),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity(horizontal: -1, vertical: -1),
        ),
      ),
    );
  }
}

// ─── Conversation body ────────────────────────────────────────────────────────

class _ConversationBody extends StatefulWidget {
  const _ConversationBody({
    required this.chatService,
    required this.isInitializing,
    this.initialMessage,
    super.key,
  });

  final ChatService? chatService;
  final bool isInitializing;
  final String? initialMessage;

  @override
  State<_ConversationBody> createState() => _ConversationBodyState();
}

class _ConversationBodyState extends State<_ConversationBody> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isStreaming = false;
  String _streamingText = '';
  StreamSubscription<String>? _streamSub;
  bool _didSendInitial = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.chatService != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSendInitial());
    }
  }

  @override
  void didUpdateWidget(_ConversationBody old) {
    super.didUpdateWidget(old);
    // chatService may have been null on first build (initializing) — try again.
    if (!_didSendInitial &&
        widget.initialMessage != null &&
        widget.chatService != null &&
        old.chatService == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSendInitial());
    }
  }

  void _maybeSendInitial() {
    if (_didSendInitial) return;
    _didSendInitial = true;
    _send(widget.initialMessage!);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isStreaming) return;
    if (widget.chatService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.aiChatUnavailable),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    _controller.clear();
    setState(() {
      _isStreaming = true;
      _streamingText = '';
    });
    _scrollToBottom();

    _streamSub?.cancel();
    _streamSub = widget.chatService!.sendMessage(trimmed).listen(
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
        setState(() {
          _isStreaming = false;
          _streamingText = context.l10n.aiChatNetworkError;
        });
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
    final messages = widget.chatService?.history ?? [];
    final messageBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    const userBubbleBg = Color(0xFF0088FF);

    return Column(
      children: [
        // Messages / empty state
        Expanded(
          child: messages.isEmpty && !_isStreaming
              ? _buildEmptyState(context, l10n, isDark)
              : _buildMessages(messages, messageBg, userBubbleBg, isDark),
        ),

        // Input bar
        _ChatInputBar(
          controller: _controller,
          isStreaming: _isStreaming,
          isInitializing: widget.isInitializing,
          onSend: () => _send(_controller.text),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    dynamic l10n,
    bool isDark,
  ) {
    final lang = Localizations.localeOf(context).languageCode;

    final categories = [
      (
        icon: Icons.description_outlined,
        label: l10n.homeAssistantCategoryDocuments as String,
        message: switch (lang) {
          'pt' => 'Quais documentos preciso para migrar? Explique vistos e CPF.',
          'es' => '¿Qué documentos necesito para migrar? Explica visas y CPF.',
          _ => 'What documents do I need to migrate? Explain visas and CPF.',
        },
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        label: l10n.homeAssistantCategoryCosts as String,
        message: switch (lang) {
          'pt' => 'Quanto custa se mudar? Me dê uma visão geral dos custos.',
          'es' => '¿Cuánto cuesta mudarse? Dame una visión general de los costos.',
          _ => 'How much does it cost to move? Give me a cost overview.',
        },
      ),
      (
        icon: Icons.explore_outlined,
        label: l10n.homeAssistantCategoryActivities as String,
        message: switch (lang) {
          'pt' => 'O que devo saber sobre a vida na cidade destino?',
          'es' => '¿Qué debo saber sobre la vida en la ciudad destino?',
          _ => 'What should I know about life in the destination city?',
        },
      ),
      (
        icon: Icons.home_outlined,
        label: l10n.homeAssistantCategoryStay as String,
        message: switch (lang) {
          'pt' => 'Como encontrar moradia no Brasil? Dicas para alugar.',
          'es' => '¿Cómo encontrar vivienda en Brasil? Consejos para alquilar.',
          _ => 'How to find housing in Brazil? Tips for renting.',
        },
      ),
    ];

    final chips = [
      l10n.homeAssistantChipVisa as String,
      l10n.homeAssistantChipBestTime as String,
      l10n.aiChatSuggestCpf as String,
    ];

    final isDark2 = isDark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2x2 grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.0,
            children: categories.map((c) => _CategoryCard(
              icon: c.icon,
              label: c.label,
              isDark: isDark2,
              onTap: () => _send(c.message),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Quick chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _QuickChip(
                label: chips[i],
                onTap: () => _send(chips[i]),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: allMessages.length +
          (showStreamingBubble ? 1 : 0) +
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
        if (index >= allMessages.length) return const SizedBox.shrink();

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
            color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
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
          children: [_DotPulse(color: AppColors.textSoftFor(context))],
        ),
      ),
    );
  }
}

// ─── Chat input bar ───────────────────────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.isStreaming,
    required this.isInitializing,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isStreaming;
  final bool isInitializing;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final messageBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 8, 8,
        MediaQuery.of(context).padding.bottom + 8,
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
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: isInitializing
                      ? l10n.aiChatLoading
                      : l10n.aiChatInputHint,
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
            color: isStreaming || isInitializing
                ? Colors.grey
                : const Color(0xFF0088FF),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: (isStreaming || isInitializing) ? null : onSend,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  isStreaming ? Icons.more_horiz : Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF0088FF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
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

// ─── Quick chip ───────────────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dot pulse (typing indicator) ────────────────────────────────────────────

class _DotPulse extends StatefulWidget {
  const _DotPulse({required this.color});
  final Color color;

  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.2;
          final t = (_ctrl.value - delay).clamp(0.0, 1.0);
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
      ),
    );
  }
}
