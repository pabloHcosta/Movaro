import 'package:flutter/material.dart';
import 'package:movaro_app/core/config/api_keys.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/contextual_help.dart';
import 'package:movaro_app/core/widgets/feature_guide_dialog.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/explore/application/services/documentation_guide_preferences_store.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_decision_support_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_entry_cost_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/housing_soft_landing_section.dart';
import 'package:movaro_app/features/explore/presentation/widgets/practical_cost_estimator.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/info/application/gemini_chat_service.dart';
import 'package:movaro_app/features/info/presentation/widgets/ai_chat_sheet.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';

enum DocumentationGuideSection {
  documents,
  housing,
  health,
  work,
  driving,
  costs,
}

class DocumentationGuidePage extends StatefulWidget {
  const DocumentationGuidePage({
    required this.exchangeRatesService,
    this.initialSection,
    this.journeyContextController,
    this.migrationQuestionnaireController,
    this.citiesController,
    this.showAsTab = false,
    super.key,
  });

  final CopilotExchangeRatesService exchangeRatesService;
  final DocumentationGuideSection? initialSection;
  final JourneyContextController? journeyContextController;
  final MigrationQuestionnaireController? migrationQuestionnaireController;

  /// When non-null, a [MainNavigationBar] is shown at the bottom.
  final CitiesController? citiesController;

  /// When `true`, the page acts as a primary tab (shows nav bar + AI chat FAB).
  final bool showAsTab;

  @override
  State<DocumentationGuidePage> createState() => _DocumentationGuidePageState();
}

class _DocumentationGuidePageState extends State<DocumentationGuidePage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final DocumentationGuidePreferencesStore _preferencesStore;
  final GlobalKey _resultsKey = GlobalKey();
  String _searchQuery = '';
  DocumentationGuideSection? _selectedSection;
  bool _didTryAutoGuide = false;
  bool _showScrollHint = false;
  String? _selectedCountryId;
  GeminiChatService? _chatService;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _preferencesStore = DocumentationGuidePreferencesStore();
    _selectedSection = widget.initialSection;
    widget.journeyContextController?.initialize();
    if (widget.showAsTab && ApiKeys.hasGeminiApiKey) {
      _initChatService();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScrollHint();
      if (widget.showAsTab) {
        _maybeShowInfoGuide();
      } else {
        _maybeShowGuide();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _maybeShowGuide() async {
    if (_didTryAutoGuide) {
      return;
    }
    _didTryAutoGuide = true;

    final shouldShowGuide = await _preferencesStore.shouldShowGuide();
    if (!mounted || !shouldShowGuide) {
      return;
    }

    await _preferencesStore.markIntroSeen();
    await _showGuideModal();
  }

  static const _infoHelpKey = 'info_tab';

  Future<void> _maybeShowInfoGuide() async {
    if (_didTryAutoGuide) return;
    _didTryAutoGuide = true;
    await maybeShowContextualHelpGuide(
      context,
      preferenceKey: _infoHelpKey,
      content: _infoHelpContent(context),
    );
  }

  Future<void> _showInfoGuide() {
    return showContextualHelpGuide(
      context,
      preferenceKey: _infoHelpKey,
      content: _infoHelpContent(context),
    );
  }

  ContextualHelpContent _infoHelpContent(BuildContext context) {
    final l10n = context.l10n;
    return ContextualHelpContent(
      eyebrow: l10n.infoGuideEyebrow,
      contextIcon: Icons.info_outline_rounded,
      title: l10n.infoGuideTitle,
      body: l10n.infoGuideBody,
      steps: [
        FeatureGuideStep(
          number: '1',
          title: l10n.infoGuideStepOneTitle,
          body: l10n.infoGuideStepOneBody,
        ),
        FeatureGuideStep(
          number: '2',
          title: l10n.infoGuideStepTwoTitle,
          body: l10n.infoGuideStepTwoBody,
        ),
        FeatureGuideStep(
          number: '3',
          title: l10n.infoGuideStepThreeTitle,
          body: l10n.infoGuideStepThreeBody,
        ),
      ],
    );
  }

  void _initChatService() {
    final origin =
        widget.journeyContextController?.selection.origin?.name ?? 'Argentina';
    final destination =
        widget.journeyContextController?.selection.destination?.name ??
        'Brasil';

    _chatService = GeminiChatService(apiKey: ApiKeys.geminiApiKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = context.l10n;
      final answers = _guideQuickAnswers(context);
      final buffer = StringBuffer();
      for (final a in answers) {
        buffer.writeln('Q: ${a.question}');
        buffer.writeln('A: ${a.answer}');
        buffer.writeln();
      }
      final locale = Localizations.localeOf(context).languageCode;
      _chatService!.initialize(
        curatedContent: buffer.toString(),
        originCountry: origin,
        destinationCountry: destination,
        locale: locale,
        errorMessages: ChatErrorMessages(
          notInitialized: l10n.aiChatNotInitialized,
          rateLimit: l10n.aiChatErrorRateLimit,
          apiLimit: l10n.aiChatErrorApiLimit,
          generic: l10n.aiChatErrorGeneric,
        ),
      );
    });
  }

  void _openAiChat() {
    if (_chatService == null) return;
    showAiChatSheet(context, chatService: _chatService!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final paths = _guidePaths(context);
    assert(_topics(context).isNotEmpty);
    final filteredPaths = paths.where(_matchesPath).toList();
    final quickAnswers = _guideQuickAnswers(context);
    final filteredAnswers = quickAnswers.where(_matchesAnswer).toList();
    final searchResults = _buildSearchResults(filteredPaths, filteredAnswers);
    final displayedAnswers = _searchQuery.isEmpty && _selectedSection == null
        ? filteredAnswers.take(6).toList()
        : filteredAnswers;
    final availableCountries = _availableGuideCountries(context);
    final selectedCountry = _selectedGuideCountry(context, availableCountries);
    final hasActivePlan = _hasActivePlan;
    final hasGuideData = _normalizeCountryId(selectedCountry.id) == 'brasil';

    return Scaffold(
      extendBody: widget.showAsTab,
      floatingActionButton: widget.showAsTab && _chatService != null
          ? _AiChatFab(onTap: _openAiChat)
          : null,
      bottomNavigationBar:
          widget.showAsTab &&
              widget.citiesController != null &&
              widget.journeyContextController != null &&
              widget.migrationQuestionnaireController != null
          ? MainNavigationBar(
              currentIndex: 3,
              journeyContextController: widget.journeyContextController!,
              citiesController: widget.citiesController!,
              migrationQuestionnaireController:
                  widget.migrationQuestionnaireController!,
            )
          : null,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: ListView(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 96,
                      ),
                      children: [
                        AppGlassHeader(
                          title: l10n.documentationPageTitle,
                          onBack: widget.showAsTab
                              ? null
                              : () => Navigator.maybePop(context),
                          trailing: IconButton(
                            onPressed: widget.showAsTab
                                ? _showInfoGuide
                                : _showGuideModal,
                            icon: const Icon(Icons.help_outline_rounded),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FrostedPanel(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _GuideCountryBar(
                                selectedCountry: selectedCountry,
                                selectedCountryLabel: _localizedCountryName(
                                  context,
                                  selectedCountry,
                                ),
                                hasActivePlan: hasActivePlan,
                                onTapCountry: () => _showCountryPicker(
                                  context,
                                  availableCountries,
                                  selectedCountry.id,
                                ),
                              ),
                              if (!hasActivePlan) ...[
                                const SizedBox(height: 14),
                                _GuideStatusNotice(
                                  title: l10n.documentationGuideNoPlanTitle,
                                  body: l10n.documentationGuideNoPlanBody(
                                    selectedCountry.name,
                                  ),
                                ),
                              ] else if (!hasGuideData) ...[
                                const SizedBox(height: 14),
                                _GuideStatusNotice(
                                  title: l10n
                                      .documentationGuideCountryPendingTitle(
                                        selectedCountry.name,
                                      ),
                                  body:
                                      l10n.documentationGuideCountryPendingBody,
                                ),
                              ],
                              const SizedBox(height: 14),
                              _GuideSearchField(
                                controller: _searchController,
                                hint: l10n.documentationSearchHint,
                                onSubmitted: (_) => _handlePrimarySearchAction(
                                  context,
                                  searchResults,
                                ),
                                onChanged: hasGuideData
                                    ? (value) {
                                        setState(() {
                                          _searchQuery = value;
                                          if (value.trim().isNotEmpty) {
                                            _selectedSection = null;
                                          }
                                        });
                                      }
                                    : null,
                                onClear: _searchQuery.isEmpty
                                    ? null
                                    : () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                enabled: hasGuideData,
                              ),
                              if (hasGuideData &&
                                  _searchQuery.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _SearchMatchPanel(
                                  l10n: l10n,
                                  results: searchResults,
                                  onTapResult: (result) =>
                                      _handleSearchResultTap(context, result),
                                ),
                              ],
                              if (hasGuideData) ...[
                                const SizedBox(height: 14),
                                _SectionFilterRail(
                                  l10n: l10n,
                                  paths: paths,
                                  selectedSection: _selectedSection,
                                  onSelected: (section) {
                                    setState(() {
                                      _selectedSection =
                                          _selectedSection == section
                                          ? null
                                          : section;
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (hasGuideData)
                          _GuideResultsSection(
                            key: _resultsKey,
                            l10n: l10n,
                            filteredPaths: filteredPaths,
                            filteredAnswers: displayedAnswers,
                            hasActiveFilter:
                                _searchQuery.trim().isNotEmpty ||
                                _selectedSection != null,
                            onOpenSection: (section) => Navigator.pushNamed(
                              context,
                              AppRoutes.documentationTopic,
                              arguments: section,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _ScrollHintOverlay(
                  visible: _showScrollHint,
                  label: 'See more',
                  onTap: _scrollDown,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_GuideSearchResultMeta> _buildSearchResults(
    List<_GuidePathMeta> filteredPaths,
    List<_GuideQuickAnswerMeta> filteredAnswers,
  ) {
    final sectionsById = <DocumentationGuideSection, _GuideSearchResultMeta>{};

    for (final path in filteredPaths) {
      sectionsById[path.section] = _GuideSearchResultMeta(
        icon: path.icon,
        title: path.title,
        subtitle: path.description,
        section: path.section,
      );
    }

    final allPaths = _guidePaths(context);
    for (final answer in filteredAnswers) {
      final fallbackPath = allPaths.firstWhere(
        (path) => path.section == answer.section,
      );
      sectionsById.putIfAbsent(
        answer.section,
        () => _GuideSearchResultMeta(
          icon: fallbackPath.icon,
          title: fallbackPath.title,
          subtitle: fallbackPath.description,
          section: fallbackPath.section,
        ),
      );
    }

    return sectionsById.values.toList();
  }

  void _handlePrimarySearchAction(
    BuildContext context,
    List<_GuideSearchResultMeta> results,
  ) {
    if (results.isEmpty) {
      _scrollToResults();
      return;
    }

    _handleSearchResultTap(context, results.first);
  }

  void _handleSearchResultTap(
    BuildContext context,
    _GuideSearchResultMeta result,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.documentationTopic,
      arguments: result.section,
    );
  }

  void _scrollToResults() {
    final targetContext = _resultsKey.currentContext;
    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _handleScroll() {
    _refreshScrollHint();
  }

  void _refreshScrollHint() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final nextValue =
        position.maxScrollExtent > 40 &&
        position.pixels < position.maxScrollExtent - 32;
    if (nextValue != _showScrollHint && mounted) {
      setState(() {
        _showScrollHint = nextValue;
      });
    }
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    final nextOffset = _scrollController.offset + 360;
    _scrollController.animateTo(
      nextOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _showGuideModal() async {
    final l10n = context.l10n;

    await showContextualHelpGuide(
      context,
      preferenceKey: 'documentation_guide',
      content: ContextualHelpContent(
        eyebrow: l10n.documentationHeroEyebrow,
        contextIcon: Icons.description_outlined,
        title: l10n.documentationGuideModalTitle,
        body: l10n.documentationGuideModalBody,
        steps: [
          FeatureGuideStep(
            number: '1',
            title: l10n.documentationGuideModalStepCountryTitle,
            body: l10n.documentationGuideModalStepCountryBody,
          ),
          FeatureGuideStep(
            number: '2',
            title: l10n.documentationGuideModalStepSearchTitle,
            body: l10n.documentationGuideModalStepSearchBody,
          ),
          FeatureGuideStep(
            number: '3',
            title: l10n.documentationGuideModalStepOpenTitle,
            body: l10n.documentationGuideModalStepOpenBody,
          ),
        ],
      ),
    );
  }

  bool get _hasActivePlan {
    final selection = widget.journeyContextController?.selection;
    if (selection?.destination != null) {
      return true;
    }
    return widget.migrationQuestionnaireController?.generatedPlan != null;
  }

  List<CatalogCountry> _availableGuideCountries(BuildContext context) {
    final journeyCountries =
        widget.journeyContextController?.countries ?? const [];
    final selectable = journeyCountries
        .where((country) => country.coverage.canChooseAsDestination)
        .toList(growable: false);
    if (selectable.isNotEmpty) {
      return selectable;
    }
    return [
      CatalogCountry(
        id: 'brasil',
        name: context.l10n.questionOptionBrazil,
        isoCode: 'BR',
      ),
    ];
  }

  CatalogCountry _selectedGuideCountry(
    BuildContext context,
    List<CatalogCountry> countries,
  ) {
    final preferredId =
        _normalizeCountryId(_selectedCountryId) ??
        _normalizeCountryId(
          widget.journeyContextController?.destinationCountryId,
        ) ??
        _normalizeCountryId(
          widget
              .migrationQuestionnaireController
              ?.generatedPlan
              ?.destinationCountry,
        ) ??
        'brasil';

    for (final country in countries) {
      if (country.id == preferredId) {
        return country;
      }
    }
    return countries.first;
  }

  String? _normalizeCountryId(String? raw) {
    if (raw == null) {
      return null;
    }
    final normalized = raw.toLowerCase().trim();
    return switch (normalized) {
      'brazil' || 'brasil' => 'brasil',
      'argentina' => 'argentina',
      _ => normalized,
    };
  }

  String _localizedCountryName(BuildContext context, CatalogCountry country) {
    final l10n = context.l10n;
    final normalizedId = _normalizeCountryId(country.id) ?? country.id;

    return switch (normalizedId) {
      'argentina' => l10n.questionOptionArgentina,
      'brasil' => l10n.questionOptionBrazil,
      'chile' => l10n.countryLabel('chile'),
      'uruguai' => l10n.countryLabel('uruguai'),
      'paraguai' => l10n.countryLabel('paraguai'),
      _ => country.name,
    };
  }

  Future<void> _showCountryPicker(
    BuildContext context,
    List<CatalogCountry> countries,
    String selectedCountryId,
  ) async {
    final selected = await showModalBottomSheet<CatalogCountry>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FrostedPanel(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < countries.length; index++) ...[
                    _GuideCountryOptionTile(
                      country: countries[index],
                      countryLabel: _localizedCountryName(
                        context,
                        countries[index],
                      ),
                      selected: countries[index].id == selectedCountryId,
                      onTap: () =>
                          Navigator.of(sheetContext).pop(countries[index]),
                    ),
                    if (index != countries.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedCountryId = selected.id;
      _selectedSection = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool _matchesPath(_GuidePathMeta path) {
    if (_selectedSection != null && path.section != _selectedSection) {
      return false;
    }
    return _matchesSearch([path.title, path.description, ...path.keywords]);
  }

  bool _matchesAnswer(_GuideQuickAnswerMeta answer) {
    if (_selectedSection != null && answer.section != _selectedSection) {
      return false;
    }
    return _matchesSearch([answer.question, answer.answer, ...answer.keywords]);
  }

  bool _matchesSearch(List<String> values) {
    final normalizedQuery = _normalizeSearch(_searchQuery);
    if (normalizedQuery.isEmpty) {
      return true;
    }
    final haystack = _normalizeSearch(values.join(' '));
    final tokens = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty);
    return tokens.every(haystack.contains);
  }

  List<_DocumentationTopic> _topics(BuildContext context) =>
      _documentationTopics(context);

  List<_GuidePathMeta> _guidePaths(BuildContext context) {
    final l10n = context.l10n;

    return [
      _GuidePathMeta(
        section: DocumentationGuideSection.documents,
        icon: Icons.badge_outlined,
        title: l10n.documentationPathDocumentsTitle,
        description: l10n.documentationPathDocumentsBody,
        accent: const Color(0xFFE7F0FF),
        keywords: const [
          'cpf',
          'passaporte',
          'passport',
          'dni',
          'mercosul',
          'mercosur',
          'registro',
          'registration',
          'registro migratorio',
          'crnm',
          'residencia',
          'residence',
          'permanencia',
          'stay',
          'visa',
          'visto',
          'bank',
          'banco',
          'contrato',
          'contract',
          'documentos',
          'documents',
        ],
      ),
      _GuidePathMeta(
        section: DocumentationGuideSection.housing,
        icon: Icons.home_work_outlined,
        title: l10n.documentationHousingArrivalSectionTitle,
        description: l10n.documentationHousingArrivalSectionBody,
        accent: const Color(0xFFFFF5E7),
        keywords: const [
          'moradia',
          'vivienda',
          'housing',
          'seguranca',
          'seguridad',
          'safety',
          'bairro',
          'neighborhood',
          'aluguel',
          'alquiler',
          'rent',
          'garantia',
          'deposito',
          'deposit',
          'soft landing',
          'chegada',
          'arrival',
        ],
      ),
      _GuidePathMeta(
        section: DocumentationGuideSection.health,
        icon: Icons.health_and_safety_outlined,
        title: l10n.documentationPathHealthTitle,
        description: l10n.documentationPathHealthBody,
        accent: const Color(0xFFEAF7EF),
        keywords: const [
          'sus',
          'saude',
          'salud',
          'health',
          'ubs',
          'hospital',
          'plano',
          'plan',
          'seguro',
          'insurance',
          'clinica',
        ],
      ),
      _GuidePathMeta(
        section: DocumentationGuideSection.driving,
        icon: Icons.directions_car_outlined,
        title: l10n.documentationPathDrivingTitle,
        description: l10n.documentationPathDrivingBody,
        accent: const Color(0xFFFFF5E7),
        keywords: const [
          'habilitacao',
          'habilitacion',
          'licencia',
          'license',
          'driving',
          'dirigir',
          'conducir',
          'detran',
          'carteira',
          'cnh',
        ],
      ),
      _GuidePathMeta(
        section: DocumentationGuideSection.work,
        icon: Icons.work_outline_rounded,
        title: l10n.documentationPathWorkTitle,
        description: l10n.documentationPathWorkBody,
        accent: const Color(0xFFEFF5EA),
        keywords: const [
          'trabalho',
          'trabajo',
          'work',
          'mercado de trabalho',
          'labor market',
          'job market',
          'salario',
          'salary',
          'clt',
          'pj',
          'mei',
          'cnpj',
          'inss',
          'aposentadoria',
          'jubilacion',
          'retirement',
          'renda',
          'income',
        ],
      ),
      _GuidePathMeta(
        section: DocumentationGuideSection.costs,
        icon: Icons.wallet_outlined,
        title: l10n.documentationPathCostsTitle,
        description: l10n.documentationPathCostsBody,
        accent: const Color(0xFFF5ECFF),
        keywords: const [
          'custos',
          'costos',
          'costs',
          'preco',
          'precio',
          'price',
          'taxa',
          'fee',
          'fees',
          'orcamento',
          'presupuesto',
          'budget',
        ],
      ),
    ];
  }

  List<_GuideQuickAnswerMeta> _guideQuickAnswers(BuildContext context) {
    final l10n = context.l10n;

    return [
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.work,
        icon: Icons.work_outline_rounded,
        question: l10n.documentationAnswerWorkQuestion,
        answer: l10n.documentationAnswerWorkAnswer,
        keywords: const [
          'work visa',
          'visto de visita',
          'visa de visita',
          'visitor visa',
          'trabalho formal',
          'trabajo formal',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.documents,
        icon: Icons.airplane_ticket_outlined,
        question: l10n.documentationAnswerTravelDocQuestion,
        answer: l10n.documentationAnswerTravelDocAnswer,
        keywords: const [
          'passaporte',
          'passport',
          'dni',
          'documento para viajar',
          'travel document',
          'mercosul',
          'mercosur',
          'rg',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.work,
        icon: Icons.trending_up_rounded,
        question: l10n.documentationAnswerMarketQuestion,
        answer: l10n.documentationAnswerMarketAnswer,
        keywords: const [
          'mercado de trabalho',
          'mercado laboral',
          'job market',
          'renda',
          'income',
          'salary',
          'salario',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.housing,
        icon: Icons.shield_outlined,
        question: l10n.documentationAnswerSafetyQuestion,
        answer: l10n.documentationAnswerSafetyAnswer,
        keywords: const [
          'seguranca',
          'seguridad',
          'safety',
          'bairro',
          'neighborhood',
          'cidade segura',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.documents,
        icon: Icons.badge_outlined,
        question: l10n.documentationAnswerCpfQuestion,
        answer: l10n.documentationAnswerCpfAnswer,
        keywords: const [
          'cpf banco',
          'cpf bank',
          'contrato',
          'contract',
          'cadastro',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.documents,
        icon: Icons.perm_identity_rounded,
        question: l10n.documentationAnswerRegistrationQuestion,
        answer: l10n.documentationAnswerRegistrationAnswer,
        keywords: const [
          'crnm',
          'protocolo',
          'registro migratorio',
          'migration registration',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.documents,
        icon: Icons.schedule_rounded,
        question: l10n.documentationAnswerStayQuestion,
        answer: l10n.documentationAnswerStayAnswer,
        keywords: const [
          'permanencia',
          'stay',
          'visitor',
          'residencia',
          'residence',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.health,
        icon: Icons.health_and_safety_outlined,
        question: l10n.documentationAnswerSusQuestion,
        answer: l10n.documentationAnswerSusAnswer,
        keywords: const [
          'sus',
          'public health',
          'saude publica',
          'salud publica',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.health,
        icon: Icons.local_hospital_outlined,
        question: l10n.documentationAnswerSusCardQuestion,
        answer: l10n.documentationAnswerSusCardAnswer,
        keywords: const [
          'sus card',
          'cartao sus',
          'tarjeta sus',
          'cpf before care',
          'atendimento',
          'atencion',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.driving,
        icon: Icons.drive_eta_outlined,
        question: l10n.documentationAnswerForeignLicenseQuestion,
        answer: l10n.documentationAnswerForeignLicenseAnswer,
        keywords: const [
          'foreign license',
          'licencia extranjera',
          'carteira estrangeira',
          'detran',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.work,
        icon: Icons.badge_rounded,
        question: l10n.documentationAnswerWorkCardQuestion,
        answer: l10n.documentationAnswerWorkCardAnswer,
        keywords: const [
          'clt',
          'formal employment',
          'carteira de trabalho',
          'trabajo registrado',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.work,
        icon: Icons.business_center_outlined,
        question: l10n.documentationAnswerPjQuestion,
        answer: l10n.documentationAnswerPjAnswer,
        keywords: const [
          'pj',
          'monotributo',
          'cnpj',
          'self employed',
          'cuenta propia',
        ],
      ),
      _GuideQuickAnswerMeta(
        section: DocumentationGuideSection.costs,
        icon: Icons.savings_outlined,
        question: l10n.documentationPathCostsTitle,
        answer: l10n.documentationPathCostsBody,
        keywords: const [
          'custos iniciais',
          'costos iniciales',
          'initial costs',
          'budget',
          'orcamento',
          'presupuesto',
        ],
      ),
    ];
  }
}

List<_DocumentationTopic> _documentationTopics(BuildContext context) {
  final l10n = context.l10n;

  return [
    _DocumentationTopic(
      icon: Icons.airplane_ticket_outlined,
      title: l10n.documentationTravelDocsTitle,
      summary: l10n.documentationTravelDocsSummary,
      bullets: [
        l10n.documentationTravelDocsBulletOne,
        l10n.documentationTravelDocsBulletTwo,
        l10n.documentationTravelDocsBulletThree,
      ],
      sourceNameKey: 'argentina_migraciones',
      sourceUrl:
          'https://www.argentina.gob.ar/interior/migraciones/documentacion-para-salir-o-ingresar-al-pais',
    ),
    _DocumentationTopic(
      icon: Icons.badge_outlined,
      title: l10n.documentationCpfTitle,
      summary: l10n.documentationCpfSummary,
      bullets: [
        l10n.documentationCpfBulletOne,
        l10n.documentationCpfBulletTwo,
        l10n.documentationCpfBulletThree,
      ],
      sourceNameKey: 'receita_federal_govbr',
      sourceUrl:
          'https://www.gov.br/pt-br/servicos/inscrever-no-cpf-no-exterior',
    ),
    _DocumentationTopic(
      icon: Icons.perm_identity_rounded,
      title: l10n.documentationRegistrationTitle,
      summary: l10n.documentationRegistrationSummary,
      bullets: [
        l10n.documentationRegistrationBulletOne,
        l10n.documentationRegistrationBulletTwo,
        l10n.documentationRegistrationBulletThree,
      ],
      sourceNameKey: 'policia_federal',
      sourceUrl:
          'https://www.gov.br/pf/pt-br/assuntos/imigracao/duvidas-frequentes/autorizacao-de-residencia-e-registro-nacional-migratorio-rnm/como-devo-realizar-o-registro-de-rnm',
    ),
    _DocumentationTopic(
      icon: Icons.schedule_rounded,
      title: l10n.documentationStayTitle,
      summary: l10n.documentationStaySummary,
      bullets: [
        l10n.documentationStayBulletOne,
        l10n.documentationStayBulletTwo,
        l10n.documentationStayBulletThree,
      ],
      sourceNameKey: 'mre_policia_federal',
      sourceUrl:
          'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia-resolucao-mercosul',
    ),
    _DocumentationTopic(
      icon: Icons.account_balance_wallet_outlined,
      title: l10n.documentationWorkBankTitle,
      summary: l10n.documentationWorkBankSummary,
      bullets: [
        l10n.documentationWorkBankBulletOne,
        l10n.documentationWorkBankBulletTwo,
        l10n.documentationWorkBankBulletThree,
      ],
      sourceNameKey: 'mre_banco_central',
      sourceUrl:
          'https://www.bcb.gov.br/content/cidadaniafinanceira/documentos_cidadania/Cartilha_Migrantes_Refugiados/cartilha_BC_PORTUGUES.pdf',
    ),
    _DocumentationTopic(
      icon: Icons.flag_outlined,
      title: l10n.documentationCitizenshipTitle,
      summary: l10n.documentationCitizenshipSummary,
      bullets: [
        l10n.documentationCitizenshipBulletOne,
        l10n.documentationCitizenshipBulletTwo,
        l10n.documentationCitizenshipBulletThree,
      ],
      sourceNameKey: 'ministerio_justica',
      sourceUrl:
          'https://www.gov.br/mj/pt-br/assuntos/seus-direitos/migracoes/naturalizacao/o-que-e-naturalizacao/naturalizacao-ordinaria',
    ),
    _DocumentationTopic(
      icon: Icons.health_and_safety_outlined,
      title: l10n.documentationHealthPublicTitle,
      summary: l10n.documentationHealthPublicSummary,
      bullets: [
        l10n.documentationHealthPublicBulletOne,
        l10n.documentationHealthPublicBulletTwo,
        l10n.documentationHealthPublicBulletThree,
      ],
      sourceNameKey: 'ministerio_saude',
      sourceUrl:
          'https://www.gov.br/saude/pt-br/assuntos/noticias/2025/marco/sus-estrangeiros-podem-contar-com-acesso-ao-sistema-publico-de-saude',
    ),
    _DocumentationTopic(
      icon: Icons.local_hospital_outlined,
      title: l10n.documentationHealthFlowTitle,
      summary: l10n.documentationHealthFlowSummary,
      bullets: [
        l10n.documentationHealthFlowBulletOne,
        l10n.documentationHealthFlowBulletTwo,
        l10n.documentationHealthFlowBulletThree,
      ],
      sourceNameKey: 'meu_sus_digital',
      sourceUrl:
          'https://www.gov.br/saude/pt-br/acesso-a-informacao/acoes-e-programas/meu-sus-digital',
    ),
    _DocumentationTopic(
      icon: Icons.favorite_outline_rounded,
      title: l10n.documentationHealthPrivateTitle,
      summary: l10n.documentationHealthPrivateSummary,
      bullets: [
        l10n.documentationHealthPrivateBulletOne,
        l10n.documentationHealthPrivateBulletTwo,
        l10n.documentationHealthPrivateBulletThree,
      ],
      sourceNameKey: 'ans',
      sourceUrl:
          'https://www.gov.br/ans/pt-br/assuntos/consumidor/guia-de-contratacao-de-planos-de-saude',
    ),
    _DocumentationTopic(
      icon: Icons.directions_car_outlined,
      title: l10n.documentationDrivingTitle,
      summary: l10n.documentationDrivingSummary,
      bullets: [
        l10n.documentationDrivingBulletOne,
        l10n.documentationDrivingBulletTwo,
        l10n.documentationDrivingBulletThree,
      ],
      sourceNameKey: 'detran_es_mg_gov',
      sourceUrl: 'https://www.detran.es.gov.br/primeira-habilitacao',
    ),
    _DocumentationTopic(
      icon: Icons.drive_eta_outlined,
      title: l10n.documentationForeignLicenseTitle,
      summary: l10n.documentationForeignLicenseSummary,
      bullets: [
        l10n.documentationForeignLicenseBulletOne,
        l10n.documentationForeignLicenseBulletTwo,
        l10n.documentationForeignLicenseBulletThree,
      ],
      sourceNameKey: 'senatran_mg_gov',
      sourceUrl:
          'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-Senatran/dirigir-no-brasil',
    ),
    _DocumentationTopic(
      icon: Icons.badge_outlined,
      title: l10n.documentationWorkCltTitle,
      summary: l10n.documentationWorkCltSummary,
      bullets: [
        l10n.documentationWorkCltBulletOne,
        l10n.documentationWorkCltBulletTwo,
        l10n.documentationWorkCltBulletThree,
      ],
      sourceNameKey: 'mte_ctps',
      sourceUrl: 'https://www.gov.br/pt-br/apps/ctps-digital',
    ),
    _DocumentationTopic(
      icon: Icons.business_center_outlined,
      title: l10n.documentationWorkPjTitle,
      summary: l10n.documentationWorkPjSummary,
      bullets: [
        l10n.documentationWorkPjBulletOne,
        l10n.documentationWorkPjBulletTwo,
        l10n.documentationWorkPjBulletThree,
      ],
      sourceNameKey: 'portal_empreendedor_inss',
      sourceUrl:
          'https://www.gov.br/empresas-e-negocios/pt-br/empreendedor/quero-ser-mei/passo-a-passo-para-se-formalizar',
    ),
    _DocumentationTopic(
      icon: Icons.trending_up_rounded,
      title: l10n.documentationWorkMarketTitle,
      summary: l10n.documentationWorkMarketSummary,
      bullets: [
        l10n.documentationWorkMarketBulletOne,
        l10n.documentationWorkMarketBulletTwo,
        l10n.documentationWorkMarketBulletThree,
      ],
      sourceNameKey: 'ibge_pnad_continua',
      sourceUrl:
          'https://agenciadenoticias.ibge.gov.br/agencia-noticias/2012-agencia-de-noticias/noticias/45124-pnad-continua-taxa-de-desocupacao-e-de-5-4-e-taxa-de-subutilizacao-e-de-14-9-no-trimestre-encerrado-em-outubro',
    ),
    _DocumentationTopic(
      icon: Icons.savings_outlined,
      title: l10n.documentationRetirementTitle,
      summary: l10n.documentationRetirementSummary,
      bullets: [
        l10n.documentationRetirementBulletOne,
        l10n.documentationRetirementBulletTwo,
        l10n.documentationRetirementBulletThree,
      ],
      sourceNameKey: 'ministerio_previdencia_inss',
      sourceUrl:
          'https://www.gov.br/previdencia/pt-br/noticias/2026/janeiro/guia-de-aposentadoria-2026-entenda-as-regras-de-transicao-da-reforma-da-previdencia-de-2019',
    ),
    _DocumentationTopic(
      icon: Icons.shield_outlined,
      title: l10n.documentationSafetyTitle,
      summary: l10n.documentationSafetySummary,
      bullets: [
        l10n.documentationSafetyBulletOne,
        l10n.documentationSafetyBulletTwo,
        l10n.documentationSafetyBulletThree,
      ],
      sourceNameKey: 'forum_brasileiro_seguranca_publica',
      sourceUrl:
          'https://forumseguranca.org.br/wp-content/uploads/2025/07/anuario-2025.pdf',
    ),
  ];
}

class DocumentationTopicPage extends StatelessWidget {
  const DocumentationTopicPage({
    required this.section,
    required this.exchangeRatesService,
    this.preferredCurrencyCountryId,
    super.key,
  });

  final DocumentationGuideSection section;
  final CopilotExchangeRatesService exchangeRatesService;
  final String? preferredCurrencyCountryId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = _sectionDetails(
      context,
      section,
      exchangeRatesService,
      preferredCurrencyCountryId,
    );

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: details.title,
                      onBack: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.documentationHeroEyebrow,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            details.title,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            details.description,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...details.sections,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _DocumentationSectionDetails _sectionDetails(
    BuildContext context,
    DocumentationGuideSection section,
    CopilotExchangeRatesService exchangeRatesService,
    String? preferredCurrencyCountryId,
  ) {
    final l10n = context.l10n;
    final topics = _documentationTopics(context);

    switch (section) {
      case DocumentationGuideSection.documents:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathDocumentsTitle,
          description: l10n.documentationPathDocumentsBody,
          sections: [
            _QuickAnswersSection(l10n: l10n),
            const SizedBox(height: 12),
            _DeepDiveIntro(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationTravelDocsTitle ||
                    topic.title == l10n.documentationCpfTitle ||
                    topic.title == l10n.documentationRegistrationTitle ||
                    topic.title == l10n.documentationStayTitle ||
                    topic.title == l10n.documentationWorkBankTitle ||
                    topic.title == l10n.documentationCitizenshipTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.housing:
        return _DocumentationSectionDetails(
          title: l10n.documentationHousingArrivalSectionTitle,
          description: l10n.documentationHousingArrivalSectionBody,
          sections: [
            const HousingDecisionSupportSection(),
            const SizedBox(height: 12),
            HousingEntryCostSection(
              exchangeRatesService: exchangeRatesService,
              preferredCountryId: preferredCurrencyCountryId,
            ),
            const SizedBox(height: 12),
            const HousingSoftLandingSection(),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationSafetyTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.health:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathHealthTitle,
          description: l10n.documentationPathHealthBody,
          sections: [
            _HealthDecisionsSection(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationHealthPublicTitle ||
                    topic.title == l10n.documentationHealthFlowTitle ||
                    topic.title == l10n.documentationHealthPrivateTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.work:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathWorkTitle,
          description: l10n.documentationPathWorkBody,
          sections: [
            _WorkModelsSection(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationWorkCltTitle ||
                    topic.title == l10n.documentationWorkPjTitle ||
                    topic.title == l10n.documentationWorkMarketTitle ||
                    topic.title == l10n.documentationRetirementTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.driving:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathDrivingTitle,
          description: l10n.documentationPathDrivingBody,
          sections: [
            _DrivingJourneySection(l10n: l10n),
            const SizedBox(height: 12),
            _TopicGrid(
              topics: topics.where((topic) {
                return topic.title == l10n.documentationDrivingTitle ||
                    topic.title == l10n.documentationForeignLicenseTitle;
              }).toList(),
            ),
          ],
        );
      case DocumentationGuideSection.costs:
        return _DocumentationSectionDetails(
          title: l10n.documentationPathCostsTitle,
          description: l10n.documentationPathCostsBody,
          sections: [
            PracticalCostEstimator(
              exchangeRatesService: exchangeRatesService,
              preferredCountryId: preferredCurrencyCountryId,
            ),
          ],
        );
    }
  }
}

class _DocumentationSectionDetails {
  const _DocumentationSectionDetails({
    required this.title,
    required this.description,
    required this.sections,
  });

  final String title;
  final String description;
  final List<Widget> sections;
}

class _QuickAnswersSection extends StatelessWidget {
  const _QuickAnswersSection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final cardWidth = wide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.work_outline_rounded,
                question: l10n.documentationAnswerWorkQuestion,
                answer: l10n.documentationAnswerWorkAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.airplane_ticket_outlined,
                question: l10n.documentationAnswerTravelDocQuestion,
                answer: l10n.documentationAnswerTravelDocAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.trending_up_rounded,
                question: l10n.documentationAnswerMarketQuestion,
                answer: l10n.documentationAnswerMarketAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.shield_outlined,
                question: l10n.documentationAnswerSafetyQuestion,
                answer: l10n.documentationAnswerSafetyAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.badge_outlined,
                question: l10n.documentationAnswerCpfQuestion,
                answer: l10n.documentationAnswerCpfAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.perm_identity_rounded,
                question: l10n.documentationAnswerRegistrationQuestion,
                answer: l10n.documentationAnswerRegistrationAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.schedule_rounded,
                question: l10n.documentationAnswerStayQuestion,
                answer: l10n.documentationAnswerStayAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.health_and_safety_outlined,
                question: l10n.documentationAnswerSusQuestion,
                answer: l10n.documentationAnswerSusAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.local_hospital_outlined,
                question: l10n.documentationAnswerSusCardQuestion,
                answer: l10n.documentationAnswerSusCardAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.drive_eta_outlined,
                question: l10n.documentationAnswerForeignLicenseQuestion,
                answer: l10n.documentationAnswerForeignLicenseAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.badge_rounded,
                question: l10n.documentationAnswerBrazilianLicenseQuestion,
                answer: l10n.documentationAnswerBrazilianLicenseAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.badge_outlined,
                question: l10n.documentationAnswerWorkCardQuestion,
                answer: l10n.documentationAnswerWorkCardAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.business_center_outlined,
                question: l10n.documentationAnswerPjQuestion,
                answer: l10n.documentationAnswerPjAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.savings_outlined,
                question: l10n.documentationAnswerInssQuestion,
                answer: l10n.documentationAnswerInssAnswer,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _QuickAnswerCard(
                icon: Icons.calendar_month_outlined,
                question: l10n.documentationAnswerRetirementQuestion,
                answer: l10n.documentationAnswerRetirementAnswer,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GuideSearchField extends StatelessWidget {
  const _GuideSearchField({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = isDark ? Colors.white : const Color(0xFF10233F);
    final textSoft = isDark
        ? Colors.white.withValues(alpha: 0.74)
        : const Color(0xCC28476D);

    return TextField(
      controller: controller,
      onSubmitted: enabled ? onSubmitted : null,
      onChanged: enabled ? onChanged : null,
      enabled: enabled,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: textSoft),
        prefixIcon: Icon(Icons.search_rounded, color: textPrimary),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                onPressed: onClear,
                icon: Icon(Icons.close_rounded, color: textPrimary),
              ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.82),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.30)
                : AppColors.primary.withValues(alpha: 0.26),
          ),
        ),
      ),
    );
  }
}

class _GuideCountryBar extends StatelessWidget {
  const _GuideCountryBar({
    required this.selectedCountry,
    required this.selectedCountryLabel,
    required this.hasActivePlan,
    required this.onTapCountry,
  });

  final CatalogCountry selectedCountry;
  final String selectedCountryLabel;
  final bool hasActivePlan;
  final VoidCallback onTapCountry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTapCountry,
            icon: Text(
              selectedCountry.flagEmoji,
              style: const TextStyle(fontSize: 18),
            ),
            label: Text(selectedCountryLabel),
          ),
        ),
        const SizedBox(width: 12),
        _GuideStatusChip(
          label: hasActivePlan
              ? context.l10n.documentationGuideUsingPlanLabel
              : context.l10n.documentationGuideManualCountryLabel,
        ),
      ],
    );
  }
}

class _GuideStatusChip extends StatelessWidget {
  const _GuideStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GuideStatusNotice extends StatelessWidget {
  const _GuideStatusNotice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCountryOptionTile extends StatelessWidget {
  const _GuideCountryOptionTile({
    required this.country,
    required this.countryLabel,
    required this.selected,
    required this.onTap,
  });

  final CatalogCountry country;
  final String countryLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Text(country.flagEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  countryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchMatchPanel extends StatelessWidget {
  const _SearchMatchPanel({
    required this.l10n,
    required this.results,
    required this.onTapResult,
  });

  final dynamic l10n;
  final List<_GuideSearchResultMeta> results;
  final ValueChanged<_GuideSearchResultMeta> onTapResult;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = isDark ? Colors.white : const Color(0xFF10233F);
    final textSoft = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xCC28476D);
    final visibleResults = results.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationSearchResultsCount(results.length),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.documentationSearchResultsHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textSoft),
          ),
          if (visibleResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (var index = 0; index < visibleResults.length; index++) ...[
              _SearchResultTile(
                result: visibleResults[index],
                onTap: () => onTapResult(visibleResults[index]),
                actionLabel: l10n.documentationOpenTopicAction,
              ),
              if (index != visibleResults.length - 1) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.onTap,
    required this.actionLabel,
  });

  final _GuideSearchResultMeta result;
  final VoidCallback onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = isDark ? Colors.white : const Color(0xFF10233F);
    final textSoft = isDark
        ? Colors.white.withValues(alpha: 0.76)
        : const Color(0xCC28476D);
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(result.icon, size: 18, color: textPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: textSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                actionLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDark ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionFilterRail extends StatelessWidget {
  const _SectionFilterRail({
    required this.l10n,
    required this.paths,
    required this.selectedSection,
    required this.onSelected,
  });

  final dynamic l10n;
  final List<_GuidePathMeta> paths;
  final DocumentationGuideSection? selectedSection;
  final ValueChanged<DocumentationGuideSection?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterChipButton(
              label: l10n.documentationFilterAll,
              selected: selectedSection == null,
              onTap: () => onSelected(null),
              icon: Icons.apps_rounded,
            );
          }

          final path = paths[index - 1];
          return _FilterChipButton(
            label: path.title,
            selected: selectedSection == path.section,
            onTap: () => onSelected(path.section),
          );
        },
      ),
    );
  }
}

class _GuideResultsSection extends StatelessWidget {
  const _GuideResultsSection({
    super.key,
    required this.l10n,
    required this.filteredPaths,
    required this.filteredAnswers,
    required this.hasActiveFilter,
    required this.onOpenSection,
  });

  final dynamic l10n;
  final List<_GuidePathMeta> filteredPaths;
  final List<_GuideQuickAnswerMeta> filteredAnswers;
  final bool hasActiveFilter;
  final ValueChanged<DocumentationGuideSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    if (filteredPaths.isEmpty && filteredAnswers.isEmpty) {
      return FrostedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.documentationNoResultsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.documentationNoResultsBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
              ),
            ),
          ],
        ),
      );
    }

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationResultsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            hasActiveFilter
                ? l10n.documentationResultsFilteredBody
                : l10n.documentationResultsBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          if (filteredAnswers.isNotEmpty) ...[
            const SizedBox(height: 18),
            _ResultsSubsectionHeader(
              title: l10n.documentationQuickAnswersTitle,
              body: l10n.documentationQuickAnswersBody,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final cardWidth = wide
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final answer in filteredAnswers)
                      SizedBox(
                        width: cardWidth,
                        child: _QuickAnswerCard(
                          icon: answer.icon,
                          question: answer.question,
                          answer: answer.answer,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          if (filteredPaths.isNotEmpty) ...[
            SizedBox(height: filteredAnswers.isNotEmpty ? 24 : 18),
            _ResultsSubsectionHeader(
              title: l10n.documentationQuickRoutesTitle,
              body: l10n.documentationQuickRoutesBody,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final medium = constraints.maxWidth >= 640;
                final cardWidth = wide
                    ? (constraints.maxWidth - 24) / 3
                    : medium
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final path in filteredPaths)
                      SizedBox(
                        width: cardWidth,
                        child: _PathCard(
                          icon: path.icon,
                          title: path.title,
                          description: path.description,
                          accent: path.accent,
                          actionLabel: l10n.documentationOpenTopicAction,
                          onTap: () => onOpenSection(path.section),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultsSubsectionHeader extends StatelessWidget {
  const _ResultsSubsectionHeader({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoftFor(context),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ScrollHintOverlay extends StatelessWidget {
  const _ScrollHintOverlay({
    required this.visible,
    required this.label,
    required this.onTap,
  });

  final bool visible;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: visible ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.isDark(context)
                      ? const Color(0xE6152232)
                      : const Color(0xF9FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final selectedColor = isDark ? Colors.white : AppColors.primary;
    final unselectedColor = isDark
        ? Colors.white
        : AppColors.textPrimaryFor(context);
    return Material(
      color: selected
          ? (isDark ? Colors.white : Colors.white)
          : (isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.78)),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? selectedColor : unselectedColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? selectedColor : unselectedColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthDecisionsSection extends StatelessWidget {
  const _HealthDecisionsSection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final iconSurface = AppColors.isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationHealthSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentationHealthSectionBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final cardWidth = wide
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.local_hospital_outlined,
                      title: l10n.documentationHealthPublicTitle,
                      summary: l10n.documentationHealthPublicSummary,
                      highlights: [
                        l10n.documentationHealthPublicBulletOne,
                        l10n.documentationHealthPublicBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFF1F8F3),
                      iconTint: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.favorite_outline_rounded,
                      title: l10n.documentationHealthPrivateTitle,
                      summary: l10n.documentationHealthPrivateSummary,
                      highlights: [
                        l10n.documentationHealthPrivateBulletOne,
                        l10n.documentationHealthPrivateBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFFFF8E7),
                      iconTint: AppColors.warning,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.route_outlined,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.documentationHealthFlowTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.documentationHealthFlowSummary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrivingJourneySection extends StatelessWidget {
  const _DrivingJourneySection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationDrivingSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentationDrivingSectionBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final cardWidth = wide
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _JourneyStepCard(
                      step: '01',
                      title: l10n.documentationAnswerForeignLicenseQuestion,
                      description: l10n.documentationAnswerForeignLicenseAnswer,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _JourneyStepCard(
                      step: '02',
                      title: l10n.documentationForeignLicenseTitle,
                      description: l10n.documentationForeignLicenseBulletThree,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _JourneyStepCard(
                      step: '03',
                      title: l10n.documentationDrivingTitle,
                      description: l10n.documentationDrivingSummary,
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

class _WorkModelsSection extends StatelessWidget {
  const _WorkModelsSection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final iconSurface = AppColors.isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentationWorkSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentationWorkSectionBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final cardWidth = wide
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.badge_outlined,
                      title: l10n.documentationWorkCltTitle,
                      summary: l10n.documentationWorkCltSummary,
                      highlights: [
                        l10n.documentationWorkCltBulletOne,
                        l10n.documentationWorkCltBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFEAF0FF),
                      iconTint: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _CompareCard(
                      icon: Icons.business_center_outlined,
                      title: l10n.documentationWorkPjTitle,
                      summary: l10n.documentationWorkPjSummary,
                      highlights: [
                        l10n.documentationWorkPjBulletOne,
                        l10n.documentationWorkPjBulletTwo,
                      ],
                      backgroundColor: const Color(0xFFFFF5E7),
                      iconTint: AppColors.warning,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.savings_outlined,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.documentationRetirementTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.documentationRetirementSummary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoftFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeepDiveIntro extends StatelessWidget {
  const _DeepDiveIntro({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.layers_outlined,
              color: AppColors.textPrimaryFor(context),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.documentationDeepDiveTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.documentationDeepDiveBody,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: textSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicGrid extends StatelessWidget {
  const _TopicGrid({required this.topics});

  final List<_DocumentationTopic> topics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final panelWidth = wide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final topic in topics)
              SizedBox(
                width: panelWidth,
                child: _DocumentationCard(topic: topic),
              ),
          ],
        );
      },
    );
  }
}

String _normalizeSearch(String value) {
  const replacements = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };

  var normalized = value.toLowerCase();
  replacements.forEach((from, to) {
    normalized = normalized.replaceAll(from, to);
  });

  return normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
}

class _GuidePathMeta {
  const _GuidePathMeta({
    required this.section,
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.keywords,
  });

  final DocumentationGuideSection section;
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final List<String> keywords;
}

class _GuideQuickAnswerMeta {
  const _GuideQuickAnswerMeta({
    required this.section,
    required this.icon,
    required this.question,
    required this.answer,
    required this.keywords,
  });

  final DocumentationGuideSection section;
  final IconData icon;
  final String question;
  final String answer;
  final List<String> keywords;
}

class _GuideSearchResultMeta {
  const _GuideSearchResultMeta({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.section,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final DocumentationGuideSection section;
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = isDark ? Colors.white : const Color(0xFF10233F);
    final textSoft = isDark
        ? Colors.white.withValues(alpha: 0.76)
        : const Color(0xCC28476D);
    final resolvedBackground = isDark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.12),
            const Color(0xFF101823),
          )
        : AppColors.tintedSurfaceFor(
            context,
            tint: accent,
            lightColor: Color.alphaBlend(
              accent.withValues(alpha: 0.10),
              Colors.white,
            ),
          );
    final resolvedBorder = isDark
        ? accent.withValues(alpha: 0.24)
        : accent.withValues(alpha: 0.34);
    final iconSurface = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.94);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: resolvedBackground,
      borderColor: resolvedBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: textPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.72),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : accent.withValues(alpha: 0.16),
                  ),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({
    required this.icon,
    required this.title,
    required this.summary,
    required this.highlights,
    required this.backgroundColor,
    required this.iconTint,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<String> highlights;
  final Color backgroundColor;
  final Color iconTint;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);
    final resolvedBackground = isDark
        ? Color.alphaBlend(
            backgroundColor.withValues(alpha: 0.12),
            const Color(0xFF101823),
          )
        : backgroundColor;
    final resolvedBorder = isDark
        ? iconTint.withValues(alpha: 0.22)
        : backgroundColor.withValues(alpha: 0.7);
    final iconSurface = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.9);

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      backgroundColor: resolvedBackground,
      borderColor: resolvedBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconTint),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
          const SizedBox(height: 14),
          for (final highlight in highlights) ...[
            _InlineHighlight(text: highlight),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _JourneyStepCard extends StatelessWidget {
  const _JourneyStepCard({
    required this.step,
    required this.title,
    required this.description,
  });

  final String step;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(step, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
        ],
      ),
    );
  }
}

class _InlineHighlight extends StatelessWidget {
  const _InlineHighlight({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentationCard extends StatelessWidget {
  const _DocumentationCard({required this.topic});

  final _DocumentationTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textSoft = AppColors.textSoftFor(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(topic.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            topic.summary,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: textSoft),
          ),
          const SizedBox(height: 16),
          for (final bullet in topic.bullets) ...[
            _DocumentationBullet(text: bullet),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.documentationOfficialSourceLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: textSoft),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.referenceSourceName(topic.sourceNameKey),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  topic.sourceUrl,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentationBullet extends StatelessWidget {
  const _DocumentationBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAnswerCard extends StatelessWidget {
  const _QuickAnswerCard({
    required this.icon,
    required this.question,
    required this.answer,
  });

  final IconData icon;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: textPrimary),
          ),
          const SizedBox(height: 16),
          Text(question, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            answer,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSoft),
          ),
        ],
      ),
    );
  }
}

class _DocumentationTopic {
  const _DocumentationTopic({
    required this.icon,
    required this.title,
    required this.summary,
    required this.bullets,
    required this.sourceNameKey,
    required this.sourceUrl,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<String> bullets;
  final String sourceNameKey;
  final String sourceUrl;
}

class _AiChatFab extends StatelessWidget {
  const _AiChatFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 72),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0088FF), Color(0xFF00BBFF)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0088FF).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
