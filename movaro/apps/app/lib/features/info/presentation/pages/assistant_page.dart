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
import 'package:movaro_app/core/widgets/practical_info_disclaimer.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/info/application/chat_service.dart';
import 'package:movaro_app/features/info/domain/entities/chat_message.dart';
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
        highlightedCityId: plan?.currentPlanCity?.id,
        currentPhase: _resolveCurrentPhase(progressSnapshot.activeItemId),
        completedItemIds: completedItemIds,
        migrationGoal: plan?.goal.isNotEmpty == true ? plan!.goal : null,
        planTimeline: plan?.timeline.isNotEmpty == true ? plan!.timeline : null,
      );
      // Prompts and answers are available immediately on device. The
      // assistant must never wait for the API or an AI provider to become
      // usable.
      _starterPrompts = _chatService!.localStarterPrompts();
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _AssistantTopBar(
                    mode: _mode,
                    originCountry: _resolvedOriginCountry,
                    destinationCountry: _resolvedDestinationCountry,
                    hasPlan:
                        widget.migrationQuestionnaireController.generatedPlan !=
                        null,
                    onModeChanged: (mode) => setState(() => _mode = mode),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: PracticalInfoDisclaimer(compact: true),
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
  const _ModeSegmentedControl({
    required this.mode,
    required this.onChanged,
    this.compact = false,
  });

  final _AssistantMode mode;
  final ValueChanged<_AssistantMode> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final conversationLabel = l10n.assistantModeConversation;
    final guidesLabel = l10n.assistantModeGuides;

    final control = SegmentedButton<_AssistantMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: _AssistantMode.conversation,
          label: Text(conversationLabel),
        ),
        ButtonSegment(value: _AssistantMode.guides, label: Text(guidesLabel)),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        textStyle: WidgetStateProperty.all(
          Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textPrimaryFor(context);
          }
          return Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.68);
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.surfaceFor(context);
          }
          return Colors.transparent;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: AppColors.borderFor(context));
          }
          return BorderSide(color: Colors.transparent);
        }),
        shadowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black.withValues(alpha: 0.06);
          }
          return Colors.transparent;
        }),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return 1;
          }
          return 0;
        }),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity(
          horizontal: compact ? -2 : -1,
          vertical: compact ? -2 : -1,
        ),
      ),
    );

    final framedControl = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: control,
    );

    if (compact) {
      return framedControl;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: framedControl,
    );
  }
}

class _AssistantTopBar extends StatelessWidget {
  const _AssistantTopBar({
    required this.mode,
    required this.originCountry,
    required this.destinationCountry,
    required this.hasPlan,
    required this.onModeChanged,
  });

  final _AssistantMode mode;
  final String originCountry;
  final String destinationCountry;
  final bool hasPlan;
  final ValueChanged<_AssistantMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$originCountry → $destinationCountry',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _ModeStatusPill(
                label: hasPlan
                    ? switch (locale) {
                        'es' => 'Con plan',
                        'en' => 'With plan',
                        _ => 'Com plano',
                      }
                    : switch (locale) {
                        'es' => 'Manual',
                        'en' => 'Manual',
                        _ => 'Manual',
                      },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ModeSegmentedControl(
            mode: mode,
            onChanged: onModeChanged,
            compact: true,
          ),
        ],
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
    this.initialMessage,
    super.key,
  });

  final ChatService? chatService;
  final ChatStarterPrompts? starterPrompts;
  final bool isInitializing;
  final String originCountry;
  final String destinationCountry;
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compactCategories.isNotEmpty) ...[
            Text(
              switch (Localizations.localeOf(context).languageCode) {
                'es' => 'Preguntá por tema',
                'en' => 'Ask by topic',
                _ => 'Pergunte por tema',
              },
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
                      isDark: isDark,
                      compact: false,
                      onTap: () => _send(c.message),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
          ],
          if (compactChips.isNotEmpty) ...[
            _PromptStrip(
              title: switch (Localizations.localeOf(context).languageCode) {
                'es' => 'Preguntas rápidas',
                'en' => 'Quick prompts',
                _ => 'Perguntas rápidas',
              },
              child: Wrap(
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
          width: compact ? null : 168,
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
                Icon(
                  icon,
                  size: compact ? 18 : 20,
                  color: const Color(0xFF0088FF),
                ),
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

class _PromptStrip extends StatelessWidget {
  const _PromptStrip({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          child,
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
