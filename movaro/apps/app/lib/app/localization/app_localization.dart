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
      case 'portuguese_familiarity':
        return questionPortugueseFamiliarityTitle;
      case 'timeline':
        return questionTimelineTitle;
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
      case 'portuguese_familiarity':
        return portugueseFamiliarityLabel(value);
      case 'timeline':
        return timelineLabel(value);
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
      case 'remote_work':
      case 'Trabalhar remoto':
        return questionOptionRemoteWork;
      case 'study':
      case 'Estudar':
        return questionOptionStudy;
      case 'entrepreneur':
      case 'Empreender':
        return questionOptionEntrepreneur;
      case 'retire':
      case 'Aposentar':
        return questionOptionRetire;
      case 'quality_of_life':
      case 'Qualidade de vida':
        return questionOptionQualityOfLife;
      case 'beach_life':
      case 'Praia e litoral':
        return questionOptionBeachLife;
      default:
        return value;
    }
  }

  String timelineLabel(String value) {
    switch (value) {
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
        return recommendationReasonEconomical;
      case 'Popular entre argentinos':
        return recommendationReasonPopularArgentina;
      case 'Melhor adaptação para quem ainda não fala português':
        return recommendationReasonLanguageSupport;
      case 'Mercado de trabalho mais forte':
        return recommendationReasonWorkMarket;
      case 'Custo mais alto, mas melhor infraestrutura':
        return recommendationReasonInfrastructure;
      case 'Opção equilibrada dentro do catálogo inicial do MVP':
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
      default:
        return value;
    }
  }

  String referenceSourceName(String value) {
    switch (value) {
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
      case 'banco_central_brasil':
        return sourceProviderBancoCentralBrasil;
      case 'movaro':
        return sourceProviderMovaro;
      default:
        return value;
    }
  }
}
