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
    return questionTitleForJourney(questionId);
  }

  String questionTitleForJourney(
    String questionId, {
    String? destinationLabel,
  }) {
    switch (questionId) {
      case 'origin_country':
        return questionOriginCountryTitle;
      case 'destination_country':
        return questionDestinationCountryTitle;
      case 'goal':
        return questionGoalTitle;
      case 'intent':
        return questionIntentPrompt();
      case 'funding':
        return qFundingPrompt;
      case 'portuguese_familiarity':
        return questionPortugueseFamiliarityTitle;
      case 'timeline':
        return questionTimelinePrompt();
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
      case 'support_needs':
        return _localizedText(
          pt: 'O que precisa entrar no seu plano?',
          es: '¿Qué necesitás incluir en tu plan?',
          en: 'What needs to be included in your plan?',
        );
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

  String questionIntentPrompt({String? destinationLabel}) {
    return _localizedText(
      pt: 'O que você busca nessa mudança agora?',
      es: '¿Qué buscás en esta mudanza ahora?',
      en: 'What are you looking for in this move right now?',
    );
  }

  String questionTimelinePrompt({String? destinationLabel}) {
    return _localizedText(
      pt: 'Quando você gostaria de fazer essa mudança? (aprox.)',
      es: '¿Cuándo te gustaría hacer esta mudanza? (aprox.)',
      en: 'When would you like to make this move? (roughly)',
    );
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
      case 'support_needs':
        return supportNeedLabel(value);
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

  String supportNeedLabel(String value) {
    return switch (value) {
      'children_school' => _localizedText(
        pt: 'Filhos e escola',
        es: 'Hijos y escuela',
        en: 'Children and school',
      ),
      'travel_with_pet' => _localizedText(
        pt: 'Viajar com pet',
        es: 'Viajar con mascota',
        en: 'Travel with a pet',
      ),
      'continuous_medication' => _localizedText(
        pt: 'Medicamento contínuo',
        es: 'Medicación continua',
        en: 'Ongoing medication',
      ),
      'foreign_income' => _localizedText(
        pt: 'Renda do exterior',
        es: 'Ingresos del exterior',
        en: 'Foreign income',
      ),
      'no_special_needs' => _localizedText(
        pt: 'Nada disso',
        es: 'Nada de esto',
        en: 'None of these',
      ),
      _ => value,
    };
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
      case 'AR':
      case 'argentina':
      case 'Argentina':
        return questionOptionArgentina;
      case 'BR':
      case 'brazil':
      case 'Brasil':
        return questionOptionBrazil;
      case 'CL':
      case 'chile':
      case 'Chile':
        return questionOptionChile;
      case 'UY':
      case 'uruguai':
      case 'Uruguai':
      case 'uruguay':
      case 'Uruguay':
        return questionOptionUruguay;
      case 'PY':
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
    pt: 'Escolha onde sua nova vida pode começar',
    es: 'Elegí dónde puede empezar tu nueva vida',
    en: 'Choose where your new life can begin',
  );

  String introRedesignCityDescription() => _localizedText(
    pt: 'Compare custo, trabalho, segurança e adaptação para escolher sua cidade com mais confiança.',
    es: 'Compará costo, trabajo, seguridad y adaptación para elegir tu ciudad con más confianza.',
    en: 'Compare costs, jobs, safety, and adaptation to choose your city with more confidence.',
  );

  String introRedesignPlanTitle() => _localizedText(
    pt: 'Transforme dúvidas em um plano possível',
    es: 'Convertí tus dudas en un plan posible',
    en: 'Turn uncertainty into a practical plan',
  );

  String introRedesignPlanDescription() => _localizedText(
    pt: 'Conte o que busca e receba prioridades claras para decidir e preparar sua mudança.',
    es: 'Contanos qué buscás y recibí prioridades claras para decidir y preparar tu mudanza.',
    en: 'Tell us what you need and get clear priorities to decide and prepare your move.',
  );

  String introRedesignGuideTitle() => _localizedText(
    pt: 'Saiba o que fazer — e em que ordem',
    es: 'Sabé qué hacer y en qué orden',
    en: 'Know what to do — and in what order',
  );

  String introRedesignGuideDescription() => _localizedText(
    pt: 'Organize documentos, moradia, dinheiro e chegada com fontes oficiais.',
    es: 'Organizá documentos, vivienda, dinero y llegada con fuentes oficiales.',
    en: 'Organize documents, housing, money, and arrival with official sources.',
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

  String citiesWorkAreaFilterLabel() => _localizedText(
    pt: 'Filtrar por área de trabalho',
    es: 'Filtrar por área de trabajo',
    en: 'Filter by work area',
  );

  /// Localized display label for a work area (industry) coming from the city
  /// catalog (stored in Portuguese). Falls back to the raw label when unknown,
  /// so new industries still render instead of breaking.
  String workAreaLabel(String area) {
    switch (_normalizeWorkArea(area)) {
      case 'servicos':
        return _localizedText(pt: 'Serviços', es: 'Servicios', en: 'Services');
      case 'turismo':
        return _localizedText(pt: 'Turismo', es: 'Turismo', en: 'Tourism');
      case 'comercio':
        return _localizedText(pt: 'Comércio', es: 'Comercio', en: 'Commerce');
      case 'tecnologia':
        return _localizedText(
          pt: 'Tecnologia',
          es: 'Tecnología',
          en: 'Technology',
        );
      case 'hospedagem':
        return _localizedText(
          pt: 'Hospedagem',
          es: 'Hospedaje',
          en: 'Hospitality',
        );
      case 'porto':
        return _localizedText(pt: 'Porto', es: 'Puerto', en: 'Port');
      case 'saude':
        return _localizedText(pt: 'Saúde', es: 'Salud', en: 'Healthcare');
      case 'agronegocio':
        return _localizedText(
          pt: 'Agronegócio',
          es: 'Agronegocio',
          en: 'Agribusiness',
        );
      case 'logistica':
        return _localizedText(
          pt: 'Logística',
          es: 'Logística',
          en: 'Logistics',
        );
      case 'industria':
        return _localizedText(pt: 'Indústria', es: 'Industria', en: 'Industry');
      case 'energia':
        return _localizedText(pt: 'Energia', es: 'Energía', en: 'Energy');
      case 'construcao':
        return _localizedText(
          pt: 'Construção',
          es: 'Construcción',
          en: 'Construction',
        );
      case 'gastronomia':
        return _localizedText(
          pt: 'Gastronomia',
          es: 'Gastronomía',
          en: 'Gastronomy',
        );
      case 'transporte maritimo':
        return _localizedText(
          pt: 'Transporte marítimo',
          es: 'Transporte marítimo',
          en: 'Maritime transport',
        );
      case 'agroindustria':
        return _localizedText(
          pt: 'Agroindústria',
          es: 'Agroindustria',
          en: 'Agro-industry',
        );
      case 'frigorificos':
        return _localizedText(
          pt: 'Frigoríficos',
          es: 'Frigoríficos',
          en: 'Meat processing',
        );
      case 'industria metal-mecanica':
        return _localizedText(
          pt: 'Indústria metal-mecânica',
          es: 'Industria metalmecánica',
          en: 'Metalworking',
        );
      case 'autopecas':
        return _localizedText(
          pt: 'Autopeças',
          es: 'Autopartes',
          en: 'Auto parts',
        );
      case 'educacao':
        return _localizedText(pt: 'Educação', es: 'Educación', en: 'Education');
      case 'financas':
        return _localizedText(pt: 'Finanças', es: 'Finanzas', en: 'Finance');
      case 'administracao publica':
        return _localizedText(
          pt: 'Administração pública',
          es: 'Administración pública',
          en: 'Public administration',
        );
      case 'universidades':
        return _localizedText(
          pt: 'Universidades',
          es: 'Universidades',
          en: 'Universities',
        );
      case 'biotecnologia':
        return _localizedText(
          pt: 'Biotecnologia',
          es: 'Biotecnología',
          en: 'Biotech',
        );
      default:
        return area;
    }
  }

  String _normalizeWorkArea(String value) {
    const accents = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ç': 'c',
    };
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      buffer.write(accents[ch] ?? ch);
    }
    return buffer.toString();
  }

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

  String settingsCurrencyTitle() => _localizedText(
    pt: 'Moeda preferida',
    es: 'Moneda preferida',
    en: 'Preferred currency',
  );

  String settingsCurrencyBody() => _localizedText(
    pt: 'Escolha a moeda usada para exibir valores no app. Os precos sao convertidos em tempo real com cotacoes oficiais.',
    es: 'Elegí la moneda usada para mostrar valores en la app. Los precios se convierten en tiempo real con cotizaciones oficiales.',
    en: 'Choose the currency used to display amounts in the app. Prices are converted in real time using official exchange rates.',
  );

  String settingsCurrencyAuto() => _localizedText(
    pt: 'Automatico (pelo pais de origem)',
    es: 'Automatico (por pais de origen)',
    en: 'Automatic (by origin country)',
  );

  String helpHideAgainLabel() => _localizedText(
    pt: 'Não mostrar novamente',
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
    pt: '4 perguntas essenciais para chegar a uma shortlist de cidades sem perder tempo.',
    es: '4 preguntas esenciales para llegar a una shortlist de ciudades sin perder tiempo.',
    en: '4 essential questions to reach a city shortlist without wasting time.',
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

  String questionnaireGuideEyebrow() => _localizedText(
    pt: 'Motor de sugestão de cidades',
    es: 'Motor de sugerencia de ciudades',
    en: 'City suggestion engine',
  );

  String questionnaireGuideTitle() => _localizedText(
    pt: 'Como a Movaro sugere cidades',
    es: 'Cómo Movaro sugiere ciudades',
    en: 'How Movaro suggests cities',
  );

  String questionnaireGuideBody() => _localizedText(
    pt: 'Suas respostas viram critérios de comparação. Primeiro filtramos o que é obrigatório; depois ordenamos as cidades com dados comparáveis e mostramos as limitações.',
    es: 'Tus respuestas se convierten en criterios de comparación. Primero filtramos lo obligatorio; después ordenamos las ciudades con datos comparables y mostramos las limitaciones.',
    en: 'Your answers become comparison criteria. We first apply mandatory filters, then rank cities using comparable data and show the limitations.',
  );

  String discoverFlowBannerTitle() => _localizedText(
    pt: 'Descoberta guiada',
    es: 'Descubrimiento guiado',
    en: 'Guided discovery',
  );

  String discoverFlowBannerBody() => _localizedText(
    pt: 'Responda poucas perguntas para receber uma direção inicial com cidade em destaque, alternativas e próximos passos.',
    es: 'Respondé pocas preguntas para recibir una dirección inicial con una ciudad destacada, alternativas y próximos pasos.',
    en: 'Answer a few questions to get an initial direction with a highlighted city, alternatives, and next steps.',
  );

  String discoverFlowBannerAction() => _localizedText(
    pt: 'Você compara com calma depois de receber a primeira direção.',
    es: 'Comparás con calma después de recibir la primera dirección.',
    en: 'You can compare calmly after you get the first direction.',
  );

  String validateCityBannerTitle() => _localizedText(
    pt: 'Validação de cidade',
    es: 'Validación de ciudad',
    en: 'City validation',
  );

  String validateCityBannerBody() => _localizedText(
    pt: 'Busque uma cidade, abra os detalhes e compare custo, encaixe e próximos passos antes de escolher.',
    es: 'Buscá una ciudad, abrí los detalles y compará costo, encaje y próximos pasos antes de elegir.',
    en: 'Search for a city, open the details, and compare cost, fit, and next steps before choosing.',
  );

  String validateCityBannerAction() => _localizedText(
    pt: 'Se fizer sentido, você confirma a cidade depois.',
    es: 'Si tiene sentido, confirmás la ciudad después.',
    en: 'If it makes sense, you confirm the city after that.',
  );

  String questionnaireGuideStepOneTitle() => _localizedText(
    pt: 'Você define o que importa',
    es: 'Vos definís lo que importa',
    en: 'You define what matters',
  );

  String questionnaireGuideStepOneBody() => _localizedText(
    pt: 'Objetivo, orçamento, trabalho, família, estudo e prioridades ajustam a análise. Você pode revisar suas respostas.',
    es: 'Objetivo, presupuesto, trabajo, familia, estudio y prioridades ajustan el análisis. Podés revisar tus respuestas.',
    en: 'Your goal, budget, work, family, studies, and priorities shape the analysis. You can review your answers.',
  );

  String questionnaireGuideStepTwoTitle() => _localizedText(
    pt: 'Exigências viram filtros',
    es: 'Los requisitos se vuelven filtros',
    en: 'Requirements become filters',
  );

  String questionnaireGuideStepTwoBody() => _localizedText(
    pt: 'Quando você marca algo como obrigatório — como transporte, custo ou universidade — opções incompatíveis ficam fora. A lista não é completada à força.',
    es: 'Cuando marcás algo como obligatorio — como transporte, costo o universidad — las opciones incompatibles quedan afuera. La lista no se completa a la fuerza.',
    en: 'When something is mandatory — such as transit, cost, or university access — incompatible options are removed. We do not force a full list.',
  );

  String questionnaireGuideStepThreeTitle() => _localizedText(
    pt: 'Cada dado tem um papel claro',
    es: 'Cada dato tiene un papel claro',
    en: 'Every data point has a clear role',
  );

  String questionnaireGuideStepThreeBody() => _localizedText(
    pt: 'Combinamos fontes públicas e oficiais, como IBGE, INEP e Ipea, com sinais derivados ou curados identificados. O que não tem base comparável fica fora do cálculo.',
    es: 'Combinamos fuentes públicas y oficiales, como IBGE, INEP e Ipea, con señales derivadas o curadas identificadas. Lo que no tiene una base comparable queda fuera del cálculo.',
    en: 'We combine public and official sources such as IBGE, INEP, and Ipea with clearly identified derived or curated signals. Data without a comparable basis stays out of the calculation.',
  );

  String questionnaireGuideStepFourTitle() => _localizedText(
    pt: 'É uma direção, não um veredito',
    es: 'Es una orientación, no un veredicto',
    en: 'It is guidance, not a verdict',
  );

  String questionnaireGuideStepFourBody() => _localizedText(
    pt: 'O resultado mostra uma cidade em destaque, alternativas, estabilidade e limitações. É apoio educacional e comparativo — não consultoria, garantia ou decisão automática.',
    es: 'El resultado muestra una ciudad destacada, alternativas, estabilidad y limitaciones. Es apoyo educativo y comparativo, no asesoramiento, garantía ni decisión automática.',
    en: 'The result shows a highlighted city, alternatives, stability, and limitations. It is educational comparison support, not advice, a guarantee, or an automated decision.',
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

  String migrationStartFootnote() => _localizedText(
    pt: 'Você pode mudar seu plano a qualquer momento',
    es: 'Podés cambiar tu plan en cualquier momento',
    en: 'You can always change your plan later',
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
      case 'support_needs':
        return _localizedText(
          pt: 'Marque tudo que muda seus próximos passos.',
          es: 'Marcá todo lo que cambia tus próximos pasos.',
          en: 'Select everything that changes your next steps.',
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
      case 'support_needs':
        return switch (value) {
          'children_school' => _localizedText(
            pt: 'Filhos',
            es: 'Hijos',
            en: 'Children',
          ),
          'travel_with_pet' => _localizedText(
            pt: 'Pet',
            es: 'Mascota',
            en: 'Pet',
          ),
          'continuous_medication' => _localizedText(
            pt: 'Medicamentos',
            es: 'Medicación',
            en: 'Medicine',
          ),
          'foreign_income' => _localizedText(
            pt: 'Renda exterior',
            es: 'Ingreso exterior',
            en: 'Foreign income',
          ),
          'no_special_needs' => _localizedText(
            pt: 'Nada disso',
            es: 'Nada de esto',
            en: 'None',
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

  String cityDetailQuickSummaryTitle() => _localizedText(
    pt: 'Resumo rápido',
    es: 'Resumen rápido',
    en: 'Quick summary',
  );

  String cityDetailPhotosAction() =>
      _localizedText(pt: 'Fotos', es: 'Fotos', en: 'Photos');

  String cityDetailMapAction() =>
      _localizedText(pt: 'Mapa', es: 'Mapa', en: 'Map');

  String cityDetailMapOpenSheetLabel() => _localizedText(
    pt: 'Toque para ampliar',
    es: 'Tocá para ampliar',
    en: 'Tap to expand',
  );

  String cityDetailMapSheetTitle(String cityName) => _localizedText(
    pt: 'Mapa de $cityName',
    es: 'Mapa de $cityName',
    en: 'Map of $cityName',
  );

  String cityDetailMapSheetBody() => _localizedText(
    pt: 'Veja a cidade com mais espaço, aproxime o mapa e compare a distância da sua origem.',
    es: 'Mirá la ciudad con más espacio, acercá el mapa y compará la distancia desde tu origen.',
    en: 'See the city with more room, zoom in, and compare the distance from your origin.',
  );

  String cityDetailMapCurrentLocationLabel() => _localizedText(
    pt: 'Sua localização',
    es: 'Tu ubicación',
    en: 'Your location',
  );

  String cityDetailMapSheetDestinationLabel() =>
      _localizedText(pt: 'Destino', es: 'Destino', en: 'Destination');

  String cityDetailMapSheetOriginLabel() =>
      _localizedText(pt: 'Origem', es: 'Origen', en: 'Origin');

  String cityDetailMapOriginMissingLabel() => _localizedText(
    pt: 'Ative a localização para ver a distância',
    es: 'Activá la ubicación para ver la distancia',
    en: 'Turn on location to see the distance',
  );

  String cityDetailMapUnknownDistanceLabel() => _localizedText(
    pt: 'Indisponível',
    es: 'No disponible',
    en: 'Unavailable',
  );

  String cityDetailFlightsAction() =>
      _localizedText(pt: 'Voos', es: 'Vuelos', en: 'Flights');

  String cityDetailCostAction() =>
      _localizedText(pt: 'Custo', es: 'Costo', en: 'Cost');

  String cityDetailSeasonalityAction() =>
      _localizedText(pt: 'Sazonal.', es: 'Temporada', en: 'Season');

  String cityDetailAnalysisAction() =>
      _localizedText(pt: 'Análise', es: 'Análisis', en: 'Analysis');

  String cityDetailArrivalViabilityTitle() => _localizedText(
    pt: 'Viabilidade de chegada',
    es: 'Viabilidad de llegada',
    en: 'Arrival viability',
  );

  String cityDetailArrivalViabilityBody() => _localizedText(
    pt: 'Antes de decidir, veja quanto essa cidade costuma exigir no começo e onde vale focar primeiro.',
    es: 'Antes de decidir, mirá cuánto suele exigir esta ciudad al llegar y dónde conviene enfocarte primero.',
    en: 'Before deciding, check what this city usually demands at the start and where it makes sense to focus first.',
  );

  String cityDetailArrivalReserveLabel() => _localizedText(
    pt: 'Reserva base',
    es: 'Reserva base',
    en: 'Base reserve',
  );

  String cityDetailArrivalReserveSupporting(int months) => _localizedText(
    pt: 'Estimativa derivada do custo atual da cidade para cerca de $months meses de chegada.',
    es: 'Estimación derivada del costo actual de la ciudad para cerca de $months meses de llegada.',
    en: 'Estimate derived from the city current cost for roughly $months months of arrival.',
  );

  String cityDetailArrivalReserveBasis(String cityName) => _localizedText(
    pt: 'Base usada: custo mensal sem aluguel + 1 quarto em $cityName, multiplicado por uma reserva inicial.',
    es: 'Base usada: costo mensual sin alquiler + 1 ambiente en $cityName, multiplicado por una reserva inicial.',
    en: 'Base used: monthly cost excluding rent + 1-bedroom in $cityName, multiplied by an initial reserve window.',
  );

  String cityDetailArrivalReserveFallback() =>
      _localizedText(pt: 'Ver custo', es: 'Ver costo', en: 'See cost');

  String cityDetailArrivalReserveSupportingNoData() => _localizedText(
    pt: 'Abra o bloco de custo para ver a leitura mais prática dessa cidade.',
    es: 'Abrí el bloque de costo para ver la lectura más práctica de esta ciudad.',
    en: 'Open the cost block to see the more practical read for this city.',
  );

  String cityDetailArrivalPressureLabel() => _localizedText(
    pt: 'Pressão inicial',
    es: 'Presión inicial',
    en: 'Entry pressure',
  );

  String cityDetailArrivalPressureBasis(
    String housing,
    String language,
    String safety,
    String seasonality,
    String? flight,
  ) => _localizedText(
    pt: flight == null
        ? 'Base usada: moradia $housing, idioma $language, segurança $safety, sazonalidade $seasonality.'
        : 'Base usada: moradia $housing, idioma $language, segurança $safety, sazonalidade $seasonality, voo $flight.',
    es: flight == null
        ? 'Base usada: vivienda $housing, idioma $language, seguridad $safety, temporada $seasonality.'
        : 'Base usada: vivienda $housing, idioma $language, seguridad $safety, temporada $seasonality, vuelo $flight.',
    en: flight == null
        ? 'Base used: housing $housing, language $language, safety $safety, seasonality $seasonality.'
        : 'Base used: housing $housing, language $language, safety $safety, seasonality $seasonality, flight $flight.',
  );

  String cityDetailArrivalSeasonalityBasisActive() =>
      _localizedText(pt: 'ativa', es: 'activa', en: 'active');

  String cityDetailArrivalSeasonalityBasisStable() =>
      _localizedText(pt: 'estável', es: 'estable', en: 'stable');

  String cityDetailArrivalPressureLow() =>
      _localizedText(pt: 'Baixa', es: 'Baja', en: 'Low');

  String cityDetailArrivalPressureMedium() =>
      _localizedText(pt: 'Média', es: 'Media', en: 'Medium');

  String cityDetailArrivalPressureHigh() =>
      _localizedText(pt: 'Alta', es: 'Alta', en: 'High');

  String cityDetailArrivalPressureLowBody() => _localizedText(
    pt: 'A cidade parece mais administrável para começar, com menos fricção combinada entre moradia, idioma e rotina.',
    es: 'La ciudad parece más manejable para empezar, con menos fricción combinada entre vivienda, idioma y rutina.',
    en: 'The city looks more manageable to start, with less combined friction across housing, language, and routine.',
  );

  String cityDetailArrivalPressureMediumBody() => _localizedText(
    pt: 'Dá para começar bem, mas vale entrar com reserva e validar bairro, custo real e ritmo da rotina.',
    es: 'Se puede empezar bien, pero conviene entrar con reserva y validar barrio, costo real y ritmo de rutina.',
    en: 'You can start well here, but it is worth arriving with some reserve and validating neighborhood, real costs, and routine pace.',
  );

  String cityDetailArrivalPressureSeasonalBody() => _localizedText(
    pt: 'A entrada pode pesar mais se você chegar em época alta. Vale olhar moradia e temporada antes de decidir.',
    es: 'La llegada puede pesar más si caés en temporada alta. Conviene mirar vivienda y temporada antes de decidir.',
    en: 'Getting started may weigh more if you arrive in peak season. It is worth checking housing and seasonality before deciding.',
  );

  String cityDetailArrivalPressureHighBody() => _localizedText(
    pt: 'Essa cidade tende a exigir mais coordenação logo na chegada. Moradia, custo ou adaptação merecem validação extra.',
    es: 'Esta ciudad tiende a exigir más coordinación al llegar. Vivienda, costo o adaptación merecen validación extra.',
    en: 'This city tends to require more coordination at the start. Housing, cost, or adaptation deserve extra validation.',
  );

  String cityDetailFlightBurdenTitle() => _localizedText(
    pt: 'Peso da passagem',
    es: 'Peso del vuelo',
    en: 'Flight burden',
  );

  String cityDetailFlightBurdenBody() => _localizedText(
    pt: 'Essa leitura separa o custo de chegar do custo de viver. Uma cidade pode encaixar bem, mas ainda pesar na rota de entrada.',
    es: 'Esta lectura separa el costo de llegar del costo de vivir. Una ciudad puede encajar bien, pero igual pesar en la ruta de entrada.',
    en: 'This separates the cost of getting there from the cost of living there. A city may fit well and still be heavy on the entry route.',
  );

  String cityDetailFlightBurdenRangeLabel() => _localizedText(
    pt: 'Faixa da rota',
    es: 'Rango de ruta',
    en: 'Route range',
  );

  String cityDetailFlightBurdenRangeSupporting(
    String originIata,
    String destIata,
  ) => _localizedText(
    pt: 'Faixa histórica de baixa para $originIata -> $destIata. Use como referência inicial antes de abrir o preço ao vivo.',
    es: 'Rango histórico de baja para $originIata -> $destIata. Usalo como referencia inicial antes de abrir el precio en vivo.',
    en: 'Historical low-season range for $originIata -> $destIata. Use it as a starting reference before opening live pricing.',
  );

  String cityDetailFlightBurdenPressureLabel() => _localizedText(
    pt: 'Impacto na chegada',
    es: 'Impacto al llegar',
    en: 'Arrival impact',
  );

  String cityDetailFlightBurdenPressureLow() =>
      _localizedText(pt: 'Leve', es: 'Leve', en: 'Light');

  String cityDetailFlightBurdenPressureMedium() =>
      _localizedText(pt: 'Atenção', es: 'Atención', en: 'Watch');

  String cityDetailFlightBurdenPressureHigh() =>
      _localizedText(pt: 'Pesado', es: 'Pesado', en: 'Heavy');

  String cityDetailFlightBurdenPressureLowBody() => _localizedText(
    pt: 'A passagem tende a pesar menos na decisão. Ainda vale validar data e bagagem, mas a rota não costuma ser o principal bloqueio.',
    es: 'El vuelo tiende a pesar menos en la decisión. Igual conviene validar fecha y equipaje, pero la ruta no suele ser el principal bloqueo.',
    en: 'The flight tends to weigh less in the decision. It is still worth checking dates and baggage, but the route is not usually the main blocker.',
  );

  String cityDetailFlightBurdenPressureMediumBody() => _localizedText(
    pt: 'A rota já merece atenção junto com aluguel e reserva inicial. Pequenas mudanças de data podem fazer diferença.',
    es: 'La ruta ya merece atención junto con alquiler y reserva inicial. Pequeños cambios de fecha pueden hacer diferencia.',
    en: 'The route already deserves attention alongside rent and initial reserve. Small date changes can make a difference.',
  );

  String cityDetailFlightBurdenPressureHighBody() => _localizedText(
    pt: 'Aqui o voo pode virar parte real do problema. Vale comparar essa cidade com opções do sul ou do sudeste antes de fechar a decisão.',
    es: 'Acá el vuelo puede volverse parte real del problema. Conviene comparar esta ciudad con opciones del sur o sudeste antes de cerrar la decisión.',
    en: 'Here the flight can become a real part of the problem. It is worth comparing this city with southern or southeastern options before locking the decision.',
  );

  String cityDetailFlightBurdenPressureBasis(String value, String route) =>
      _localizedText(
        pt: 'Base usada: baixa histórica em $value para a rota $route.',
        es: 'Base usada: piso histórico de $value para la ruta $route.',
        en: 'Base used: historical low range of $value for the $route route.',
      );

  String cityDetailFlightBurdenTradeoffLabel() => _localizedText(
    pt: 'Trade-off com outras cidades',
    es: 'Trade-off con otras ciudades',
    en: 'Trade-off vs other cities',
  );

  String cityDetailFlightBurdenTradeoffBody(
    String cheaperCity,
    String cheaperRange,
    String currentRange,
  ) => _localizedText(
    pt: 'Chegar aqui tende a custar mais do que chegar em $cheaperCity. Faixa desta rota: $currentRange. Faixa em $cheaperCity: $cheaperRange.',
    es: 'Llegar acá tiende a costar más que llegar a $cheaperCity. Rango de esta ruta: $currentRange. Rango en $cheaperCity: $cheaperRange.',
    en: 'Getting here tends to cost more than getting to $cheaperCity. This route range: $currentRange. $cheaperCity range: $cheaperRange.',
  );

  String cityDetailFlightBurdenSource() => _localizedText(
    pt: 'Fonte: histórico de rotas do Movaro (USD) + comparação ao vivo em Google Flights/Skyscanner',
    es: 'Fuente: historial de rutas de Movaro (USD) + comparación en vivo en Google Flights/Skyscanner',
    en: 'Source: Movaro route history (USD) + live comparison on Google Flights/Skyscanner',
  );

  String migrationResultFlightTradeoffTitle() => _localizedText(
    pt: 'Atenção com o voo',
    es: 'Atención con el vuelo',
    en: 'Watch the flight',
  );

  String migrationResultFlightTradeoffBody(
    String currentCity,
    String currentRange,
    String cheaperCity,
    String cheaperRange,
  ) => _localizedText(
    pt: '$currentCity pode encaixar melhor no perfil, mas a chegada tende a pesar mais no voo. Faixa estimada: $currentRange. Em $cheaperCity, a faixa histórica fica em $cheaperRange.',
    es: '$currentCity puede encajar mejor con tu perfil, pero la llegada tiende a pesar más en el vuelo. Rango estimado: $currentRange. En $cheaperCity, el rango histórico queda en $cheaperRange.',
    en: '$currentCity may fit your profile better, but getting there tends to weigh more on airfare. Estimated range: $currentRange. In $cheaperCity, the historical range sits at $cheaperRange.',
  );

  String cityDetailArrivalFirstFocusLabel() =>
      _localizedText(pt: 'Primeiro foco', es: 'Primer foco', en: 'First focus');

  String cityDetailArrivalFocusBasis(String headline, String value) =>
      _localizedText(
        pt: 'Dado usado: $headline ($value).',
        es: 'Dato usado: $headline ($value).',
        en: 'Data used: $headline ($value).',
      );

  String cityDetailArrivalSourceLabel(String source) => _localizedText(
    pt: 'Fonte: $source',
    es: 'Fuente: $source',
    en: 'Source: $source',
  );

  String cityDetailArrivalFocusHousing() =>
      _localizedText(pt: 'Moradia', es: 'Vivienda', en: 'Housing');

  String cityDetailArrivalFocusLanguage() =>
      _localizedText(pt: 'Idioma', es: 'Idioma', en: 'Language');

  String cityDetailArrivalFocusWork() =>
      _localizedText(pt: 'Renda', es: 'Ingresos', en: 'Income');

  String cityDetailArrivalFocusSafety() => _localizedText(
    pt: 'Bairro e rotina',
    es: 'Barrio y rutina',
    en: 'Neighborhood & routine',
  );

  String cityDetailArrivalFocusHousingBody() => _localizedText(
    pt: 'Vale validar aluguel, garantia, entrada e bairro antes de assumir compromisso maior.',
    es: 'Conviene validar alquiler, garantía, costo de entrada y barrio antes de asumir un compromiso mayor.',
    en: 'It is worth validating rent, guarantees, entry costs, and neighborhood before taking on a larger commitment.',
  );

  String cityDetailArrivalFocusLanguageBody() => _localizedText(
    pt: 'A adaptação com o português pode pesar mais no começo. Rotina, atendimento e busca por moradia pedem mais atenção.',
    es: 'La adaptación con el portugués puede pesar más al principio. Rutina, atención y búsqueda de vivienda piden más cuidado.',
    en: 'Adapting to Portuguese may weigh more at the start. Routine, services, and housing search will need more attention.',
  );

  String cityDetailArrivalFocusWorkBody() => _localizedText(
    pt: 'Antes de escolher, vale confirmar se sua forma de renda combina com o ritmo e as oportunidades dessa cidade.',
    es: 'Antes de elegir, conviene confirmar si tu forma de ingresos encaja con el ritmo y las oportunidades de esta ciudad.',
    en: 'Before choosing, it is worth confirming whether your income path matches the pace and opportunities of this city.',
  );

  String cityDetailArrivalFocusSafetyBody() => _localizedText(
    pt: 'Aqui faz diferença validar bairro, deslocamento e rotina real antes de definir a base da mudança.',
    es: 'Acá hace diferencia validar barrio, traslados y rutina real antes de definir la base de la mudanza.',
    en: 'Here it makes a difference to validate neighborhood, commute, and real routine before locking the base of the move.',
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
    pt: 'Faixa de aderência',
    es: 'Nivel de afinidad',
    en: 'Match band',
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

  /// Labels for city signals shown in the recommendation breakdown.
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
    pt: 'A cidade em destaque e o plano atual serão descartados.',
    es: 'La ciudad destacada y el plan actual se descartarán.',
    en: 'The highlighted city and current plan will be discarded.',
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

  String citySelectorTapToSelect() => _localizedText(
    pt: 'Toque no nome da cidade no mapa',
    es: 'Toca el nombre de la ciudad en el mapa',
    en: 'Tap the city name on the map',
  );

  String citySelectorRegionAll() =>
      _localizedText(pt: 'Todas', es: 'Todas', en: 'All');

  String citySelectorRegionSouthSE() => _localizedText(
    pt: 'Sul / Sudeste',
    es: 'Sur / Sudeste',
    en: 'South / SE',
  );

  String citySelectorRegionNE() =>
      _localizedText(pt: 'Nordeste', es: 'Nordeste', en: 'Northeast');

  String citySelectorRegionCW() => _localizedText(
    pt: 'Centro-Oeste',
    es: 'Centro-Oeste',
    en: 'Central-West',
  );

  String citySelectorRegionNorth() =>
      _localizedText(pt: 'Norte', es: 'Norte', en: 'North');

  String citySelectorNoSelection() => _localizedText(
    pt: 'Selecione uma cidade',
    es: 'Selecciona una ciudad',
    en: 'Select a city',
  );

  // ── Preferred City Questionnaire Step ──────────────────────────────────

  String preferredCityQuestionTitle() => _localizedText(
    pt: 'Como voce quer comecar?',
    es: 'Como queres empezar?',
    en: 'How do you want to start?',
  );

  String preferredCityQuestionSubtitle() => _localizedText(
    pt: 'Voce pode partir de uma cidade ou ver sugestoes baseadas no seu perfil',
    es: 'Podes partir de una ciudad o ver sugerencias basadas en tu perfil',
    en: 'You can start from a city or see suggestions based on your profile',
  );

  String preferredCityStartWithCityTitle() => _localizedText(
    pt: 'Comecar com uma cidade',
    es: 'Empezar con una ciudad',
    en: 'Start with a city',
  );

  String preferredCityStartWithCitySubtitle() => _localizedText(
    pt: 'Escolha um lugar para usar como base do seu plano',
    es: 'Elegi un lugar para usar como base de tu plan',
    en: 'Choose a place to use as the base of your plan',
  );

  String preferredCityChooseCityLabel() => _localizedText(
    pt: 'Escolher cidade',
    es: 'Elegir ciudad',
    en: 'Choose city',
  );

  String preferredCitySuggestionsTitle() => _localizedText(
    pt: 'Ver sugestoes para mim',
    es: 'Ver sugerencias para mi',
    en: 'See suggestions for me',
  );

  String preferredCitySuggestionsSubtitle() => _localizedText(
    pt: 'A gente encontra boas opcoes com base no seu perfil',
    es: 'Encontramos buenas opciones segun tu perfil',
    en: 'We find good options based on your profile',
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
    pt: '$cityName também aparece entre os encaixes mais fortes com base no seu perfil.',
    es: '$cityName también aparece entre los encajes más fuertes según tu perfil.',
    en: '$cityName also appears among the stronger matches based on your profile.',
  );

  String antiAnchorComparisonTitle(String preferredCity) => _localizedText(
    pt: 'Você pensou em $preferredCity — ótima cidade!',
    es: 'Pensaste en $preferredCity — ¡gran ciudad!',
    en: 'You thought about $preferredCity — great city!',
  );

  String antiAnchorComparisonBody(
    String preferredCity,
    String highlightedCity,
  ) => _localizedText(
    pt: 'Mas com base no seu perfil, $highlightedCity também aparece como um encaixe forte. Veja a comparação:',
    es: 'Pero según tu perfil, $highlightedCity también aparece como un encaje fuerte. Mirá la comparación:',
    en: 'But based on your profile, $highlightedCity also appears as a strong match. See the comparison:',
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
      case 'step_education_admission_route':
        return _localizedText(
          pt: 'Defina sua rota de ingresso no ensino superior',
          es: 'Define tu vía de ingreso a la educación superior',
          en: 'Choose your higher-education admission route',
        );
      case 'step_education_documents':
        return _localizedText(
          pt: 'Prepare seus documentos acadêmicos',
          es: 'Prepara tus documentos académicos',
          en: 'Prepare your academic documents',
        );
      case 'step_school_enrollment':
        return _localizedText(
          pt: 'Planeje a matrícula escolar das crianças',
          es: 'Planifica la matrícula escolar de los niños',
          en: 'Plan children’s school enrollment',
        );
      default:
        return value;
    }
  }

  String guideActionTitleLabel(String value) {
    switch (value) {
      case 'item_0_1_rule_90_days':
        return _localizedText(
          pt: 'Entender a regra dos 90 dias',
          es: 'Entender la regla de los 90 días',
          en: 'Understand the 90-day rule',
        );
      case 'item_0_2_antecedentes':
        return _localizedText(
          pt: 'Providenciar certificado de antecedentes criminais',
          es: 'Gestionar certificado de antecedentes penales',
          en: 'Get your criminal record certificate',
        );
      case 'item_0_3_budget':
        return _localizedText(
          pt: 'Calcular quanto você vai precisar nos primeiros meses',
          es: 'Calcular cuánto vas a necesitar en los primeros meses',
          en: 'Estimate what you need for the first months',
        );
      case 'item_1_3_money':
        return _localizedText(
          pt: 'Organizar o dinheiro para os primeiros dias',
          es: 'Organizar el dinero para los primeros días',
          en: 'Organize money for the first days',
        );
      case 'item_0_4_flight':
        return flightPlannerTitle();
      case 'item_1_1_chip':
        return _localizedText(
          pt: 'Comprar chip de celular brasileiro',
          es: 'Comprar un chip de celular brasileño',
          en: 'Buy a Brazilian SIM card',
        );
      case 'item_1_2_housing_temporary':
        return _localizedText(
          pt: 'Garantir onde ficar nos primeiros 30 a 60 dias',
          es: 'Asegurar dónde quedarte en los primeros 30 a 60 días',
          en: 'Secure where to stay for the first 30 to 60 days',
        );
      case 'item_2_1_cpf':
        return _localizedText(
          pt: 'Organizar o CPF',
          es: 'Resolver el CPF',
          en: 'Sort out your CPF',
        );
      case 'item_2_2_residencia':
        return _localizedText(
          pt: 'Iniciar residência Mercosul na Polícia Federal',
          es: 'Iniciar residencia Mercosur en la Policía Federal',
          en: 'Start Mercosur residence at the Federal Police',
        );
      case 'item_4_5_registro_rnm':
        return _localizedText(
          pt: 'Acompanhar registro RNM e CRNM',
          es: 'Seguir registro RNM y CRNM',
          en: 'Track RNM and CRNM registration',
        );
      case 'item_2_3_ctps':
        return _localizedText(
          pt: 'Emitir a Carteira de Trabalho Digital',
          es: 'Emitir la Carteira de Trabalho Digital',
          en: 'Issue the digital work card',
        );
      case 'item_3_1_conta_bancaria':
        return _localizedText(
          pt: 'Abrir conta bancária no Brasil',
          es: 'Abrir una cuenta bancaria en Brasil',
          en: 'Open a bank account in Brazil',
        );
      case 'item_3_2_aluguel_fixo':
        return _localizedText(
          pt: 'Buscar aluguel fixo na sua cidade',
          es: 'Buscar alquiler fijo en tu ciudad',
          en: 'Search for a long-term rental in your city',
        );
      case 'item_3_3_pix':
        return _localizedText(
          pt: 'Entender como funcionam os pagamentos no Brasil',
          es: 'Entender cómo funcionan los pagos en Brasil',
          en: 'Understand how payments work in Brazil',
        );
      case 'item_3_4_trabalho':
        return _localizedText(
          pt: 'Estruturar sua renda no Brasil',
          es: 'Estructurar tus ingresos en Brasil',
          en: 'Structure your income in Brazil',
        );
      case 'item_3_5_revalidacao_estudos':
        return _localizedText(
          pt: 'Verificar se seu diploma precisa de revalidação',
          es: 'Verificar si tu diploma necesita revalidación',
          en: 'Check whether your diploma needs validation',
        );
      case 'item_4_1_cnh':
        return _localizedText(
          pt: 'Converter a carteira argentina para CNH brasileira',
          es: 'Convertir la licencia argentina en CNH brasileña',
          en: 'Convert your Argentine license to a Brazilian license',
        );
      case 'item_4_2_saude':
        return _localizedText(
          pt: 'Cuidar da saúde no Brasil',
          es: 'Resolver la salud en Brasil',
          en: 'Handle healthcare in Brazil',
        );
      case 'item_4_3_permanencia':
        return _localizedText(
          pt: 'Transformar a residência temporária em permanente',
          es: 'Transformar la residencia temporaria en permanente',
          en: 'Turn temporary residence into permanent residence',
        );
      case 'item_4_4_mei':
        return _localizedText(
          pt: 'Abrir MEI para trabalhar como autônomo',
          es: 'Abrir MEI para trabajar como autónomo',
          en: 'Open an MEI to work independently',
        );
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
      case 'step_desc_education_admission_route':
        return _localizedText(
          pt: 'Compare Enem/Sisu, vestibular próprio, transferência, PEC-G e processos internacionais da instituição.',
          es: 'Compara Enem/Sisu, examen propio, transferencia, PEC-G y procesos internacionales de la institución.',
          en: 'Compare Enem/Sisu, institution exams, transfer, PEC-G, and international admission routes.',
        );
      case 'step_desc_education_documents':
        return _localizedText(
          pt: 'Confirme no edital diploma ou certificado, histórico, apostilamento, tradução e proficiência exigidos.',
          es: 'Confirma en la convocatoria diploma o certificado, historial, apostilla, traducción y dominio del idioma exigidos.',
          en: 'Check the rules for certificates, transcripts, apostilles, translations, and language proficiency.',
        );
      case 'step_desc_school_enrollment':
        return _localizedText(
          pt: 'Localize a rede pública ou particular e reúna os documentos disponíveis sem adiar o direito à matrícula.',
          es: 'Ubica la red pública o privada y reúne los documentos disponibles sin postergar el derecho a matrícula.',
          en: 'Find the public or private school network and gather available documents without delaying enrollment rights.',
        );
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
      case 'education':
        return _localizedText(pt: 'Educação', es: 'Educación', en: 'Education');
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
