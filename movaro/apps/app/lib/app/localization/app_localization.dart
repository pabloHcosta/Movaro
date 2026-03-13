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
      case 'priorities':
        return qPrioritiesPrompt;
      case 'constraints':
        return qConstraintsPrompt;
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
      case 'priorities':
        return priorityLabel(value);
      case 'constraints':
        return constraintLabel(value);
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
