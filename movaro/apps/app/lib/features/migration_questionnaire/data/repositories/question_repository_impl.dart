import 'package:movaro_app/core/catalog/domain/repositories/catalog_repository.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/available_capital_ranges_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/option_model.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/question_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/question.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  const QuestionRepositoryImpl({
    required CatalogRepository catalogRepository,
    required JourneyContextController journeyContextController,
  }) : _catalogRepository = catalogRepository,
       _journeyContextController = journeyContextController;

  final CatalogRepository _catalogRepository;
  final JourneyContextController _journeyContextController;

  @override
  Future<List<Question>> getQuestions() async {
    await AvailableCapitalRangesStore.load();
    final countries = await _catalogRepository.getCountries();

    final destinationCountryId = _journeyContextController.destinationCountryId;
    final selectedDestination = _journeyContextController.selectedDestination;
    final effectiveDestination =
        selectedDestination ??
        countries.where((country) => country.id == 'brasil').firstOrNull;
    final effectiveDestinationId =
        destinationCountryId ?? effectiveDestination?.id;
    if (effectiveDestination == null ||
        effectiveDestinationId == null ||
        !_journeyContextController.canUseAsDestination(effectiveDestination)) {
      return const [];
    }

    final originOptions = _journeyContextController.availableOrigins
        .where(
          (country) =>
              _journeyContextController.canUseAsOrigin(country) &&
              country.id != effectiveDestinationId &&
              _journeyContextController.isRouteSupported(
                originCountryId: country.id,
                destinationCountryId: effectiveDestinationId,
              ),
        )
        .map(
          (country) => OptionModel(
            id: country.id,
            label: country.name,
            value: country.journeyValue,
          ),
        )
        .toList(growable: false);

    return [
      QuestionModel(
        id: 'origin_country',
        title: 'origin_country',
        type: 'single_card',
        variants: QuestionnaireVariant.values,
        options: originOptions,
      ).toEntity(),
      QuestionModel(
        id: 'timeline',
        title: 'timeline',
        type: 'single_chip',
        variants: QuestionnaireVariant.values,
        options: const [
          OptionModel(
            id: 'just_exploring',
            label: 'just_exploring',
            value: 'just_exploring',
          ),
          OptionModel(id: 'in_0_3m', label: 'in_0_3m', value: 'in_0_3m'),
          OptionModel(id: 'in_3_6m', label: 'in_3_6m', value: 'in_3_6m'),
          OptionModel(id: 'in_6_12m', label: 'in_6_12m', value: 'in_6_12m'),
          OptionModel(
            id: 'in_12m_plus',
            label: 'in_12m_plus',
            value: 'in_12m_plus',
          ),
          OptionModel(id: 'depends', label: 'depends', value: 'depends'),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'travel_group',
        title: 'travel_group',
        type: 'single_card',
        variants: const [QuestionnaireVariant.strategic],
        options: const [
          OptionModel(id: 'solo', label: 'solo', value: 'solo'),
          OptionModel(id: 'partner', label: 'partner', value: 'partner'),
          OptionModel(
            id: 'family_no_kids',
            label: 'family_no_kids',
            value: 'family_no_kids',
          ),
          OptionModel(
            id: 'family_kids',
            label: 'family_kids',
            value: 'family_kids',
          ),
          OptionModel(id: 'undecided', label: 'undecided', value: 'undecided'),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'priorities',
        title: 'priorities',
        type: 'multi_chip',
        maxSelections: 3,
        variants: QuestionnaireVariant.values,
        options: const [
          OptionModel(id: 'low_cost', label: 'low_cost', value: 'low_cost'),
          OptionModel(
            id: 'job_opportunities',
            label: 'job_opportunities',
            value: 'job_opportunities',
          ),
          OptionModel(id: 'safety', label: 'safety', value: 'safety'),
          OptionModel(
            id: 'warm_climate_beach',
            label: 'warm_climate_beach',
            value: 'warm_climate_beach',
          ),
          OptionModel(
            id: 'transit_infra',
            label: 'transit_infra',
            value: 'transit_infra',
          ),
          OptionModel(id: 'nature', label: 'nature', value: 'nature'),
          OptionModel(
            id: 'university',
            label: 'university',
            value: 'university',
          ),
          OptionModel(id: 'community', label: 'community', value: 'community'),
          OptionModel(
            id: 'close_to_argentina',
            label: 'close_to_argentina',
            value: 'close_to_argentina',
          ),
          OptionModel(
            id: 'balanced_unsure',
            label: 'balanced_unsure',
            value: 'balanced_unsure',
          ),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'constraints',
        title: 'constraints',
        type: 'multi_chip',
        maxSelections: 2,
        isOptional: true,
        variants: [QuestionnaireVariant.strategic],
        options: const [
          OptionModel(
            id: 'prefer_south',
            label: 'prefer_south',
            value: 'prefer_south',
          ),
          OptionModel(
            id: 'need_big_city',
            label: 'need_big_city',
            value: 'need_big_city',
          ),
          OptionModel(
            id: 'prefer_mid_city',
            label: 'prefer_mid_city',
            value: 'prefer_mid_city',
          ),
          OptionModel(
            id: 'want_coast',
            label: 'want_coast',
            value: 'want_coast',
          ),
          OptionModel(
            id: 'prefer_cooler',
            label: 'prefer_cooler',
            value: 'prefer_cooler',
          ),
          OptionModel(
            id: 'need_transit',
            label: 'need_transit',
            value: 'need_transit',
          ),
          OptionModel(
            id: 'avoid_expensive',
            label: 'avoid_expensive',
            value: 'avoid_expensive',
          ),
          OptionModel(
            id: 'no_constraints',
            label: 'no_constraints',
            value: 'no_constraints',
          ),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'funding',
        title: 'funding',
        type: 'single_card',
        variants: QuestionnaireVariant.values,
        options: const [
          OptionModel(id: 'savings', label: 'savings', value: 'savings'),
          OptionModel(
            id: 'remote_income',
            label: 'remote_income',
            value: 'remote_income',
          ),
          OptionModel(
            id: 'job_search',
            label: 'job_search',
            value: 'job_search',
          ),
          OptionModel(id: 'job_offer', label: 'job_offer', value: 'job_offer'),
          OptionModel(
            id: 'family_support',
            label: 'family_support',
            value: 'family_support',
          ),
          OptionModel(id: 'dont_know', label: 'dont_know', value: 'dont_know'),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'available_capital',
        title: 'available_capital',
        type: 'single_card',
        isOptional: true,
        variants: const [QuestionnaireVariant.strategic],
        options: const [
          OptionModel(id: 'low', label: 'low', value: 'low'),
          OptionModel(id: 'medium', label: 'medium', value: 'medium'),
          OptionModel(id: 'high', label: 'high', value: 'high'),
          OptionModel(id: 'very_high', label: 'very_high', value: 'very_high'),
          OptionModel(
            id: 'prefer_not_say',
            label: 'prefer_not_say',
            value: 'prefer_not_say',
          ),
        ],
      ).toEntity(),
      QuestionModel(
        id: 'intent',
        title: 'intent',
        type: 'single_card',
        variants: QuestionnaireVariant.values,
        options: const [
          OptionModel(
            id: 'find_job_br',
            label: 'find_job_br',
            value: 'find_job_br',
          ),
          OptionModel(
            id: 'remote_income',
            label: 'remote_income',
            value: 'remote_income',
          ),
          OptionModel(id: 'study', label: 'study', value: 'study'),
          OptionModel(
            id: 'family_partner',
            label: 'family_partner',
            value: 'family_partner',
          ),
          OptionModel(
            id: 'fresh_start',
            label: 'fresh_start',
            value: 'fresh_start',
          ),
          OptionModel(
            id: 'explore_unsure',
            label: 'explore_unsure',
            value: 'explore_unsure',
          ),
        ],
      ).toEntity(),
    ];
  }
}
