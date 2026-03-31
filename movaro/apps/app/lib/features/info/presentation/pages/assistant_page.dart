import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/info/application/chat_service.dart';
import 'package:movaro_app/features/info/application/gemini_chat_service.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';

enum _AssistantMode { conversation, guides }

/// The Assistant tab page — replaces the old InfoTab (slot 3).
///
/// Contains two modes via a [SegmentedButton]:
/// - Conversation: backend-mediated Movaro chat
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
  static const _assistantHelpKey = 'assistant_tab';
  _AssistantMode _mode = _AssistantMode.conversation;
  ChatService? _chatService;
  ChatStarterPrompts? _starterPrompts;
  bool _chatInitStarted = false;
  bool _isChatInitializing = false;
  final MigrationCopilotProgressStore _progressStore =
      MigrationCopilotProgressStore();

  String get _resolvedOriginCountry {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    return plan?.originCountry.isNotEmpty == true
        ? plan!.originCountry
        : widget.journeyContextController.selection.origin?.name ?? 'argentina';
  }

  String get _resolvedDestinationCountry {
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    return plan?.destinationCountry.isNotEmpty == true
        ? plan!.destinationCountry
        : widget.journeyContextController.selection.destination?.name ??
              'brasil';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_chatInitStarted) {
      _chatInitStarted = true;
      _initChatService();
    }
  }

  Future<void> _initChatService() async {
    setState(() => _isChatInitializing = true);
    final locale = Localizations.localeOf(context).languageCode;
    final plan = widget.migrationQuestionnaireController.generatedPlan;
    final originCountry = _resolvedOriginCountry;
    final destinationCountry = _resolvedDestinationCountry;

    try {
      final progressSnapshot = plan == null
          ? const MigrationCopilotProgressSnapshot()
          : await _progressStore.read(plan);
      final completedItemIds = progressSnapshot.getAllCompletedIds().toList()
        ..sort();

      _chatService = ChatService(
        networkClient: NetworkClient(environment: widget.environment),
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        locale: locale,
        recommendedCityId: plan?.recommendedCity?.id,
        currentPhase: _resolveCurrentPhase(progressSnapshot.activeItemId),
        completedItemIds: completedItemIds,
        migrationGoal: plan?.goal.isNotEmpty == true ? plan!.goal : null,
        planTimeline: plan?.timeline.isNotEmpty == true ? plan!.timeline : null,
      );
      try {
        _starterPrompts = await _chatService!.fetchStarterPrompts();
      } catch (e) {
        dev.log('[AssistantPage] Starter prompts unavailable: $e');
        _starterPrompts = null;
      }
      dev.log('[AssistantPage] ChatService ready ✓');
    } catch (e) {
      dev.log('[AssistantPage] ChatService init failed: $e');
      _chatService = null;
      _starterPrompts = null;
    } finally {
      if (mounted) {
        setState(() => _isChatInitializing = false);
      }
    }
  }

  String? _resolveCurrentPhase(String? activeItemId) {
    if (activeItemId == null || activeItemId.isEmpty) {
      return null;
    }
    if (activeItemId.startsWith('item_0_')) return 'preparation';
    if (activeItemId.startsWith('item_1_')) return 'housing';
    if (activeItemId.startsWith('item_2_')) return 'documents';
    if (activeItemId.startsWith('item_3_')) return 'work';
    if (activeItemId.startsWith('item_4_')) return 'arrival';
    return null;
  }

  Future<void> _showAssistantGuide() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _assistantHelpKey,
      content: _assistantHelpContent(context),
    );
  }

  ContextualHelpContent _assistantHelpContent(BuildContext context) {
    final l10n = context.l10n;
    final isConversation = _mode == _AssistantMode.conversation;
    final lang = Localizations.localeOf(context).languageCode;
    final title = isConversation
        ? l10n.aiChatTitle
        : l10n.documentationPageTitle;
    final body = switch ((isConversation, lang)) {
      (true, 'pt') =>
        'Faça perguntas diretas sobre mudança, documentos, custos e primeiros passos para receber respostas mais rápidas.',
      (true, 'es') =>
        'Hacé preguntas directas sobre mudanza, documentos, costos y primeros pasos para recibir respuestas más rápidas.',
      (true, _) =>
        'Ask direct questions about moving, documents, costs, and first steps to get faster answers.',
      (false, 'pt') =>
        'Use os guias para navegar por temas práticos e abrir o conteúdo certo sem ficar procurando sozinho.',
      (false, 'es') =>
        'Usá las guías para navegar por temas prácticos y abrir el contenido correcto sin buscar solo.',
      (false, _) =>
        'Use the guides to browse practical topics and open the right content without searching on your own.',
    };

    return ContextualHelpContent(
      eyebrow: l10n.infoGuideEyebrow,
      contextIcon: isConversation
          ? Icons.chat_bubble_outline_rounded
          : Icons.help_outline_rounded,
      title: title,
      body: body,
      steps: [
        FeatureGuideStep(
          number: '1',
          title: switch (lang) {
            'pt' => 'Comece pelo ponto real da sua dúvida',
            'es' => 'Empezá por el punto real de tu duda',
            _ => 'Start with the real point of your question',
          },
          body: switch (lang) {
            'pt' =>
              'Pergunte do jeito que você falaria com uma pessoa: custo, documentos, moradia ou trabalho.',
            'es' =>
              'Preguntá como hablarías con una persona: costo, documentos, vivienda o trabajo.',
            _ =>
              'Ask the way you would ask a person: costs, documents, housing, or work.',
          },
        ),
        FeatureGuideStep(
          number: '2',
          title: switch (lang) {
            'pt' => 'Use o modo certo para cada necessidade',
            'es' => 'Usá el modo correcto para cada necesidad',
            _ => 'Use the right mode for each need',
          },
          body: switch (lang) {
            'pt' =>
              'Conversa ajuda a tirar dúvidas rápidas. Guias ajuda a abrir conteúdo organizado por tema.',
            'es' =>
              'Conversación sirve para dudas rápidas. Guías sirve para abrir contenido organizado por tema.',
            _ =>
              'Conversation is best for quick questions. Guides are best for organized content by topic.',
          },
        ),
        FeatureGuideStep(
          number: '3',
          title: switch (lang) {
            'pt' => 'Refine quando precisar',
            'es' => 'Ajustá cuando haga falta',
            _ => 'Refine when needed',
          },
          body: switch (lang) {
            'pt' =>
              'Se a resposta vier ampla, complete com seu país de origem, destino ou momento da mudança.',
            'es' =>
              'Si la respuesta sale muy amplia, agregá tu país de origen, destino o momento de la mudanza.',
            _ =>
              'If the answer is too broad, add your origin country, destination, or moving stage.',
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark
          ? const Color(0xFF07090E)
          : const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: AppGlassHeader(
                    title: context.l10n.aiChatTitle,
                    onBack: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.publicHome,
                    ),
                    onHelp: _showAssistantGuide,
                  ),
                ),
                const SizedBox(height: 8),
                _ModeSegmentedControl(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _AssistantContextCard(
                    mode: _mode,
                    originCountry: _resolvedOriginCountry,
                    destinationCountry: _resolvedDestinationCountry,
                    hasPlan:
                        widget.migrationQuestionnaireController.generatedPlan !=
                        null,
                    onOpenGuides: () =>
                        setState(() => _mode = _AssistantMode.guides),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: IndexedStack(
                    index: _mode == _AssistantMode.conversation ? 0 : 1,
                    children: [
                      _ConversationBody(
                        key: const ValueKey('conversation'),
                        chatService: _chatService,
                        starterPrompts: _starterPrompts,
                        isInitializing: _isChatInitializing,
                        initialMessage: widget.initialMessage,
                        originCountry: _resolvedOriginCountry,
                        destinationCountry: _resolvedDestinationCountry,
                        onOpenGuides: () =>
                            setState(() => _mode = _AssistantMode.guides),
                      ),
                      DocumentationGuidePage(
                        key: const ValueKey('guides'),
                        environment: widget.environment,
                        embedded: true,
                        exchangeRatesService: widget.exchangeRatesService,
                        journeyContextController:
                            widget.journeyContextController,
                        migrationQuestionnaireController:
                            widget.migrationQuestionnaireController,
                        citiesController: widget.citiesController,
                      ),
                    ],
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

// ─── Segmented control ────────────────────────────────────────────────────────

class _ModeSegmentedControl extends StatelessWidget {
  const _ModeSegmentedControl({required this.mode, required this.onChanged});

  final _AssistantMode mode;
  final ValueChanged<_AssistantMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final conversationLabel = l10n.assistantModeConversation;
    final guidesLabel = l10n.assistantModeGuides;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<_AssistantMode>(
        segments: [
          ButtonSegment(
            value: _AssistantMode.conversation,
            label: Text(conversationLabel),
          ),
          ButtonSegment(value: _AssistantMode.guides, label: Text(guidesLabel)),
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
    required this.starterPrompts,
    required this.isInitializing,
    required this.originCountry,
    required this.destinationCountry,
    required this.onOpenGuides,
    this.initialMessage,
    super.key,
  });

  final ChatService? chatService;
  final ChatStarterPrompts? starterPrompts;
  final bool isInitializing;
  final String originCountry;
  final String destinationCountry;
  final VoidCallback onOpenGuides;
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
    _streamSub = widget.chatService!
        .sendMessage(trimmed)
        .listen(
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

  Widget _buildEmptyState(BuildContext context, dynamic l10n, bool isDark) {
    final categories =
        widget.starterPrompts?.categories ?? const <ChatStarterPrompt>[];
    final chips = widget.starterPrompts?.chips ?? const <ChatStarterPrompt>[];
    final compactCategories = categories.take(4).toList(growable: false);
    final compactChips = chips.take(4).toList(growable: false);

    final isDark2 = isDark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConversationRoutePanel(
            originCountry: widget.originCountry,
            destinationCountry: widget.destinationCountry,
            onOpenGuides: widget.onOpenGuides,
          ),
          const SizedBox(height: 16),
          if (compactCategories.isNotEmpty) ...[
            Text(
              l10n.assistantQuickTopicsTitle,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: compactCategories
                  .map(
                    (c) => _CategoryCard(
                      icon: _categoryIcon(c.key),
                      label: c.label,
                      isDark: isDark2,
                      compact: true,
                      onTap: () => _send(c.message),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (compactChips.isNotEmpty) ...[
            Text(
              l10n.assistantQuickQuestionsTitle,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: compactChips
                  .map(
                    (chip) => _QuickChip(
                      label: chip.label,
                      onTap: () => _send(chip.message),
                    ),
                  )
                  .toList(),
              ),
            ],
          if (compactCategories.isEmpty && compactChips.isEmpty)
            Text(
              l10n.aiChatInputHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _categoryIcon(String key) {
    return switch (key) {
      'documents' => Icons.description_outlined,
      'costs' => Icons.account_balance_wallet_outlined,
      'activities' => Icons.explore_outlined,
      'stay' => Icons.home_outlined,
      _ => Icons.chat_bubble_outline,
    };
  }

  Widget _buildMessages(
    List<ChatMessage> messages,
    Color messageBg,
    Color userBubbleBg,
    bool isDark,
  ) {
    final allMessages = [...messages];
    final visibleMessages =
        _isStreaming &&
            allMessages.isNotEmpty &&
            allMessages.last.role == 'assistant'
        ? allMessages.sublist(0, allMessages.length - 1)
        : allMessages;
    final showStreamingBubble = _isStreaming && _streamingText.isNotEmpty;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount:
          visibleMessages.length +
          (showStreamingBubble ? 1 : 0) +
          (_isStreaming && _streamingText.isEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isStreaming &&
            _streamingText.isEmpty &&
            index == visibleMessages.length) {
          return _buildTypingIndicator(isDark);
        }
        if (showStreamingBubble && index == visibleMessages.length) {
          return _buildBubble(
            text: _streamingText,
            isUser: false,
            messageBg: messageBg,
            userBubbleBg: userBubbleBg,
            isDark: isDark,
          );
        }
        if (index >= visibleMessages.length) return const SizedBox.shrink();

        final msg = visibleMessages[index];
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
        16,
        8,
        8,
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
    this.compact = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final bool compact;
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
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: compact ? 0 : 120),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: compact ? 18 : 20, color: const Color(0xFF0088FF)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: cs.primary),
          ),
        ),
      ),
    );
  }
}

class _AssistantContextCard extends StatelessWidget {
  const _AssistantContextCard({
    required this.mode,
    required this.originCountry,
    required this.destinationCountry,
    required this.hasPlan,
    required this.onOpenGuides,
  });

  final _AssistantMode mode;
  final String originCountry;
  final String destinationCountry;
  final bool hasPlan;
  final VoidCallback onOpenGuides;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isConversation = mode == _AssistantMode.conversation;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isConversation ? Icons.chat_bubble_outline_rounded : Icons.map_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConversation
                      ? l10n.assistantContextChatTitle
                      : l10n.assistantContextGuideTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  isConversation
                      ? l10n.assistantContextChatBody(
                          originCountry,
                          destinationCountry,
                        )
                      : l10n.assistantContextGuideBody(destinationCountry),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isConversation)
            TextButton(
              onPressed: onOpenGuides,
              child: Text(l10n.assistantOpenGuidesAction),
            )
          else
            _ModeStatusPill(
              label: hasPlan
                  ? l10n.documentationGuideUsingPlanLabel
                  : l10n.documentationGuideManualCountryLabel,
            ),
        ],
      ),
    );
  }
}

class _ConversationRoutePanel extends StatelessWidget {
  const _ConversationRoutePanel({
    required this.originCountry,
    required this.destinationCountry,
    required this.onOpenGuides,
  });

  final String originCountry;
  final String destinationCountry;
  final VoidCallback onOpenGuides;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.assistantStartCardTitle,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.assistantStartCardBody(originCountry, destinationCountry),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onOpenGuides,
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(l10n.assistantOpenGuidesAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeStatusPill extends StatelessWidget {
  const _ModeStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
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
