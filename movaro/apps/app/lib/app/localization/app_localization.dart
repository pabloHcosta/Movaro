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
  String flightPlannerTitle() => _localizedText(
    pt: 'Planejar meu voo',
    es: 'Planear mi vuelo',
    en: 'Plan my flight',
  );

  String flightPlannerBody(String destinationLabel) => _localizedText(
    pt: 'Escolha a cidade de saida e a data que voce pretende viajar para abrir a busca pronta ate $destinationLabel.',
    es: 'Elegi la ciudad de salida y la fecha en la que pensas viajar para abrir la busqueda lista hacia $destinationLabel.',
    en: 'Choose the departure city and the date you expect to travel to open the search already prepared for $destinationLabel.',
  );

  String flightQuestionBody(String destinationLabel) => _localizedText(
    pt: 'Abra uma busca externa de voos para comparar rotas ate $destinationLabel.',
    es: 'Abri una busqueda externa de vuelos para comparar rutas hasta $destinationLabel.',
    en: 'Open an external flight search to compare routes to $destinationLabel.',
  );

  String flightDestinationFallback(String destinationCountryIso) {
    switch (destinationCountryIso.toUpperCase()) {
      case 'AR':
        return countryLabel('argentina');
      case 'BR':
        return countryLabel('brazil');
      case 'UY':
        return _localizedText(pt: 'Uruguai', es: 'Uruguay', en: 'Uruguay');
      case 'CL':
        return _localizedText(pt: 'Chile', es: 'Chile', en: 'Chile');
      case 'PY':
        return _localizedText(pt: 'Paraguai', es: 'Paraguay', en: 'Paraguay');
      default:
        return destinationCountryIso.toUpperCase();
    }
  }

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
      case 'work_arrangement':
        return _localizedText(
          pt: 'Como você vai trabalhar no Brasil?',
          es: '¿Cómo vas a trabajar en Brasil?',
          en: 'How are you planning to work in Brazil?',
        );
      case 'argentina_origin':
        return _localizedText(
          pt: 'De onde na Argentina você vem?',
          es: '¿De dónde en Argentina venís?',
          en: 'Where in Argentina are you from?',
        );
      case 'preferred_city':
        return preferredCityQuestionTitle();
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
      case 'work_arrangement':
        return workArrangementLabel(value);
      case 'argentina_origin':
        return argentinaOriginLabel(value);
      case 'preferred_city':
        return preferredCityOptionLabel(value);
      default:
        return value;
    }
  }

  String preferredCityOptionLabel(String value) {
    switch (value) {
      case 'choose_on_map':
        return preferredCityChooseOnMap();
      case 'dont_know':
        return preferredCityDontKnow();
      default:
        return value;
    }
  }

  String workArrangementLabel(String value) {
    switch (value) {
      case 'remote':
        return _localizedText(
          pt: 'Trabalho remotamente (renda em outra moeda)',
          es: 'Trabajo de forma remota (ingresos en otra moneda)',
          en: 'I work remotely (income in another currency)',
        );
      case 'local_job':
        return _localizedText(
          pt: 'Preciso encontrar emprego local no Brasil',
          es: 'Necesito encontrar trabajo local en Brasil',
          en: 'I need to find a local job in Brazil',
        );
      case 'both_open':
        return _localizedText(
          pt: 'Aberto para as duas opções',
          es: 'Abierto a las dos opciones',
          en: 'Open to both options',
        );
      default:
        return value;
    }
  }

  String argentinaOriginLabel(String value) {
    switch (value) {
      case 'buenos_aires':
        return _localizedText(
          pt: 'Buenos Aires (CABA / Grande Buenos Aires)',
          es: 'Buenos Aires (CABA / Gran Buenos Aires)',
          en: 'Buenos Aires (CABA / Greater Buenos Aires)',
        );
      case 'cordoba':
        return _localizedText(pt: 'Córdoba', es: 'Córdoba', en: 'Córdoba');
      case 'mendoza':
        return _localizedText(pt: 'Mendoza', es: 'Mendoza', en: 'Mendoza');
      case 'rosario':
        return _localizedText(
          pt: 'Rosário (Santa Fe)',
          es: 'Rosario (Santa Fe)',
          en: 'Rosario (Santa Fe)',
        );
      case 'salta_jujuy':
        return _localizedText(
          pt: 'Salta / Jujuy (NOA)',
          es: 'Salta / Jujuy (NOA)',
          en: 'Salta / Jujuy (NOA)',
        );
      case 'litoral':
        return _localizedText(
          pt: 'Litoral (Misiones, Corrientes, Entre Ríos)',
          es: 'Litoral (Misiones, Corrientes, Entre Ríos)',
          en: 'Litoral (Misiones, Corrientes, Entre Ríos)',
        );
      case 'other_origin':
        return _localizedText(
          pt: 'Outra / Prefiro não informar',
          es: 'Otra / Prefiero no informar',
          en: 'Other / Prefer not to say',
        );
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
        return _localizedText(pt: 'Sozinho(a)', es: 'Solo/a', en: 'Solo');
      case 'partner':
        return _localizedText(
          pt: 'Com parceiro(a)',
          es: 'Con pareja',
          en: 'With a partner',
        );
      case 'family_kids':
        return _localizedText(
          pt: 'Com filhos',
          es: 'Con hijos',
          en: 'With kids',
        );
      case 'solo_parent':
        return _localizedText(
          pt: 'Só eu e meus filhos',
          es: 'Solo yo y mis hijos',
          en: 'Just me and my kids',
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
    pt: 'Podemos deixar tudo mais preciso para você',
    es: 'Podemos hacer todo más preciso para vos',
    en: 'We can make everything more precise for you',
  );

  String locationPermissionSubtitle() => _localizedText(
    pt: 'Usamos sua localização para sugerir sua origem e deixar custos, cidades e próximos passos mais certeiros para você.',
    es: 'Usamos tu ubicación para sugerir tu origen y hacer más precisos los costos, las ciudades y los próximos pasos.',
    en: 'We use your location to suggest your origin and make costs, cities, and next steps more accurate for you.',
  );

  String locationPermissionBenefitAutoOrigin() => _localizedText(
    pt: 'Preencher sua origem automaticamente',
    es: 'Completar tu origen automáticamente',
    en: 'Fill in your origin automatically',
  );

  String locationPermissionBenefitDistance() => _localizedText(
    pt: 'Mostrar cidades e contexto mais próximos da sua realidade',
    es: 'Mostrar ciudades y contexto más cercanos a tu realidad',
    en: 'Show cities and context that are closer to your reality',
  );

  String locationPermissionBenefitContent() => _localizedText(
    pt: 'Organizar documentos, custos e recomendações com mais confiança',
    es: 'Organizar documentos, costos y recomendaciones con más confianza',
    en: 'Organize documents, costs, and recommendations with more confidence',
  );

  String locationPermissionAllowAction() => _localizedText(
    pt: 'Permitir localização',
    es: 'Permitir ubicación',
    en: 'Allow location',
  );

  String locationPermissionLaterAction() =>
      _localizedText(pt: 'Agora não', es: 'Ahora no', en: 'Not now');

  String locationBannerBody() => _localizedText(
    pt: 'Ative a localização para uma experiência mais precisa',
    es: 'Activá la ubicación para una experiencia más precisa',
    en: 'Turn on location for a more accurate experience',
  );

  String locationBannerAction() =>
      _localizedText(pt: 'Ativar', es: 'Activar', en: 'Enable');

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
    pt: 'Descubra qual cidade faz mais sentido para você',
    es: 'Descubrí qué ciudad tiene más sentido para vos',
    en: 'Discover which city makes the most sense for you',
  );

  String introRedesignCityDescription() => _localizedText(
    pt: 'A gente compara custo, trabalho e qualidade de vida para te ajudar a decidir com mais segurança.',
    es: 'Comparamos costo, trabajo y calidad de vida para ayudarte a decidir con más seguridad.',
    en: 'We compare cost, work, and quality of life to help you decide with more confidence.',
  );

  String introRedesignPlanTitle() => _localizedText(
    pt: 'Em poucos passos, você já sabe o que fazer',
    es: 'En pocos pasos, ya sabés qué hacer',
    en: 'In just a few steps, you will know what to do',
  );

  String introRedesignPlanDescription() => _localizedText(
    pt: 'A gente transforma suas respostas em um plano claro para você seguir.',
    es: 'Transformamos tus respuestas en un plan claro para que lo sigas.',
    en: 'We turn your answers into a clear plan for you to follow.',
  );

  String introRedesignGuideTitle() => _localizedText(
    pt: 'Saiba exatamente o que precisa resolver antes de chegar',
    es: 'Sabé exactamente qué necesitás resolver antes de llegar',
    en: 'Know exactly what you need to sort out before you arrive',
  );

  String introRedesignGuideDescription() => _localizedText(
    pt: 'Documentos, moradia e primeiros passos organizados para você não se perder.',
    es: 'Documentos, vivienda y primeros pasos organizados para que no te pierdas.',
    en: 'Documents, housing, and first steps organized so you do not get lost.',
  );

  String introRedesignLocationTitle() => _localizedText(
    pt: 'Podemos deixar tudo mais preciso para você',
    es: 'Podemos hacer todo más preciso para vos',
    en: 'We can make everything more precise for you',
  );

  String introRedesignLocationDescription() => _localizedText(
    pt: 'Com sua localização, ajustamos custos, documentos e recomendações.',
    es: 'Con tu ubicación, ajustamos costos, documentos y recomendaciones.',
    en: 'With your location, we can tailor costs, documents, and recommendations.',
  );

  String commonNextAction() =>
      _localizedText(pt: 'Continuar', es: 'Continuar', en: 'Continue');

  String cityDetailHeaderTitle() =>
      _localizedText(pt: 'Detalhes', es: 'Detalles', en: 'Details');

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

  String settingsTitle() =>
      _localizedText(pt: 'Configuracoes', es: 'Configuracion', en: 'Settings');

  String settingsLanguageTitle() => _localizedText(
    pt: 'Idioma do app',
    es: 'Idioma de la app',
    en: 'App language',
  );

  String settingsLanguageBody() => _localizedText(
    pt: 'Escolha o idioma usado dentro do aplicativo. Se preferir, voce pode manter o idioma do sistema.',
    es: 'Elegí el idioma usado dentro de la app. Si preferís, podés mantener el idioma del sistema.',
    en: 'Choose the language used inside the app. If you prefer, you can keep the system language.',
  );

  String settingsLanguageSystem(String language) => _localizedText(
    pt: 'Sistema ($language)',
    es: 'Sistema ($language)',
    en: 'System ($language)',
  );

  String settingsSystemLanguageTitle() => _localizedText(
    pt: 'Configuracoes do dispositivo',
    es: 'Configuracion del dispositivo',
    en: 'Device settings',
  );

  String settingsSystemLanguageBody() => _localizedText(
    pt: 'No iPhone e em alguns aparelhos Android, voce tambem pode definir um idioma especifico para o app nas configuracoes do sistema.',
    es: 'En iPhone y en algunos dispositivos Android, tambien podés definir un idioma especifico para la app desde la configuracion del sistema.',
    en: 'On iPhone and on some Android devices, you can also define a specific app language in the system settings.',
  );

  String settingsOpenAction() => _localizedText(
    pt: 'Abrir configuracoes',
    es: 'Abrir configuracion',
    en: 'Open settings',
  );

  String settingsThemeTitle() =>
      _localizedText(pt: 'Aparencia', es: 'Apariencia', en: 'Appearance');

  String settingsThemeBody() => _localizedText(
    pt: 'Escolha o tema visual do aplicativo. Por padrao, o app usa o modo escuro.',
    es: 'Elegí el tema visual de la app. Por defecto, la app usa el modo oscuro.',
    en: 'Choose the visual theme of the app. By default, the app uses dark mode.',
  );

  String settingsThemeDark() =>
      _localizedText(pt: 'Modo escuro', es: 'Modo oscuro', en: 'Dark mode');

  String settingsThemeLight() =>
      _localizedText(pt: 'Modo claro', es: 'Modo claro', en: 'Light mode');

  String settingsThemeSystem() => _localizedText(
    pt: 'Seguir sistema',
    es: 'Seguir sistema',
    en: 'Follow system',
  );

  String helpHideAgainLabel() => _localizedText(
    pt: 'Nao mostrar novamente',
    es: 'No mostrar de nuevo',
    en: "Don't show again",
  );

  String questionnaireVariantPageTitle() => _localizedText(
    pt: 'Responder algumas perguntas rápidas',
    es: 'Responder algunas preguntas rápidas',
    en: 'Answer a few quick questions',
  );

  String questionnaireVariantEyebrow() =>
      _localizedText(pt: 'PRIMEIRO PASSO', es: 'PRIMER PASO', en: 'FIRST STEP');

  // Headline: "Em minutos, você terá:"
  String questionnaireVariantHeroTitle() => _localizedText(
    pt: 'Em minutos, você terá:',
    es: 'En minutos, tendrás:',
    en: 'In minutes, you\'ll have:',
  );

  String questionnaireVariantHeroBody() => _localizedText(
    pt: 'Escolha o ritmo. Você pode mudar depois.',
    es: 'Elegí el ritmo. Lo podés cambiar después.',
    en: 'Choose the pace. You can change it later.',
  );

  // Result outcome items (full string + bold substring for RichText)
  String questionnaireVariantItem1Full() => _localizedText(
    pt: 'Sua cidade ideal no Brasil',
    es: 'Tu ciudad ideal en Brasil',
    en: 'Your ideal city in Brazil',
  );

  String questionnaireVariantItem1Bold() =>
      _localizedText(pt: 'cidade ideal', es: 'ciudad ideal', en: 'ideal city');

  String questionnaireVariantItem2Full() => _localizedText(
    pt: 'Um guia personalizado de migração',
    es: 'Una guía personalizada de migración',
    en: 'A personalized migration guide',
  );

  String questionnaireVariantItem2Bold() => _localizedText(
    pt: 'guia personalizado',
    es: 'guía personalizada',
    en: 'personalized migration guide',
  );

  String questionnaireVariantItem3Full() => _localizedText(
    pt: 'Seu perfil de migrante completo',
    es: 'Tu perfil de migrante completo',
    en: 'Your complete migrant profile',
  );

  String questionnaireVariantItem3Bold() => _localizedText(
    pt: 'perfil de migrante',
    es: 'perfil de migrante',
    en: 'complete migrant profile',
  );

  // Transition label and shared CTA
  String questionnaireVariantHowLabel() => _localizedText(
    pt: 'Como você quer chegar lá?',
    es: '¿Cómo querés llegar?',
    en: 'How do you want to get there?',
  );

  String questionnaireVariantCtaLabel() => _localizedText(
    pt: 'Quero minha cidade →',
    es: 'Quiero mi ciudad →',
    en: 'I want my city →',
  );

  String questionnaireVariantLeanBadge() =>
      _localizedText(pt: '⚡ Mais rápido', es: '⚡ Más rápido', en: '⚡ Fastest');

  String questionnaireVariantLeanDescription() => _localizedText(
    pt: '4 perguntas essenciais para chegar a uma cidade recomendada sem perder tempo.',
    es: '4 preguntas esenciales para llegar a una ciudad recomendada sin perder tiempo.',
    en: '4 essential questions to reach a recommended city without wasting time.',
  );

  String questionnaireVariantLeanTime() =>
      _localizedText(pt: '~2 min', es: '~2 min', en: '~2 min');

  String questionnaireVariantLeanQuestionCount() => _localizedText(
    pt: '4 pergs. no total',
    es: '4 preg. en total',
    en: '4 qs. total',
  );

  String questionnaireVariantLeanAction() =>
      _localizedText(pt: 'Começar agora', es: 'Empezar ahora', en: 'Start now');

  String questionnaireVariantSeparator() => _localizedText(
    pt: 'ou se preferir mais precisão',
    es: 'o si preferís más precisión',
    en: 'or if you prefer more precision',
  );

  String questionnaireVariantStrategicBadge() => _localizedText(
    pt: '⭐ Mais preciso',
    es: '⭐ Más preciso',
    en: '⭐ More precise',
  );

  String questionnaireVariantStrategicDescription() => _localizedText(
    pt: '10 perguntas, resultado mais afinado ao seu perfil e restrições.',
    es: '10 preguntas, resultado más ajustado a tu perfil y restricciones.',
    en: '10 questions, result more tailored to your profile and constraints.',
  );

  String questionnaireVariantStrategicTime() =>
      _localizedText(pt: '~4 min', es: '~4 min', en: '~4 min');

  String questionnaireVariantStrategicQuestionCount() => _localizedText(
    pt: '10 pergs. no total',
    es: '10 preg. en total',
    en: '10 qs. total',
  );

  String questionnaireVariantStrategicAction() => _localizedText(
    pt: 'Escolher plano estratégico',
    es: 'Elegir plan estratégico',
    en: 'Choose strategic plan',
  );

  String questionnaireVariantTimeLabel() =>
      _localizedText(pt: 'tempo', es: 'tiempo', en: 'time');

  String questionnaireVariantCountLabel() =>
      _localizedText(pt: 'no total', es: 'en total', en: 'in total');

  String exploreGuideTitle() => _localizedText(
    pt: 'Explore com contexto do plano',
    es: 'Explorá con el contexto del plan',
    en: 'Explore with plan context',
  );

  String exploreGuideBody() => _localizedText(
    pt: 'O explorar organiza cidades e conteudo pratico ao redor da sua rota atual para que a descoberta continue ajudando na decisao.',
    es: 'Explorar organiza ciudades y contenido practico alrededor de tu ruta actual para que el descubrimiento siga ayudando en la decision.',
    en: 'Explore groups cities and practical content around your current route so discovery still supports a decision.',
  );

  String exploreGuideStepOneTitle() => _localizedText(
    pt: 'Veja o que combina com seu plano',
    es: 'Mirá lo que coincide con tu plan',
    en: 'Check what matches your plan',
  );

  String exploreGuideStepOneBody() => _localizedText(
    pt: 'A primeira secao reflete a recomendacao ativa e a rota atual quando elas estiverem disponiveis.',
    es: 'La primera seccion refleja la recomendacion activa y la ruta actual cuando estan disponibles.',
    en: 'The first section reflects the active recommendation and route when available.',
  );

  String exploreGuideStepTwoTitle() => _localizedText(
    pt: 'Navegue por outras cidades',
    es: 'Recorré otras ciudades',
    en: 'Browse other cities',
  );

  String exploreGuideStepTwoBody() => _localizedText(
    pt: 'Use os cards de cidade para comparar alternativas sem perder o seu plano atual.',
    es: 'Usá las tarjetas de ciudades para comparar alternativas sin perder tu plan actual.',
    en: 'Use city cards to compare alternatives without losing your current plan.',
  );

  String exploreGuideStepThreeTitle() => _localizedText(
    pt: 'Abra o conteudo util',
    es: 'Abrí el contenido util',
    en: 'Open useful content',
  );

  String exploreGuideStepThreeBody() => _localizedText(
    pt: 'A secao de conteudo aponta para os guias praticos mais relevantes sobre documentos, moradia e trabalho.',
    es: 'La seccion de contenido apunta a las guias practicas mas relevantes sobre documentos, vivienda y trabajo.',
    en: 'The content section points to the practical guides most relevant to documents, housing, and work.',
  );

  String exploreSignalStrong() =>
      _localizedText(pt: 'Forte', es: 'Fuerte', en: 'Strong');

  String exploreSignalBalanced() =>
      _localizedText(pt: 'Equilibrado', es: 'Equilibrado', en: 'Balanced');

  String exploreSignalWatch() =>
      _localizedText(pt: 'Atencao', es: 'Atencion', en: 'Watch');

  String journeySetupGuideTitle() => _localizedText(
    pt: 'Defina a rota em um lugar so',
    es: 'Definí la ruta en un solo lugar',
    en: 'Pick a route in one place',
  );

  String journeySetupGuideBody() => _localizedText(
    pt: 'Escolha o destino, use a localizacao apenas como pista se quiser, e mantenha a origem editavel antes de iniciar o questionario.',
    es: 'Elegí el destino, usá la ubicacion solo como pista si querés y mantené el origen editable antes de empezar el cuestionario.',
    en: 'Choose the destination, optionally use location as a hint, and keep origin editable before starting the questionnaire.',
  );

  String journeySetupGuideStepOneTitle() => _localizedText(
    pt: 'Escolha o destino',
    es: 'Elegí el destino',
    en: 'Choose the destination',
  );

  String journeySetupGuideStepOneBody() => _localizedText(
    pt: 'Selecione primeiro para onde voce quer se mudar para manter os proximos passos relevantes.',
    es: 'Seleccioná primero hacia dónde querés mudarte para mantener relevantes los proximos pasos.',
    en: 'Select where you want to move first so the next steps stay relevant.',
  );

  String journeySetupGuideStepTwoTitle() => _localizedText(
    pt: 'Use a localizacao so se ajudar',
    es: 'Usá la ubicacion solo si ayuda',
    en: 'Use location only if helpful',
  );

  String journeySetupGuideStepTwoBody() => _localizedText(
    pt: 'A localizacao do aparelho e opcional e serve apenas para sugerir a origem. Voce pode mudar isso manualmente a qualquer momento.',
    es: 'La ubicacion del dispositivo es opcional y solo sugiere el origen. Podés cambiarlo manualmente en cualquier momento.',
    en: 'Device location is optional and only suggests an origin. You can change it manually anytime.',
  );

  String journeySetupGuideStepThreeTitle() => _localizedText(
    pt: 'Comece quando estiver pronto',
    es: 'Empezá cuando estés listo',
    en: 'Start when ready',
  );

  String journeySetupGuideStepThreeBody() => _localizedText(
    pt: 'Voce pode seguir para o questionario ou navegar por cidades e conteudo sem concluir essa etapa primeiro.',
    es: 'Podés seguir al cuestionario o explorar ciudades y contenido sin terminar esta etapa primero.',
    en: 'You can continue to the questionnaire or browse cities and content without finishing setup first.',
  );

  String questionnaireGuideTitle() => _localizedText(
    pt: 'Responda algumas perguntas rápidas',
    es: 'Respondé algunas preguntas rápidas',
    en: 'Answer a few quick questions',
  );

  String questionnaireGuideBody() => _localizedText(
    pt: 'A gente usa essas respostas para organizar sua rota, salvar seu progresso e montar um plano claro para seguir.',
    es: 'Usamos estas respuestas para ordenar tu ruta, guardar tu progreso y armar un plan claro para seguir.',
    en: 'We use these answers to organize your route, save your progress, and build a clear plan to follow.',
  );

  String questionnaireGuideStepOneTitle() => _localizedText(
    pt: 'Confirme a base',
    es: 'Confirmá la base',
    en: 'Confirm the setup',
  );

  String questionnaireGuideStepOneBody() => _localizedText(
    pt: 'Comece pela origem e responda o essencial primeiro.',
    es: 'Empezá por el origen y respondé primero lo esencial.',
    en: 'Start with your origin and answer the essentials first.',
  );

  String questionnaireGuideStepTwoTitle() => _localizedText(
    pt: 'Avance quando quiser',
    es: 'Avanzá cuando quieras',
    en: 'Move forward when ready',
  );

  String questionnaireGuideStepTwoBody() => _localizedText(
    pt: 'Voce pode voltar a qualquer momento sem perder respostas nem progresso.',
    es: 'Podés volver en cualquier momento sin perder respuestas ni progreso.',
    en: 'You can go back anytime without losing answers or progress.',
  );

  String questionnaireGuideStepThreeTitle() => _localizedText(
    pt: 'Gere o resultado',
    es: 'Generá el resultado',
    en: 'Generate the result',
  );

  String questionnaireGuideStepThreeBody() => _localizedText(
    pt: 'A etapa final cria a recomendacao e envia todo o contexto da jornada para a tela de resultado.',
    es: 'La etapa final crea la recomendacion y pasa todo el contexto del recorrido a la pantalla de resultado.',
    en: 'The final step creates the recommendation and passes the full journey context to the result screen.',
  );

  String migrationStartPageTitle() => _localizedText(
    pt: 'Começar meu plano',
    es: 'Empezar mi plan',
    en: 'Start my plan',
  );

  String migrationStartHeroTitle() => _localizedText(
    pt: 'How do you want to start?',
    es: 'How do you want to start?',
    en: 'How do you want to start?',
  );

  String migrationStartHeroBody() => _localizedText(
    pt: 'Choose the option that fits you best.',
    es: 'Choose the option that fits you best.',
    en: 'Choose the option that fits you best.',
  );

  String migrationStartKnownCityTitle() => _localizedText(
    pt: 'I already know my city',
    es: 'I already know my city',
    en: 'I already know my city',
  );

  String migrationStartKnownCitySubtitle() => _localizedText(
    pt: 'Choose it and see what to do next',
    es: 'Choose it and see what to do next',
    en: 'Choose it and see what to do next',
  );

  String migrationStartKnownCityCta() => _localizedText(
    pt: 'Escolher cidade',
    es: 'Elegir ciudad',
    en: 'Choose city',
  );

  String migrationStartDecidingTitle() => _localizedText(
    pt: 'I’m still deciding',
    es: 'I’m still deciding',
    en: 'I’m still deciding',
  );

  String migrationStartDecidingSubtitle() => _localizedText(
    pt: 'Answer a few quick questions',
    es: 'Answer a few quick questions',
    en: 'Answer a few quick questions',
  );

  String migrationStartDecidingCta() => _localizedText(
    pt: 'Start questions',
    es: 'Start questions',
    en: 'Start questions',
  );

  String migrationStartConfirmCityAction() =>
      _localizedText(pt: 'Ver meu plano', es: 'Ver mi plan', en: 'See my plan');

  String migrationStartCityLoadError() => _localizedText(
    pt: 'Nao foi possivel carregar as cidades agora.',
    es: 'No pudimos cargar las ciudades ahora.',
    en: 'We could not load cities right now.',
  );

  String migrationStartPlanError() => _localizedText(
    pt: 'Nao foi possivel montar seu plano agora.',
    es: 'No pudimos armar tu plan ahora.',
    en: 'We could not build your plan right now.',
  );

  String questionnaireSelectionHelper(int maxSelections) => _localizedText(
    pt: 'Selecione ate $maxSelections',
    es: 'Elegi hasta $maxSelections',
    en: 'Pick up to $maxSelections',
  );

  String questionnaireSelectionValidation(int maxSelections) => _localizedText(
    pt: 'Voce pode marcar ate $maxSelections',
    es: 'Podes marcar hasta $maxSelections',
    en: 'You can pick up to $maxSelections',
  );

  String questionnaireCompactHint(String questionId) {
    switch (questionId) {
      case 'origin_country':
        return _localizedText(
          pt: 'Escolha origem e destino.',
          es: 'Elegi origen y destino.',
          en: 'Choose origin and destination.',
        );
      case 'funding':
        return _localizedText(
          pt: 'Escolha sua base financeira.',
          es: 'Elegi tu base financiera.',
          en: 'Choose your financial base.',
        );
      case 'travel_group':
        return _localizedText(
          pt: 'Defina quem vai com voce.',
          es: 'Definí quién se muda con vos.',
          en: 'Choose who is moving with you.',
        );
      case 'available_capital':
        return _localizedText(
          pt: 'Defina sua reserva inicial.',
          es: 'Definí tu capital inicial.',
          en: 'Choose your initial capital.',
        );
      default:
        return bmpScrollHint;
    }
  }

  String questionnaireCompactOptionLabel(String questionId, String value) {
    switch (questionId) {
      case 'timeline':
        return switch (value) {
          'just_exploring' => _localizedText(
            pt: 'Explorar',
            es: 'Explorar',
            en: 'Explore',
          ),
          'in_0_3m' => _localizedText(
            pt: '0-3 meses',
            es: '0-3 meses',
            en: '0-3 mo',
          ),
          'in_3_6m' => _localizedText(
            pt: '3-6 meses',
            es: '3-6 meses',
            en: '3-6 mo',
          ),
          'in_6_12m' => _localizedText(
            pt: '6-12 meses',
            es: '6-12 meses',
            en: '6-12 mo',
          ),
          'in_12m_plus' => _localizedText(
            pt: '12+ meses',
            es: '12+ meses',
            en: '12+ mo',
          ),
          'depends' => _localizedText(
            pt: 'Flexivel',
            es: 'Flexible',
            en: 'Flexible',
          ),
          _ => questionOptionLabel(questionId, value),
        };
      case 'intent':
        return switch (value) {
          'find_job_br' => _localizedText(
            pt: 'Trabalho',
            es: 'Trabajo',
            en: 'Work',
          ),
          'remote_income' => _localizedText(
            pt: 'Remoto',
            es: 'Remoto',
            en: 'Remote',
          ),
          'study' => _localizedText(pt: 'Estudo', es: 'Estudio', en: 'Study'),
          'family_partner' => _localizedText(
            pt: 'Familia',
            es: 'Familia',
            en: 'Family',
          ),
          'fresh_start' => _localizedText(
            pt: 'Recomeco',
            es: 'Reinicio',
            en: 'Restart',
          ),
          'explore_unsure' => _localizedText(
            pt: 'Explorar',
            es: 'Explorar',
            en: 'Explore',
          ),
          _ => questionOptionLabel(questionId, value),
        };
      case 'funding':
        return switch (value) {
          'savings' => _localizedText(
            pt: 'Reserva',
            es: 'Ahorros',
            en: 'Savings',
          ),
          'remote_income' => _localizedText(
            pt: 'Remoto',
            es: 'Remoto',
            en: 'Remote',
          ),
          'job_search' => _localizedText(
            pt: 'Buscar vaga',
            es: 'Buscar trabajo',
            en: 'Need job',
          ),
          'job_offer' => _localizedText(
            pt: 'Oferta',
            es: 'Oferta',
            en: 'Offer',
          ),
          'family_support' => _localizedText(
            pt: 'Familia',
            es: 'Familia',
            en: 'Family',
          ),
          'dont_know' => _localizedText(
            pt: 'Nao sei',
            es: 'No se',
            en: 'Unsure',
          ),
          _ => questionOptionLabel(questionId, value),
        };
      case 'constraints':
        return switch (value) {
          'prefer_south' => _localizedText(pt: 'Sul', es: 'Sur', en: 'South'),
          'need_big_city' => _localizedText(
            pt: 'Cidade grande',
            es: 'Ciudad grande',
            en: 'Big city',
          ),
          'prefer_mid_city' => _localizedText(
            pt: 'Cidade media',
            es: 'Ciudad media',
            en: 'Mid city',
          ),
          'want_coast' => _localizedText(
            pt: 'Litoral',
            es: 'Costa',
            en: 'Coast',
          ),
          'prefer_cooler' => _localizedText(
            pt: 'Mais fresco',
            es: 'Mas fresco',
            en: 'Cooler',
          ),
          'need_transit' => _localizedText(
            pt: 'Transporte',
            es: 'Transporte',
            en: 'Transit',
          ),
          'avoid_expensive' => _localizedText(
            pt: 'Menor custo',
            es: 'Menor costo',
            en: 'Lower cost',
          ),
          'no_constraints' => _localizedText(
            pt: 'Aberto',
            es: 'Abierto',
            en: 'Open',
          ),
          _ => questionOptionLabel(questionId, value),
        };
      case 'priorities':
        return switch (value) {
          'low_cost' => _localizedText(
            pt: 'Baixo custo',
            es: 'Bajo costo',
            en: 'Low cost',
          ),
          'job_opportunities' => _localizedText(
            pt: 'Emprego',
            es: 'Empleo',
            en: 'Jobs',
          ),
          'safety' => _localizedText(
            pt: 'Seguranca',
            es: 'Seguridad',
            en: 'Safety',
          ),
          'warm_climate_beach' => _localizedText(
            pt: 'Costa quente',
            es: 'Costa calida',
            en: 'Warm coast',
          ),
          'transit_infra' => _localizedText(
            pt: 'Transporte',
            es: 'Transporte',
            en: 'Transit',
          ),
          'nature' => _localizedText(
            pt: 'Natureza',
            es: 'Naturaleza',
            en: 'Nature',
          ),
          'university' => _localizedText(
            pt: 'Estudo',
            es: 'Estudio',
            en: 'Study',
          ),
          'community' => _localizedText(
            pt: 'Comunidade',
            es: 'Comunidad',
            en: 'Community',
          ),
          'close_to_argentina' => _localizedText(
            pt: 'Perto da AR',
            es: 'Cerca de AR',
            en: 'Near AR',
          ),
          'balanced_unsure' => _localizedText(
            pt: 'Equilibrado',
            es: 'Equilibrado',
            en: 'Balanced',
          ),
          _ => questionOptionLabel(questionId, value),
        };
      default:
        return questionOptionLabel(questionId, value);
    }
  }

  String copilotGuideTitle() => _localizedText(
    pt: 'Como usar o guia',
    es: 'Como usar la guia',
    en: 'How to use the guide',
  );

  String copilotGuideBody() => _localizedText(
    pt: 'Esse guia transforma seu plano em passos concretos. Foque em uma etapa por vez e siga no seu ritmo.',
    es: 'Esta guia convierte tu plan en pasos concretos. Enfocate en una etapa por vez y seguí a tu ritmo.',
    en: 'This guide turns your plan into concrete steps. Focus on one stage at a time and move at your pace.',
  );

  String copilotGuideStepOneTitle() => _localizedText(
    pt: 'Veja o que fazer agora',
    es: 'Mira que hacer ahora',
    en: 'See what to do now',
  );

  String copilotGuideStepOneBody() => _localizedText(
    pt: 'O card no topo sempre mostra a proxima acao mais importante do seu plano.',
    es: 'La tarjeta de arriba siempre muestra la proxima accion mas importante de tu plan.',
    en: 'The card at the top always shows the most important next action in your plan.',
  );

  String copilotGuideStepTwoTitle() => _localizedText(
    pt: 'Marque quando concluir',
    es: 'Marca cuando termines',
    en: 'Mark steps when you finish them',
  );

  String copilotGuideStepTwoBody() => _localizedText(
    pt: 'Cada check salva seu progresso automaticamente. Voce pode continuar de onde parou.',
    es: 'Cada check guarda tu progreso automaticamente. Podes seguir desde donde paraste.',
    en: 'Each check saves your progress automatically. You can continue where you left off.',
  );

  String copilotGuideStepThreeTitle() => _localizedText(
    pt: 'Use as ferramentas quando precisar',
    es: 'Usa las herramientas cuando las necesites',
    en: 'Use the tools when you need them',
  );

  String copilotGuideStepThreeBody() => _localizedText(
    pt: 'Orcamento, voo e aluguel ficam disponiveis pelo botao Ferramentas.',
    es: 'Presupuesto, vuelo y alquiler quedan disponibles en el boton Herramientas.',
    en: 'Budget, flight, and housing tools are available through the Tools button.',
  );

  String copilotStageStateLabel(bool selected) => _localizedText(
    pt: selected ? 'Etapa atual' : 'Abrir etapa',
    es: selected ? 'Etapa actual' : 'Abrir etapa',
    en: selected ? 'Current stage' : 'Open stage',
  );

  String cityExploreTitle() =>
      _localizedText(pt: 'Explorar', es: 'Explorar', en: 'Explore');

  String cityExploreEntryTitle(String city) => _localizedText(
    pt: 'Explorar $city',
    es: 'Explorar $city',
    en: 'Explore $city',
  );

  String cityExploreEntryBody() => _localizedText(
    pt: 'Videos, fotos e mapa',
    es: 'Videos, fotos y mapa',
    en: 'Videos, photos, and map',
  );

  String cityDetailMapDistanceBadge(String distanceKm, String originCity) =>
      _localizedText(
        pt: '~$distanceKm km de $originCity',
        es: '~$distanceKm km de $originCity',
        en: '~$distanceKm km from $originCity',
      );

  String cityDetailMapDistanceMiniLabel() =>
      _localizedText(pt: 'DISTANCIA', es: 'DISTANCIA', en: 'DISTANCE');

  String cityDetailMapCountryLabel() =>
      _localizedText(pt: 'Brasil', es: 'Brasil', en: 'Brazil');

  String cityDetailExploreMediaTitle() => _localizedText(
    pt: 'Videos e fotos',
    es: 'Videos y fotos',
    en: 'Videos and photos',
  );

  String cityDetailExploreMediaBody() => _localizedText(
    pt: 'Conheca a cidade antes de decidir',
    es: 'Conocé la ciudad antes de decidir',
    en: 'Get to know the city before deciding',
  );

  String cityExploreTabVideos() =>
      _localizedText(pt: 'Videos', es: 'Videos', en: 'Videos');

  String cityExploreTabPhotos() =>
      _localizedText(pt: 'Fotos', es: 'Fotos', en: 'Photos');

  String cityExploreTabMap() =>
      _localizedText(pt: 'No mapa', es: 'En el mapa', en: 'On the map');

  String cityExplorePlanBadge() =>
      _localizedText(pt: 'Seu plano', es: 'Tu plan', en: 'Your plan');

  String cityExploreShareTooltip() => _localizedText(
    pt: 'Compartilhar busca',
    es: 'Compartir búsqueda',
    en: 'Share search',
  );

  String cityExploreVideoQueriesLabel() => _localizedText(
    pt: 'Buscas usadas',
    es: 'Búsquedas usadas',
    en: 'Search queries used',
  );

  String cityExploreYouTubeAction() => _localizedText(
    pt: 'Ver mais no YouTube',
    es: 'Ver más en YouTube',
    en: 'See more on YouTube',
  );

  String cityExploreVideoUnavailableTitle() => _localizedText(
    pt: 'Videos indisponíveis no app agora',
    es: 'Videos no disponibles en la app ahora',
    en: 'Videos are unavailable in the app right now',
  );

  String cityExploreVideoUnavailableBody() => _localizedText(
    pt: 'Se a API estiver sem cota ou sem configuração, você ainda pode abrir a busca direta no YouTube.',
    es: 'Si la API no tiene cuota o no está configurada, igual podés abrir la búsqueda directa en YouTube.',
    en: 'If the API is out of quota or not configured, you can still open the direct search on YouTube.',
  );

  String cityExplorePhotosAttribution(String value) => _localizedText(
    pt: 'Fotos via $value',
    es: 'Fotos vía $value',
    en: 'Photos via $value',
  );

  String cityExploreSearchQuery(String city) => _localizedText(
    pt: '$city morar brasileiros vida',
    es: '$city vivir brasileños vida',
    en: '$city move to brazil city life',
  );

  String cityExploreGalleryTitle(String city, int index, int total) =>
      _localizedText(
        pt: '$city · ${index + 1}/$total',
        es: '$city · ${index + 1}/$total',
        en: '$city · ${index + 1}/$total',
      );

  String cityExploreSourceGooglePlaces() => 'Google Places';

  String cityExploreSourceUnsplash() => 'Unsplash';

  String cityExplorePhotosSeeAll(int count) => _localizedText(
    pt: 'Ver todas as fotos ($count)',
    es: 'Ver todas las fotos ($count)',
    en: 'See all photos ($count)',
  );

  String cityExploreEmptyTitle() => _localizedText(
    pt: 'Conteúdo indisponível por enquanto',
    es: 'Contenido no disponible por ahora',
    en: 'Content unavailable for now',
  );

  String cityExploreEmptyBody() => _localizedText(
    pt: 'Ainda não temos mídia suficiente para esta cidade nesta experiência.',
    es: 'Todavía no tenemos suficiente contenido para esta ciudad en esta experiencia.',
    en: 'We do not have enough media for this city in this experience yet.',
  );

  String cityExploreOpenGalleryAction() => _localizedText(
    pt: 'Abrir galeria',
    es: 'Abrir galería',
    en: 'Open gallery',
  );

  String cityExploreCopiedShareFeedback() => _localizedText(
    pt: 'Link de exploração compartilhado.',
    es: 'Link de exploración compartido.',
    en: 'Explore link shared.',
  );

  String cityExploreFallbackTitle() => _localizedText(
    pt: 'Videos disponíveis no YouTube',
    es: 'Videos disponibles en YouTube',
    en: 'Videos available on YouTube',
  );

  String cityExploreFallbackBody(String city) => _localizedText(
    pt: 'Encontramos conteúdo sobre $city. Abrimos direto no YouTube para você.',
    es: 'Encontramos contenido sobre $city. Lo abrimos directo en YouTube para vos.',
    en: 'We found content about $city. We open it directly on YouTube for you.',
  );

  String cityExploreFallbackAction() => _localizedText(
    pt: 'Abrir busca no YouTube',
    es: 'Abrir búsqueda en YouTube',
    en: 'Open YouTube search',
  );

  String cityExploreFallbackFootnote() => _localizedText(
    pt: 'Abre o app do YouTube com os melhores termos',
    es: 'Abre la app de YouTube con los mejores términos',
    en: 'Opens the YouTube app with the best search terms',
  );

  String cityExploreFeaturedLabel() =>
      _localizedText(pt: 'Em destaque', es: 'Destacado', en: 'Featured');

  String cityExploreMoreVideosLabel() =>
      _localizedText(pt: 'Mais videos', es: 'Más videos', en: 'More videos');

  String cityExplorePhotosAttributionFull() => _localizedText(
    pt: 'Fotos via Google Places · Unsplash',
    es: 'Fotos vía Google Places · Unsplash',
    en: 'Photos via Google Places · Unsplash',
  );

  String cityExplorePhotosAttributionGooglePlaces() => _localizedText(
    pt: 'Fotos via Google Places',
    es: 'Fotos vía Google Places',
    en: 'Photos via Google Places',
  );

  String cityExplorePhotosAttributionPexels() => _localizedText(
    pt: 'Fotos via Pexels',
    es: 'Fotos vía Pexels',
    en: 'Photos via Pexels',
  );

  String cityExplorePhotosAttributionGeneric() => _localizedText(
    pt: 'Fotos da cidade',
    es: 'Fotos de la ciudad',
    en: 'City photos',
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

  // ── MigrationResultRevealPage strings ─────────────────────────────────────

  String migrationResultRevealBreakdownTitle(String cityName) => _localizedText(
    pt: 'Por que $cityName?',
    es: '¿Por qué $cityName?',
    en: 'Why $cityName?',
  );

  String migrationResultRevealBreakdownOverall() => _localizedText(
    pt: 'Compatibilidade geral',
    es: 'Compatibilidad general',
    en: 'Overall compatibility',
  );

  String migrationResultRevealTapToSeeDetails() => _localizedText(
    pt: 'Toque para ver o detalhamento',
    es: 'Toca para ver el detalle',
    en: 'Tap to see breakdown',
  );

  String migrationResultRevealViewDetailsCta(String cityName) => _localizedText(
    pt: 'Ver detalhes de $cityName',
    es: 'Ver detalles de $cityName',
    en: 'View details of $cityName',
  );

  /// Labels for individual scoring dimensions shown in the compatibility
  /// breakdown bottom sheet.
  String dimensionLabel(String key) {
    switch (key) {
      case 'affordability':
        return _localizedText(
          pt: 'Custo de vida',
          es: 'Costo de vida',
          en: 'Cost of living',
        );
      case 'job_market':
        return _localizedText(
          pt: 'Mercado de trabalho',
          es: 'Mercado laboral',
          en: 'Job market',
        );
      case 'safety':
        return _localizedText(pt: 'Segurança', es: 'Seguridad', en: 'Safety');
      case 'climate_warmth':
        return _localizedText(pt: 'Clima', es: 'Clima', en: 'Climate');
      case 'transit_infra':
        return _localizedText(
          pt: 'Infraestrutura e transporte',
          es: 'Infraestructura y transporte',
          en: 'Infrastructure & transit',
        );
      case 'nature':
        return _localizedText(
          pt: 'Natureza e praia',
          es: 'Naturaleza y playa',
          en: 'Nature & beach',
        );
      case 'community':
        return _localizedText(
          pt: 'Comunidade argentina',
          es: 'Comunidad argentina',
          en: 'Argentine community',
        );
      case 'university':
        return _localizedText(
          pt: 'Universidades',
          es: 'Universidades',
          en: 'Universities',
        );
      case 'proximity_argentina':
        return _localizedText(
          pt: 'Proximidade da Argentina',
          es: 'Proximidad a Argentina',
          en: 'Proximity to Argentina',
        );
      default:
        return key;
    }
  }

  // ── FlightSearchTool strings ───────────────────────────────────────────────

  String flightSearchDepartureDateLabel() => _localizedText(
    pt: 'Quando você vai partir?',
    es: '¿Cuándo vas a partir?',
    en: 'When are you departing?',
  );

  String flightSearchDateRequired() => _localizedText(
    pt: 'Selecione a data de partida para continuar',
    es: 'Seleccioná la fecha de partida para continuar',
    en: 'Please select a departure date to continue',
  );

  String flightSearchDestinationLabel() =>
      _localizedText(pt: 'Para onde?', es: '¿A dónde vas?', en: 'Where to?');

  String flightSearchButtonLabel() => _localizedText(
    pt: 'Buscar voos',
    es: 'Buscar vuelos',
    en: 'Search flights',
  );

  String flightSearchSelectDateHint() => _localizedText(
    pt: 'Selecione a data de partida',
    es: 'Seleccioná la fecha de partida',
    en: 'Select departure date',
  );

  // ── Redo Questionnaire Confirmation Dialog ──────────────────────────────

  String redoQuestionnaireDialogTitle() => _localizedText(
    pt: 'Refazer questionário?',
    es: '¿Rehacer cuestionario?',
    en: 'Redo questionnaire?',
  );

  String redoQuestionnaireDialogBody() => _localizedText(
    pt: 'Suas respostas anteriores serão apagadas e você vai recomeçar desde a primeira pergunta.',
    es: 'Tus respuestas anteriores se borrarán y vas a recomenzar desde la primera pregunta.',
    en: 'Your previous answers will be erased and you will start over from the first question.',
  );

  String redoQuestionnaireDialogWarning() => _localizedText(
    pt: 'A cidade recomendada e o plano atual serão descartados.',
    es: 'La ciudad recomendada y el plan actual se descartarán.',
    en: 'The recommended city and current plan will be discarded.',
  );

  String redoQuestionnaireDialogConfirm() => _localizedText(
    pt: 'Sim, começar do zero',
    es: 'Sí, empezar de cero',
    en: 'Yes, start from scratch',
  );

  String redoQuestionnaireDialogCancel() => _localizedText(
    pt: 'Cancelar — manter resultado',
    es: 'Cancelar — mantener resultado',
    en: 'Cancel — keep result',
  );

  // ── City Picker Bottom Sheet ──────────────────────────────────────────────

  String cityPickerMapTab() =>
      _localizedText(pt: 'Mapa', es: 'Mapa', en: 'Map');

  String cityPickerListTab() =>
      _localizedText(pt: 'Lista', es: 'Lista', en: 'List');

  String cityPickerSearchHint() => _localizedText(
    pt: 'Buscar cidade (ex: Floripa, San Pablo...)',
    es: 'Buscar ciudad (ej: Floripa, San Pablo...)',
    en: 'Search city (e.g. Floripa, São Paulo...)',
  );

  String cityPickerConfirmLabel() => _localizedText(
    pt: 'Escolher esta cidade',
    es: 'Elegir esta ciudad',
    en: 'Choose this city',
  );

  String cityPickerSkipLabel() => _localizedText(
    pt: 'Ainda não sei, pular',
    es: 'Todavía no sé, omitir',
    en: "I don't know yet, skip",
  );

  String cityPickerNoResults() => _localizedText(
    pt: 'Nenhuma cidade encontrada',
    es: 'Ninguna ciudad encontrada',
    en: 'No cities found',
  );

  // ── Preferred City Questionnaire Step ──────────────────────────────────

  String preferredCityQuestionTitle() => _localizedText(
    pt: 'Você já tem alguma cidade em mente?',
    es: '¿Ya tenés alguna ciudad en mente?',
    en: 'Do you already have a city in mind?',
  );

  String preferredCityChooseOnMap() => _localizedText(
    pt: 'Sim, quero escolher no mapa',
    es: 'Sí, quiero elegir en el mapa',
    en: 'Yes, I want to choose on the map',
  );

  String preferredCityDontKnow() => _localizedText(
    pt: 'Ainda não sei, me surpreenda',
    es: 'Todavía no sé, sorprendeme',
    en: "I don't know yet, surprise me",
  );

  String preferredCityChangeLabel() => _localizedText(
    pt: 'Trocar cidade',
    es: 'Cambiar ciudad',
    en: 'Change city',
  );

  // ── Anti-Anchoring (Result Reveal) ─────────────────────────────────────

  String antiAnchorReinforcementTitle(String cityName) => _localizedText(
    pt: 'Sua intuição estava certa!',
    es: '¡Tu intuición estaba bien!',
    en: 'Your intuition was right!',
  );

  String antiAnchorReinforcementBody(String cityName) => _localizedText(
    pt: '$cityName também é a nossa recomendação com base no seu perfil.',
    es: '$cityName también es nuestra recomendación según tu perfil.',
    en: '$cityName is also our recommendation based on your profile.',
  );

  String antiAnchorComparisonTitle(String preferredCity) => _localizedText(
    pt: 'Você pensou em $preferredCity — ótima cidade!',
    es: 'Pensaste en $preferredCity — ¡gran ciudad!',
    en: 'You thought about $preferredCity — great city!',
  );

  String antiAnchorComparisonBody(
    String preferredCity,
    String recommendedCity,
  ) => _localizedText(
    pt: 'Mas com base no seu perfil, $recommendedCity pode ser uma opção ainda melhor. Veja a comparação:',
    es: 'Pero según tu perfil, $recommendedCity podría ser una opción aún mejor. Mirá la comparación:',
    en: 'But based on your profile, $recommendedCity might be an even better option. See the comparison:',
  );

  String antiAnchorGoWithPreferred(String cityName) => _localizedText(
    pt: 'Continuar com $cityName',
    es: 'Continuar con $cityName',
    en: 'Continue with $cityName',
  );

  String antiAnchorTryRecommended(String cityName) => _localizedText(
    pt: 'Ver detalhes de $cityName',
    es: 'Ver detalles de $cityName',
    en: 'See details of $cityName',
  );

  String migrationResultSelectedCityTitle(String cityName) => _localizedText(
    pt: 'Cidade que voce tinha em mente: $cityName',
    es: 'Ciudad que tenías en mente: $cityName',
    en: 'City you had in mind: $cityName',
  );

  String migrationResultSelectedCityBody() => _localizedText(
    pt: 'Agora veja a cidade que faz mais sentido para o seu plano e abra os detalhes quando quiser.',
    es: 'Ahora mirá la ciudad que más sentido tiene para tu plan y abrí los detalles cuando quieras.',
    en: 'Now review the city that makes the most sense for your plan and open the details whenever you want.',
  );

  String antiAnchorStrength() =>
      _localizedText(pt: 'Ponto forte', es: 'Punto fuerte', en: 'Strength');

  String antiAnchorAttention() => _localizedText(
    pt: 'Ponto de atenção',
    es: 'Punto de atención',
    en: 'Attention point',
  );

  // ─────────────────────────────────────────────────────────────────────────

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
