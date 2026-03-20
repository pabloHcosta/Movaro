import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';

class AppLocalization {
  const AppLocalization._();

  static const defaultLocale = Locale('en');

  static const supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('pt'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static Locale resolveLocale(Locale? locale) {
    if (locale == null) {
      return defaultLocale;
    }

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return defaultLocale;
  }

  static Locale resolveLocales(List<Locale>? locales) {
    if (locales == null || locales.isEmpty) {
      return defaultLocale;
    }

    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale;
        }
      }
    }

    return defaultLocale;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsFormatting on AppLocalizations {
  String questionTitle(String questionId) {
    switch (questionId) {
      case 'origin_country':
        return questionOriginCountryTitle;
      case 'destination_country':
        return questionDestinationCountryTitle;
      case 'goal':
        return questionGoalTitle;
      case 'intent':
        return qIntentPrompt;
      case 'funding':
        return qFundingPrompt;
      case 'portuguese_familiarity':
        return questionPortugueseFamiliarityTitle;
      case 'timeline':
        return qTimelinePrompt;
      case 'travel_group':
        return _localizedText(
          pt: 'Como você vai fazer essa mudança?',
          es: '¿Cómo vas a hacer esta mudanza?',
          en: 'How are you planning to make this move?',
        );
      case 'priorities':
        return qPrioritiesPrompt;
      case 'constraints':
        return qConstraintsPrompt;
      case 'available_capital':
        return _localizedText(
          pt: 'Quanto você tem guardado para os primeiros meses?',
          es: '¿Cuánto tenés ahorrado para los primeros meses?',
          en: 'How much do you have saved for the first months?',
        );
      default:
        return questionId;
    }
  }

  String questionOptionLabel(String questionId, String value) {
    switch (questionId) {
      case 'origin_country':
      case 'destination_country':
        return countryLabel(value);
      case 'goal':
        return goalLabel(value);
      case 'intent':
        return goalLabel(value);
      case 'funding':
        return fundingLabel(value);
      case 'portuguese_familiarity':
        return portugueseFamiliarityLabel(value);
      case 'timeline':
        return timelineLabel(value);
      case 'travel_group':
        return travelGroupLabel(value);
      case 'priorities':
        return priorityLabel(value);
      case 'constraints':
        return constraintLabel(value);
      case 'available_capital':
        return availableCapitalLabel(value);
      default:
        return value;
    }
  }

  String countryLabel(String value) {
    switch (value) {
      case 'argentina':
      case 'Argentina':
        return questionOptionArgentina;
      case 'brazil':
      case 'Brasil':
        return questionOptionBrazil;
      case 'chile':
      case 'Chile':
        return questionOptionChile;
      case 'uruguai':
      case 'Uruguai':
      case 'uruguay':
      case 'Uruguay':
        return questionOptionUruguay;
      case 'paraguai':
      case 'Paraguai':
      case 'paraguay':
      case 'Paraguay':
        return questionOptionParaguay;
      case 'unknown':
      case 'Ainda não sei':
        return questionOptionUnknown;
      default:
        return value;
    }
  }

  String goalLabel(String value) {
    switch (value) {
      case 'work':
      case 'Trabalhar':
        return questionOptionWork;
      case 'find_job_br':
        return questionOptionFindJobBr;
      case 'remote_work':
      case 'Trabalhar remoto':
        return questionOptionRemoteWork;
      case 'remote_income':
        return questionOptionRemoteIncome;
      case 'study':
      case 'Estudar':
        return questionOptionStudy;
      case 'family_partner':
        return questionOptionFamilyPartner;
      case 'quality_of_life':
      case 'Qualidade de vida':
        return questionOptionQualityOfLife;
      case 'beach_life':
      case 'Praia e litoral':
        return questionOptionBeachLife;
      case 'fresh_start':
        return questionOptionFreshStart;
      case 'explore_unsure':
        return questionOptionExploreUnsure;
      default:
        return value;
    }
  }

  String timelineLabel(String value) {
    switch (value) {
      case 'just_exploring':
        return questionOptionJustExploring;
      case 'in_0_3m':
        return questionOptionIn03Months;
      case 'in_3_6m':
        return questionOptionIn36Months;
      case 'in_6_12m':
        return questionOptionIn612Months;
      case 'in_12m_plus':
        return questionOptionIn12PlusMonths;
      case 'depends':
        return questionOptionDepends;
      case 'researching':
      case 'Só estou pesquisando':
        return questionOptionResearching;
      case '12_months':
      case 'Nos próximos 12 meses':
        return questionOption12Months;
      case '6_months':
      case 'Nos próximos 6 meses':
        return questionOption6Months;
      case 'asap':
      case 'O mais rápido possível':
        return questionOptionAsap;
      default:
        return value;
    }
  }

  String priorityLabel(String value) {
    switch (value) {
      case 'low_cost':
        return questionOptionLowCost;
      case 'job_opportunities':
        return questionOptionJobOpportunities;
      case 'safety':
        return questionOptionSafetyPriority;
      case 'warm_climate_beach':
        return questionOptionWarmClimateBeach;
      case 'transit_infra':
        return questionOptionTransitInfra;
      case 'nature':
        return questionOptionNature;
      case 'university':
        return questionOptionUniversity;
      case 'community':
        return questionOptionCommunity;
      case 'close_to_argentina':
        return questionOptionCloseToArgentina;
      case 'balanced_unsure':
        return questionOptionBalancedUnsure;
      default:
        return value;
    }
  }

  String fundingLabel(String value) {
    switch (value) {
      case 'savings':
        return questionOptionFundingSavings;
      case 'remote_income':
        return questionOptionRemoteIncome;
      case 'job_search':
        return questionOptionFundingJobSearch;
      case 'job_offer':
        return questionOptionFundingJobOffer;
      case 'family_support':
        return questionOptionFundingFamilySupport;
      case 'dont_know':
        return questionOptionFundingDontKnow;
      default:
        return value;
    }
  }

  String travelGroupLabel(String value) {
    switch (value) {
      case 'solo':
        return _localizedText(pt: 'Sozinho', es: 'Solo', en: 'Solo');
      case 'partner':
        return _localizedText(
          pt: 'Com parceiro(a)',
          es: 'Con pareja',
          en: 'With a partner',
        );
      case 'family_no_kids':
        return _localizedText(
          pt: 'Com parceiro(a) e sem filhos',
          es: 'Con pareja y sin hijos',
          en: 'With a partner and no kids',
        );
      case 'family_kids':
        return _localizedText(
          pt: 'Com filhos',
          es: 'Con hijos',
          en: 'With kids',
        );
      case 'undecided':
        return _localizedText(
          pt: 'Ainda não sei',
          es: 'Todavía no lo sé',
          en: "I don't know yet",
        );
      default:
        return value;
    }
  }

  String availableCapitalLabel(String value) {
    switch (value) {
      case 'prefer_not_say':
        return _localizedText(
          pt: 'Prefiro não informar',
          es: 'Prefiero no decirlo',
          en: 'Prefer not to say',
        );
      default:
        return value;
    }
  }

  String locationPermissionTitle() => _localizedText(
    pt: 'Ative sua localização',
    es: 'Activá tu ubicación',
    en: 'Turn on your location',
  );

  String locationPermissionSubtitle() => _localizedText(
    pt: 'Isso nos ajuda a personalizar sua experiência desde o início',
    es: 'Esto nos ayuda a personalizar tu experiencia desde el inicio',
    en: 'This helps us personalize your experience from the start',
  );

  String locationPermissionBenefitAutoOrigin() => _localizedText(
    pt: 'Detectar seu país de origem automaticamente',
    es: 'Detectar tu país de origen automáticamente',
    en: 'Detect your origin country automatically',
  );

  String locationPermissionBenefitDistance() => _localizedText(
    pt: 'Mostrar distâncias e contexto das cidades',
    es: 'Mostrar distancias y contexto de las ciudades',
    en: 'Show city distance and context',
  );

  String locationPermissionBenefitContent() => _localizedText(
    pt: 'Personalizar o conteúdo para onde você está',
    es: 'Personalizar el contenido según dónde estás',
    en: 'Personalize content based on where you are',
  );

  String locationPermissionAllowAction() => _localizedText(
    pt: 'Permitir localização',
    es: 'Permitir ubicación',
    en: 'Allow location',
  );

  String locationPermissionLaterAction() => _localizedText(
    pt: 'Agora não',
    es: 'Ahora no',
    en: 'Not now',
  );

  String locationBannerBody() => _localizedText(
    pt: 'Ative a localização para uma experiência mais precisa',
    es: 'Activá la ubicación para una experiencia más precisa',
    en: 'Turn on location for a more accurate experience',
  );

  String locationBannerAction() => _localizedText(
    pt: 'Ativar',
    es: 'Activar',
    en: 'Enable',
  );

  String locationSettingsTitle() => _localizedText(
    pt: 'Permissão bloqueada',
    es: 'Permiso bloqueado',
    en: 'Permission blocked',
  );

  String locationSettingsBody() => _localizedText(
    pt: 'Para usar a localização, abra as configurações do app e permita o acesso à localização.',
    es: 'Para usar la ubicación, abrí la configuración de la app y permití el acceso a la ubicación.',
    en: 'To use location, open the app settings and allow location access.',
  );

  String locationOpenSettingsAction() => _localizedText(
    pt: 'Abrir configurações',
    es: 'Abrir configuración',
    en: 'Open settings',
  );

  String locationQuestionnaireUnsupportedBody(String country) => _localizedText(
    pt: 'Detectamos $country, mas esse país ainda não está disponível no app. Você pode escolher manualmente.',
    es: 'Detectamos $country, pero ese país todavía no está disponible en la app. Podés elegir manualmente.',
    en: 'We detected $country, but that country is not supported in the app yet. You can choose manually.',
  );

  String introRedesignCityTitle() => _localizedText(
    pt: 'Encontre a cidade certa para você',
    es: 'Encontrá la ciudad ideal para vos',
    en: 'Find the right city for you',
  );

  String introRedesignCityDescription() => _localizedText(
    pt: 'Comparamos custo, segurança e mercado para recomendar onde você vai viver melhor.',
    es: 'Comparamos costo, seguridad y mercado para recomendar dónde vas a vivir mejor.',
    en: 'We compare cost, safety, and job market to recommend where you can live better.',
  );

  String introRedesignPlanTitle() => _localizedText(
    pt: '5 minutos para seu plano personalizado',
    es: '5 minutos para tu plan personalizado',
    en: '5 minutes to your personalized plan',
  );

  String introRedesignPlanDescription() => _localizedText(
    pt: 'Respondendo algumas perguntas simples, geramos a cidade e o guia certos para você.',
    es: 'Respondiendo algunas preguntas simples, generamos la ciudad y la guía correctas para vos.',
    en: 'By answering a few simple questions, we generate the right city and guide for you.',
  );

  String introRedesignGuideTitle() => _localizedText(
    pt: 'Do CPF ao primeiro dia — tudo organizado',
    es: 'Del CPF al primer día: todo organizado',
    en: 'From CPF to day one, everything organized',
  );

  String introRedesignGuideDescription() => _localizedText(
    pt: 'Documentos, moradia, saúde e banco. Um guia prático para cada etapa da chegada.',
    es: 'Documentos, vivienda, salud y banco. Una guía práctica para cada etapa de la llegada.',
    en: 'Documents, housing, healthcare, and banking. A practical guide for each arrival step.',
  );

  String introRedesignLocationTitle() => _localizedText(
    pt: 'Ative sua localização',
    es: 'Activá tu ubicación',
    en: 'Turn on your location',
  );

  String introRedesignLocationDescription() => _localizedText(
    pt: 'Detectamos de onde você está saindo e personalizamos tudo antes mesmo do questionário.',
    es: 'Detectamos desde dónde salís y personalizamos todo incluso antes del cuestionario.',
    en: 'We detect where you are leaving from and personalize everything before the questionnaire.',
  );

  String commonNextAction() => _localizedText(
    pt: 'Próximo',
    es: 'Siguiente',
    en: 'Next',
  );

  String cityDetailHeaderTitle() => _localizedText(
    pt: 'Detalhes',
    es: 'Detalles',
    en: 'Details',
  );

  String cityDetailGuideEyebrow() => _localizedText(
    pt: 'Detalhes da cidade',
    es: 'Detalles de la ciudad',
    en: 'City details',
  );

  String cityDetailGuideTitle() => _localizedText(
    pt: 'Como ler esta tela',
    es: 'Cómo leer esta pantalla',
    en: 'How to read this screen',
  );

  String cityDetailGuideBody() => _localizedText(
    pt: 'Aqui você valida a cidade com mais profundidade antes de comparar bairros, confirmar o plano ou salvar como referência.',
    es: 'Acá validás la ciudad con más profundidad antes de comparar barrios, confirmar el plan o guardarla como referencia.',
    en: 'Here you validate the city in more depth before comparing neighborhoods, confirming the plan, or saving it as a reference.',
  );

  String cityDetailGuideStepOneTitle() => _localizedText(
    pt: 'Leia o retrato geral',
    es: 'Leé la vista general',
    en: 'Read the overall picture',
  );

  String cityDetailGuideStepOneBody() => _localizedText(
    pt: 'O topo resume clima, contexto e sinais rápidos para entender se a cidade ainda faz sentido para o seu perfil.',
    es: 'La parte superior resume clima, contexto y señales rápidas para entender si la ciudad todavía encaja con tu perfil.',
    en: 'The top area summarizes climate, context, and quick signals to see whether the city still fits your profile.',
  );

  String cityDetailGuideStepTwoTitle() => _localizedText(
    pt: 'Valide custo e adaptação',
    es: 'Validá costo y adaptación',
    en: 'Validate cost and adaptation',
  );

  String cityDetailGuideStepTwoBody() => _localizedText(
    pt: 'Use os blocos de moradia, custo e rotina para medir o peso real da mudança inicial.',
    es: 'Usá los bloques de vivienda, costo y rutina para medir el peso real de la mudanza inicial.',
    en: 'Use the housing, cost, and routine sections to measure the real weight of the initial move.',
  );

  String cityDetailGuideStepThreeTitle() => _localizedText(
    pt: 'Compare só quando precisar',
    es: 'Compará solo cuando haga falta',
    en: 'Compare only when needed',
  );

  String cityDetailGuideStepThreeBody() => _localizedText(
    pt: 'Se a cidade continuar forte, desça até os cards de comparação e próximos passos para abrir alternativas sem perder o contexto.',
    es: 'Si la ciudad sigue fuerte, bajá hasta las tarjetas de comparación y próximos pasos para abrir alternativas sin perder el contexto.',
    en: 'If the city still looks strong, scroll down to the comparison and next-step cards to open alternatives without losing context.',
  );

  String cityComparisonGuideTitle() => _localizedText(
    pt: 'Como funciona a comparação',
    es: 'Cómo funciona la comparación',
    en: 'How comparison works',
  );

  String cityComparisonGuideBody() => _localizedText(
    pt: 'Use esta tela para ler rapidamente onde cada cidade vence, perde ou empata antes de abrir os detalhes.',
    es: 'Usá esta pantalla para ver rápido dónde cada ciudad gana, pierde o empata antes de abrir los detalles.',
    en: 'Use this screen to quickly see where each city wins, loses, or ties before opening details.',
  );

  String cityComparisonGuideStepOneTitle() => _localizedText(
    pt: 'Leia linha por linha',
    es: 'Leé fila por fila',
    en: 'Read one row at a time',
  );

  String cityComparisonGuideStepOneBody() => _localizedText(
    pt: 'Cada linha mostra uma métrica. A célula com melhor valor fica destacada em verde.',
    es: 'Cada fila muestra una métrica. La celda con mejor valor queda destacada en verde.',
    en: 'Each row shows one metric. The cell with the best value is highlighted in green.',
  );

  String cityComparisonGuideStepTwoTitle() => _localizedText(
    pt: 'Veja o alerta mais fraco',
    es: 'Mirá la alerta más débil',
    en: 'Check the weakest result',
  );

  String cityComparisonGuideStepTwoBody() => _localizedText(
    pt: 'Células em vermelho indicam o pior valor naquela métrica.',
    es: 'Las celdas en rojo indican el peor valor en esa métrica.',
    en: 'Red cells indicate the weakest value for that metric.',
  );

  String cityComparisonGuideStepThreeTitle() => _localizedText(
    pt: 'Edite quando precisar',
    es: 'Editá cuando haga falta',
    en: 'Edit when needed',
  );

  String cityComparisonGuideStepThreeBody() => _localizedText(
    pt: "O badge 'TOP' mostra a cidade com mais vitórias no total. Toque em 'Editar' para trocar as cidades comparadas.",
    es: "El badge 'TOP' muestra la ciudad con más victorias en total. Tocá 'Editar' para cambiar las ciudades comparadas.",
    en: "The 'TOP' badge shows the city with the most wins overall. Tap 'Edit' to switch the compared cities.",
  );

  String questionnaireVariantLabel(String value) {
    switch (value) {
      case 'lean':
        return bmpVariantLeanTitle;
      case 'strategic':
        return bmpVariantStrategicTitle;
      default:
        return value;
    }
  }

  String archetypeLabel(String value) {
    switch (value) {
      case 'job_hunter':
        return archetypeJobHunter;
      case 'job_hunter_with_offer':
        return archetypeJobHunterWithOffer;
      case 'job_hunter_searching':
        return archetypeJobHunterSearching;
      case 'remote_worker':
        return archetypeRemoteWorker;
      case 'remote_stable':
        return archetypeRemoteStable;
      case 'student':
        return archetypeStudent;
      case 'family_move':
        return archetypeFamilyMove;
      case 'fresh_start':
        return archetypeFreshStart;
      case 'explorer':
        return archetypeExplorer;
      default:
        return value;
    }
  }

  String constraintLabel(String value) {
    switch (value) {
      case 'prefer_south':
        return questionOptionPreferSouth;
      case 'need_big_city':
        return questionOptionNeedBigCity;
      case 'prefer_mid_city':
        return questionOptionPreferMidCity;
      case 'want_coast':
        return questionOptionWantCoast;
      case 'prefer_cooler':
        return questionOptionPreferCooler;
      case 'need_transit':
        return questionOptionNeedTransit;
      case 'avoid_expensive':
        return questionOptionAvoidExpensive;
      case 'no_constraints':
        return qConstraintsNone;
      default:
        return value;
    }
  }

  String portugueseFamiliarityLabel(String value) {
    switch (value) {
      case 'no_portuguese':
        return questionOptionNoPortuguese;
      case 'basic_portuguese':
        return questionOptionBasicPortuguese;
      case 'comfortable_portuguese':
        return questionOptionComfortablePortuguese;
      default:
        return value;
    }
  }

  String _localizedText({
    required String pt,
    required String es,
    required String en,
  }) {
    if (localeName.startsWith('pt')) {
      return pt;
    }
    if (localeName.startsWith('es')) {
      return es;
    }
    return en;
  }

  String recommendationReasonLabel(String value) {
    switch (value) {
      case 'Boa opção para quem prioriza custo':
      case 'Boa opcao para quem prioriza custo':
        return recommendationReasonEconomical;
      case 'Popular entre argentinos':
        return recommendationReasonPopularArgentina;
      case 'Melhor adaptação para quem ainda não fala português':
      case 'Melhor adaptacao para quem ainda nao fala portugues':
        return recommendationReasonLanguageSupport;
      case 'Mercado de trabalho mais forte':
        return recommendationReasonWorkMarket;
      case 'Custo mais alto, mas melhor infraestrutura':
        return recommendationReasonInfrastructure;
      case 'Opção equilibrada dentro do catálogo inicial do MVP':
      case 'Opcao equilibrada dentro do catalogo inicial do MVP':
        return recommendationReasonBalanced;
      case 'plan_reason_goal_work':
        return planReasonGoalWork;
      case 'plan_reason_goal_remote_work':
        return planReasonGoalRemoteWork;
      case 'plan_reason_goal_study':
        return planReasonGoalStudy;
      case 'plan_reason_goal_entrepreneur':
        return planReasonGoalEntrepreneur;
      case 'plan_reason_goal_retire':
        return planReasonGoalRetire;
      case 'plan_reason_goal_quality_of_life':
        return planReasonGoalQualityOfLife;
      case 'plan_reason_goal_beach_life':
        return planReasonGoalBeachLife;
      case 'plan_reason_timeline_asap':
        return planReasonTimelineAsap;
      case 'plan_reason_timeline_6_months':
        return planReasonTimeline6Months;
      case 'plan_reason_timeline_12_months':
        return planReasonTimeline12Months;
      case 'plan_reason_language_needs_support':
        return planReasonLanguageNeedsSupport;
      case 'plan_reason_language_basic':
        return planReasonLanguageBasic;
      case 'plan_reason_budget_fit':
        return planReasonBudgetFit;
      case 'plan_reason_job_mobility':
        return planReasonJobMobility;
      case 'plan_reason_safety':
        return planReasonSafety;
      case 'plan_reason_climate_nature':
        return planReasonClimateNature;
      case 'plan_reason_transit':
        return planReasonTransit;
      case 'plan_reason_proximity_argentina':
        return planReasonProximityArgentina;
      case 'plan_reason_university':
        return planReasonUniversity;
      case 'plan_reason_community':
        return planReasonCommunity;
      case 'plan_reason_balanced_profile':
        return planReasonBalancedProfile;
      default:
        return value;
    }
  }

  String planStepTitleLabel(String value) {
    switch (value) {
      case 'step_visa_residence':
      case 'Verificar tipo de residência ou visto':
        return planStepTitleVisaResidence;
      case 'step_cpf':
      case 'Obter CPF':
        return planStepTitleCpf;
      case 'step_bank_account':
      case 'Abrir conta bancária':
        return planStepTitleBankAccount;
      case 'step_housing':
      case 'Buscar moradia':
        return planStepTitleHousing;
      case 'step_settle_documents':
      case 'Regularizar documentação local':
        return planStepTitleSettleDocuments;
      case 'step_map_destinations':
      case 'Mapear destinos possíveis':
        return planStepTitleMapDestinations;
      case 'step_decision_criteria':
      case 'Definir critério de decisão':
        return planStepTitleDecisionCriteria;
      case 'step_choose_base_city':
        return planStepTitleChooseBaseCity;
      case 'step_residence_path':
        return planStepTitleResidencePath;
      case 'step_cpf_start':
        return planStepTitleCpfStart;
      default:
        return value;
    }
  }

  String planStepDescriptionLabel(String value) {
    switch (value) {
      case 'step_desc_visa_residence':
      case 'Mapear a base migratoria adequada para a sua motivacao principal de mudanca.':
        return planStepDescriptionVisaResidence;
      case 'step_desc_cpf':
      case 'Organizar o registro fiscal necessario para servicos e transacoes no Brasil.':
        return planStepDescriptionCpf;
      case 'step_desc_bank_account':
      case 'Preparar uma conta local para movimentacao financeira inicial.':
        return planStepDescriptionBankAccount;
      case 'step_desc_housing':
      case 'Pesquisar bairros, contratos e custos para uma instalacao segura.':
        return planStepDescriptionHousing;
      case 'step_desc_settle_documents':
      case 'Conferir registros adicionais, comprovantes e etapas administrativas locais.':
        return planStepDescriptionSettleDocuments;
      case 'step_desc_map_destinations':
      case 'Comparar opcoes de pais com base no seu objetivo e janela de mudanca.':
        return planStepDescriptionMapDestinations;
      case 'step_desc_decision_criteria':
      case 'Organizar prioridades como custo, documentacao e qualidade de vida.':
        return planStepDescriptionDecisionCriteria;
      case 'step_desc_choose_base_city_explore':
        return planStepDescriptionChooseBaseCityExplore;
      case 'step_desc_choose_base_city_balanced':
        return planStepDescriptionChooseBaseCityBalanced;
      case 'step_desc_choose_base_city_urgent':
        return planStepDescriptionChooseBaseCityUrgent;
      case 'step_desc_choose_base_city_offer':
        return planStepDescriptionChooseBaseCityOffer;
      case 'step_desc_residence_path_explore':
        return planStepDescriptionResidencePathExplore;
      case 'step_desc_residence_path_balanced':
        return planStepDescriptionResidencePathBalanced;
      case 'step_desc_residence_path_urgent':
        return planStepDescriptionResidencePathUrgent;
      case 'step_desc_residence_path_funding_unknown':
        return planStepDescriptionResidencePathFundingUnknown;
      case 'step_desc_cpf_start':
        return planStepDescriptionCpfStart;
      default:
        return value;
    }
  }

  String stepCategoryLabel(String value) {
    switch (value) {
      case 'documentation':
        return stepCategoryDocumentation;
      case 'financial':
        return stepCategoryFinancial;
      case 'housing':
        return stepCategoryHousing;
      case 'settlement':
        return stepCategorySettlement;
      case 'research':
        return stepCategoryResearch;
      case 'planning':
        return stepCategoryPlanning;
      default:
        return value;
    }
  }

  String industryLabel(String value) {
    switch (value) {
      case 'Agronegócio':
        return industryAgribusiness;
      case 'Comercio':
        return industryCommerce;
      case 'Construção':
        return industryConstruction;
      case 'Energia':
        return industryEnergy;
      case 'Finanças':
        return industryFinance;
      case 'Industria':
        return industryIndustry;
      case 'Logística':
        return industryLogistics;
      case 'Porto':
        return industryPort;
      case 'Saúde':
        return industryHealth;
      case 'Serviços':
        return industryServices;
      case 'Tecnologia':
        return industryTechnology;
      case 'Turismo':
        return industryTourism;
      default:
        return value;
    }
  }

  String citySourceTitle(String value) {
    switch (value) {
      case 'territorial_identity':
        return citySourceTerritorialTitle;
      case 'population':
        return citySourcePopulationTitle;
      case 'human_development':
        return citySourceHumanDevelopmentTitle;
      case 'curated_metrics':
        return citySourceCuratedMetricsTitle;
      case 'ranking':
        return citySourceRankingTitle;
      case 'public_reviews':
        return citySourcePublicReviewsTitle;
      default:
        return value;
    }
  }

  String citySourceDescription(String value) {
    switch (value) {
      case 'territorial_identity':
        return citySourceTerritorialDescription;
      case 'population':
        return citySourcePopulationDescription;
      case 'human_development':
        return citySourceHumanDevelopmentDescription;
      case 'curated_metrics':
        return citySourceCuratedMetricsDescription;
      case 'ranking':
        return citySourceRankingDescription;
      case 'public_reviews':
        return citySourcePublicReviewsDescription;
      default:
        return value;
    }
  }

  String citySourceProvider(String value) {
    switch (value) {
      case 'territorial_identity':
        return sourceProviderIbgeLocalities;
      case 'population':
        return sourceProviderIbgeCities;
      case 'human_development':
        return sourceProviderAtlasHumanDevelopment;
      case 'curated_metrics':
        return sourceProviderMovaroDataset;
      case 'ranking':
        return sourceProviderMovaroRanking;
      case 'public_reviews':
        return sourceProviderGoogleMaps;
      default:
        return value;
    }
  }

  String referenceSourceName(String value) {
    switch (value) {
      case 'argentina_migraciones':
        return sourceProviderArgentinaMigraciones;
      case 'receita_federal_govbr':
        return sourceProviderReceitaFederalGovBr;
      case 'policia_federal':
        return sourceProviderPoliciaFederal;
      case 'policia_federal_govbr':
        return sourceProviderPoliciaFederalGovBr;
      case 'mre_policia_federal':
        return sourceProviderMrePoliciaFederal;
      case 'mre_banco_central':
        return sourceProviderMreBancoCentral;
      case 'ministerio_justica':
        return sourceProviderMinisterioJustica;
      case 'ministerio_saude':
        return sourceProviderMinisterioSaude;
      case 'meu_sus_digital':
        return sourceProviderMeuSusDigital;
      case 'ans':
        return sourceProviderAns;
      case 'detran_es_mg_gov':
        return sourceProviderDetranEsMgGov;
      case 'senatran_mg_gov':
        return sourceProviderSenatranMgGov;
      case 'mte_ctps':
        return sourceProviderMteCtps;
      case 'portal_empreendedor_inss':
        return sourceProviderPortalEmpreendedorInss;
      case 'ministerio_previdencia_inss':
        return sourceProviderMinisterioPrevidenciaInss;
      case 'ibge_pnad_continua':
        return sourceProviderIbgePnadContinua;
      case 'forum_brasileiro_seguranca_publica':
        return sourceProviderForumBrasileiroSegurancaPublica;
      case 'banco_central_brasil':
        return sourceProviderBancoCentralBrasil;
      case 'movaro':
        return sourceProviderMovaro;
      default:
        return value;
    }
  }
}
