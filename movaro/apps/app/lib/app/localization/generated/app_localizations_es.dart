// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get homeTitle => 'Movaro';

  @override
  String get homeEnvironmentLabel => 'Entorno actual';

  @override
  String environmentValue(String environment) {
    return '$environment';
  }

  @override
  String get splashLoadingLabel => 'Preparando tu experiencia';

  @override
  String get splashHeroTitle => 'Planificación migratoria con más claridad.';

  @override
  String get splashHeroBody =>
      'Cargando ciudades, costos y contexto práctico para armar tu ruta inicial.';

  @override
  String get splashInitializingLabel => 'Iniciando la experiencia';

  @override
  String get loadingCountriesLabel => 'Cargando países';

  @override
  String get loadingCitiesCatalogLabel => 'Cargando catálogo de ciudades';

  @override
  String get journeySetupPageTitle => 'Elegí tu trayecto';

  @override
  String get journeySetupHeroTitle =>
      'Empezá definiendo desde dónde salís y a dónde querés ir';

  @override
  String get journeySetupHeroBody =>
      'Movaro usa esta elección para armar la experiencia correcta para vos. Hoy, el beta está disponible para Argentina -> Brasil, pero la estructura ya está pensada para crecer a nivel global.';

  @override
  String get journeyOriginTitle => 'País de origen';

  @override
  String get journeyOriginBody =>
      'Elegí el país desde el que salís. Esto ayuda a contextualizar idioma, trámites y adaptación.';

  @override
  String get journeyDestinationTitle => 'País de destino';

  @override
  String get journeyDestinationBody =>
      'Elegí el país que querés evaluar. La home y el plan pasan a reflejar ese destino.';

  @override
  String get journeySummaryTitle => 'Tu trayecto actual';

  @override
  String journeySummaryValue(String origin, String destination) {
    return '$origin -> $destination';
  }

  @override
  String get journeySummaryPlaceholder =>
      'Seleccioná origen y destino para continuar.';

  @override
  String get journeyAvailabilityNote =>
      'Hoy, solo el trayecto Argentina -> Brasil está disponible para uso completo. Los demás países ya aparecen para señalar la dirección global del producto.';

  @override
  String get journeyContinueAction => 'Continuar con este trayecto';

  @override
  String get journeyAvailableNowLabel => 'Disponible ahora';

  @override
  String get journeyComingSoonLabel => 'Próximamente';

  @override
  String get journeyChangeAction => 'Cambiar trayecto';

  @override
  String get publicHomeHeadline => 'Planificá tu mudanza con más claridad';

  @override
  String get publicHomeDescription =>
      'Entendé tus opciones en pocos pasos antes de decidir qué querés guardar.';

  @override
  String get publicHomeScopeBadge => 'Hoy: Argentina -> Brasil';

  @override
  String get publicHomeFocusedDescription =>
      'Hoy, Movaro está diseñado para quienes están evaluando una mudanza de Argentina a Brasil. En vez de mostrar todo de una sola vez, te ayuda a elegir el mejor primer paso.';

  @override
  String publicHomeSelectedJourneyDescription(
    String origin,
    String destination,
  ) {
    return 'Movaro va a organizar tu experiencia para el trayecto $origin -> $destination. Empezás con lo esencial y profundizás solo cuando haga falta.';
  }

  @override
  String get publicHomePrimaryQuestionTitle =>
      'Empezá por la decisión principal';

  @override
  String get publicHomePrimaryQuestionBody =>
      'Primero, definí si necesitás un plan guiado, comparar ciudades o solo una vista rápida de lo que resuelve el producto.';

  @override
  String get publicHomeTrustFastTitle => 'Entrada rápida';

  @override
  String get publicHomeTrustFastBody =>
      'Podés empezar sin un formulario largo ni un bloqueo inicial.';

  @override
  String get publicHomeTrustGuestTitle => 'Sin login por ahora';

  @override
  String get publicHomeTrustGuestBody =>
      'Explorá como visitante y entrá solo cuando tenga sentido guardar algo.';

  @override
  String get publicHomeTrustFocusTitle => 'Alcance claro';

  @override
  String get publicHomeTrustFocusBody =>
      'Este beta está enfocado en el corredor Argentina -> Brasil.';

  @override
  String publicHomeTrustSelectedBody(String origin, String destination) {
    return 'Tu navegación ahora está contextualizada para $origin -> $destination, sin adelantar contenido irrelevante antes de elegir.';
  }

  @override
  String get publicHomeFirstStepTitle => 'Elegí tu primer paso';

  @override
  String get publicHomeFirstStepBody =>
      'La home ahora orienta la entrada. El contenido más profundo aparece después, dentro del camino que elijas.';

  @override
  String get publicHomeSecondaryTitle => 'La documentación viene después';

  @override
  String get publicHomeSecondaryBody =>
      'La guía práctica de Brasil sigue disponible, pero como apoyo. Tiene más sentido después de entender si querés generar un plan o comparar ciudades.';

  @override
  String get publicHomeSecondaryGenericBody =>
      'Cuando un nuevo destino esté disponible, la documentación y los detalles locales deberían aparecer como apoyo contextual, no como ruido en la primera pantalla.';

  @override
  String get publicHomeExploreAction => 'Explorar más';

  @override
  String get publicHomeQuestionnaireAction => 'Crear mi plan';

  @override
  String get publicHomeLoginAction => 'Entrar cuando necesite guardar';

  @override
  String get publicHomeGuestSectionTitle => 'Podés empezar en modo visitante';

  @override
  String get publicHomeGuestSectionBody =>
      'Podés explorar todo esto sin entrar. El inicio de sesión aparece solo cuando tiene sentido guardar algo personal.';

  @override
  String get publicHomeBetaSectionBody =>
      'Este beta ya abre lo que está listo: exploración, documentación práctica y tu primer plan.';

  @override
  String get publicHomeHowItWorksAction => 'Ver cómo funciona';

  @override
  String get publicHomeCitiesTitle => 'Descubrir ciudades';

  @override
  String get publicHomeCitiesBody =>
      'Mirá sugerencias por costo, trabajo y popularidad entre argentinos.';

  @override
  String get publicHomeCitiesAction => 'Ver ciudades';

  @override
  String get publicHomeQuestionsTitle => 'Guía práctica';

  @override
  String get publicHomeQuestionsBody =>
      'Abrí la guía para entender documentos, salud, vivienda y costos iniciales sin investigación dispersa.';

  @override
  String get publicHomeQuestionsAction => 'Resolver dudas';

  @override
  String get homeHeroWelcomeDefault => 'Bienvenido a Movaro';

  @override
  String get homeHeroWelcomeBack => 'Continuá donde lo dejaste';

  @override
  String homeHeroGreetingMorning(Object name) {
    return 'Buen día, $name';
  }

  @override
  String homeHeroGreetingAfternoon(Object name) {
    return 'Buenas tardes, $name';
  }

  @override
  String homeHeroGreetingEvening(Object name) {
    return 'Buenas noches, $name';
  }

  @override
  String get homeHeroSubtitleNoPlan => 'Planificá tu mudanza';

  @override
  String get homeHeroSubtitleWithPlan => 'Continuá donde lo dejaste';

  @override
  String get homeHeroOriginLabel => 'Origen';

  @override
  String get homeHeroDestinationLabel => 'Destino';

  @override
  String get homeHeroNoPlanTitle => 'Tu plan migratorio en 3 pasos';

  @override
  String get homeHeroNoPlanBody =>
      'Respondé el cuestionario y recibí una ciudad recomendada para tu perfil.';

  @override
  String get homeHeroStepQuestionnaire => 'Responder cuestionario';

  @override
  String get homeHeroStepCity => 'Recibir ciudad ideal';

  @override
  String get homeHeroStepGuide => 'Ejecutar con guía';

  @override
  String get homeHeroStartAction => 'Armar mi plan -> lleva ~5 min';

  @override
  String get homeHeroPlanActiveBadge => 'Plan activo';

  @override
  String get homeHeroSelectedCityEyebrow => 'Tu ciudad elegida';

  @override
  String get homeHeroProgressLabel => 'Progreso general del plan';

  @override
  String get homeHeroStageMetricLabel => 'ETAPA';

  @override
  String get homeHeroStageTotalValue => '5';

  @override
  String get homeHeroCostMetricLabel => 'COSTO';

  @override
  String get homeHeroClimateMetricLabel => 'CLIMA';

  @override
  String get homeHeroNextStepLabel => 'PRÓXIMA ETAPA';

  @override
  String get homeHeroContinueAction => 'Continuar plan ->';

  @override
  String get homeHeroDiscoverCitiesBody => 'Costo, trabajo y calidad de vida';

  @override
  String homeHeroDiscoverCitiesBodyWithCity(Object city) {
    return 'Ver alternativas a $city';
  }

  @override
  String get homeHeroExploreAction => 'Explorar ->';

  @override
  String get homeHeroGuideBody => 'Documentos y llegada a Brasil';

  @override
  String get homeHeroOpenGuideAction => 'Abrir guía ->';

  @override
  String get homeHeroOpenShortAction => 'Abrir ->';

  @override
  String get homeHeroExploreSectionTitle => 'Explorar';

  @override
  String get homeHeroPlanCompleteTask => 'Revisar plan completado';

  @override
  String get publicHomePlanTitle => 'Crear mi plan';

  @override
  String get publicHomePlanBody =>
      'Respondé pocas preguntas y recibí un plan inicial con sugerencias más claras.';

  @override
  String get publicHomeJourneyDraftTitle =>
      'Empezá tu plan con el destino ya definido';

  @override
  String publicHomeJourneyDraftBody(Object destination) {
    return 'Tu destino es $destination. Ahora respondé pocas preguntas y contanos desde dónde salís para que Movaro genere el plan correcto.';
  }

  @override
  String get publicHomeStoriesTitle => 'Leer experiencias reales';

  @override
  String get publicHomeStoriesBody =>
      'Entendé qué están buscando otras personas antes de decidir tu siguiente paso.';

  @override
  String get publicHomeStoriesAction => 'Explorar historias';

  @override
  String get decisionSupportTitle =>
      'Empezá por la pregunta que más te importa';

  @override
  String get decisionSupportBody =>
      'Quien piensa en mudarse suele buscar respuestas rápidas sobre idioma, costo, papeles y trabajo. Movaro debería dejar eso claro desde el inicio.';

  @override
  String get decisionSupportLanguageTitle =>
      '¿Voy a poder manejarme sin portugués al principio?';

  @override
  String get decisionSupportLanguageBody =>
      'Usá la señal de adaptación al idioma para ver qué lugares se sienten más fáciles si todavía dependés del español.';

  @override
  String get decisionSupportCostTitle =>
      '¿La vida diaria se va a sentir demasiado cara?';

  @override
  String get decisionSupportCostBody =>
      'Compará ciudades por costo y alquiler antes de profundizar en un destino.';

  @override
  String get decisionSupportPaperworkTitle =>
      '¿Cuáles son los primeros trámites que tendría que hacer?';

  @override
  String get decisionSupportPaperworkBody =>
      'El plan guiado convierte esa duda en una lista corta, en vez de una investigación interminable.';

  @override
  String get decisionSupportWorkTitle =>
      '¿Dónde conviene empezar si necesito estructura o trabajo?';

  @override
  String get decisionSupportWorkBody =>
      'El cuestionario y el ranking ayudan a reducir la búsqueda a ciudades con mejor encaje inicial.';

  @override
  String get commonNeedsTitle => 'Si todavía no sabés por dónde empezar';

  @override
  String get commonNeedsBody =>
      'Estos son los atajos más útiles para quien llega con dudas mezcladas y quiere bajar la ansiedad antes de decidir.';

  @override
  String get commonNeedCompareCostTitle =>
      'Quiero comparar costo y alquiler primero';

  @override
  String get commonNeedCompareCostBody =>
      'Andá directo a ciudades y usá las señales de costo, alquiler, idioma y trabajo como primera lectura.';

  @override
  String get commonNeedDocumentsTitle =>
      'Necesito entender los documentos antes que nada';

  @override
  String get commonNeedDocumentsBody =>
      'La guía de documentación resume CPF, registro, permanencia, trabajo y banco con fuente oficial y lenguaje simple.';

  @override
  String get commonNeedDirectionTitle => 'Todavía no sé qué camino me conviene';

  @override
  String get commonNeedDirectionBody =>
      'El plan guiado reduce la duda a una ciudad inicial y a un orden corto de primeros pasos.';

  @override
  String get commonNeedExploreAllTitle =>
      'Quiero mirar todo sin quedarme trabado';

  @override
  String get commonNeedExploreAllBody =>
      'La sección Explorar reúne ciudades, documentación y otros caminos en un solo lugar.';

  @override
  String get explorePageTitle => 'Explorar';

  @override
  String get explorePublicFeaturesTitle => 'Exploración pública';

  @override
  String get explorePublicFeaturesDescription =>
      'Descubrí ciudades y países disponibles para cualquier usuario visitante.';

  @override
  String get exploreDocumentationTitle => 'Vida práctica en Brasil';

  @override
  String get exploreDocumentationDescription =>
      'Entendé documentos, salud, licencia, trabajo y cuenta bancaria con lenguaje simple.';

  @override
  String get exploreDocumentationAction => 'Ver documentación';

  @override
  String get exploreCitiesAction => 'Ver ciudades';

  @override
  String get exploreCountriesAction => 'Ver países';

  @override
  String get exploreCommunityTitle => 'Contenido de la comunidad';

  @override
  String get exploreCommunityDescription =>
      'El contenido de la comunidad es público, pero publicar requiere autenticación.';

  @override
  String get exploreCreatePostAction => 'Crear post';

  @override
  String get exploreIntroTitle => 'Cómo usar Movaro';

  @override
  String get exploreIntroDescription =>
      'Antes de salir a navegar, mirá en menos de un minuto qué resuelve Movaro y qué ya está disponible en este beta.';

  @override
  String get exploreIntroAction => 'Abrir introducción';

  @override
  String get exploreChecklistTitle => 'Tu plan inicial';

  @override
  String get exploreChecklistDescription =>
      'Las personas visitantes pueden responder un flujo corto y generar un plan inicial antes de iniciar sesión.';

  @override
  String get exploreQuestionnaireAction => 'Iniciar cuestionario';

  @override
  String get exploreTrailsEyebrow => 'Tres caminos claros';

  @override
  String get exploreTrailsTitle => 'Elegí el tipo de ayuda que necesitás ahora';

  @override
  String get exploreTrailsBody =>
      'En vez de mostrar todo de una vez, la app ahora separa la experiencia en tres recorridos: decidir ciudad, entender la burocracia práctica y preparar la mudanza.';

  @override
  String get exploreTrailCitiesTitle => 'Decidir ciudad';

  @override
  String get exploreTrailCitiesBody =>
      'Compará ciudades y usá señales de litoral, costo, trabajo, idioma y vivienda para ver qué contexto te cierra mejor.';

  @override
  String get exploreTrailDocsTitle => 'Entender la burocracia práctica';

  @override
  String get exploreTrailDocsBody =>
      'Mirá alquiler, SUS, CPF, trabajo, conducción y costos iniciales en bloques más claros y con menos ruido.';

  @override
  String get exploreTrailPrepTitle => 'Preparar la mudanza';

  @override
  String get exploreTrailPrepBodyStart =>
      'Si todavía no confirmaste una ciudad, empezá por el plan inicial para ordenar la decisión.';

  @override
  String get exploreTrailPrepBodyReady =>
      'Como ya confirmaste una ciudad, acá el foco pasa a checklist, documentos, vivienda y llegada.';

  @override
  String get exploreSavePlanAction => 'Guardar plan';

  @override
  String get exploreUnifiedTitle =>
      'Explore cities, content, and your next move in one place';

  @override
  String get exploreUnifiedBody =>
      'Use this area to reinforce your decision, review the city options that still matter, and open the practical content that matches your route.';

  @override
  String get explorePlanSectionTitle => 'Based on your plan';

  @override
  String get explorePlanSectionBody =>
      'Resume the current plan, reopen the leading city, or jump straight into the most useful guide for your next step.';

  @override
  String get exploreCitiesSectionTitle => 'Discover other cities';

  @override
  String get exploreCitiesSectionBody =>
      'Keep comparing before locking the decision. These cities are strong alternatives for your current route and profile.';

  @override
  String get exploreContentSectionTitle => 'Useful content';

  @override
  String get exploreContentSectionBody =>
      'Open the practical guidance that usually matters next: documents, housing, and work.';

  @override
  String exploreRouteLabel(Object origin, Object destination) {
    return 'Journey: $origin -> $destination';
  }

  @override
  String exploreDestinationLabel(Object destination) {
    return 'Destination selected: $destination';
  }

  @override
  String get exploreNoJourneyLabel =>
      'Set a destination to make exploration more relevant.';

  @override
  String get explorePlanEmptyTitle => 'Start a plan before you go deeper';

  @override
  String get explorePlanEmptyBody =>
      'Choose your destination, answer a few questions, and let Movaro turn exploration into a practical direction.';

  @override
  String get explorePlanReadyTitle => 'Your plan is ready to continue';

  @override
  String explorePlanReadyBody(Object city) {
    return '$city is already confirmed. Open your checklist and keep moving through the next actions.';
  }

  @override
  String get explorePlanDraftTitle => 'Your plan still needs a decision';

  @override
  String get explorePlanDraftBody =>
      'You already have a draft. Reopen the result and confirm the city before moving into checklist mode.';

  @override
  String explorePlanDraftBodyWithCity(Object city) {
    return '$city is currently leading. Reopen the result, compare it, and confirm it when ready.';
  }

  @override
  String get exploreRecommendedCityTitle => 'Leading city right now';

  @override
  String get exploreRecommendedCityBody =>
      'Open the city details to validate cost, quality of life, and fit with your plan.';

  @override
  String get exploreOpenCityAction => 'Open city';

  @override
  String get exploreOpenContentAction => 'Open guide';

  @override
  String get explorePlanDocsBody =>
      'Documents usually unlock the next part of the move faster than more comparison.';

  @override
  String get exploreContentDocumentsBody =>
      'See CPF, registration, banking, and legal stay with less noise and clearer routing.';

  @override
  String get exploreContentHousingBody =>
      'Review rent pressure, guarantees, deposits, and first-landing decisions before choosing a neighborhood.';

  @override
  String get exploreContentWorkBody =>
      'Check work setup, contribution paths, and what to validate before treating income as solved.';

  @override
  String get documentationPageTitle => 'Documentación y vida práctica';

  @override
  String get documentationHeroEyebrow => 'Guía práctica';

  @override
  String get documentationHeroTitle =>
      'Entendé mejor cómo organizar la vida práctica en Brasil';

  @override
  String get documentationHeroDescription =>
      'Escribí una duda o elegí un tema. Movaro te ayuda a entender mejor el camino y encontrar la guía correcta sobre documentos, salud, trabajo, vivienda, movilidad y costos iniciales.';

  @override
  String get documentationFocusTitle => 'Useful for your current journey';

  @override
  String documentationFocusBody(Object origin, Object destination) {
    return 'These categories are the strongest starting point for moving from $origin to $destination.';
  }

  @override
  String documentationFocusBodyDestination(Object destination) {
    return 'These categories are a strong starting point for your route into $destination.';
  }

  @override
  String get documentationFocusBodyDefault =>
      'Open the category that removes the biggest blocker first: documents, housing, or work.';

  @override
  String get documentationHeroStepOneTitle => 'Escribí una duda';

  @override
  String get documentationHeroStepOneBody =>
      'Podés buscar en español, portugués o inglés.';

  @override
  String get documentationHeroStepTwoTitle => 'Elegí un tema';

  @override
  String get documentationHeroStepTwoBody =>
      'Filtrá por documentos, salud, trabajo, vivienda, movilidad y costos.';

  @override
  String get documentationHeroStepThreeTitle => 'Abrí la guía correcta';

  @override
  String get documentationHeroStepThreeBody =>
      'Entrá a una respuesta rápida o al bloque completo cuando necesites más contexto.';

  @override
  String get documentationSearchLabel => '¿Qué necesitás entender?';

  @override
  String get documentationSearchHint =>
      'Ej.: puedo trabajar con visa de visita? / CPF / bank / salud / costos';

  @override
  String get documentationSearchSupport =>
      'Podés buscar en español, portugués o inglés.';

  @override
  String get documentationSearchPanelTitle =>
      'Empezá por la búsqueda o por un tema';

  @override
  String get documentationSearchPanelBody =>
      'Escribí tu duda o tocá un tema para llegar más rápido al bloque correcto.';

  @override
  String get documentationGuideHideNextTime => 'No mostrar nuevamente';

  @override
  String get documentationGuideStepsLabel => '3 pasos';

  @override
  String get documentationGuideDismissAction => 'Ahora no';

  @override
  String get documentationGuidePrimaryAction => 'Entendido';

  @override
  String get documentationGuideModalTitle => 'Usá la guía práctica más rápido';

  @override
  String get documentationGuideModalBody =>
      'Elegí el país que querés revisar, buscá un tema o una duda y abrí la sección que destraba el próximo paso.';

  @override
  String get documentationGuideModalStepCountryTitle => 'Elegí el país';

  @override
  String get documentationGuideModalStepCountryBody =>
      'La guía abre con el país de destino cuando existe, pero podés cambiar de país en cualquier momento.';

  @override
  String get documentationGuideModalStepSearchTitle => 'Buscá por necesidad';

  @override
  String get documentationGuideModalStepSearchBody =>
      'Escribí un tema, documento o duda cotidiana para ir directo a la sección más relevante.';

  @override
  String get documentationGuideModalStepOpenTitle => 'Abrí la sección';

  @override
  String get documentationGuideModalStepOpenBody =>
      'Usá los filtros o los resultados para entrar directo en documentos, vivienda, salud, trabajo, manejo o costos.';

  @override
  String get documentationGuideNoPlanTitle =>
      'Todavía no hay un plan seleccionado';

  @override
  String documentationGuideNoPlanBody(Object country) {
    return 'Igualmente podés usar la guía práctica. Cargamos $country por ahora, y podés cambiar de país cuando lo necesites.';
  }

  @override
  String documentationGuideCountryPendingTitle(Object country) {
    return 'La guía de $country todavía no está disponible';
  }

  @override
  String get documentationGuideCountryPendingBody =>
      'Por ahora Movaro tiene cobertura de guía práctica para Brasil. Elegí Brasil para seguir navegando el contenido disponible.';

  @override
  String get documentationGuideUsingPlanLabel => 'Desde tu plan';

  @override
  String get documentationGuideManualCountryLabel => 'País manual';

  @override
  String documentationSearchResultsCount(int count) {
    return '$count ítems encontrados';
  }

  @override
  String get documentationSearchResultsHint =>
      'Tocá un ítem para abrir el tema o ir directo a los resultados filtrados.';

  @override
  String get documentationFilterAll => 'Todo';

  @override
  String get documentationQuickRoutesTitle => 'Entradas por tema';

  @override
  String get documentationQuickRoutesBody =>
      'Deslizá y entrá directo al bloque correcto si ya sabés qué tema querés abrir primero.';

  @override
  String get documentationQuickChoicesTitle => 'Elecciones rápidas';

  @override
  String get documentationQuickChoicesBody =>
      'Filtrá por tema o usá preguntas listas para llegar más rápido al bloque correcto.';

  @override
  String get documentationResultsTitle => 'Resultados de la guía';

  @override
  String get documentationResultsBody =>
      'Empezá por una respuesta rápida o abrí el tema completo para profundizar.';

  @override
  String get documentationResultsFilteredBody =>
      'La búsqueda cruza respuestas rápidas y bloques completos para acortar el camino hasta la información correcta.';

  @override
  String get documentationViewMatchesAction => 'Ver';

  @override
  String get documentationNoResultsTitle => 'No apareció nada con ese término';

  @override
  String get documentationNoResultsBody =>
      'Probá con CPF, registro, work, visa, salud, alquiler o costos.';

  @override
  String get documentationQuickStepCpf => 'CPF';

  @override
  String get documentationQuickStepRegistration => 'Registro';

  @override
  String get documentationQuickStepStay => 'Permanencia';

  @override
  String get documentationQuickStepWorkBank => 'Trabajo y banco';

  @override
  String get documentationQuickStepCitizenship => 'Naturalización';

  @override
  String get documentationQuickStepHealth => 'Salud';

  @override
  String get documentationQuickStepDriving => 'Licencia';

  @override
  String get documentationQuickStepWork => 'Trabajo';

  @override
  String get documentationQuickStepRetirement => 'Previsión';

  @override
  String get documentationOfficialSourceLabel => 'Fuente oficial';

  @override
  String get documentationPathsTitle => 'Empezá por tu duda principal';

  @override
  String get documentationPathsBody =>
      'En vez de leer todo, elegí el área que más te pesa ahora. Lo demás queda como apoyo cuando necesites profundizar.';

  @override
  String get documentationHousingArrivalSectionTitle => 'Vivienda y llegada';

  @override
  String get documentationHousingArrivalSectionBody =>
      'Mirá alquiler, costo de entrada, garantía, soft landing y cómo evitar los primeros errores.';

  @override
  String get documentationNavigatorTitle => 'Dónde encontrar cada tema';

  @override
  String get documentationNavigatorBody =>
      'Usá estos bloques para encontrar más rápido alquiler, SUS, trabajo, conducir y costos, sin leer toda la página de una sola vez.';

  @override
  String get documentationNavigatorHousing => 'Vivienda y alquiler';

  @override
  String get documentationNavigatorHealth => 'SUS y salud';

  @override
  String get documentationNavigatorWork => 'Trabajo e ingresos';

  @override
  String get documentationNavigatorDriving => 'Conducir en Brasil';

  @override
  String get documentationNavigatorCosts => 'Costos iniciales';

  @override
  String get documentationNavigatorDocuments => 'Documentos base';

  @override
  String get documentationPathDocumentsTitle => 'Documentos y permanencia';

  @override
  String get documentationPathDocumentsBody =>
      'CPF, registro, plazo de permanencia y lo que suele destrabar la vida práctica primero.';

  @override
  String get documentationPathHealthTitle => 'Salud en la rutina diaria';

  @override
  String get documentationPathHealthBody =>
      'Entendé cuándo conviene usar el SUS, una UBS, un hospital o un plan privado.';

  @override
  String get documentationPathDrivingTitle => 'Manejar y moverte';

  @override
  String get documentationPathDrivingBody =>
      'Mirá si tu licencia extranjera ayuda al principio y cuándo te conviene revisar el Detran.';

  @override
  String get documentationPathWorkTitle => 'Trabajo y aportes';

  @override
  String get documentationPathWorkBody =>
      'Entendé trabajo registrado, PJ y cómo eso se relaciona con la previsión.';

  @override
  String get documentationPathCostsTitle => 'Costos iniciales';

  @override
  String get documentationPathCostsBody =>
      'Leé costos aproximados en reales, pesos y dólares, sin confundir referencia con precio final.';

  @override
  String get documentationOpenTopicAction => 'Abrir tema';

  @override
  String get documentationQuickAnswersTitle =>
      'Respuestas rápidas para las dudas más comunes';

  @override
  String get documentationQuickAnswersBody =>
      'Antes de abrir cada card, empezá por estas respuestas cortas. Si alguna ya responde tu duda, ahorrás tiempo.';

  @override
  String get documentationAnswerWorkQuestion =>
      '¿Puedo trabajar solo con visa de visita?';

  @override
  String get documentationAnswerWorkAnswer =>
      'No. Para trabajo formal, necesitás una situación migratoria compatible y registro regular.';

  @override
  String get documentationAnswerTravelDocQuestion =>
      '¿Necesito pasaporte para viajar de Argentina a Brasil?';

  @override
  String get documentationAnswerTravelDocAnswer =>
      'No necesariamente. Las personas argentinas pueden viajar a Brasil con DNI físico vigente, en buen estado y con foto que permita identificar claramente al titular. Una constancia de trámite no alcanza.';

  @override
  String get documentationAnswerCpfQuestion =>
      '¿El CPF solo resuelve banco y contrato?';

  @override
  String get documentationAnswerCpfAnswer =>
      'No. El CPF ayuda mucho, pero normalmente no reemplaza un documento migratorio regular.';

  @override
  String get documentationAnswerRegistrationQuestion =>
      '¿El registro migratorio sale en el momento?';

  @override
  String get documentationAnswerRegistrationAnswer =>
      'No. El protocolo ya importa mientras se confecciona la CRNM, así que el proceso no depende de una tarjeta inmediata.';

  @override
  String get documentationAnswerStayQuestion =>
      '¿Quedarse más tiempo como visitante es lo mismo que vivir de forma regular?';

  @override
  String get documentationAnswerStayAnswer =>
      'No. Para quien va a vivir en Brasil, la residencia regular suele ser el camino correcto.';

  @override
  String get documentationAnswerSusQuestion =>
      '¿Una persona extranjera puede usar el SUS?';

  @override
  String get documentationAnswerSusAnswer =>
      'Sí. El SUS es universal en Brasil y el propio Ministerio de Salud reafirma el acceso para personas extranjeras.';

  @override
  String get documentationAnswerSusCardQuestion =>
      '¿Tengo que esperar la tarjeta del SUS o el CPF para atenderme?';

  @override
  String get documentationAnswerSusCardAnswer =>
      'No necesariamente. El registro ayuda, pero el acceso inicial y, sobre todo, las urgencias no deberían depender de tener todo listo.';

  @override
  String get documentationAnswerForeignLicenseQuestion =>
      '¿Puedo manejar al principio con mi licencia extranjera?';

  @override
  String get documentationAnswerForeignLicenseAnswer =>
      'En general, sí, por un período limitado, con documento válido y según la regla del acuerdo aplicable. Después, conviene confirmar con el Detran del estado.';

  @override
  String get documentationAnswerBrazilianLicenseQuestion =>
      '¿Después puedo sacar la licencia brasileña?';

  @override
  String get documentationAnswerBrazilianLicenseAnswer =>
      'Sí, si estás regular en el país y cumplís los requisitos del Detran. El proceso y las tasas cambian según el estado.';

  @override
  String get documentationAnswerWorkCardQuestion =>
      '¿Sigue existiendo el trabajo registrado y cómo funciona?';

  @override
  String get documentationAnswerWorkCardAnswer =>
      'Sí. En el trabajo formal por CLT, la relación queda registrada y la Carteira de Trabalho Digital concentra el historial laboral.';

  @override
  String get documentationAnswerPjQuestion =>
      '¿Trabajar como PJ es igual al monotributo?';

  @override
  String get documentationAnswerPjAnswer =>
      'Puede recordar esa lógica de trabajo por cuenta propia y CNPJ, pero no es la misma estructura. En Brasil cambian las reglas fiscales, previsionales y contractuales según el encuadre.';

  @override
  String get documentationAnswerMarketQuestion =>
      '¿Se puede construir ingreso en el mercado laboral brasileño?';

  @override
  String get documentationAnswerMarketAnswer =>
      'Sí, pero la expectativa más realista es ingreso sostenible y crecimiento gradual, no salarios excepcionalmente altos apenas llegás. Brasil tiene un mercado grande y diverso, pero el ingreso cambia bastante según ciudad, sector, idioma y tu situación regular para trabajar.';

  @override
  String get documentationAnswerSafetyQuestion =>
      '¿La seguridad en Brasil es igual en todos lados?';

  @override
  String get documentationAnswerSafetyAnswer =>
      'No. La seguridad cambia mucho según el estado, la ciudad, el barrio y la rutina diaria. Lo más seguro es comparar el área concreta donde querés vivir y moverte, y no tratar al país entero como un solo bloque.';

  @override
  String get documentationAnswerInssQuestion =>
      '¿La previsión pública en Brasil es el INSS?';

  @override
  String get documentationAnswerInssAnswer =>
      'Sí. El INSS es la puerta principal de la previsión pública para beneficios como la jubilación, siempre que existan aportes y requisitos cumplidos.';

  @override
  String get documentationAnswerRetirementQuestion =>
      '¿La jubilación depende solo de la edad?';

  @override
  String get documentationAnswerRetirementAnswer =>
      'No. La edad mínima importa, pero también cuentan el tiempo de aporte y las reglas de transición.';

  @override
  String get documentationHealthSectionTitle => 'Salud pública x salud privada';

  @override
  String get documentationHealthSectionBody =>
      'Lo importante es entender la función de cada camino. La salud pública no es un plan barato, y la salud privada no reemplaza, por sí sola, una buena lectura de cobertura.';

  @override
  String get documentationWorkSectionTitle =>
      'Cómo se conectan trabajo y previsión';

  @override
  String get documentationWorkSectionBody =>
      'Acá conviene separar el modelo de trabajo del modo de aportar. Trabajo registrado, trabajo por CNPJ y aporte al INSS no significan exactamente lo mismo.';

  @override
  String get documentationDrivingSectionTitle =>
      'Cómo pensar la licencia sin complicarlo';

  @override
  String get documentationDrivingSectionBody =>
      'El flujo más seguro es separar tres preguntas: si podés manejar ahora, qué tenés que validar en el estado y cuándo conviene iniciar la licencia brasileña.';

  @override
  String get documentationDeepDiveTitle => 'Si necesitás ir un nivel más allá';

  @override
  String get documentationDeepDiveBody =>
      'Acá quedan los cards completos con fuente oficial. Siguen siendo cortos, pero sirven cuando la respuesta rápida no alcanza.';

  @override
  String get documentationCostsTitle =>
      'Costos aproximados que ayudan a orientarte';

  @override
  String get documentationCostsBody =>
      'Cuando existe un valor nacional o una referencia oficial útil, la app muestra la conversión aproximada para ayudarte en una primera lectura.';

  @override
  String documentationCostsUpdatedAt(String value) {
    return 'Tipo de cambio aproximado actualizado en $value';
  }

  @override
  String get documentationCostsUnavailable =>
      'No fue posible actualizar la cotización ahora. Los valores en reales siguen como referencia.';

  @override
  String get documentationCostsDisclaimer =>
      'Usá esto como orientación inicial. Los costos cambian según el estado, convenio, edad, cobertura y reglas locales.';

  @override
  String get documentationCostFreeValue => 'Gratis';

  @override
  String get documentationCostVariableValue => 'Variable';

  @override
  String get documentationCostCpfTitle => 'Pedido oficial de CPF';

  @override
  String get documentationCostCpfSupporting =>
      'El trámite oficial es gratuito; la app lo trata como costo cero.';

  @override
  String get documentationCostSusCardTitle =>
      'Tarjeta del SUS y registro inicial';

  @override
  String get documentationCostSusCardSupporting =>
      'La emisión y el registro público no suelen exigir pago directo.';

  @override
  String get documentationCostPublicCareTitle => 'Atención inicial en el SUS';

  @override
  String get documentationCostPublicCareSupporting =>
      'La UBS y otras puertas públicas de entrada no funcionan como una consulta particular paga.';

  @override
  String get documentationCostDrivingTitle => 'Primera licencia';

  @override
  String get documentationCostDrivingValue => 'Ejemplo oficial';

  @override
  String get documentationCostDrivingSupporting =>
      'Referencia reciente del Detran-ES: R\$ 533,34. Tu estado y tu autoescuela pueden cobrar distinto.';

  @override
  String get documentationCostPrivateHealthTitle => 'Plan de salud privado';

  @override
  String get documentationCostPrivateHealthSupporting =>
      'No existe un precio único nacional. Edad, cobertura, red y carencias cambian mucho el valor final.';

  @override
  String get documentationCpfTitle => 'CPF';

  @override
  String get documentationCpfSummary =>
      'El primer documento práctico para abrir camino en banco, contrato y registros.';

  @override
  String get documentationCpfBulletOne =>
      'Una persona extranjera puede pedir CPF; en Brasil, el trámite puede hacerse online o en una entidad conveniada.';

  @override
  String get documentationCpfBulletTwo =>
      'El servicio oficial informa un plazo estimado de hasta 30 días corridos.';

  @override
  String get documentationCpfBulletThree =>
      'El CPF no reemplaza el documento migratorio, pero suele destrabar gran parte de la vida práctica.';

  @override
  String get documentationTravelDocsTitle =>
      'Documento para viajar de Argentina a Brasil';

  @override
  String get documentationTravelDocsSummary =>
      'Para turismo y entrada inicial, el pasaporte no es la única opción. La clave es viajar con un documento físico reconocido y válido para el corredor Mercosur.';

  @override
  String get documentationTravelDocsBulletOne =>
      'Las personas argentinas pueden viajar a Brasil con Documento Nacional de Identidad (DNI) o pasaporte.';

  @override
  String get documentationTravelDocsBulletTwo =>
      'El documento debe estar en buen estado y permitir identificar claramente al titular por la foto.';

  @override
  String get documentationTravelDocsBulletThree =>
      'Una constancia de trámite, documentos deteriorados o documentos antiguos no aceptados por la regla migratoria pueden impedir la salida o el embarque.';

  @override
  String get documentationRegistrationTitle => 'Registro migratorio y CRNM';

  @override
  String get documentationRegistrationSummary =>
      'Después de entrar de forma regular, el registro ante la Policía Federal suele ser la etapa clave.';

  @override
  String get documentationRegistrationBulletOne =>
      'Quien entra con visa temporaria debe hacer el registro dentro de los 90 días posteriores al ingreso.';

  @override
  String get documentationRegistrationBulletTwo =>
      'Si la autorización de residencia fue concedida ya en Brasil, el registro debe hacerse dentro de 30 días.';

  @override
  String get documentationRegistrationBulletThree =>
      'La CRNM puede tardar cerca de 30 días hábiles en confeccionarse; el servicio oficial admite un plazo total mayor y el protocolo preserva derechos.';

  @override
  String get documentationStayTitle => 'Cuánto tiempo puedo quedarme';

  @override
  String get documentationStaySummary =>
      'Para una persona argentina, lo más práctico suele ser regularizar la residencia y no depender de una estadía de visita.';

  @override
  String get documentationStayBulletOne =>
      'La visa de visita no fue pensada para vivir en Brasil ni para trabajo remunerado.';

  @override
  String get documentationStayBulletTwo =>
      'La residencia por el Acuerdo del Mercosur puede otorgarse por 2 años.';

  @override
  String get documentationStayBulletThree =>
      'Antes de que termine ese plazo, podés pedir la conversión a residencia por tiempo indeterminado si cumplís los requisitos.';

  @override
  String get documentationWorkBankTitle => 'Trabajo y cuenta bancaria';

  @override
  String get documentationWorkBankSummary =>
      'Trabajar y abrir cuenta dependen más de tu regularización que de un solo documento milagroso.';

  @override
  String get documentationWorkBankBulletOne =>
      'La visa de visita no autoriza actividad remunerada en Brasil.';

  @override
  String get documentationWorkBankBulletTwo =>
      'Para trabajar formalmente, necesitás una situación migratoria compatible y registro regular.';

  @override
  String get documentationWorkBankBulletThree =>
      'El banco puede pedir documentos adicionales; el CPF ayuda, pero un documento migratorio regular suele pesar en el alta.';

  @override
  String get documentationCitizenshipTitle => 'Naturalización';

  @override
  String get documentationCitizenshipSummary =>
      'La nacionalidad brasileña no llega solo por tiempo de CPF o estadía; depende de residencia regular y reglas propias.';

  @override
  String get documentationCitizenshipBulletOne =>
      'La naturalización ordinaria, en general, exige residencia por tiempo indeterminado en Brasil.';

  @override
  String get documentationCitizenshipBulletTwo =>
      'La regla general pide 4 años de residencia antes del pedido, además de otros requisitos legales.';

  @override
  String get documentationCitizenshipBulletThree =>
      'Hay hipótesis oficiales de reducción de ese plazo, por eso conviene revisar la regla exacta antes de planificar.';

  @override
  String get documentationHealthPublicTitle => 'SUS, UBS y acceso público';

  @override
  String get documentationHealthPublicSummary =>
      'La salud pública en Brasil no funciona como un plan prepago. La lógica es de acceso universal, con puertas distintas según la necesidad.';

  @override
  String get documentationHealthPublicBulletOne =>
      'El SUS atiende de forma universal, incluso a personas extranjeras en territorio brasileño.';

  @override
  String get documentationHealthPublicBulletTwo =>
      'La UBS suele ser la puerta de entrada para rutina, seguimiento, vacunas y cuidado básico.';

  @override
  String get documentationHealthPublicBulletThree =>
      'Urgencias y emergencias siguen otra lógica de acceso; no esperes tener todo resuelto en el registro antes de pedir ayuda.';

  @override
  String get documentationHealthFlowTitle =>
      'Cómo encontrar la atención correcta';

  @override
  String get documentationHealthFlowSummary =>
      'No toda duda de salud empieza en un hospital. Conviene saber cuándo buscar una UBS, una UPA, un hospital o una app oficial.';

  @override
  String get documentationHealthFlowBulletOne =>
      'Usá la UBS para rutina, derivaciones, recetas y seguimiento.';

  @override
  String get documentationHealthFlowBulletTwo =>
      'Usá la UPA o un hospital cuando el caso sea urgente, agudo o no pueda esperar una agenda básica.';

  @override
  String get documentationHealthFlowBulletThree =>
      'Meu SUS Digital y la secretaría local ayudan a ubicar unidades, exámenes e información de seguimiento.';

  @override
  String get documentationHealthPrivateTitle => 'Salud privada';

  @override
  String get documentationHealthPrivateSummary =>
      'Un plan privado puede acelerar el acceso a la red y la conveniencia, pero entra como costo recurrente y exige comparar cobertura con cuidado.';

  @override
  String get documentationHealthPrivateBulletOne =>
      'El plan de salud privado es pago y está regulado por la ANS.';

  @override
  String get documentationHealthPrivateBulletTwo =>
      'Precio, red, alcance y carencias cambian según el contrato, la edad y la operadora.';

  @override
  String get documentationHealthPrivateBulletThree =>
      'Antes de contratar, compará red, cobertura y reglas en el material oficial de la ANS, no solo el precio.';

  @override
  String get documentationWorkCltTitle => 'Trabajo registrado';

  @override
  String get documentationWorkCltSummary =>
      'En el trabajo formal, la relación laboral sigue la CLT y el registro aparece en la Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletOne =>
      'El trabajo registrado es la forma más reconocible de trabajo formal en Brasil.';

  @override
  String get documentationWorkCltBulletTwo =>
      'El historial laboral puede seguirse en la Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletThree =>
      'En este modelo, la relación con el aporte previsional suele estar más integrada a la nómina salarial.';

  @override
  String get documentationWorkPjTitle => 'PJ, CNPJ y trabajo por cuenta propia';

  @override
  String get documentationWorkPjSummary =>
      'Trabajar como PJ o con CNPJ cambia la lógica del vínculo. Puede recordar al monotributo en la comparación cultural, pero no es la misma estructura jurídica.';

  @override
  String get documentationWorkPjBulletOne =>
      'PJ no es trabajo registrado; el vínculo es empresarial o autónomo, no laboral.';

  @override
  String get documentationWorkPjBulletTwo =>
      'Abrir CNPJ y aportar a la previsión son temas conectados, pero no automáticos en todos los casos.';

  @override
  String get documentationWorkPjBulletThree =>
      'Antes de aceptar este formato, conviene entender impuestos, contrato y cómo va a funcionar el aporte previsional.';

  @override
  String get documentationWorkMarketTitle =>
      'Mercado laboral y expectativa de ingresos';

  @override
  String get documentationWorkMarketSummary =>
      'Brasil ofrece escala y muchos formatos de trabajo, pero el planeamiento migratorio más realista parte de ingresos moderados y progresión gradual, no de salarios fuera de escala en la primera etapa.';

  @override
  String get documentationWorkMarketBulletOne =>
      'En el trimestre móvil terminado en octubre de 2025, el IBGE registró desocupación de 5,4%, ingreso medio habitual de R\$ 3.528 y un récord de 39,2 millones de asalariados privados con registro.';

  @override
  String get documentationWorkMarketBulletTwo =>
      'Eso muestra un mercado grande y activo, con espacio en servicios, comercio, logística, salud, educación, tecnología y redes locales de negocios.';

  @override
  String get documentationWorkMarketBulletThree =>
      'Para quien llega desde otro país, la lectura más segura es planificar con ingreso realista, fondo de reserva y diferencias salariales entre ciudades.';

  @override
  String get documentationRetirementTitle => 'Previsión pública y jubilación';

  @override
  String get documentationRetirementSummary =>
      'En Brasil, la jubilación pública gira alrededor del INSS, con edad mínima, tiempo de aportes y reglas de transición que cambian la lectura de cada caso.';

  @override
  String get documentationRetirementBulletOne =>
      'La regla general actual usa edad mínima de 62 años para mujeres y 65 para hombres en la jubilación por edad.';

  @override
  String get documentationRetirementBulletTwo =>
      'El tiempo de aportes sigue siendo relevante, sobre todo en las reglas de transición y en la lectura de elegibilidad.';

  @override
  String get documentationRetirementBulletThree =>
      'Para quien llega del exterior, lo más seguro es entender pronto cómo será su forma de aportar en Brasil.';

  @override
  String get documentationSafetyTitle =>
      'Seguridad: leela por ciudad y por barrio';

  @override
  String get documentationSafetySummary =>
      'La seguridad en Brasil no es uniforme. La decisión útil no es si el país es \'seguro\' en abstracto, sino cómo la ciudad, el barrio, el trayecto y el horario encajan con tu rutina.';

  @override
  String get documentationSafetyBulletOne =>
      'El Anuario Brasileño de Seguridad Pública 2025 reúne datos oficiales de secretarías y policías y es una de las lecturas más amplias del tema en el país.';

  @override
  String get documentationSafetyBulletTwo =>
      'Los números cambian mucho entre estados y tipos de delito, así que el promedio nacional por sí solo no alcanza para elegir dónde vivir.';

  @override
  String get documentationSafetyBulletThree =>
      'Antes de alquilar o aceptar un trabajo, compará contexto del barrio, movilidad nocturna, recorridos y la rutina práctica que de verdad vas a tener.';

  @override
  String get documentationDrivingTitle => 'Primera licencia en Brasil';

  @override
  String get documentationDrivingSummary =>
      'Si vas a vivir en Brasil, la licencia brasileña depende del Detran del estado y de un proceso local con etapas obligatorias.';

  @override
  String get documentationDrivingBulletOne =>
      'El proceso suele incluir examen médico y psicológico, clases, examen teórico y examen práctico.';

  @override
  String get documentationDrivingBulletTwo =>
      'Una persona extranjera regularizada puede iniciar el proceso si cumple las exigencias de identificación y residencia del estado.';

  @override
  String get documentationDrivingBulletThree =>
      'Las tasas y el costo final cambian según el Detran y la autoescuela, así que usá el valor mostrado solo como referencia.';

  @override
  String get documentationForeignLicenseTitle =>
      'Licencia extranjera y conducción inicial';

  @override
  String get documentationForeignLicenseSummary =>
      'Tener una licencia extranjera válida puede ayudar al principio, pero no reemplaza para siempre la necesidad de confirmar la regla brasileña.';

  @override
  String get documentationForeignLicenseBulletOne =>
      'La posibilidad de manejar con licencia extranjera depende de la validez, la identificación y la regla aplicable a tu caso.';

  @override
  String get documentationForeignLicenseBulletTwo =>
      'El período inicial de uso no significa equivalencia automática para toda tu permanencia en Brasil.';

  @override
  String get documentationForeignLicenseBulletThree =>
      'Si vas a fijar residencia, conviene confirmar temprano con el Detran del estado si habrá registro, canje o un proceso nuevo completo.';

  @override
  String get citiesPageTitle => 'Ciudades';

  @override
  String get countriesPageTitle => 'Países';

  @override
  String get publicAccessLabel => 'Acceso público';

  @override
  String get loginPageTitle => 'Entrar';

  @override
  String get loginHeadline => 'Entrá solo cuando tenga sentido para vos';

  @override
  String get loginDescription =>
      'Movaro deja la exploración abierta. El inicio de sesión aparece solo cuando querés guardar algo personal.';

  @override
  String get loginGoogleAction => 'Continuar con Google';

  @override
  String get loginAppleAction => 'Continuar con Apple';

  @override
  String get loginDevOnlyHint =>
      'Estos botones usan FakeAuthDataSource solo en desarrollo.';

  @override
  String get loginLaterAction => 'Ahora no';

  @override
  String loginActionRequired(String action) {
    return 'Para $action, necesitamos vincular esta acción con vos.';
  }

  @override
  String get pendingActionSavePlan => 'guardar tu plan';

  @override
  String get pendingActionPostCommunity => 'publicar en la comunidad';

  @override
  String get pendingActionSaveCity => 'guardar esta ciudad';

  @override
  String get onboardingPageTitle => 'Tu contexto';

  @override
  String get onboardingHeadline => 'Queremos entender tu momento';

  @override
  String get onboardingDescription =>
      'Esto ayuda a que la experiencia sea más útil sin pedir demasiada información.';

  @override
  String get onboardingOriginLabel => '¿De dónde venís?';

  @override
  String get onboardingDestinationLabel => '¿A dónde querés ir?';

  @override
  String get onboardingContinueAction => 'Continuar';

  @override
  String get authenticatedHomeTitle => 'Tu espacio';

  @override
  String authenticatedWelcome(String name) {
    return 'Hola, $name';
  }

  @override
  String get authenticatedHomeDescription =>
      'Acá retomás lo que estabas haciendo y encontrás tus atajos principales.';

  @override
  String get authenticatedPlanSectionTitle => 'Tu plan';

  @override
  String get authenticatedShortcutsTitle => 'Atajos útiles';

  @override
  String get authenticatedCitiesShortcut => 'Ver ciudades';

  @override
  String get authenticatedSearchShortcut => 'Buscar ciudad';

  @override
  String get signOutAction => 'Salir';

  @override
  String onboardingSummary(String origin, String destination) {
    return 'Origen: $origin  Destino: $destination';
  }

  @override
  String savedPlansCount(int count) {
    return 'Planes guardados: $count';
  }

  @override
  String get startNewPlanAction => 'Iniciar un nuevo plan';

  @override
  String get questionnairePageTitle => 'Tu plan inicial';

  @override
  String get questionnaireLoadingLabel => 'Preparando tus preguntas';

  @override
  String get questionnaireSupportText =>
      'Toma menos de un minuto. Una pregunta por vez.';

  @override
  String get questionnaireSectionOrigin => 'Origen';

  @override
  String get questionnaireSectionBasicProfile => 'Perfil básico';

  @override
  String get questionnaireSectionPreferences => 'Preferencias';

  @override
  String get questionnaireSectionFinancial => 'Situación financiera';

  @override
  String get questionnaireSectionGoal => 'Objetivo migratorio';

  @override
  String questionnaireNextSection(Object section) {
    return 'Sigue: $section';
  }

  @override
  String get questionnaireReadyForPlan =>
      'Después de esto, vamos a convertir tus respuestas en tu primer plan.';

  @override
  String get questionnaireProcessingTitle => 'Armando tu primer plan';

  @override
  String get questionnaireProcessingBody =>
      'Estamos conectando tu trayecto, tu perfil y tus prioridades en un punto de partida claro.';

  @override
  String questionProgress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get backAction => 'Volver';

  @override
  String get nextAction => 'Continuar';

  @override
  String get generatePlanAction => 'Ver mi plan';

  @override
  String get migrationPlanPageTitle => 'Tu primer plan';

  @override
  String get migrationPlanSummaryTitle => 'Lo que nos contaste';

  @override
  String get planRecommendedCityTitle => 'Ciudad sugerida para empezar';

  @override
  String planRecommendedCityDescription(String city, String stateCode) {
    return 'Según tus respuestas, Movaro sugiere mirar primero $city, $stateCode.';
  }

  @override
  String get planRecommendedCityAction => 'Ver esta ciudad';

  @override
  String planSummaryOrigin(String value) {
    return 'Origen: $value';
  }

  @override
  String planSummaryDestination(String value) {
    return 'Destino: $value';
  }

  @override
  String planSummaryGoal(String value) {
    return 'Objetivo: $value';
  }

  @override
  String planSummaryTimeline(String value) {
    return 'Momento de la mudanza: $value';
  }

  @override
  String get migrationPlanStepsTitle => 'Primeros pasos sugeridos';

  @override
  String get planNextActionsTitle => 'Lo que suele venir justo después';

  @override
  String get planNextActionsBody =>
      'Si este resultado te ayudó, el siguiente paso suele ser confirmar documentos, comparar la ciudad sugerida con otras opciones o rehacer el plan con otra prioridad.';

  @override
  String get planNextActionDocumentsTitle =>
      'Confirmar documentos antes de avanzar';

  @override
  String get planNextActionDocumentsBody =>
      'Usá la guía práctica para revisar CPF, registro, permanencia, trabajo y banco sin caer en una investigación dispersa.';

  @override
  String get planNextActionCitiesTitle =>
      'Comparar otras ciudades antes de decidir';

  @override
  String get planNextActionCitiesBody =>
      'Mirá si la ciudad sugerida sigue teniendo sentido cuando la comparás por costo, idioma, seguridad y trabajo.';

  @override
  String get planNextActionRetakeTitle => 'Rehacer el plan con otra prioridad';

  @override
  String get planNextActionRetakeBody =>
      'Si tu prioridad cambió, conviene responder de nuevo y ver si también cambia el orden de los pasos.';

  @override
  String get readinessSectionTitle =>
      'Checklist práctico para la siguiente fase';

  @override
  String get readinessStageNow => 'Empezá ahora';

  @override
  String get readinessStageSoon => 'Prepará después';

  @override
  String get readinessStageLanding => 'Antes de llegar';

  @override
  String get readinessSummaryResearching =>
      'Como todavía estás explorando, el mejor paso ahora es reducir la incertidumbre antes de abrir demasiados frentes.';

  @override
  String get readinessSummaryTwelveMonths =>
      'Todavía tenés tiempo para preparar bien la mudanza, así que usá este checklist para reducir fricción con anticipación.';

  @override
  String get readinessSummarySixMonths =>
      'Seis meses ya alcanzan para salir de la improvisación y estructurar documentos, dinero y ciudad.';

  @override
  String get readinessSummaryAsap =>
      'Como el plan está cerca, la prioridad ahora es ordenar lo esencial y evitar errores evitables.';

  @override
  String get readinessItemMigrationPathTitle =>
      'Confirmá primero la ruta migratoria';

  @override
  String get readinessItemMigrationPathBody =>
      'Antes de banco, vivienda o trabajo, validá qué camino de residencia encaja mejor con tu entrada a Brasil.';

  @override
  String get readinessItemDocumentsTitle =>
      'Armá el paquete documental esencial';

  @override
  String get readinessItemDocumentsBody =>
      'Separá pasaporte, antecedentes, necesidad de apostilla y documentos que todavía pueden requerir traducción.';

  @override
  String get readinessItemBudgetTitle => 'Probá el presupuesto de aterrizaje';

  @override
  String get readinessItemBudgetBody =>
      'Proyectá lo que van a exigir los primeros 30 a 90 días, no solo el costo mensual una vez instalada la rutina.';

  @override
  String get readinessItemCityTitle => 'Convertí la ciudad en un filtro real';

  @override
  String get readinessItemCityBody =>
      'Usá tu selección actual de ciudades para reducir la incertidumbre sobre vivienda, transporte y rutina antes de bajar al nivel de barrio.';

  @override
  String readinessItemCityBodyWithCity(String city) {
    return 'Usá $city como primer filtro y comparala con alternativas antes de decidir a nivel de barrio.';
  }

  @override
  String get readinessItemLanguageTitle => 'Prepará tu primera capa de idioma';

  @override
  String get readinessItemLanguageBody =>
      'Concentrate en el portugués que reduce fricción en la vida diaria: vivienda, transporte, banco y servicios.';

  @override
  String get readinessItemLanguageWorkBody =>
      'Concentrate en el portugués que afecta entrevistas, rutina laboral, negociación y pedidos básicos de servicio.';

  @override
  String get readinessItemLanguageStudyBody =>
      'Concentrate en el portugués necesario para clases, inscripción, rutina diaria y comunicación institucional.';

  @override
  String get readinessGoalWorkTitle => 'Mapeá empleabilidad antes de llegar';

  @override
  String get readinessGoalWorkBody =>
      'Revisá qué tipo de trabajo podés buscar al inicio, qué documentos pueden frenarte y cómo la ciudad cambia tus posibilidades.';

  @override
  String get readinessGoalRemoteTitle =>
      'Estabilizá la base del trabajo remoto';

  @override
  String get readinessGoalRemoteBody =>
      'Chequeá internet, flujo bancario, costo diario y la estructura local mínima antes de depender del ingreso remoto.';

  @override
  String get readinessGoalStudyTitle => 'Validá la ruta de estudio';

  @override
  String get readinessGoalStudyBody =>
      'Revisá admisión, costo de rutina, tiempos de estudiante y qué debe regularizarse antes de tomar el estudio como base.';

  @override
  String get readinessGoalEntrepreneurTitle =>
      'Planificá la entrada para emprender';

  @override
  String get readinessGoalEntrepreneurBody =>
      'Mapeá la capa práctica inicial: documentos locales, banco, ciudad y estructura mínima para operar con más seguridad.';

  @override
  String get readinessGoalRetireTitle => 'Protegé rutina y previsibilidad';

  @override
  String get readinessGoalRetireBody =>
      'Priorizá acceso a salud, rutina de barrio, costo recurrente y los documentos que protegen una llegada tranquila.';

  @override
  String get readinessGoalQualityTitle =>
      'Convertí calidad de vida en criterio';

  @override
  String get readinessGoalQualityBody =>
      'Transformá el estilo de vida en filtros reales: seguridad, rutina, adaptación al idioma y costo de permanencia.';

  @override
  String get readinessItemCpfBankTitle =>
      'Prepará el CPF y la primera base bancaria';

  @override
  String get readinessItemCpfBankBody =>
      'El CPF y la situación regular influyen en banco, contrato y buena parte de la estructura práctica de la llegada.';

  @override
  String get readinessItemHousingTitle =>
      'Reducí la fricción de vivienda antes de buscar';

  @override
  String get readinessItemHousingBody =>
      'Revisá garantía, reserva financiera, prioridad de barrio y comprobantes que pueden pedirte antes de hablar con propietarios.';

  @override
  String get readinessItemArrivalTitle => 'Armá un plan de llegada de 30 días';

  @override
  String get readinessItemArrivalBody =>
      'Listá lo que debe funcionar en el primer mes: conectividad, salud, transporte, pagos y seguimiento documental.';

  @override
  String readinessProgressLabel(int done, int total) {
    return '$done de $total ítems completados';
  }

  @override
  String planStepMeta(String category, int days) {
    return 'Categoría: $category  Días estimados: $days';
  }

  @override
  String get planStepOpenDetailsAction => 'Abrir detalles';

  @override
  String get planStepOpenVisaEyebrow => 'Residencia y visa';

  @override
  String get planStepOpenVisaSummary =>
      'Antes de decidir banco, trabajo o contrato, conviene confirmar cuál es tu base migratoria correcta para entrar y permanecer de forma regular.';

  @override
  String get planStepOpenVisaPointOne =>
      'Para una persona argentina, la residencia por el Acuerdo del Mercosur suele ser uno de los caminos más directos.';

  @override
  String get planStepOpenVisaPointTwo =>
      'La visa de visita no fue hecha para vivir en Brasil ni para actividad remunerada.';

  @override
  String get planStepOpenVisaPointThree =>
      'Si tu intención ya es vivir en Brasil, conviene resolver esto antes de asumir alquiler o trabajo.';

  @override
  String get planStepOpenCpfEyebrow => 'Documento fiscal';

  @override
  String get planStepOpenCpfSummary =>
      'El CPF ayuda a destrabar banco, contrato, registro y gran parte de la vida práctica al comienzo.';

  @override
  String get planStepOpenCpfPointOne =>
      'El trámite puede empezar online, según la orientación oficial.';

  @override
  String get planStepOpenCpfPointTwo =>
      'El plazo informado oficialmente puede llegar a 30 días corridos.';

  @override
  String get planStepOpenCpfPointThree =>
      'El CPF ayuda mucho, pero no reemplaza un documento migratorio regular.';

  @override
  String get planStepOpenBankEyebrow => 'Cuenta inicial';

  @override
  String get planStepOpenBankSummary =>
      'Abrir cuenta depende más de tu regularización y de los documentos presentados que de un banco específico.';

  @override
  String get planStepOpenBankPointOne =>
      'Hay bancos tradicionales y digitales, pero los requisitos pueden variar.';

  @override
  String get planStepOpenBankPointTwo =>
      'El CPF ayuda, pero la CRNM, el protocolo u otro documento regular pueden influir en el alta.';

  @override
  String get planStepOpenBankPointThree =>
      'Empezá comparando una cuenta digital para una rutina simple y un banco tradicional si necesitás atención presencial.';

  @override
  String get planStepOpenHousingEyebrow => 'Vivienda y barrios';

  @override
  String get planStepOpenHousingSummary =>
      'Antes de cerrar vivienda, conviene comparar barrios con mejor rutina, acceso y costo.';

  @override
  String planStepOpenHousingSummaryCity(String city) {
    return 'Para $city, compará barrios con mejor rutina, acceso y costo antes de cerrar una vivienda.';
  }

  @override
  String get planStepOpenHousingPointOne =>
      'Priorizá barrios con buena conexión con lo que necesitás: trabajo, transporte y servicios.';

  @override
  String get planStepOpenHousingPointTwo =>
      'Usá la lectura de costo de la ciudad como punto de partida, pero confirmá alquiler y contrato antes de decidir.';

  @override
  String get planStepOpenHousingPointThree =>
      'El análisis por barrio todavía necesita una base dedicada; por ahora, usá la ciudad recomendada como filtro inicial.';

  @override
  String get planStepOpenGeneralEyebrow => 'Checklist guiada';

  @override
  String get planStepOpenGeneralSummary =>
      'Este paso funciona mejor como una validación práctica dentro de tu llegada a Brasil.';

  @override
  String get planStepOpenGeneralPointOne =>
      'Resolvé primero lo esencial para no abrir demasiados frentes al mismo tiempo.';

  @override
  String get planStepOpenGeneralPointTwo =>
      'Cuando la etapa dependa de un documento oficial, confirmá el requisito más reciente antes de presentar nada.';

  @override
  String get planStepOpenGeneralPointThree =>
      'Usá el plan como un orden sugerido, no como una regla fija para todos los casos.';

  @override
  String get planStepOpenTagMercosur => 'Mercosur';

  @override
  String get planStepOpenTagVisitor => 'La visita no autoriza trabajo';

  @override
  String get planStepOpenTagOnline => 'Trámite online';

  @override
  String get planStepOpenTagReceitaFederal => 'Receita Federal';

  @override
  String get planStepOpenTagTraditionalBanks => 'Bancos tradicionales';

  @override
  String get planStepOpenTagDigitalBanks => 'Bancos digitales';

  @override
  String get planStepOpenTagNeighborhoods => 'Barrios';

  @override
  String get planStepOpenTagRent => 'Alquiler';

  @override
  String get planStepOpenTagChecklist => 'Paso a paso';

  @override
  String get savePlanAction => 'Guardar plan';

  @override
  String get savePlanPageTitle => 'Guardar plan';

  @override
  String get savePlanSuccessTitle => 'Plan guardado por ahora';

  @override
  String savePlanSuccessBody(int count) {
    return 'Planes guardados temporalmente en esta sesión: $count';
  }

  @override
  String get goToProfileAction => 'Ir a mi espacio';

  @override
  String get citiesExploreTitle => 'Ciudades';

  @override
  String get citiesExploreHeadline => 'Descubrí ciudades con más contexto';

  @override
  String get citiesExploreDescription =>
      'Mirá sugerencias por intención y entendé por qué cada ciudad aparece acá.';

  @override
  String get citiesExploreSearchFirstDescription =>
      'Buscá una ciudad o usá los chips para filtrar el catálogo cuando tenga sentido. La lista no abre cargada: los resultados aparecen solo cuando buscás o elegís un recorte.';

  @override
  String get citiesGuideEyebrow => 'Guía rápida';

  @override
  String get citiesGuideTitle => 'Cómo usar la exploración de ciudades';

  @override
  String get citiesGuideBody =>
      'Acá podés buscar por nombre, filtrar el catálogo con recortes rápidos o abrir el mapa para elegir por ubicación.';

  @override
  String get citiesGuideStepOneTitle => 'Buscá una ciudad';

  @override
  String get citiesGuideStepOneBody =>
      'Escribí el nombre y tocá el resultado más cercano para abrir el detalle.';

  @override
  String get citiesGuideStepTwoTitle => 'Usá un recorte rápido';

  @override
  String get citiesGuideStepTwoBody =>
      'Los chips ayudan a reducir la lista por popularidad, costo, trabajo, idioma y otras señales.';

  @override
  String get citiesGuideStepThreeTitle => 'Elegí en el mapa';

  @override
  String get citiesGuideStepThreeBody =>
      'Abrí el mapa, tocá una ciudad y seguí al detalle cuando quieras decidir por ubicación.';

  @override
  String get citiesGuideHideNextTime => 'No mostrar nuevamente';

  @override
  String get citiesGuideStepsLabel => '3 pasos';

  @override
  String get citiesGuideDismissAction => 'Ahora no';

  @override
  String get citiesGuidePrimaryAction => 'Entendido';

  @override
  String get citiesExploreSearchIdleTitle =>
      'Buscá una ciudad o elegí un filtro';

  @override
  String get citiesExploreSearchIdleDescription =>
      'Escribí el nombre de la ciudad para tener autocomplete inmediato o deslizá los chips para explorar por popularidad, playa, trabajo, idioma y llegada.';

  @override
  String get citiesLoadingLabel => 'Cargando ciudades';

  @override
  String get citiesMethodologyNote =>
      'Rankings basados en datos públicos y en la metodología de Movaro.';

  @override
  String get citiesExplorePopularTitle => 'Más elegidas por argentinos';

  @override
  String get citiesExploreLanguageTitle =>
      'Más fáciles si todavía dependés del español';

  @override
  String get citiesExploreEconomicalTitle =>
      'Buenas opciones si priorizás costo';

  @override
  String get citiesExploreWorkTitle => 'Buenas opciones si buscás trabajo';

  @override
  String get citiesExploreHousingEasyTitle =>
      'Mejores para una llegada más liviana';

  @override
  String get citiesExploreHousingPressureTitle => 'Piden más caja al entrar';

  @override
  String get citiesExploreSoftLandingTitle =>
      'Buenas para llegar con menos fricción';

  @override
  String get citiesExploreFamilyStabilityTitle =>
      'Buenas para llegar con más previsibilidad';

  @override
  String get citiesExploreIncomeStartTitle =>
      'Buenas para llegar buscando ingresos';

  @override
  String get citiesExploreCoastalTitle =>
      'Buenas para quien quiere vivir cerca de la playa';

  @override
  String get citiesExploreCoastalSoftLandingTitle =>
      'Playa con llegada más liviana';

  @override
  String get citiesExploreCoastalBalancedTitle =>
      'Playa con mejor equilibrio de rutina';

  @override
  String get citiesHighlightPopularLabel =>
      'Entre las ciudades analizadas por Movaro';

  @override
  String get citiesHighlightLanguageLabel =>
      'Buena opción si la adaptación al idioma importa para vos';

  @override
  String get citiesHighlightEconomicalLabel =>
      'Buena opción si priorizás costo';

  @override
  String get citiesHighlightWorkLabel =>
      'Buena opción si buscás más oportunidades de trabajo';

  @override
  String get citiesHighlightHousingEasyLabel => 'Buena para soft landing';

  @override
  String get citiesHighlightHousingPressureLabel => 'Presión de vivienda alta';

  @override
  String get citiesHighlightSoftLandingLabel =>
      'Buena para un aterrizaje inicial con menos fricción';

  @override
  String get citiesHighlightFamilyStabilityLabel =>
      'Buena para equilibrar seguridad, vivienda y rutina';

  @override
  String get citiesHighlightIncomeStartLabel =>
      'Buena si necesitás activar ingresos más temprano';

  @override
  String get citiesHighlightCoastalLabel => 'Buena para una rutina de litoral';

  @override
  String get citiesHighlightMetropolisLabel =>
      'Buena si querés un ritmo más urbano';

  @override
  String get citiesHighlightInlandLabel =>
      'Buena si buscás una rutina más tranquila';

  @override
  String get citiesHighlightBorderLabel =>
      'Buena si querés entender mejor una ciudad de frontera';

  @override
  String get citiesHighlightCoastalSoftLandingLabel =>
      'Playa con mejor soft landing';

  @override
  String get citiesHighlightCoastalBalancedLabel =>
      'Playa con mejor equilibrio entre rutina y costo';

  @override
  String get citiesExploreEmptyTitle => 'Seguimos ampliando este catálogo';

  @override
  String get citiesExploreEmptyDescription =>
      'Las sugerencias de ciudades van a aparecer acá a medida que la base de Movaro crezca.';

  @override
  String get citiesSearchTitle => 'Buscar ciudades';

  @override
  String get citiesSearchHeadline =>
      'Encontrá una ciudad en el catálogo inicial';

  @override
  String get citiesSearchDescription =>
      'Buscá por nombre o recorré la lista actual de Movaro.';

  @override
  String get citiesSearchHint => 'Buscar ciudad';

  @override
  String get citiesSearchFieldLabel => 'Nombre de la ciudad';

  @override
  String get citiesSearchHelper =>
      'Escribí para buscar ciudades por nombre y tocar el autocomplete.';

  @override
  String get citiesQuickChoicesTitle => 'Elecciones rápidas';

  @override
  String get citiesQuickChoicesBody =>
      'Usá un recorte para reducir la lista más rápido o andá por el mapa si preferís ubicación.';

  @override
  String citiesSearchResultsCount(int count) {
    return '$count ciudades encontradas';
  }

  @override
  String get citiesSearchResultsHint =>
      'Tocá una ciudad para abrir directo el detalle.';

  @override
  String get citiesMapOpenAction => 'Elegir en el mapa';

  @override
  String get citiesMapCalloutBody =>
      '¿Preferís decidir por ubicación? Entrá al mapa y compará las ciudades por el punto donde querés empezar.';

  @override
  String get citiesMapCalloutStepOne => 'Abrir mapa';

  @override
  String get citiesMapCalloutStepTwo => 'Tocar la ciudad';

  @override
  String get citiesMapCalloutStepThree => 'Abrir detalle';

  @override
  String get citiesMapSheetTitle => 'Elegí una ciudad en el mapa';

  @override
  String get citiesMapSheetBody =>
      'Abrí el mapa de Brasil, tocá un punto y seleccioná la ciudad por su posición.';

  @override
  String get citiesMapOpenCityAction => 'Abrir ciudad';

  @override
  String get citiesQuickFilterAll => 'Vista general';

  @override
  String get citiesQuickFilterPopular => 'Más populares';

  @override
  String get citiesQuickFilterLowCost => 'Mejor costo';

  @override
  String get citiesQuickFilterWork => 'Más trabajo';

  @override
  String get citiesQuickFilterLanguage => 'Idioma más fácil';

  @override
  String get citiesQuickFilterHousingEasy => 'Llegada liviana';

  @override
  String get citiesQuickFilterHousingPressure => 'Más caja';

  @override
  String get citiesQuickFilterSoftLanding => 'Menos fricción';

  @override
  String get citiesQuickFilterFamilyStability => 'Más previsible';

  @override
  String get citiesQuickFilterIncomeStart => 'Ingresos rápidos';

  @override
  String get citiesQuickFilterCoastal => 'Playa';

  @override
  String get citiesSearchingLabel => 'Buscando ciudades';

  @override
  String get citiesCatalogLoadingLabel => 'Cargando catálogo';

  @override
  String get citiesFilterClear => 'Limpiar';

  @override
  String get citiesResultsTitle => 'Resultados';

  @override
  String citiesResultsBody(int count) {
    return '$count ciudades coinciden con esta búsqueda o filtro.';
  }

  @override
  String get citiesResultsMoreHint => 'Deslizá para cargar más ciudades';

  @override
  String get citiesSearchEmptyTitle => 'No encontramos esa ciudad';

  @override
  String get citiesSearchEmptyDescription =>
      'Probá con otro nombre o explorá el catálogo inicial de Movaro.';

  @override
  String get citiesSearchFirstEmptyDescription =>
      'Probá otro nombre o cambiá el filtro para ampliar los resultados.';

  @override
  String get citiesCatalogEmptyTitle => 'El catálogo todavía está vacío';

  @override
  String get citiesCatalogEmptyDescription =>
      'Las ciudades del catálogo de Movaro aparecerán acá.';

  @override
  String get cityDetailTitleFallback => 'Ciudad';

  @override
  String get cityDetailLoadingLabel => 'Cargando detalles de la ciudad';

  @override
  String get cityDetailEmptyTitle => 'Ciudad no disponible';

  @override
  String get cityDetailEmptyDescription =>
      'No encontramos los detalles de esta ciudad en este momento.';

  @override
  String get cityDetailContextNote =>
      'Usá estos indicadores como punto de partida, no como una verdad absoluta.';

  @override
  String get cityDetailDecisionSnapshotTitle => 'Resumen para decidir';

  @override
  String cityDetailDecisionSnapshotSubtitle(Object bestFor) {
    return 'Movaro ve esta ciudad como una buena opción si hoy priorizás $bestFor.';
  }

  @override
  String cityDetailDecisionSnapshotPlanSubtitle(Object bestFor) {
    return 'Para tu plan, esta ciudad aparece fuerte si hoy priorizás $bestFor.';
  }

  @override
  String cityDetailDecisionSnapshotRecommendedSubtitle(Object bestFor) {
    return 'Esta ciudad hoy lidera en tu plan si tu foco es $bestFor.';
  }

  @override
  String get cityDetailWatchoutTitle => 'El principal punto a validar';

  @override
  String get cityDetailPlanLeadingChip => 'Lidera en tu plan';

  @override
  String get cityDetailPlanMatchChip => 'Encaja con tu plan';

  @override
  String cityDetailUpdatedLabel(Object date) {
    return 'Actualizado el $date';
  }

  @override
  String get cityDetailAffordabilityTitle => 'Costo y vivienda';

  @override
  String get cityDetailSummaryTitle => 'Quick summary';

  @override
  String get cityDetailSummaryBody =>
      'Use this top read to understand whether the city looks easier, more balanced, or more demanding before opening the deeper analysis.';

  @override
  String get cityDetailAddToPlanAction => 'Add to my plan';

  @override
  String get cityDetailCompareSavedAction => 'Saved to compare';

  @override
  String get cityDetailQualityLabel => 'Quality of life';

  @override
  String get cityDetailQualitySupporting =>
      'A quick read based on HDI, safety, and language adaptation for arrival.';

  @override
  String get cityDetailQualityHigh => 'Stronger';

  @override
  String get cityDetailQualityBalanced => 'Balanced';

  @override
  String get cityDetailQualityDeveloping => 'Needs validation';

  @override
  String get cityDetailDifficultyLabel => 'Difficulty';

  @override
  String get cityDetailDifficultyEasy => 'Lighter move';

  @override
  String get cityDetailDifficultyBalanced => 'Moderate move';

  @override
  String get cityDetailDifficultyChallenging => 'More demanding move';

  @override
  String get cityDetailSettleInTitle => 'Adaptación y comunidad';

  @override
  String get cityDetailCommunityTitle => 'Red de apoyo';

  @override
  String get cityDetailContextTitle => 'Contexto de la ciudad';

  @override
  String get cityLifestyleCoastalLabel => 'Estilo de vida de litoral';

  @override
  String get cityLifestyleMetropolisLabel => 'Ritmo de metrópoli';

  @override
  String get cityLifestyleBorderLabel => 'Ciudad de frontera';

  @override
  String get cityLifestyleInlandLabel => 'Rutina de interior';

  @override
  String get cityDetailMapTitle => 'Dónde queda la ciudad';

  @override
  String get cityDetailMapDescription =>
      'Mirá la ubicación de la ciudad en el mapa antes de comparar contexto, distancia y región.';

  @override
  String get cityDetailMapRegionLabel => 'Región';

  @override
  String cityDetailMapDistanceLabel(Object origin, Object distanceKm) {
    return 'Distancia desde $origin: ~$distanceKm km';
  }

  @override
  String get cityDetailSnapshotTitle => 'Vista rápida';

  @override
  String get cityDetailSnapshotPositiveTag => 'Punto fuerte';

  @override
  String get cityDetailSnapshotWatchoutTag => 'Atención';

  @override
  String get cityDetailSnapshotContextTag => 'Contexto';

  @override
  String get cityDetailMetricsSummary =>
      'Abrí solo si querés ver todos los indicadores y el recorte completo.';

  @override
  String get cityDetailPopulationLabel => 'Población';

  @override
  String get cityDetailCostLabel => 'Costo';

  @override
  String get cityDetailRentLabel => 'Alquiler';

  @override
  String get cityDetailSafetyLabel => 'Seguridad';

  @override
  String get cityDetailPopularityLabel => 'Popularidad entre argentinos';

  @override
  String get cityDetailLanguageLabel => 'Adaptación al idioma';

  @override
  String get cityDetailWorkLabel => 'Mercado laboral';

  @override
  String get cityDetailIdhmLabel => 'IDHM';

  @override
  String get cityDetailIdhmOfficialNote =>
      'dato oficial del Atlas de Desarrollo Humano';

  @override
  String get cityDetailUnemploymentLabel => 'Tasa de desempleo';

  @override
  String get cityDetailIndustriesTitle => 'Sectores fuertes';

  @override
  String get cityDetailReasonsTitle => 'Por qué Movaro la recomienda';

  @override
  String get cityDetailSourcesTitle => 'Fuentes de datos';

  @override
  String cityDetailSourcesSummary(int count) {
    return '$count fuentes disponibles. Expandí solo si querés validar el origen de los datos.';
  }

  @override
  String get cityDetailSourceOfficialBadge => 'Fuente oficial';

  @override
  String get cityDetailSourceCuratedBadge => 'Fuente curada';

  @override
  String get cityDetailSourceProviderLabel => 'Proveedor';

  @override
  String get cityDetailSourceUrlLabel => 'Referencia';

  @override
  String get cityDetailPublicOpinionTitle =>
      'Lo que suelen comentar quienes visitan la ciudad';

  @override
  String cityDetailPublicOpinionSubtitle(Object provider) {
    return 'Lectura de temas recurrentes en reseñas públicas de $provider. No representa la opinión de toda la ciudad.';
  }

  @override
  String cityDetailPublicOpinionRating(Object rating) {
    return 'Nota $rating';
  }

  @override
  String cityDetailPublicOpinionSample(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reseñas',
      one: '1 reseña',
      zero: 'Sin reseñas',
    );
    return '$_temp0';
  }

  @override
  String get cityDetailPublicOpinionFallbackSummary =>
      'Estos temas muestran puntos que aparecen con frecuencia en las reseñas públicas encontradas para la localidad.';

  @override
  String get cityDetailPublicOpinionPositiveTitle => 'Lo más elogiado';

  @override
  String get cityDetailPublicOpinionCriticalTitle => 'Lo más criticado';

  @override
  String cityDetailPublicOpinionNote(Object date) {
    return 'Resumen automático consultado el $date. Usalo como señal de percepción recurrente, no como consenso absoluto.';
  }

  @override
  String get citySourceTerritorialTitle => 'Identidad territorial';

  @override
  String get citySourceTerritorialDescription =>
      'Nombre oficial, estado, código IBGE y región municipal.';

  @override
  String get citySourcePopulationTitle => 'Población';

  @override
  String get citySourcePopulationDescription =>
      'Referencia oficial de población del municipio.';

  @override
  String get citySourceHumanDevelopmentTitle => 'Desarrollo humano';

  @override
  String get citySourceHumanDevelopmentDescription =>
      'IDHM municipal oficial con referencia al Censo 2010.';

  @override
  String get citySourceCuratedMetricsTitle => 'Métricas curadas del producto';

  @override
  String get citySourceCuratedMetricsDescription =>
      'Actualmente, proviene del dataset curado de Movaro. Las sustituciones oficiales prioritarias son Atlas da Violência (seguridad), Novo Caged (empleo), FipeZAP (alquiler) e IBGE PIB dos Municípios (actividad económica).';

  @override
  String get citySourceRankingTitle => 'Metodología de puntaje';

  @override
  String get citySourceRankingDescription =>
      'Puntajes de Movaro calculados sobre datos públicos y el dataset curado.';

  @override
  String get citySourcePublicReviewsTitle =>
      'Percepción pública de la localidad';

  @override
  String get citySourcePublicReviewsDescription =>
      'Temas recurrentes extraídos de reseñas públicas de Google sobre la localidad. No representa la opinión de toda la ciudad.';

  @override
  String get cityDetailSaveAction => 'Guardar ciudad';

  @override
  String get cityDetailSavedAction => 'Ciudad guardada';

  @override
  String get cityDetailSavedFeedback =>
      'Ciudad guardada temporalmente en este dispositivo.';

  @override
  String get cityDetailFavoriteAction => 'Agregar a favoritas';

  @override
  String get cityDetailFavoriteRemoveAction => 'Quitar de favoritas';

  @override
  String get cityDetailFavoriteNote =>
      'Podés guardar hasta 3 ciudades favoritas para volver rápido desde la home.';

  @override
  String cityDetailFavoriteAddedFeedback(Object city) {
    return '$city fue agregada a favoritas.';
  }

  @override
  String cityDetailFavoriteRemovedFeedback(Object city) {
    return '$city fue quitada de favoritas.';
  }

  @override
  String cityDetailFavoriteLimitFeedback(Object count) {
    return 'Podés elegir hasta $count ciudades favoritas.';
  }

  @override
  String get cityDetailDiscoverTitle => 'Conoce mejor la ciudad';

  @override
  String cityDetailDiscoverBody(Object city, Object state) {
    return 'Si quieres ver fotos, búsquedas y contexto general de $city ($state), abre la vista de Google sin salir de la app.';
  }

  @override
  String get cityDetailDiscoverAction => 'Explorar la ciudad';

  @override
  String get cityDetailDeepDiveTitle => 'Análisis detallado';

  @override
  String get cityDetailDeepDiveSummary =>
      'Abrí esta área si querés ver todos los indicadores, el contexto y una lectura más profunda de la ciudad.';

  @override
  String get cityDetailCompareAction => 'Comparar otras ciudades';

  @override
  String cityDetailCompareSelectedBody(Object city) {
    return '$city preseleccionada';
  }

  @override
  String get cityDetailPlanAction => 'Armar mi plan';

  @override
  String get cityDetailFooterNote =>
      'Estos indicadores ayudan en la exploración inicial y no reemplazan un análisis individual.';

  @override
  String get publicHomeFavoritesTitle => 'Tus ciudades favoritas';

  @override
  String get publicHomeFavoritesBody =>
      'Guardá hasta 3 ciudades para volver rápido a sus detalles cuando quieras compararlas mejor.';

  @override
  String get publicHomeFavoritesJumpAction => 'Ver ciudades favoritas';

  @override
  String get publicHomeFavoriteCardHint =>
      'Abrí los detalles para volver a comparar costo, trabajo y encaje de llegada.';

  @override
  String get mainNavHome => 'Home';

  @override
  String get mainNavFavorites => 'Favoritas';

  @override
  String get mainNavCopilot => 'Guía';

  @override
  String get mainNavExplore => 'Explore';

  @override
  String get mainNavPlan => 'Plan';

  @override
  String get mainNavProfile => 'Profile';

  @override
  String get mainNavPlanNeedsJourney =>
      'Choose your destination first so Movaro can open the right plan step.';

  @override
  String get mainNavFavoritesDisabled =>
      'Agregá al menos 1 ciudad a favoritas para habilitar esta pestaña.';

  @override
  String get mainNavCopilotDisabled =>
      'Confirmá una ciudad en tu plan para habilitar la guía de la mudanza.';

  @override
  String get favoritesEmptyTitle => 'Todavía no hay ciudades favoritas';

  @override
  String get favoritesEmptyBody =>
      'Cuando guardes ciudades favoritas, quedan reunidas acá para seguir detalles, clima y comparación más rápido.';

  @override
  String get favoritesEmptyHint =>
      'Explorá ciudades, guardá las más fuertes y volvé acá cuando quieras retomar.';

  @override
  String get favoritesPageTitle => 'Ciudades guardadas';

  @override
  String favoritesPageCount(Object current, Object total) {
    return '$current de $total';
  }

  @override
  String get favoritesCompareTitle => 'Comparar ciudades';

  @override
  String favoritesCompareSubtitle(Object left, Object right) {
    return '$left vs $right';
  }

  @override
  String get favoritesCompareAction => 'Comparar';

  @override
  String get favoritesPageEmptyTitle => 'No hay ciudades guardadas';

  @override
  String get favoritesPageEmptyBody =>
      'Explorá ciudades y guardá las que más te interesan para compararlas después.';

  @override
  String get favoritesAddCityTitle => 'Agregar ciudad';

  @override
  String favoritesAddCitySubtitle(Object count) {
    return '$count lugar(es) disponible(s)';
  }

  @override
  String get favoritesActivePlanBadge => 'Plan activo';

  @override
  String get favoritesContinuePlanAction => 'Continuar plan';

  @override
  String get favoritesOpenDetailsAction => 'Ver detalles';

  @override
  String get favoritesRemoveAction => 'Eliminar';

  @override
  String get favoritesClimateLabel => 'Clima actual';

  @override
  String get favoritesClimatePending => 'Cargando';

  @override
  String get favoritesQualityLabel => 'Calidad';

  @override
  String get cityComparisonTitle => 'Comparar ciudades';

  @override
  String get cityComparisonCompareAction => 'Comparar';

  @override
  String get cityComparisonEditAction => 'Cambiar';

  @override
  String get cityComparisonModeTwo => '2 ciudades';

  @override
  String get cityComparisonModeThree => '3 ciudades';

  @override
  String get cityComparisonAddAction => 'Agregar';

  @override
  String get cityComparisonSearchPlaceholder =>
      'Buscar ciudad para comparar...';

  @override
  String get cityComparisonHeaderLabel => 'Métrica';

  @override
  String get cityComparisonBestFitBadge => 'MEJOR FIT';

  @override
  String get cityComparisonTopBadge => 'TOP';

  @override
  String get cityComparisonGroupCost => 'Costo de vida';

  @override
  String get cityComparisonGroupQuality => 'Calidad de vida';

  @override
  String get cityComparisonGroupWork => 'Trabajo y llegada';

  @override
  String get cityComparisonRentLabel => 'Alquiler estimado';

  @override
  String get cityComparisonFoodLabel => 'Costo mensual de alimentación';

  @override
  String get cityComparisonTransportLabel => 'Costo mensual de transporte';

  @override
  String get cityComparisonHdiLabel => 'IDH';

  @override
  String get cityComparisonClimateLabel => 'Clima actual';

  @override
  String get cityComparisonSafetyLabel => 'Índice de seguridad';

  @override
  String get cityComparisonJobLabel => 'Mercado laboral';

  @override
  String get cityComparisonCommunityLabel => 'Comunidad inmigrante';

  @override
  String get cityComparisonCommunityLarge => 'Grande';

  @override
  String get cityComparisonCommunityMedium => 'Media';

  @override
  String get cityComparisonCommunitySmall => 'Pequeña';

  @override
  String get cityComparisonWinnerLabel => 'MEJOR OPCIÓN PARA VOS';

  @override
  String get cityComparisonUnavailable => '—';

  @override
  String cityComparisonStartPlanAction(Object city) {
    return 'Iniciar plan en $city →';
  }

  @override
  String cityComparisonOtherDetailsAction(Object city) {
    return 'Ver detalles de $city';
  }

  @override
  String get favoritesExploreAction => 'Explorar ciudades';

  @override
  String get favoritesGuideEyebrow => 'Guía rápida';

  @override
  String get favoritesGuideTitle => 'Cómo usar Favoritas';

  @override
  String get favoritesGuideBody =>
      'Acá podés guardar hasta 3 ciudades para retomarlas después sin repetir la búsqueda. Usá esta área para comparar mejor, reabrir detalles y decidir con más claridad.';

  @override
  String get favoritesGuideStepOneTitle =>
      'Guardá las ciudades más prometedoras';

  @override
  String get favoritesGuideStepOneBody =>
      'Usá el corazón en los cards o en el detalle para mantener las ciudades que te hacen sentido.';

  @override
  String get favoritesGuideStepTwoTitle => 'Volvé para comparar rápido';

  @override
  String get favoritesGuideStepTwoBody =>
      'Favoritas reúne tus elecciones en un solo lugar para que no te pierdas entre búsquedas y filtros.';

  @override
  String get favoritesGuideStepThreeTitle =>
      'Abrí el detalle cuando quieras decidir';

  @override
  String get favoritesGuideStepThreeBody =>
      'Tocá una ciudad para revisar contexto, clima, costo y las señales principales antes de avanzar.';

  @override
  String get favoritesGuideHideNextTime => 'No mostrar nuevamente';

  @override
  String get favoritesGuideStepsLabel => '3 pasos';

  @override
  String get favoritesGuideDismissAction => 'Ahora no';

  @override
  String get favoritesGuidePrimaryAction => 'Entendido';

  @override
  String get profileJourneyTitle => 'Journey';

  @override
  String get profileJourneyBody =>
      'Movaro uses this route to keep home, exploration, and content connected to the same move context.';

  @override
  String profileJourneyValue(Object origin, Object destination) {
    return '$origin -> $destination';
  }

  @override
  String profileJourneyPendingValue(Object destination) {
    return 'Destination saved: $destination';
  }

  @override
  String get profileJourneyEmptyValue => 'No journey selected yet';

  @override
  String get profilePlanTitle => 'Plan status';

  @override
  String get profilePlanBody =>
      'Your saved plan stays connected to the journey so you can continue without starting from zero.';

  @override
  String get profilePlanEmptyValue => 'No plan generated yet';

  @override
  String profilePlanReadyValue(Object city) {
    return 'Ready to continue in $city';
  }

  @override
  String get profilePlanDraftValue => 'Draft result waiting for confirmation';

  @override
  String get profileSavedCitiesTitle => 'Saved cities';

  @override
  String get profileSavedCitiesBody =>
      'Keep up to 3 cities here so you can compare them again without losing your route or plan context.';

  @override
  String get publicHomeJourneyResetAction => 'Elegir otra ruta';

  @override
  String get publicHomeJourneyResetTitle => '¿Elegir otra ruta?';

  @override
  String get publicHomeJourneyResetBody =>
      'Tu ruta actual ya está guardada en este dispositivo. Si la reiniciás ahora, Movaro va a abrir de nuevo la selección para que elijas otro origen o destino.';

  @override
  String get publicHomeJourneyResetConfirm => 'Rehacer ruta';

  @override
  String get publicHomePlanResetTitle => '¿Iniciar otro plan?';

  @override
  String get publicHomePlanResetBody =>
      'Tu plan actual se va a eliminar de este dispositivo para que puedas responder el cuestionario otra vez desde cero.';

  @override
  String cityWeatherSummary(Object temperature) {
    return '$temperature°C ahora';
  }

  @override
  String get introPageTitle => 'Cómo funciona Movaro';

  @override
  String get introHeroTitle => 'Entendé la app en menos de un minuto';

  @override
  String get introHeroDescription =>
      'Movaro te ayuda a comparar ciudades, entender burocracias prácticas y armar una primera dirección de mudanza sin empezar por un exceso de información.';

  @override
  String get introExploreTitle => 'Explorá ciudades con contexto';

  @override
  String get introExploreDescription =>
      'Mirá costo, seguridad, adaptación al idioma y señales locales para entender por qué una ciudad aparece como buena opción.';

  @override
  String get introPlanTitle => 'Armá un primer plan';

  @override
  String get introPlanDescription =>
      'Respondé pocas preguntas y recibí una dirección práctica para tu próximo paso.';

  @override
  String get introDocumentationTitle =>
      'Consultá la documentación cuando la necesites';

  @override
  String get introDocumentationDescription =>
      'Usá la guía para entender CPF, registro, salud, trabajo y costos aproximados del arranque de la mudanza.';

  @override
  String get introBetaTitle => 'Qué ya está disponible en este beta';

  @override
  String get introBetaDescription =>
      'Esta versión se enfoca en claridad. Ya podés explorar ciudades, comparar señales y generar un plan inicial antes de que lleguen las funciones más profundas de cuenta.';

  @override
  String get introBottomSupportLabel => 'Siguiente paso';

  @override
  String get introPrimaryAction => 'Empezar a explorar';

  @override
  String get introSkipAction => 'Saltar';

  @override
  String get cityPracticalAnswersTitle =>
      'Respuestas rápidas para dudas comunes';

  @override
  String get cityPracticalLanguageQuestion =>
      '¿La vida diaria sería más fácil si todavía dependés del español?';

  @override
  String get cityPracticalCostQuestion =>
      '¿Esta ciudad parece manejable en costo de vida cotidiano?';

  @override
  String get cityPracticalWorkQuestion =>
      '¿Parece una buena ciudad para empezar a trabajar?';

  @override
  String get cityPracticalSafetyQuestion =>
      '¿Parece más fácil adaptarse con una rutina más estable?';

  @override
  String get cityPracticalLanguageEasy =>
      'Se ve más fácil que el promedio para alguien que llega hablando español, porque combina mejor adaptación con el idioma y familiaridad con argentinos.';

  @override
  String get cityPracticalLanguageMedium =>
      'Se ve manejable, pero igual conviene llegar con una base de portugués para la rutina.';

  @override
  String get cityPracticalLanguageHard =>
      'Probablemente te exija adaptarte más rápido al portugués, porque el apoyo cotidiano en español parece menor.';

  @override
  String get cityPracticalCostEasy =>
      'Su señal de costo se ve más amigable para una mudanza inicial dentro del catálogo actual.';

  @override
  String get cityPracticalCostMedium =>
      'Se ve equilibrada, pero todavía conviene validar alquiler y barrios con cuidado.';

  @override
  String get cityPracticalCostHard =>
      'Puede sentirse más pesada al principio, así que acá pesan más el presupuesto y la búsqueda de vivienda.';

  @override
  String get cityPracticalWorkStrong =>
      'Muestra señales más fuertes de oportunidades laborales y estructura económica inicial.';

  @override
  String get cityPracticalWorkMedium =>
      'Puede funcionar según tu perfil, pero la elección de ciudad necesita ser más deliberada.';

  @override
  String get cityPracticalWorkLow =>
      'Se ve menos atractiva si tu principal preocupación es conseguir trabajo rápido.';

  @override
  String get cityPracticalSafetyGood =>
      'Dentro de este catálogo inicial, parece más apta para una rutina diaria más estable.';

  @override
  String get cityPracticalSafetyMedium =>
      'Se ve razonable, pero el contexto local y el barrio siguen importando mucho.';

  @override
  String get cityPracticalSafetyLow =>
      'Conviene mirarla con más cuidado y validar mejor el contexto local antes de tomarla como una opción simple.';

  @override
  String get cityMetricBadgePositive => 'Lectura favorable';

  @override
  String get cityMetricBadgeNeutral => 'Pide equilibrio';

  @override
  String get cityMetricBadgeAttention => 'Pide más atención';

  @override
  String get cityMetricCostLowHeadline => 'Costo bajo';

  @override
  String get cityMetricCostLowSupporting =>
      'Más liviano para el presupuesto del día a día.';

  @override
  String get cityMetricCostMediumHeadline => 'Costo moderado';

  @override
  String get cityMetricCostMediumSupporting =>
      'Un equilibrio razonable entre rutina e infraestructura.';

  @override
  String get cityMetricCostHighHeadline => 'Costo alto';

  @override
  String get cityMetricCostHighSupporting =>
      'Va a exigir más cuidado con el alquiler y los gastos mensuales.';

  @override
  String get cityMetricSafetyHighHeadline => 'Seguridad alta';

  @override
  String get cityMetricSafetyHighSupporting =>
      'Lectura más cómoda para la rutina inicial.';

  @override
  String get cityMetricSafetyMediumHeadline => 'Seguridad moderada';

  @override
  String get cityMetricSafetyMediumSupporting =>
      'Depende más del barrio y del contexto local.';

  @override
  String get cityMetricSafetyLowHeadline => 'Más cautela';

  @override
  String get cityMetricSafetyLowSupporting =>
      'Conviene validar mejor la ciudad antes de tomarla como una mudanza simple.';

  @override
  String get cityMetricLanguageEasyHeadline => 'Adaptación fácil';

  @override
  String get cityMetricLanguageEasySupporting =>
      'Suele ser más amigable para quien llega hablando español.';

  @override
  String get cityMetricLanguageMediumHeadline => 'Adaptación moderada';

  @override
  String get cityMetricLanguageMediumSupporting =>
      'Una base de portugués ayuda bastante en la rutina.';

  @override
  String get cityMetricLanguageHardHeadline => 'Adaptación más difícil';

  @override
  String get cityMetricLanguageHardSupporting =>
      'El idioma tiende a pesar más en la integración diaria.';

  @override
  String get cityMetricWorkStrongHeadline => 'Mercado fuerte';

  @override
  String get cityMetricWorkStrongSupporting =>
      'Ciudad con una lectura más favorable para buscar oportunidades.';

  @override
  String get cityMetricWorkMediumHeadline => 'Mercado moderado';

  @override
  String get cityMetricWorkMediumSupporting =>
      'Puede funcionar bien, pero depende más de tu perfil.';

  @override
  String get cityMetricWorkLowHeadline => 'Mercado más limitado';

  @override
  String get cityMetricWorkLowSupporting =>
      'Pide más estrategia si conseguir trabajo rápido es tu prioridad.';

  @override
  String get cityIdhmVeryHigh => 'Desarrollo muy alto';

  @override
  String get cityIdhmVeryHighSupporting =>
      'Entre los niveles municipales más fuertes del indicador oficial.';

  @override
  String get cityIdhmHigh => 'Desarrollo alto';

  @override
  String get cityIdhmHighSupporting =>
      'Una lectura sólida de desarrollo humano en la referencia oficial.';

  @override
  String get cityIdhmMedium => 'Desarrollo medio';

  @override
  String get cityIdhmMediumSupporting =>
      'Conviene leerlo junto con costo y oportunidades.';

  @override
  String get cityIdhmLow => 'Desarrollo bajo';

  @override
  String get cityIdhmLowSupporting =>
      'Pide más cuidado antes de asumir una buena estructura general.';

  @override
  String get cityIdhmVeryLow => 'Desarrollo muy bajo';

  @override
  String get cityIdhmVeryLowSupporting =>
      'Señala una base más frágil en el indicador oficial.';

  @override
  String get citySnapshotRentLower => 'Alquiler más liviano';

  @override
  String get citySnapshotRentLowerSupporting =>
      'Suele pesar menos al inicio de la mudanza.';

  @override
  String get citySnapshotRentModerate => 'Alquiler moderado';

  @override
  String get citySnapshotRentModerateSupporting =>
      'Pide equilibrio entre barrio, contrato y rutina.';

  @override
  String get citySnapshotRentHigher => 'Alquiler más alto';

  @override
  String get citySnapshotRentHigherSupporting =>
      'Va a exigir más cuidado antes de cerrar vivienda.';

  @override
  String get cityHousingViabilityTileLabel => 'Entrada de vivienda';

  @override
  String get cityHousingViabilityEasyHeadline => 'Entrada más liviana';

  @override
  String get cityHousingViabilityEasySupporting =>
      'Tiende a permitir un aterrizaje más suave, con menos presión de alquiler y más margen para ajustar barrio y rutina.';

  @override
  String get cityHousingViabilityEasyBadge => 'Buena para soft landing';

  @override
  String get cityHousingViabilityBalancedHeadline => 'Entrada equilibrada';

  @override
  String get cityHousingViabilityBalancedSupporting =>
      'Puede funcionar bien si llegás con reserva y validás barrio, garantía y costo total antes de firmar.';

  @override
  String get cityHousingViabilityBalancedBadge => 'Necesita validación';

  @override
  String get cityHousingViabilityHardHeadline => 'Exige más caja';

  @override
  String get cityHousingViabilityHardSupporting =>
      'Acá el alquiler y la entrada suelen pesar más. Conviene tratar la vivienda como un filtro serio antes de elegir la ciudad.';

  @override
  String get cityHousingViabilityHardBadge => 'Presión de vivienda alta';

  @override
  String get cityMetricInsightTapHint =>
      'Tocá para entender los datos detrás de esta lectura.';

  @override
  String get cityMetricInsightMeaningTitle => 'Qué significa';

  @override
  String get cityMetricInsightMethodTitle => 'Cómo se armó esta lectura';

  @override
  String get cityMetricInsightFactsTitle => 'Datos usados hoy';

  @override
  String get cityMetricInsightValidateTitle =>
      'Qué conviene validar antes de decidir';

  @override
  String get cityMetricInsightSourcesTitle => 'Base y fuentes';

  @override
  String get cityMetricInsightDisclaimer =>
      'Usá este card como triage inicial. La decisión final todavía depende del barrio, del precio real y de la validación local.';

  @override
  String get cityMetricInsightCurrentBaseBadge => 'Base usada hoy';

  @override
  String get cityMetricInsightMappedBaseBadge => 'Referencia mapeada';

  @override
  String get cityMetricInsightOpenSourceAction => 'Abrir fuente';

  @override
  String get cityMetricInsightRangeLabel => 'Rango de este card';

  @override
  String get cityMetricInsightSpanishSupportLabel => 'Apoyo en español';

  @override
  String get cityMetricInsightLanguageCurrentBaseTitle =>
      'Lectura práctica de adaptación';

  @override
  String get cityMetricInsightHousingMeaning =>
      'Cuando este bloque cae en alerta, significa que el alquiler y el costo de entrada suelen pesar más en la mudanza inicial a esta ciudad.';

  @override
  String get cityMetricInsightHousingMethod =>
      'Hoy la app cruza el rentScore de la ciudad con el score económico general. Cuando la lectura de vivienda queda por debajo de 55, el producto trata la entrada de vivienda como un filtro crítico.';

  @override
  String get cityMetricInsightHousingValidate =>
      'Compará alquiler real, depósito, garantía, muebles y costo del barrio antes de firmar. Acá equivocarse con la vivienda suele costar más.';

  @override
  String get cityMetricInsightHousingMappedSource =>
      'FipeZAP es la referencia más sólida ya mapeada en el proyecto para recalibrar alquiler y presión de vivienda cuando exista cobertura municipal.';

  @override
  String get cityMetricInsightSafetyMeaning =>
      'Esta alerta no quiere decir que la ciudad sea inviable. Quiere decir que el barrio, la rutina y la validación local pesan más antes de tratar la mudanza como simple.';

  @override
  String get cityMetricInsightSafetyMethod =>
      'Hoy el card usa el safetyScore del catálogo Movaro. Debajo de 55 la lectura pasa a cautela; entre 55 y 69 queda moderada; desde 70 pasa a ser más favorable.';

  @override
  String get cityMetricInsightSafetyValidate =>
      'Revisá barrio por barrio, traslados nocturnos, rutina real de quien ya vive en la ciudad y la diferencia entre zonas turísticas y residenciales.';

  @override
  String get cityMetricInsightSafetyMappedSource =>
      'Atlas da Violência es la referencia oficial mapeada en el proyecto para recalibrar este grupo con base pública y metodología abierta.';

  @override
  String get cityMetricInsightWorkMeaning =>
      'Mercado moderado no es un bloqueo. Significa que la ciudad puede funcionar, pero el resultado depende más de tu área, seniority y forma de entrada.';

  @override
  String get cityMetricInsightWorkMethod =>
      'La nota de trabajo combina jobMarketScore, economicActivityScore y desempleo invertido. Entre 62 y 77 la lectura queda moderada; por encima de 78 queda fuerte.';

  @override
  String get cityMetricInsightWorkValidate =>
      'Buscá vacantes reales en tu área, mirá qué sectores empujan la ciudad y estimá cuánto margen tendrías hasta generar el primer ingreso.';

  @override
  String get cityMetricInsightWorkMappedSource =>
      'Novo Caged es la principal referencia oficial mapeada para medir dinamismo del empleo formal municipal.';

  @override
  String get cityMetricInsightWorkEconomicMappedSource =>
      'PIB dos Municípios, de IBGE, es la referencia oficial mapeada para calibrar el peso de la actividad económica de la ciudad.';

  @override
  String get cityMetricInsightLanguageMeaning =>
      'Adaptación más difícil significa que el portugués tiende a pesar más en la integración práctica del día a día y que el apoyo informal en español parece menor.';

  @override
  String get cityMetricInsightLanguageMethod =>
      'Esta lectura usa el score de adaptación lingüística con apoyo del soporte en español y de la familiaridad con argentinos. Debajo de 65, la fricción suele ser mayor.';

  @override
  String get cityMetricInsightLanguageValidate =>
      'Probá la rutina sin depender del español: alquiler, mercado, salud, servicios y trabajo. Si eso se vuelve un freno, la adaptación real de la ciudad es más dura para tu perfil.';

  @override
  String get cityMetricInsightLanguageMappedSource =>
      'Todavía no hay una fuente oficial única para esta lectura. Hoy sigue siendo una heurística curada del producto para medir adaptación práctica.';

  @override
  String get citySnapshotPopularityHigh => 'Muy buscada';

  @override
  String get citySnapshotPopularityHighSupporting =>
      'Ya aparece con fuerte afinidad entre argentinos.';

  @override
  String get citySnapshotPopularityMedium => 'Popularidad moderada';

  @override
  String get citySnapshotPopularityMediumSupporting =>
      'Tiene una familiaridad razonable dentro del catálogo actual.';

  @override
  String get citySnapshotPopularityLow => 'Menos recurrente';

  @override
  String get citySnapshotPopularityLowSupporting =>
      'Todavía aparece menos en el recorte inicial de interés argentino.';

  @override
  String get citySnapshotUnemploymentLower => 'Desempleo más bajo';

  @override
  String get citySnapshotUnemploymentModerate => 'Desempleo moderado';

  @override
  String get citySnapshotUnemploymentHigher => 'Desempleo más alto';

  @override
  String get languageSelectorTooltip => 'Elegir idioma';

  @override
  String get languageOptionSpanishArgentina => 'Español (Argentina)';

  @override
  String get languageOptionEnglish => 'English';

  @override
  String get languageOptionPortuguese => 'Portugués';

  @override
  String get commonRetryAction => 'Intentar de nuevo';

  @override
  String get commonBackAction => 'Volver';

  @override
  String get commonGotItAction => 'Entendido';

  @override
  String get protectedCommunityCreateTitle => 'Crear publicación';

  @override
  String get protectedCommunityCreateDescription =>
      'Este espacio va a permitir crear publicaciones cuando la comunidad esté habilitada.';

  @override
  String get questionOriginCountryTitle => '¿De dónde venís?';

  @override
  String get journeyEntryTitle => 'Elegí tu destino y empezá más rápido';

  @override
  String get journeyEntryBody =>
      'Primero elegí a dónde querés mudarte. Movaro guarda esa decisión ahora y te pide el origen en la primera parte del cuestionario.';

  @override
  String get journeyEntryDestinationLabel => '¿A dónde querés ir?';

  @override
  String get journeyEntryStartAction => 'Empezar mi plan';

  @override
  String get journeyEntryDynamicTitle =>
      'Start with a route that matches where you are and where you want to go';

  @override
  String get journeyEntryDynamicBody =>
      'You can use your current location as a quick hint or choose everything manually. Movaro never locks your origin from device location, and you can always override it.';

  @override
  String get journeyEntryUseLocationTitle => 'Use my location';

  @override
  String get journeyEntryUseLocationBody =>
      'Ask only now, detect your current country if possible, and let you confirm whether it should be used as origin.';

  @override
  String get journeyEntryUseLocationAction => 'Use my location';

  @override
  String get journeyEntryManualTitle => 'Choose manually';

  @override
  String get journeyEntryManualBody =>
      'Skip location, set origin and destination yourself, and keep full control over the route.';

  @override
  String get journeyEntryManualAction => 'Choose manually';

  @override
  String get journeyEntryContinueAction => 'Continue to questionnaire';

  @override
  String journeyEntrySelectedDestination(Object destination) {
    return 'Destino elegido: $destination';
  }

  @override
  String get journeyEntryOriginPending =>
      'Vamos a pedir tu origen en la primera pregunta antes de generar el plan.';

  @override
  String get journeyLocationPanelTitle =>
      'Location can save one step, but it never decides for you';

  @override
  String get journeyLocationPanelBody =>
      'If you allow location, Movaro tries to detect your current country and suggests it as origin. You can reject the suggestion and choose manually instead.';

  @override
  String get journeyLocationFallbackTitle =>
      'Location did not resolve a usable country';

  @override
  String get journeyLocationDeniedBody =>
      'Location permission was denied. You can keep going by choosing origin and destination manually.';

  @override
  String get journeyLocationDeniedForeverBody =>
      'Location permission is blocked for this app right now. You can still continue with manual selection.';

  @override
  String get journeyLocationUnavailableBody =>
      'Location services are off on this device. Turn them on if you want a location hint, or continue manually.';

  @override
  String get journeyLocationFailedBody =>
      'Movaro could not detect your location this time. You can retry or choose manually.';

  @override
  String get journeyLocationRetryAction => 'Try again';

  @override
  String journeyDetectedLocationLabel(Object value) {
    return 'Detected location: $value';
  }

  @override
  String journeyDetectedConfirmBody(Object country) {
    return 'Use $country as your origin? This only sets a suggestion you can edit at any time.';
  }

  @override
  String journeyDetectedUnknownBody(Object country) {
    return 'Movaro detected $country, but it could not match that country to the current route catalog. Choose your origin manually to continue.';
  }

  @override
  String journeyDetectedConfirmAction(Object country) {
    return 'Use $country as origin';
  }

  @override
  String get questionnaireOriginAutoDetectTitle => 'Encontramos tu ubicación';

  @override
  String get questionnaireOriginUnsupportedTitle =>
      'Este país todavía no está cubierto';

  @override
  String get questionnaireOriginLocationFailedTitle =>
      'No pudimos detectar tu ubicación';

  @override
  String questionnaireOriginUnsupportedBody(Object country) {
    return 'Movaro detectó $country, pero el plan guiado solo está disponible para personas que vienen desde Argentina por ahora. Podés elegir Argentina manualmente o usarla para continuar.';
  }

  @override
  String get questionnaireOriginUseArgentinaAction => 'Usar Argentina';

  @override
  String get journeyDetectedManualAction => 'Choose origin manually';

  @override
  String get journeyOriginSectionTitle => 'Origin';

  @override
  String get journeyOriginSectionBody =>
      'Optional for now. Confirm it here if you already know it, or skip and answer it in the first questionnaire step.';

  @override
  String get journeyOriginSkipAction => 'Skip for now';

  @override
  String get journeyDestinationSectionTitle => 'Destination';

  @override
  String get journeyDestinationSectionBody =>
      'Choose where you want the migration plan to point. Destination is still required before the questionnaire starts.';

  @override
  String get journeyPickerChooseDestinationTitle => 'Elegir destino';

  @override
  String get journeyPickerChooseOriginTitle => 'Elegir origen';

  @override
  String get journeyPickerSearchHint => 'Buscar país';

  @override
  String get journeyPickerNoResults => 'No se encontraron países';

  @override
  String get journeyCoverageFull => 'Full coverage';

  @override
  String get journeyCoveragePartial => 'Partial coverage';

  @override
  String get journeyCoverageUnsupported => 'Unsupported';

  @override
  String get journeyCoverageReadyTitle => 'This route is ready for planning';

  @override
  String journeyCoverageReadyBody(Object origin, Object destination) {
    return '$origin -> $destination is supported in the current migration flow.';
  }

  @override
  String get journeyCoverageDestinationLimitedTitle =>
      'Destination coverage is still limited';

  @override
  String journeyCoverageDestinationLimitedBody(Object destination) {
    return '$destination does not yet have full destination coverage for the guided migration flow. You can still explore content while the route expands.';
  }

  @override
  String get journeyCoverageOriginLimitedTitle =>
      'Origin coverage is still limited';

  @override
  String journeyCoverageOriginLimitedBody(Object origin) {
    return '$origin can be saved as your origin, but the current guided plan does not fully support that starting country yet.';
  }

  @override
  String get journeyCoverageDetectedUnknownTitle =>
      'Detected country is outside the current catalog';

  @override
  String journeyCoverageDetectedUnknownBody(Object country) {
    return '$country is not mapped in the current supported-country catalog yet. Choose another origin manually or keep browsing public content.';
  }

  @override
  String get journeyCoverageUnsupportedTitle =>
      'Choose a supported route to generate a plan';

  @override
  String get journeyCoverageUnsupportedBody =>
      'Movaro can still show cities and practical content, but the guided migration flow is only available on routes with full coverage.';

  @override
  String get journeyCoverageChooseRouteAction => 'Choose another route';

  @override
  String get journeyCoverageBrowseAction => 'Browse explore';

  @override
  String get journeyCoverageContentAction => 'Open content';

  @override
  String get journeyCoverageWaitlistAction => 'Join waitlist';

  @override
  String get journeyCoverageWaitlistStub =>
      'Waitlist registration is not live yet, but this route can be tracked safely for future coverage.';

  @override
  String get questionDestinationCountryTitle => '¿A dónde querés ir?';

  @override
  String get questionGoalTitle => '¿Qué querés hacer en el nuevo país?';

  @override
  String get questionPortugueseFamiliarityTitle =>
      '¿Qué tan cómodo te sentís hoy con el portugués?';

  @override
  String get questionTimelineTitle => '¿Cuándo pensás mudarte?';

  @override
  String get questionOptionArgentina => 'Argentina';

  @override
  String get questionOptionBrazil => 'Brasil';

  @override
  String get questionOptionChile => 'Chile';

  @override
  String get questionOptionUruguay => 'Uruguay';

  @override
  String get questionOptionParaguay => 'Paraguay';

  @override
  String get questionOptionUnknown => 'Todavía no lo sé';

  @override
  String get questionOptionWork => 'Trabajar';

  @override
  String get questionOptionRemoteWork => 'Trabajar remoto';

  @override
  String get questionOptionStudy => 'Estudiar';

  @override
  String get questionOptionEntrepreneur => 'Emprender';

  @override
  String get questionOptionRetire => 'Retirarme';

  @override
  String get questionOptionQualityOfLife => 'Calidad de vida';

  @override
  String get questionOptionBeachLife => 'Playa y litoral';

  @override
  String get questionOptionNoPortuguese =>
      'Todavía dependo principalmente del español';

  @override
  String get questionOptionBasicPortuguese => 'Me manejo con portugués básico';

  @override
  String get questionOptionComfortablePortuguese =>
      'Ya puedo vivir en portugués';

  @override
  String get questionOptionResearching => 'Solo estoy investigando';

  @override
  String get questionOption12Months => 'En los próximos 12 meses';

  @override
  String get questionOption6Months => 'En los próximos 6 meses';

  @override
  String get questionOptionAsap => 'Lo antes posible';

  @override
  String get recommendationReasonEconomical =>
      'Buena opción para quien prioriza costo';

  @override
  String get recommendationReasonPopularArgentina => 'Popular entre argentinos';

  @override
  String get recommendationReasonLanguageSupport =>
      'Adaptación más fácil si todavía dependés del español';

  @override
  String get recommendationReasonWorkMarket => 'Mercado laboral más fuerte';

  @override
  String get recommendationReasonInfrastructure =>
      'Costo más alto, pero mejor infraestructura';

  @override
  String get recommendationReasonBalanced =>
      'Opción equilibrada dentro del catálogo inicial de Movaro';

  @override
  String get planReasonGoalWork =>
      'Se destaca para quien está buscando más oportunidades de trabajo.';

  @override
  String get planReasonGoalRemoteWork =>
      'Encaja mejor para quien quiere trabajar remoto y equilibrar costo con calidad de vida.';

  @override
  String get planReasonGoalStudy =>
      'Tiene una buena combinación de estructura urbana y adaptación inicial para estudiar.';

  @override
  String get planReasonGoalEntrepreneur =>
      'Muestra mejores señales de actividad económica para quien quiere emprender.';

  @override
  String get planReasonGoalRetire =>
      'Tiene más sentido para quien busca más seguridad y un costo más controlado.';

  @override
  String get planReasonGoalQualityOfLife =>
      'Se ajusta mejor a una búsqueda de más calidad de vida y adaptación gradual.';

  @override
  String get planReasonGoalBeachLife =>
      'Tiene más sentido si querés priorizar litoral, playa y una rutina más conectada con el mar.';

  @override
  String get planReasonLanguageNeedsSupport =>
      'Como dijiste que todavía dependés del español, dimos más peso a ciudades con mejor adaptación lingüística.';

  @override
  String get planReasonLanguageBasic =>
      'Como dijiste que te manejás con portugués básico, la adaptación al idioma todavía influye en la recomendación.';

  @override
  String get planReasonTimelineAsap =>
      'Puede ayudar en una mudanza más rápida por combinar mejor adaptación inicial y vida práctica.';

  @override
  String get planReasonTimeline6Months =>
      'Funciona bien para un horizonte de mudanza más corto.';

  @override
  String get planReasonTimeline12Months =>
      'Ofrece una base equilibrada para quien todavía está armando la mudanza.';

  @override
  String get planStepTitleVisaResidence =>
      'Revisar el tipo de residencia o visa';

  @override
  String get planStepDescriptionVisaResidence =>
      'Mapear la base migratoria adecuada para tu principal motivación de cambio.';

  @override
  String get planStepTitleCpf => 'Obtener CPF';

  @override
  String get planStepDescriptionCpf =>
      'Organizar el registro fiscal necesario para servicios y transacciones en Brasil.';

  @override
  String get planStepTitleBankAccount => 'Abrir una cuenta bancaria';

  @override
  String get planStepDescriptionBankAccount =>
      'Preparar una cuenta local para el movimiento financiero inicial.';

  @override
  String get planStepTitleHousing => 'Buscar vivienda';

  @override
  String get planStepDescriptionHousing =>
      'Investigar barrios, contratos y costos para instalarte con más seguridad.';

  @override
  String get planStepTitleSettleDocuments =>
      'Regularizar la documentación local';

  @override
  String get planStepDescriptionSettleDocuments =>
      'Revisar registros adicionales, comprobantes y pasos administrativos locales.';

  @override
  String get planStepTitleMapDestinations => 'Mapear destinos posibles';

  @override
  String get planStepDescriptionMapDestinations =>
      'Comparar opciones de destino según tu objetivo y tu ventana de cambio.';

  @override
  String get planStepTitleDecisionCriteria => 'Definir criterios de decisión';

  @override
  String get planStepDescriptionDecisionCriteria =>
      'Ordenar prioridades como costo, documentación y calidad de vida.';

  @override
  String get planBeachDecisionTitle => 'Litoral en la decisión';

  @override
  String get planBeachDecisionIntro =>
      'Si playa y litoral entran en tu criterio, no alcanza con mirar belleza o turismo. El filtro real pasa por vivienda, ritmo de la ciudad y aterrizaje inicial.';

  @override
  String get planBeachDecisionCoastalHeadline =>
      'La recomendación ya apunta al litoral';

  @override
  String planBeachDecisionCoastalBody(Object cityName) {
    return '$cityName ya entra en el recorte de ciudad costera. El siguiente filtro es entender si la entrada de vivienda y la rutina local encajan con tu momento.';
  }

  @override
  String get planBeachDecisionNotCoastalHeadline =>
      'Tu criterio de playa pide una comparación extra';

  @override
  String get planBeachDecisionNotCoastalBody =>
      'Incluso con este objetivo, conviene comparar ciudades de playa antes de cerrar la decisión. No toda ciudad fuerte en el plan entrega la rutina costera que tal vez buscás.';

  @override
  String get planBeachDecisionPriorityNote =>
      'Si la playa es prioridad, tratá la vivienda y la rutina local como filtro principal.';

  @override
  String get planBeachDecisionHousingHeadline =>
      'Entrada de vivienda en el litoral';

  @override
  String get stepCategoryDocumentation => 'Documentación';

  @override
  String get stepCategoryFinancial => 'Finanzas';

  @override
  String get stepCategoryHousing => 'Vivienda';

  @override
  String get stepCategorySettlement => 'Instalación';

  @override
  String get stepCategoryResearch => 'Investigación';

  @override
  String get stepCategoryPlanning => 'Planificación';

  @override
  String get industryAgribusiness => 'Agronegocio';

  @override
  String get industryCommerce => 'Comercio';

  @override
  String get industryConstruction => 'Construcción';

  @override
  String get industryEnergy => 'Energía';

  @override
  String get industryFinance => 'Finanzas';

  @override
  String get industryIndustry => 'Industria';

  @override
  String get industryLogistics => 'Logística';

  @override
  String get industryPort => 'Puerto';

  @override
  String get industryHealth => 'Salud';

  @override
  String get industryServices => 'Servicios';

  @override
  String get industryTechnology => 'Tecnología';

  @override
  String get industryTourism => 'Turismo';

  @override
  String get errorNetworkTitle => 'Parece que estás sin conexión.';

  @override
  String get errorNetworkDescription =>
      'Revisá tu conexión e intentá de nuevo en un momento.';

  @override
  String get errorServerTitle => 'Algo salió mal. Intentá de nuevo.';

  @override
  String get errorServerDescription =>
      'No pudimos completar esta acción ahora. Intentá de nuevo en unos instantes.';

  @override
  String get errorNotFoundTitle => 'No encontramos esta información.';

  @override
  String get errorNotFoundDescription =>
      'Este contenido no está disponible en este momento o todavía no forma parte de esta base.';

  @override
  String get errorUnauthorizedTitle =>
      'Necesitás iniciar sesión para continuar.';

  @override
  String get errorUnauthorizedDescription =>
      'Algunas acciones necesitan estar vinculadas con vos antes de poder guardarse.';

  @override
  String get errorUnknownTitle => 'Ocurrió algo inesperado.';

  @override
  String get errorUnknownDescription => 'Intentá de nuevo en unos instantes.';

  @override
  String get errorValidationTitle => 'No fue posible completar la acción.';

  @override
  String get errorNetworkMovaroDescription =>
      'No pudimos comunicarnos con Movaro en este momento. Intentá de nuevo en unos instantes.';

  @override
  String get errorApiGenericDescription =>
      'No fue posible completar esta acción ahora.';

  @override
  String get apiUnavailableTitle =>
      'Movaro no pudo conectarse con la API en este momento.';

  @override
  String get apiUnavailableDescription =>
      'La app abrió, pero el servicio principal no está disponible ahora. Sin esa conexión, no puede cargar tu recorrido con datos reales.';

  @override
  String get apiUnavailableSupportingText =>
      'Intentá nuevamente en unos instantes. Si el problema sigue, revisá si la API está online y si este ambiente apunta a la URL correcta.';

  @override
  String get apiUnavailableRetryAction => 'Intentar de nuevo';

  @override
  String get sourceProviderIbgeLocalities => 'IBGE Localidades';

  @override
  String get sourceProviderIbgeCities => 'IBGE Ciudades y Estados';

  @override
  String get sourceProviderAtlasHumanDevelopment =>
      'Atlas de Desarrollo Humano en Brasil (PNUD, Ipea y FJP)';

  @override
  String get sourceProviderMovaroDataset => 'Dataset Curado de Movaro v1';

  @override
  String get sourceProviderMovaroRanking =>
      'Metodología de Ranking de Movaro v1';

  @override
  String get sourceProviderGoogleMaps => 'Google Maps';

  @override
  String get sourceProviderReceitaFederalGovBr => 'Receita Federal / Gov.br';

  @override
  String get sourceProviderArgentinaMigraciones =>
      'Argentina.gob.ar / Migraciones';

  @override
  String get sourceProviderPoliciaFederal => 'Policía Federal';

  @override
  String get sourceProviderPoliciaFederalGovBr => 'Policía Federal / Gov.br';

  @override
  String get sourceProviderMrePoliciaFederal => 'Cancillería / Policía Federal';

  @override
  String get sourceProviderMreBancoCentral => 'Cancillería / Banco Central';

  @override
  String get sourceProviderMinisterioJustica => 'Ministerio de Justicia';

  @override
  String get sourceProviderMinisterioSaude => 'Gov.br / Ministerio de Salud';

  @override
  String get sourceProviderMeuSusDigital => 'Meu SUS Digital / Gov.br';

  @override
  String get sourceProviderAns => 'ANS';

  @override
  String get sourceProviderDetranEsMgGov => 'Detran-ES / MG.gov.br';

  @override
  String get sourceProviderSenatranMgGov => 'SENATRAN / MG.gov.br';

  @override
  String get sourceProviderMteCtps =>
      'Ministerio de Trabajo / Carteira de Trabalho Digital';

  @override
  String get sourceProviderPortalEmpreendedorInss =>
      'Portal del Emprendedor / INSS';

  @override
  String get sourceProviderMinisterioPrevidenciaInss =>
      'Ministerio de Previsión / INSS';

  @override
  String get sourceProviderIbgePnadContinua => 'IBGE / PNAD Continua';

  @override
  String get sourceProviderForumBrasileiroSegurancaPublica =>
      'Foro Brasileño de Seguridad Pública';

  @override
  String get sourceProviderBancoCentralBrasil => 'Banco Central de Brasil';

  @override
  String get sourceProviderMovaro => 'Movaro';

  @override
  String get documentReadinessSectionTitle =>
      'Preparación documental antes de la mudanza';

  @override
  String get documentReadinessPriorityCritical => 'Crítico ahora';

  @override
  String get documentReadinessPriorityPrepare => 'Prepará con anticipación';

  @override
  String get documentReadinessPriorityArrival =>
      'Llevalo listo para la llegada';

  @override
  String get documentReadinessSummaryResearching =>
      'Antes de comparar demasiados caminos, confirmá si tu mudanza depende de un paquete documental que realmente pueda armarse sin sorpresas.';

  @override
  String get documentReadinessSummaryTwelveMonths =>
      'Con más tiempo, la meta es eliminar riesgo documental evitable temprano, en vez de descubrir faltantes cerca de la mudanza.';

  @override
  String get documentReadinessSummarySixMonths =>
      'Seis meses ya alcanzan para ordenar los documentos más sensibles ahora y dejar más liviana la llegada.';

  @override
  String get documentReadinessSummaryAsap =>
      'Como la mudanza está cerca, enfocáte primero en los documentos que pueden trabar residencia, banco y vivienda.';

  @override
  String get documentReadinessRouteTitle => 'Validá la ruta legal de entrada';

  @override
  String get documentReadinessRouteBodyBrazil =>
      'Confirmá si tu mudanza va a usar la residencia Mercosur y qué exige ese camino antes de armar el resto sobre supuestos.';

  @override
  String get documentReadinessRouteBodyGeneric =>
      'Confirmá primero la ruta legal del destino para que el resto del checklist se apoye en el camino migratorio correcto.';

  @override
  String get documentReadinessIdentityPackTitle =>
      'Separá el paquete base de identidad';

  @override
  String get documentReadinessIdentityPackBody =>
      'Mantené pasaporte, partidas, antecedentes e identificaciones personales en un solo bloque revisado antes de abrir otros frentes.';

  @override
  String get documentReadinessApostilleTitle =>
      'Revisá apostilla y vigencia documental';

  @override
  String get documentReadinessApostilleBodyBrazil =>
      'Para Brasil, revisá qué documentos argentinos necesitan apostilla, qué vigencia práctica tienen y qué puede vencer antes de la llegada.';

  @override
  String get documentReadinessRuleCheckTitle =>
      'Chequeá temprano las reglas documentales oficiales';

  @override
  String get documentReadinessRuleCheckBody =>
      'Mapeá qué documentos deben ser originales, apostillados, traducidos o reemitidos para no depender de supuestos.';

  @override
  String get documentReadinessTranslationTitle =>
      'Mapeá la traducción antes de pagar dos veces';

  @override
  String get documentReadinessTranslationBodyBrazil =>
      'Separá qué puede quedar en español y qué puede exigir traducción pública en Brasil, sobre todo para residencia y prueba civil.';

  @override
  String get documentReadinessTranslationBodyGeneric =>
      'Separá qué puede quedar en el idioma de origen y qué puede exigir traducción certificada en el país de destino.';

  @override
  String get documentReadinessHousingProofTitle =>
      'Prepará pruebas para vivienda y rutina inicial';

  @override
  String get documentReadinessHousingProofBodyBrazil =>
      'Agrupá comprobante de ingresos, reserva, identidad y documentos de apoyo que puedan pedir propietarios, bancos o garantías en Brasil.';

  @override
  String get documentReadinessProofPackTitle =>
      'Armá tu paquete práctico de comprobaciones';

  @override
  String get documentReadinessProofPackBody =>
      'Agrupá identidad, prueba de fondos, ingresos y los documentos que suelen destrabar banco, vivienda y servicios esenciales.';

  @override
  String get documentReadinessCpfTitle =>
      'Tratá el CPF y el estatus regular como una sola capa';

  @override
  String get documentReadinessCpfBodyBrazil =>
      'El CPF, el seguimiento de la residencia y el primer comprobante local suelen destrabar la vida práctica. Dejá ese bloque listo para ejecutar rápido.';

  @override
  String get documentReadinessCopiesTitle =>
      'Mantené backup físico y digital alineado';

  @override
  String get documentReadinessCopiesBody =>
      'Guardá scans, originales y copias de emergencia en una estructura accesible desde el celular y fácil de usar en persona si hace falta.';

  @override
  String get documentReadinessArrivalFolderTitle =>
      'Prepará una carpeta de llegada, no archivos sueltos';

  @override
  String get documentReadinessArrivalFolderBodyBrazil =>
      'Armá una carpeta única con seguimiento de residencia, referencias del CPF, notas de dirección y las pruebas que más pueden pedirte en el primer mes.';

  @override
  String get documentReadinessArrivalFolderBodyGeneric =>
      'Armá una carpeta única con los primeros documentos, notas de comprobación local y las evidencias que más probablemente necesites en las primeras semanas.';

  @override
  String get documentReadinessGoalWorkTitle =>
      'Protegé los documentos de empleabilidad';

  @override
  String get documentReadinessGoalWorkBodyBrazil =>
      'Revisá qué puede trabar trabajo temprano en Brasil: consistencia de identidad, seguimiento de residencia y pruebas específicas de tu área.';

  @override
  String get documentReadinessGoalWorkBodyGeneric =>
      'Revisá qué puede trabar trabajo temprano en el destino: consistencia de identidad, estatus migratorio y pruebas específicas de tu profesión.';

  @override
  String get documentReadinessGoalRemoteTitle =>
      'Estabilizá la base documental del ingreso remoto';

  @override
  String get documentReadinessGoalRemoteBodyBrazil =>
      'Mantené identidad fiscal, referencias bancarias y pruebas que sostengan contratos, transferencias y una rutina estable en Brasil.';

  @override
  String get documentReadinessGoalRemoteBodyGeneric =>
      'Mantené identidad fiscal, referencias bancarias y pruebas que sostengan contratos y flujo internacional de ingresos en el nuevo país.';

  @override
  String get documentReadinessGoalStudyTitle =>
      'Protegé la ruta de estudio con los registros correctos';

  @override
  String get documentReadinessGoalStudyBodyBrazil =>
      'Dejá admisión, historial académico, identidad y papeles sensibles a plazo alineados antes de depender del estudio como puerta de entrada.';

  @override
  String get documentReadinessGoalStudyBodyGeneric =>
      'Dejá admisión, historial académico, identidad y papeles sensibles a plazo alineados antes de depender del estudio como base.';

  @override
  String get documentReadinessGoalEntrepreneurTitle =>
      'Prepará la capa documental para operar';

  @override
  String get documentReadinessGoalEntrepreneurBodyBrazil =>
      'Separá las pruebas de identidad, banco y residencia que van a influir en la seguridad para empezar a operar en Brasil.';

  @override
  String get documentReadinessGoalEntrepreneurBodyGeneric =>
      'Separá las pruebas de identidad, banco e inmigración que van a influir en la seguridad para empezar a operar en el país de destino.';

  @override
  String get documentReadinessGoalRetireTitle =>
      'Protegé una llegada tranquila con papeles revisados';

  @override
  String get documentReadinessGoalRetireBodyBrazil =>
      'Priorizá el conjunto documental que reduce sorpresas en salud, banco y rutina recurrente cuando llegues a Brasil.';

  @override
  String get documentReadinessGoalRetireBodyGeneric =>
      'Priorizá el conjunto documental que reduce sorpresas en salud, banco y rutina recurrente cuando llegues.';

  @override
  String get documentReadinessGoalQualityTitle =>
      'Usá los documentos para reducir fricción, no solo para cumplir';

  @override
  String get documentReadinessGoalQualityBodyBrazil =>
      'Incluso cuando la prioridad es calidad de vida, la mudanza más suave es la que llega a Brasil con identidad, comprobaciones y carpeta de llegada ya ordenadas.';

  @override
  String get documentReadinessGoalQualityBodyGeneric =>
      'Incluso cuando la prioridad es calidad de vida, la mudanza más suave es la que llega con identidad, comprobaciones y carpeta de llegada ya ordenadas.';

  @override
  String get documentReadinessRiskBlocking => 'Puede trabar la mudanza';

  @override
  String get documentReadinessRiskCaution => 'Evita demoras y retrabajo';

  @override
  String get documentReadinessRiskReview => 'Revisar en la etapa correcta';

  @override
  String get documentReadinessReviewBeforeBooking =>
      'Revisá antes de comprar el pasaje';

  @override
  String get documentReadinessReviewCloseToMove =>
      'Reconfirmá cerca de la mudanza';

  @override
  String get documentReadinessReviewOnArrival => 'Dejalo listo para la llegada';

  @override
  String documentReadinessSourceLabel(Object source) {
    return 'Base: $source';
  }

  @override
  String get housingDecisionSectionTitle =>
      'La vivienda es una decisión crítica antes de la ciudad';

  @override
  String housingDecisionSectionTitleWithCity(Object city) {
    return 'La vivienda puede definir si $city realmente te sirve';
  }

  @override
  String get housingDecisionSectionBody =>
      'Antes de decidir la ciudad, conviene entender cómo funcionan el alquiler y las garantías en Brasil. El mayor riesgo no es solo el precio mensual: es llegar sin un camino viable para contrato, barrio e instalación inicial.';

  @override
  String housingDecisionSectionBodyWithCity(Object city) {
    return 'Antes de asumir que $city es la mejor opción, validá si el alquiler, las garantías y la instalación inicial parecen viables para tu momento. El riesgo no está solo en el precio, sino en el camino real para cerrar vivienda.';
  }

  @override
  String get housingDecisionGuaranteesTitle =>
      'Las garantías pueden trabar el alquiler';

  @override
  String get housingDecisionGuaranteesBody =>
      'El fiador local todavía pesa en muchos contratos. Si eso no es realista para vos, compará caución, seguro-fianza, título de capitalización y exigencia de ingresos antes de contar con un barrio.';

  @override
  String get housingDecisionSoftLandingTitle =>
      'Una llegada suave evita errores caros';

  @override
  String get housingDecisionSoftLandingBody =>
      'Temporal, amoblado, coliving o contrato corto por 30 a 90 días suele ser más seguro que tomar un alquiler largo antes de entender la rutina local.';

  @override
  String get housingDecisionProofPackTitle =>
      'Llevá la carpeta que destraba la conversación';

  @override
  String get housingDecisionProofPackBody =>
      'Agrupá identidad, ingresos, reserva, referencias y comprobantes digitales en una sola carpeta. No garantiza aprobación, pero reduce fricción desde el primer contacto.';

  @override
  String get housingDecisionCityReadTitle =>
      'Leé la ciudad por la presión de vivienda';

  @override
  String housingDecisionCityReadTitleWithCity(Object city) {
    return 'Leé $city por la presión de vivienda';
  }

  @override
  String get housingDecisionCityReadBody =>
      'No compares solo el alquiler promedio. Mirá barrios, transporte, servicios cerca, necesidad de muebles, distancia al trabajo y margen de caja para entrada e imprevistos.';

  @override
  String housingDecisionCityReadBodyWithCity(Object city) {
    return 'En $city, compará barrios, transporte, servicios cerca, necesidad de muebles y margen de caja para entrada e imprevistos antes de tratar la vivienda como resuelta.';
  }

  @override
  String get housingDecisionSectionNote =>
      'Hoy, Movaro organiza el contexto para decidir mejor. El contrato, la garantía aceptada y la política de cada propietario o plataforma todavía deben validarse en la fuente antes de cerrar vivienda.';

  @override
  String get housingEntrySectionTitle =>
      'Estimación del costo de entrada a la vivienda';

  @override
  String housingEntrySectionTitleWithCity(Object city) {
    return 'Cuánto puede exigir la vivienda para entrar en $city';
  }

  @override
  String get housingEntrySectionBody =>
      'Un alquiler que parece accesible en el anuncio puede exigir mucho más al entrar. Usá esta lectura para simular caución, seguro-fianza o un aterrizaje temporario antes de decidir la ciudad.';

  @override
  String housingEntrySectionBodyWithCity(Object city) {
    return 'En $city, no mires solo el alquiler mensual. Usá esta lectura para estimar cuánto puede exigir la entrada con caución, seguro-fianza o un aterrizaje temporario.';
  }

  @override
  String housingEntryRentLabel(Object amount) {
    return 'Alquiler mensual de referencia: $amount';
  }

  @override
  String get housingEntryModeDeposit => 'Caución';

  @override
  String get housingEntryModeInsurance => 'Seguro-fianza';

  @override
  String get housingEntryModeTemporary => 'Temporal';

  @override
  String get housingEntryModeDepositBody =>
      'Lectura común cuando el contrato pide cerca de 3 meses de caución más el primer mes.';

  @override
  String get housingEntryModeInsuranceBody =>
      'Lectura común cuando el fiador se reemplaza por una tasa anual de seguro o garantía digital.';

  @override
  String get housingEntryModeTemporaryBody =>
      'Una lectura más liviana para los primeros 30 a 90 días, priorizando flexibilidad antes de tomar un contrato largo.';

  @override
  String get housingEntryTotalTitle => 'Cuánto puede costar entrar';

  @override
  String get housingEntryFirstMonthLabel => 'Primer mes';

  @override
  String get housingEntryGuaranteeLabel => 'Garantía / caución';

  @override
  String get housingEntrySetupLabel => 'Tasas e instalación';

  @override
  String get housingEntryPlatformsTitle => 'Plataformas y caminos útiles';

  @override
  String get housingEntryPlatformsHeadline =>
      'Usá el canal correcto para tu nivel de riesgo';

  @override
  String get housingEntryPlatformsBody =>
      'La mejor plataforma depende menos del anuncio lindo y más de la burocracia que realmente podés sostener ahora.';

  @override
  String get housingEntryPlatformsQuintoAndar =>
      'Digital y sin fiador, pero igual exige ingresos y documentación consistentes.';

  @override
  String get housingEntryPlatformsZap =>
      'Usá filtros como alquiler sin fiador para reducir el tiempo perdido en la búsqueda.';

  @override
  String get housingEntryPlatformsCredPago =>
      'Garantía digital aceptada por muchas inmobiliarias como reemplazo del fiador.';

  @override
  String get housingEntryPlatformsAirbnb =>
      'Sirve para los primeros 15 a 30 días mientras visitás barrios antes de tomar un contrato más largo.';

  @override
  String get housingEntryDisclaimer =>
      'Esta simulación es orientativa. El valor real cambia según la ciudad, el barrio, la plataforma, la comprobación de ingresos y la política del propietario. La idea es evitar subestimar el costo de entrada.';

  @override
  String get housingSoftLandingTitle =>
      'Cómo suelen aterrizar los argentinos antes del alquiler fijo';

  @override
  String get housingSoftLandingBody =>
      'En los primeros días, el camino común no es ir directo al contrato tradicional. La secuencia suele ser llegada, vivienda temporaria y, solo después, la búsqueda de una base más estable con menos riesgo.';

  @override
  String get housingSoftLandingTemporaryTitle =>
      'Aterrizá por temporada o flat';

  @override
  String get housingSoftLandingTemporaryBody =>
      'Airbnb con descuento mensual, apart hotel y flat ayudan a aterrizar sin fiador ni comprobación local. Eso compra tiempo para visitar barrios y entender la ciudad en la práctica.';

  @override
  String get housingSoftLandingDirectTitle =>
      'Búsqueda directa con dueño o grupos locales';

  @override
  String get housingSoftLandingDirectBody =>
      'Facebook Marketplace, OLX y contactos directos suelen ser más flexibles que la inmobiliaria tradicional. A cambio, sube el riesgo de estafa y la validación del inmueble debe ser más estricta.';

  @override
  String get housingSoftLandingGuaranteeTitle =>
      'La moneda de cambio es la garantía';

  @override
  String get housingSoftLandingGuaranteeBody =>
      'Sin fiador, el argumento más fuerte suele ser caución, seguro-fianza, título de capitalización o algunos meses pagados por adelantado. El punto no es prometer de más, sino llegar con una estructura creíble.';

  @override
  String get housingSoftLandingSurvivalTitle =>
      'Checklist de supervivencia al llegar';

  @override
  String get housingSoftLandingSurvivalChip =>
      'Comprá un chip brasileño rápido. Sin número local, inmobiliarias y propietarios suelen responder menos.';

  @override
  String get housingSoftLandingSurvivalCpf =>
      'Si el CPF todavía no está resuelto, tratá eso como prioridad. Pesa en plataformas, banco y conversaciones de alquiler.';

  @override
  String get housingSoftLandingSurvivalLocation =>
      'En los primeros días, priorizá quedarte cerca de mercado, farmacia, transporte y puesto de salud para bajar costo y fricción.';

  @override
  String get housingSoftLandingSurvivalScam =>
      'No envíes una reserva sin visitar el inmueble o tener a alguien de confianza validando en el lugar.';

  @override
  String get landingBudgetSectionTitle => 'Reserva sugerida para el aterrizaje';

  @override
  String landingBudgetSectionTitleWithCity(String city) {
    return 'Reserva sugerida para llegar a $city';
  }

  @override
  String get landingBudgetSummaryResearching =>
      'Usá esto como referencia de reserva para no diseñar la mudanza mirando solo el costo mensual una vez que todo ya esté estable.';

  @override
  String get landingBudgetSummaryTwelveMonths =>
      'Con más tiempo, la meta es formar una reserva realista y reducir el golpe de los costos de instalación antes de que llegue la mudanza.';

  @override
  String get landingBudgetSummarySixMonths =>
      'Seis meses ya alcanzan para transformar la mudanza en un plan con reserva, en lugar de una secuencia de gastos reactivos.';

  @override
  String get landingBudgetSummaryAsap =>
      'Como la mudanza está cerca, la reserva importa tanto como la ciudad. Usá esta estimación para no llegar con poco margen financiero.';

  @override
  String get landingBudgetLeanTitle => 'Ajustado';

  @override
  String get landingBudgetLeanBody =>
      'Sirve como referencia si pensás llegar con un gasto más controlado, una vivienda más simple y decisiones iniciales más apretadas.';

  @override
  String get landingBudgetBalancedTitle => 'Equilibrado';

  @override
  String get landingBudgetBalancedBody =>
      'Una lectura intermedia para quien quiere reducir estrés sin asumir una instalación premium desde el día uno.';

  @override
  String get landingBudgetComfortableTitle => 'Cómodo';

  @override
  String get landingBudgetComfortableBody =>
      'Un margen más seguro si querés más aire para lidiar con fricción en la vivienda, una adaptación más lenta o costos inesperados de instalación.';

  @override
  String get landingBudget30DaysLabel => 'Referencia para los primeros 30 días';

  @override
  String get landingBudgetMonthlyBaseLabel => 'Base mensual';

  @override
  String get landingBudgetSetupLabel => 'Instalación y entrada';

  @override
  String get landingBudgetBufferLabel => 'Margen de seguridad';

  @override
  String landingBudget90DaysLabel(String amount) {
    return 'Si querés un colchón de 90 días, usá algo cerca de $amount';
  }

  @override
  String get landingBudgetDisclaimer =>
      'Estas estimaciones son orientativas, no precios oficiales. Combinan señales de ciudad, presión de instalación y riesgo por timing para ayudarte a planear la reserva antes de la mudanza.';

  @override
  String landingBudgetExchangeUpdatedAt(Object value) {
    return 'Tipo de cambio oficial actualizado en $value';
  }

  @override
  String get landingBudgetExchangeUnavailable =>
      'No fue posible actualizar el tipo de cambio oficial ahora. Los valores en reales siguen como referencia.';

  @override
  String get arrivalExecutionSectionTitle => 'Primeros 7 / 30 / 90 días';

  @override
  String get arrivalExecutionStageWeek => 'Primeros 7 días';

  @override
  String get arrivalExecutionStageMonth => 'Primeros 30 días';

  @override
  String get arrivalExecutionStageQuarter => 'Primeros 90 días';

  @override
  String get arrivalExecutionSummaryResearching =>
      'Esta es la capa de ejecución después de llegar. Usala ahora para entender qué van a exigir las primeras semanas, además del papeleo.';

  @override
  String get arrivalExecutionSummaryTwelveMonths =>
      'Con más tiempo, esta capa ayuda a ver qué va a exigir la instalación, para que la mudanza no se planee solo por documentos y reserva.';

  @override
  String get arrivalExecutionSummarySixMonths =>
      'Seis meses ya alcanzan para planear la llegada como una secuencia operativa, y no solo como una decisión de destino.';

  @override
  String get arrivalExecutionSummaryAsap =>
      'Si la llegada está cerca, esta capa de 7 / 30 / 90 días importa ahora. Ahí suele aparecer primero la fricción cotidiana.';

  @override
  String get arrivalExecutionConnectivityTitle =>
      'Resolvé la conectividad desde el día uno';

  @override
  String get arrivalExecutionConnectivityBody =>
      'Empezá con chip local, internet móvil y la estructura digital mínima para mapas, banco y seguimiento documental.';

  @override
  String get arrivalExecutionTransportTitle =>
      'Aprendé la primera rutina de traslado';

  @override
  String get arrivalExecutionTransportBody =>
      'Mapeá cómo te vas a mover en la primera semana para que vivienda, servicios y burocracia no dependan de la improvisación.';

  @override
  String arrivalExecutionTransportBodyWithCity(String city) {
    return 'Mapeá cómo te vas a mover en $city durante la primera semana para que vivienda, servicios y burocracia no dependan de la improvisación.';
  }

  @override
  String get arrivalExecutionHealthTitle =>
      'Definí tu primer respaldo de salud';

  @override
  String get arrivalExecutionHealthBody =>
      'Sabé cuál es tu primera puerta de entrada en salud pública o privada para que un problema simple no se vuelva caos al llegar.';

  @override
  String get arrivalExecutionBankTitle => 'Estabilizá pagos y flujo bancario';

  @override
  String get arrivalExecutionBankBody =>
      'Asegurá que tu primer flujo local de pagos funcione: cuenta, Pix, uso de tarjeta y cómo va a circular el dinero en el primer mes.';

  @override
  String get arrivalExecutionHousingTitle =>
      'Convertí la vivienda en rutina, no solo en entrada';

  @override
  String get arrivalExecutionHousingBody =>
      'Después de llegar, confirmá si la zona elegida realmente sostiene trabajo, transporte, seguridad y el ritmo de vida que necesitás.';

  @override
  String get arrivalExecutionGoalWorkTitle =>
      'Convertí la llegada en empleabilidad';

  @override
  String get arrivalExecutionGoalWorkBody =>
      'Usá el primer mes para probar cómo documentos, idioma y ciudad afectan de verdad tu chance de conseguir trabajo.';

  @override
  String get arrivalExecutionGoalRemoteTitle =>
      'Convertí la llegada en una base remota estable';

  @override
  String get arrivalExecutionGoalRemoteBody =>
      'Validá calidad de internet, rutina silenciosa, flujo bancario y costo real de sostener trabajo remoto desde la nueva ciudad.';

  @override
  String get arrivalExecutionGoalStudyTitle =>
      'Convertí la llegada en rutina de estudio';

  @override
  String get arrivalExecutionGoalStudyBody =>
      'Usá el primer mes para confirmar si matrícula, traslado, clases y costo diario siguen sosteniendo el estudio como base del plan.';

  @override
  String get arrivalExecutionGoalEntrepreneurTitle =>
      'Convertí la llegada en capacidad de operar';

  @override
  String get arrivalExecutionGoalEntrepreneurBody =>
      'Usá el primer mes para validar si banco, documentos, rutina local y contexto de ciudad realmente sostienen operar con seguridad.';

  @override
  String get arrivalExecutionGoalRetireTitle =>
      'Convertí la llegada en una rutina previsible';

  @override
  String get arrivalExecutionGoalRetireBody =>
      'Usá el primer mes para probar si el acceso a la salud, la rutina de barrio y los costos recurrentes se sienten sostenibles en la práctica.';

  @override
  String get arrivalExecutionGoalQualityTitle =>
      'Convertí la llegada en calidad de vida real';

  @override
  String get arrivalExecutionGoalQualityBody =>
      'Usá el primer mes para verificar si la ciudad se siente bien en la vida diaria, y no solo en el papel o en rankings.';

  @override
  String get arrivalExecutionRealityCheckTitle =>
      'Hacé un reality check a los 90 días';

  @override
  String get arrivalExecutionRealityCheckBody =>
      'Compará costo real, fricción de la rutina y encaje de la ciudad con lo que sugería el plan. Ahí la mudanza deja de ser hipotética.';

  @override
  String get arrivalExecutionDocumentsTitle =>
      'Cerrá las puntas documentales abiertas';

  @override
  String get arrivalExecutionDocumentsBody =>
      'Hasta los primeros 90 días, reducÍ pendientes de residencia, comprobaciones, banco y registros locales que todavía bloquean estabilidad.';

  @override
  String get arrivalExecutionReplanTitle =>
      'Replaneá antes de que la inercia mande';

  @override
  String get arrivalExecutionReplanBody =>
      'Si ciudad, costo o ritmo no están encajando con el plan original, ajustá la ruta antes de que la fricción temporal se vuelva tu normal.';

  @override
  String arrivalExecutionReplanBodyWithCity(String city) {
    return 'Si $city no está encajando con el plan original en la práctica, ajustá la ruta antes de que la fricción temporal se vuelva tu normal.';
  }

  @override
  String get publicHomeResumePlanAction => 'Continuar mi plan';

  @override
  String get publicHomeResumePlanTitle => 'Retomá desde donde lo dejaste';

  @override
  String get publicHomeResumePlanBody =>
      'Tu último plan de mudanza sigue acá. Reabrilo para continuar el checklist, la preparación documental y la reserva de aterrizaje.';

  @override
  String publicHomeResumePlanBodyWithCity(String city, String state) {
    return 'Tu último plan sigue acá, con $city ($state) como ciudad de referencia actual. Reabrilo para continuar el checklist, la preparación documental y la reserva de aterrizaje.';
  }

  @override
  String get publicHomeRetakePlanAction => 'Rehacer plan';

  @override
  String get migrationPlanCopilotTitle => 'Guía de la mudanza';

  @override
  String get migrationPlanCopilotAction => 'Abrir guía';

  @override
  String get migrationPlanCopilotGuideEyebrow => 'Guía rápida';

  @override
  String get migrationPlanCopilotGuideTitle =>
      'Cómo usar la guía de la mudanza';

  @override
  String get migrationPlanCopilotGuideBody =>
      'Esta área transforma la ciudad elegida en preparación práctica. Abrí la etapa correcta, resolvé lo prioritario y volvé al resumen sin perder el orden del plan.';

  @override
  String get migrationPlanCopilotGuideStepOneTitle => 'Empezá por el resumen';

  @override
  String get migrationPlanCopilotGuideStepOneBody =>
      'La vista general muestra la etapa más importante ahora y te ayuda a no dispersar energía.';

  @override
  String get migrationPlanCopilotGuideStepTwoTitle =>
      'Entrá en la etapa prioritaria';

  @override
  String get migrationPlanCopilotGuideStepTwoBody =>
      'Documentos, vivienda, trabajo y llegada quedan separados para que resuelvas un bloque por vez.';

  @override
  String get migrationPlanCopilotGuideStepThreeTitle =>
      'Usá los atajos prácticos';

  @override
  String get migrationPlanCopilotGuideStepThreeBody =>
      'Abrí links, fuentes y bloques guiados dentro de la app para pasar del plan a la ejecución.';

  @override
  String get migrationPlanCopilotGuideHideNextTime => 'No mostrar nuevamente';

  @override
  String get migrationPlanCopilotGuideStepsLabel => '3 pasos';

  @override
  String get migrationPlanCopilotGuideDismissAction => 'Ahora no';

  @override
  String get migrationPlanCopilotGuidePrimaryAction => 'Entendido';

  @override
  String get migrationPlanCopilotIntroTitle =>
      'Cuando quieras pasar de la decisión a la ejecución';

  @override
  String get migrationPlanCopilotIntroBody =>
      'Esta etapa organiza checklist, documentos, vivienda y reserva de aterrizaje. Usala cuando ya quieras empezar a preparar la mudanza.';

  @override
  String migrationPlanCopilotIntroBodyWithCity(String city, String state) {
    return 'Esta etapa organiza checklist, documentos, vivienda y reserva de aterrizaje con $city ($state) como referencia principal de tu plan.';
  }

  @override
  String get migrationPlanCopilotResultBody =>
      'Primero mirá si la ciudad recomendada realmente encaja con tu contexto. Cuando quieras convertir esa decisión en preparación concreta, abrí la capa guiada con checklist, documentos y reserva de llegada.';

  @override
  String migrationPlanCopilotStepCounter(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String get migrationPlanCopilotStepStartTitle =>
      'Empezá por lo que destraba la mudanza';

  @override
  String get migrationPlanCopilotStepStartBody =>
      'Primero enfocáte en los chequeos que bajan riesgo antes de gastar energía en el resto.';

  @override
  String get migrationPlanCopilotStepDocumentsTitle =>
      'Ordená los documentos clave';

  @override
  String get migrationPlanCopilotStepDocumentsBody =>
      'Usá esta etapa para ordenar la capa documental que suele frenar el avance después.';

  @override
  String get migrationPlanCopilotStepBudgetTitle =>
      'Planificá reserva y entrada de vivienda';

  @override
  String get migrationPlanCopilotStepBudgetBody =>
      'Estimá tu reserva inicial y revisá la fricción de vivienda antes de que la llegada se vuelva urgente.';

  @override
  String get migrationPlanCopilotStepArrivalTitle =>
      'Prepará los primeros 7 / 30 / 90 días';

  @override
  String get migrationPlanCopilotStepArrivalBody =>
      'Convertí el plan en ejecución para que la llegada no dependa de improvisación.';

  @override
  String get migrationPlanCopilotHomeTitle => 'Qué hacer ahora';

  @override
  String get migrationPlanCopilotHomeBody =>
      'Usá esta home para ver los próximos pasos, el riesgo principal y la etapa que merece atención primero.';

  @override
  String migrationPlanCopilotStageCountLabel(Object count) {
    return '$count etapas guiadas';
  }

  @override
  String get migrationPlanCopilotNextActionsTitle => 'Tus próximos 3 pasos';

  @override
  String get migrationPlanCopilotNextActionsBody =>
      'Empezá por las tareas que destraban la mudanza antes de profundizar el resto.';

  @override
  String get migrationPlanCopilotNextActionStart =>
      'Reducí los primeros bloqueos';

  @override
  String get migrationPlanCopilotNextActionDocuments =>
      'Poné los documentos en movimiento';

  @override
  String get migrationPlanCopilotNextActionBudget =>
      'Revisá reserva y entrada de vivienda';

  @override
  String get migrationPlanCopilotNextActionBudgetBody =>
      'Estimá tu reserva inicial y entendé cómo la entrada de vivienda puede pesar en la llegada.';

  @override
  String get migrationPlanCopilotFallbackActionBody =>
      'Abrí esta etapa para ver la primera acción recomendada.';

  @override
  String get migrationPlanCopilotRiskTitle => 'Riesgo principal ahora';

  @override
  String get migrationPlanCopilotRiskDocuments =>
      'La capa documental sigue siendo el mayor riesgo. Si queda suelta, las etapas siguientes pueden trabarse aunque ciudad y presupuesto ya estén decididos.';

  @override
  String get migrationPlanCopilotRiskReadiness =>
      'La mudanza todavía necesita una base inicial más fuerte. Resolvé primero los bloqueos prácticos antes de gastar más energía en detalles.';

  @override
  String get migrationPlanCopilotRiskHousing =>
      'La entrada a vivienda todavía puede generar fricción en la llegada. Revisá reserva, garantías y plan de fallback antes de tratar la mudanza como algo operativo.';

  @override
  String get migrationPlanCopilotStagesTitle => 'Abrí una etapa guiada';

  @override
  String get migrationPlanCopilotStagesBody =>
      'Podés entrar directo en la etapa que necesitás, pero Movaro mantiene el orden claro para que la mudanza no pierda prioridad.';

  @override
  String get migrationPlanCopilotRecommendedTitle =>
      'Siguiente paso recomendado';

  @override
  String get migrationPlanCopilotRecommendedReadinessBody =>
      'Empezá por esta etapa para destrabar los primeros bloqueos y darle una base real al resto del plan.';

  @override
  String get migrationPlanCopilotRecommendedDocumentsBody =>
      'La capa documental todavía merece atención primero. Resolvela ahora para evitar trabas más caras después.';

  @override
  String get migrationPlanCopilotRecommendedBudgetBody =>
      'Ahora conviene convertir el plan en números reales y revisar la entrada a vivienda antes de que la llegada se vuelva ajustada.';

  @override
  String get migrationPlanCopilotRecommendedArrivalBody =>
      'Ya tenés base suficiente para organizar la llegada. Usá esta etapa para pasar del plan a la ejecución.';

  @override
  String get migrationPlanCopilotRecommendedOpen => 'Abrir etapa recomendada';

  @override
  String get migrationPlanCopilotQuickQuestionsTitle => 'Dudas rápidas';

  @override
  String get migrationPlanCopilotQuickQuestionsBody =>
      'Usá estas respuestas cortas cuando aparezca una duda práctica antes de avanzar.';

  @override
  String get migrationPlanCopilotQuickQuestionDocumentsTitle =>
      '¿Qué documentos debería mover primero?';

  @override
  String get migrationPlanCopilotQuickQuestionDocumentsAnswer =>
      'Empezá por los documentos que tardan más en salir o vencen antes. La etapa documental de Movaro te ayuda a separar lo que destraba residencia, CPF y llegada práctica sin empujarte de golpe a un flujo burocrático completo.';

  @override
  String get migrationPlanCopilotQuickQuestionHousingTitle =>
      '¿Tengo que resolver vivienda definitiva ahora?';

  @override
  String get migrationPlanCopilotQuickQuestionHousingAnswer =>
      'No siempre. En muchos casos conviene entrar con un plan de vivienda temporal, entender garantías y recién después asumir un alquiler mayor. Lo importante ahora es estimar reserva, costo de entrada y plan de fallback.';

  @override
  String get migrationPlanCopilotQuickQuestionArrivalTitle =>
      '¿Qué tengo que resolver apenas llego?';

  @override
  String get migrationPlanCopilotQuickQuestionArrivalAnswer =>
      'Pensá primero en lo que baja fricción en los primeros días: dónde quedarte, cómo moverte, qué se resuelve en los primeros 7 días y qué tareas no pueden pasar del primer mes. La etapa de llegada ya organiza eso por prioridad.';

  @override
  String get migrationPlanCopilotQuickQuestionOpenStage => 'Ir a esta etapa';

  @override
  String get migrationPlanCopilotActionOpen => 'Resolver ahora';

  @override
  String get migrationPlanCopilotOverviewAction => 'Empezar preparación guiada';

  @override
  String get migrationPlanCopilotOverviewBackAction => 'Volver al resumen';

  @override
  String get migrationPlanCopilotFinishAction => 'Cerrar por ahora';

  @override
  String get migrationPlanDecisionLabel => 'Elección de ciudad';

  @override
  String migrationPlanDecisionTitle(Object goal) {
    return 'Ahora compará las ciudades que mejor combinan con $goal';
  }

  @override
  String migrationPlanDecisionBody(Object timeline) {
    return 'Según tu plazo de $timeline, estas opciones aparecen primero porque se acercan más al perfil que marcaste.';
  }

  @override
  String get migrationPlanDecisionSummaryTitle => 'Cómo usar esta etapa';

  @override
  String get migrationPlanDecisionSummaryBody =>
      'Primero elegí la ciudad que más sentido tenga para vos. El checklist detallado entra solo después de esa decisión.';

  @override
  String migrationPlanHeroTitle(Object city) {
    return '$city es tu mejor punto de partida por ahora';
  }

  @override
  String migrationPlanHeroBody(Object timeline) {
    return 'Según tu plazo de $timeline, empezá revisando las 3 ciudades de abajo y abrí la que más fuerza tenga para tu mudanza.';
  }

  @override
  String get migrationPlanConfidenceLow => 'Recomendación inicial';

  @override
  String get migrationPlanConfidenceHigh => 'Recomendación fuerte';

  @override
  String migrationPlanSummaryArchetype(Object value) {
    return 'Perfil detectado: $value';
  }

  @override
  String migrationPlanSummaryVariant(Object value) {
    return 'Modo usado: $value';
  }

  @override
  String migrationPlanSummaryFunding(Object value) {
    return 'Sostén inicial: $value';
  }

  @override
  String get migrationPlanCandidateCitiesTitle =>
      'Ciudades más alineadas con tu perfil';

  @override
  String get migrationPlanCandidateCitiesBody =>
      'La lista ya viene ordenada para dejar primero lo que tiende a hacer más sentido para argentinos con este objetivo.';

  @override
  String get migrationPlanShortlistTitle => '3 ciudades para revisar ahora';

  @override
  String get migrationPlanShortlistBody =>
      'Estas son las 3 opciones más fuertes para empezar. Abrí una ciudad para compararla con tu contexto real.';

  @override
  String get migrationPlanCandidateCitiesSheetBody =>
      'Abrí los detalles para entender mejor cada ciudad. La confirmación de la ciudad ocurre dentro de la pantalla de detalle, después de ver más contexto.';

  @override
  String get migrationPlanSelectedCityBadge => 'Elegida';

  @override
  String get migrationPlanSuggestedCityBadge => 'Va adelante por ahora';

  @override
  String get migrationPlanChooseCityAction => 'Elegir esta ciudad';

  @override
  String get migrationPlanSelectedCityAction => 'Ciudad elegida';

  @override
  String get migrationPlanInspectCityAction => 'Abrir detalles';

  @override
  String get migrationPlanOpenCitiesAction => 'Ver ciudades sugeridas';

  @override
  String get migrationPlanCompareOtherCitiesAction => 'Comparar otras ciudades';

  @override
  String migrationPlanSuggestedCityTitle(Object city) {
    return '$city va al frente por ahora';
  }

  @override
  String migrationPlanSuggestedCityBody(Object city, Object housing) {
    return '$city aparece adelante para el perfil que marcaste, con una lectura de entrada en vivienda en $housing. Antes de decidir, abrí los detalles y comparala con las otras opciones.';
  }

  @override
  String migrationPlanConfirmedCityTitle(Object city) {
    return '$city fue la ciudad que elegiste';
  }

  @override
  String migrationPlanSelectedCityTitle(Object city) {
    return '$city va al frente por ahora';
  }

  @override
  String migrationPlanSelectedCityBody(Object city, Object housing) {
    return '$city aparece fuerte para tu contexto actual, con una lectura de entrada en vivienda en $housing. Si esta ciudad te cierra, ahí sí vale abrir la preparación guiada.';
  }

  @override
  String get migrationPlanPreparationTitle => 'Cuándo pasar a la preparación';

  @override
  String migrationPlanPreparationBody(Object city) {
    return 'Si decidís avanzar con $city, la preparación guiada abre checklist, documentos, vivienda y reserva de llegada enfocados en esa ciudad.';
  }

  @override
  String get migrationPlanResultPrimaryCtaEyebrow => 'Siguiente paso';

  @override
  String get migrationPlanResultStartPlanTitle => 'Empezar mi plan';

  @override
  String migrationPlanResultStartPlanBody(Object city) {
    return 'Revisá $city con un poco más de contexto y confirmala cuando estés listo para desbloquear el plan guiado completo.';
  }

  @override
  String get migrationPlanResultStartPlanAction => 'Empezar mi plan';

  @override
  String get migrationPlanResultOpenPlanTitle => 'Ver plan completo';

  @override
  String get migrationPlanResultOpenPlanAction => 'Ver plan completo';

  @override
  String get migrationPlanResultCompatibilityHigh => 'Alta compatibilidad';

  @override
  String get migrationPlanResultCompatibilityMedium => 'Buena compatibilidad';

  @override
  String get migrationPlanResultCompatibilityInitial =>
      'Compatibilidad inicial';

  @override
  String get migrationPlanResultCompatibilityHelpTitle =>
      'Cómo funciona la compatibilidad';

  @override
  String get migrationPlanResultCompatibilityHelpBody =>
      'La compatibilidad combina tus prioridades, tu plazo y tu objetivo de mudanza con las señales disponibles de cada ciudad. Es una lectura orientativa para empezar por la ciudad más fuerte para vos.';

  @override
  String get migrationPlanResultUnavailableTitle =>
      'No pudimos cargar el resultado de tu ciudad.';

  @override
  String get migrationPlanResultUnavailableBody =>
      'Intentá de nuevo para abrir tu recomendación y seguir desde el cuestionario.';

  @override
  String get migrationPlanResultBasedOnAnswersTitle =>
      'Basado en tus respuestas';

  @override
  String get migrationPlanResultCityDataTitle => 'Datos de la ciudad';

  @override
  String get migrationPlanResultOtherCitiesTitle =>
      'Otras ciudades compatibles';

  @override
  String get migrationPlanResultReviewsMetricTitle => 'Reseñas públicas';

  @override
  String get migrationPlanResultSafetyMetricTitle => 'Seguridad';

  @override
  String migrationPlanResultPrimaryAction(Object city) {
    return 'Iniciar mi plan en $city ->';
  }

  @override
  String get migrationPlanResultExploreDetailsAction =>
      'Explorar la ciudad en detalle';

  @override
  String migrationPlanResultReasonFromPriority(Object label) {
    return 'Elegiste: $label';
  }

  @override
  String migrationPlanResultReasonBudget(Object city) {
    return '$city mantiene el costo de entrada más controlado, lo que ayuda a llegar con menos presión.';
  }

  @override
  String migrationPlanResultReasonWork(Object city, Object signal) {
    return '$city muestra una señal laboral $signal, lo que te da más margen para moverte después de llegar.';
  }

  @override
  String migrationPlanResultReasonQuality(Object city, Object signal) {
    return '$city se destaca con una señal de calidad de vida $signal, lo que sostiene una rutina más estable en el día a día.';
  }

  @override
  String migrationPlanResultReasonClimate(Object city, Object signal) {
    return '$city encaja bien con el estilo de vida que marcaste, con $signal.';
  }

  @override
  String migrationPlanResultReasonTransit(Object city) {
    return '$city ofrece una base más práctica si necesitás moverte seguido por la ciudad.';
  }

  @override
  String migrationPlanResultReasonUniversity(Object city) {
    return '$city mantiene más cerca las rutas de estudio y formación si la educación forma parte de tu plan.';
  }

  @override
  String migrationPlanResultReasonCommunity(Object city) {
    return '$city tiene señales más fuertes de adaptación para construir rutina y apoyo cuando llegues.';
  }

  @override
  String migrationPlanResultReasonProximity(Object city) {
    return '$city te deja en una ruta que suele ser más fácil de coordinar desde Argentina.';
  }

  @override
  String migrationPlanResultReasonBalanced(Object city) {
    return '$city es la recomendación más equilibrada para tu perfil actual dentro de las señales de ciudad disponibles.';
  }

  @override
  String get migrationPlanResultWeatherPending => 'Clima actualizándose';

  @override
  String get migrationPlanResultWeatherDay => 'Día';

  @override
  String get migrationPlanResultWeatherNight => 'Noche';

  @override
  String get migrationPlanResultWeatherSunny => 'tiempo soleado ahora';

  @override
  String get migrationPlanResultWeatherCloudy => 'condiciones más nubladas';

  @override
  String get migrationPlanResultWeatherRain => 'lluvia en la zona';

  @override
  String get migrationPlanResultWeatherCold => 'temperatura más fresca';

  @override
  String get migrationPlanResultWeatherStorm => 'clima más inestable';

  @override
  String get migrationPlanResultWeatherMild => 'clima templado';

  @override
  String get migrationPlanResultWeatherClearNight => 'noche despejada';

  @override
  String get migrationPlanResultCostLabel => 'Costo estimado';

  @override
  String get migrationPlanResultWeatherLabel => 'Clima ahora';

  @override
  String get migrationPlanResultWhyLabel => 'Por qué esta ciudad';

  @override
  String migrationPlanResultReviewsLabel(Object count) {
    return '$count reseñas';
  }

  @override
  String get migrationPlanResultCostSupporting =>
      'Una lectura orientativa basada en señales de costo y alquiler de la ciudad.';

  @override
  String get migrationPlanResultCostLower => 'Más bajo';

  @override
  String get migrationPlanResultCostMedium => 'Medio';

  @override
  String get migrationPlanResultCostHigher => 'Más alto';

  @override
  String get migrationPlanResultDifficultyLabel => 'Nivel de dificultad';

  @override
  String get migrationPlanResultDifficultySupporting =>
      'Cuánta coordinación puede exigir este plan antes de llegar.';

  @override
  String get migrationPlanResultDifficultyFocused => 'Enfocado';

  @override
  String get migrationPlanResultDifficultyModerate => 'Moderado';

  @override
  String get migrationPlanResultDifficultyStructured => 'Más estructurado';

  @override
  String get migrationPlanResultTimelineLabel => 'Tiempo estimado';

  @override
  String migrationPlanResultTimelineValue(Object days) {
    return '~$days días';
  }

  @override
  String get migrationPlanResultCitySectionTitle =>
      'Por qué esta ciudad va primera';

  @override
  String get migrationPlanResultCitySectionBody =>
      'Abrí el contexto de la ciudad cuando quieras más detalle, no antes de tener clara la decisión principal.';

  @override
  String get migrationPlanResultPlanSectionTitle =>
      'Qué pasa después de este resultado';

  @override
  String get migrationPlanResultPlanSectionBody =>
      'La preparación empieza a tener valor cuando la elección de ciudad ya se siente suficientemente firme.';

  @override
  String get migrationPlanCompareThreeCitiesAction => 'Comparar las 3 ciudades';

  @override
  String get migrationPlanResultProgressSupporting =>
      'Items del checklist completados dentro del plan guiado.';

  @override
  String migrationPlanCopilotProgressValue(Object done, Object total) {
    return '$done de $total items del checklist completados';
  }

  @override
  String migrationPlanCopilotProgressHeader(
    Object current,
    Object total,
    Object percent,
  ) {
    return 'Etapa $current de $total · $percent% completado';
  }

  @override
  String get migrationPlanCopilotStatusNotStarted => 'No iniciado';

  @override
  String get migrationPlanCopilotStatusInProgress => 'En progreso';

  @override
  String get migrationPlanCopilotStatusDone => 'Completado';

  @override
  String get migrationPlanCopilotToolsButton => 'Herramientas';

  @override
  String get migrationPlanCopilotCityRequiredHint =>
      'Disponible después de confirmar tu ciudad.';

  @override
  String get migrationPlanCopilotGoalRequiredHint =>
      'Disponible después de definir tu objetivo de migración.';

  @override
  String get migrationPlanCopilotToolsFlightsHint =>
      'Planificador de vuelos disponible en Herramientas.';

  @override
  String get migrationPlanHousingCompareTitle =>
      '¿Pensando en cambiar de ciudad?';

  @override
  String migrationPlanHousingCompareBody(Object cityName) {
    return 'Compará $cityName con otras opciones antes de decidir.';
  }

  @override
  String get migrationPlanHousingCompareAction => 'Comparar ciudades';

  @override
  String get migrationPlanScrollHint => 'Ver más';

  @override
  String get languageSelectorSystem => 'Sistema';

  @override
  String get bmpDisclaimer =>
      'Es para armar un punto de partida. No es asesoría legal.';

  @override
  String bmpProgressStep(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String get bmpCtaBack => 'Volver';

  @override
  String get bmpCtaContinue => 'Continuar';

  @override
  String get bmpCtaSkip => 'Omitir';

  @override
  String get bmpCtaGenerate => 'Generar mi plan';

  @override
  String get bmpExitDialogTitle => '¿Querés salir del plan?';

  @override
  String get bmpExitDialogBody =>
      'Si volvés al inicio, vas a perder este flujo y tus respuestas actuales.';

  @override
  String get bmpExitDialogStay => 'Seguir acá';

  @override
  String get bmpExitDialogLeave => 'Volver al inicio';

  @override
  String get bmpCtaRefineYes => 'Sí, afinar';

  @override
  String get bmpCtaRefineNo => 'No, generar mi plan';

  @override
  String get bmpVariantTitle => '¿Cómo querés armar tu plan?';

  @override
  String get bmpVariantSubtitle =>
      'Podés ir rápido o responder una pregunta extra para una recomendación más afinada.';

  @override
  String get bmpVariantLeanTitle => 'Plan rápido';

  @override
  String get bmpVariantLeanBody =>
      '4 preguntas concretas para llegar a una dirección inicial sin fricción.';

  @override
  String get bmpVariantLeanTag => 'Más rápido';

  @override
  String get bmpVariantStrategicTitle => 'Plan estratégico';

  @override
  String get bmpVariantStrategicBody =>
      'Suma una preferencia extra para darte una recomendación inicial más precisa.';

  @override
  String get bmpVariantStrategicTag => 'Más preciso';

  @override
  String get bmpGuideEyebrow => 'Armá tu plan';

  @override
  String get bmpGuideTitle => 'Cómo funciona este planificador';

  @override
  String get bmpGuideBody =>
      'Empezá por el modo que mejor encaje con el nivel de detalle que querés ahora. Las dos opciones llevan a una ciudad sugerida y a una primera secuencia de acciones, pero cambian en profundidad.';

  @override
  String get bmpGuideStepsLabel => 'Qué cambia entre los dos modos';

  @override
  String get bmpGuideStepQuickTitle => 'Plan rápido';

  @override
  String get bmpGuideStepQuickBody =>
      'Este es el camino más ágil. Respondés las preguntas centrales, recibís una dirección inicial y podés refinar después si el primer resultado todavía queda demasiado amplio.';

  @override
  String get bmpGuideStepStrategicTitle => 'Plan estratégico';

  @override
  String get bmpGuideStepStrategicBody =>
      'Acá se suma una capa extra sobre cómo pensás sostenerte después de la mudanza, así la recomendación se vuelve más precisa y más práctica.';

  @override
  String get bmpGuideStepUseTitle => 'Cómo usar el resultado';

  @override
  String get bmpGuideStepUseBody =>
      'Usá el plan como punto de partida, no como veredicto final. El mejor paso siguiente suele ser comparar la ciudad sugerida, confirmar documentos y ajustar el plan si cambia tu prioridad.';

  @override
  String get bmpGuideHideNextTime =>
      'No abrir esta explicación automáticamente otra vez';

  @override
  String get bmpGuideDismissAction => 'Cerrar';

  @override
  String get bmpGuidePrimaryAction => 'Empezar plan';

  @override
  String get bmpRefineTitle =>
      '¿Querés afinar la recomendación con 1 pregunta más?';

  @override
  String get bmpRefineSubtitle => '(Opcional) Tarda ~5 segundos';

  @override
  String get qIntentPrompt => '¿Qué buscás en Brasil ahora?';

  @override
  String get qFundingPrompt => '¿Cómo pensás sostenerte los primeros 3 meses?';

  @override
  String get qFundingSubtitle =>
      'Nos ayuda a ajustar el punto de partida sin pedir datos personales.';

  @override
  String get qTimelinePrompt => '¿Cuándo te gustaría estar en Brasil? (aprox.)';

  @override
  String get qPrioritiesPrompt =>
      'Para tu primer año, ¿qué 2 puntos pesan más al elegir ciudad?';

  @override
  String get qPrioritiesHelper => 'Elegí 2 para seguir';

  @override
  String qPrioritiesSelectedCount(Object selected, Object total) {
    return '$selected/$total';
  }

  @override
  String get qPrioritiesValidation => 'Elegí 2 opciones para seguir';

  @override
  String get qConstraintsPrompt => '¿Hay algo que NO querés negociar?';

  @override
  String get qConstraintsSubtitle => '(Opcional) Elegí hasta 2';

  @override
  String get bmpScrollHint => 'Ver más opciones';

  @override
  String get qConstraintsValidation => 'Podés elegir hasta 2 opciones';

  @override
  String get qConstraintsNone => 'No tengo condiciones fijas';

  @override
  String get questionOptionFindJobBr => 'Conseguir trabajo en Brasil';

  @override
  String get questionOptionRemoteIncome =>
      'Trabajar remoto (ya tengo ingresos)';

  @override
  String get questionOptionFundingSavings => 'Tengo ahorros para arrancar';

  @override
  String get questionOptionFundingJobSearch => 'Voy a buscar trabajo en Brasil';

  @override
  String get questionOptionFundingJobOffer => 'Ya tengo oferta o contrato';

  @override
  String get questionOptionFundingFamilySupport => 'Ayuda de familia o pareja';

  @override
  String get questionOptionFundingDontKnow => 'Todavía no lo sé';

  @override
  String get questionOptionFamilyPartner => 'Mudanza por pareja o familia';

  @override
  String get questionOptionFreshStart =>
      'Mejor calidad de vida / empezar de cero';

  @override
  String get questionOptionExploreUnsure => 'Solo quiero entender opciones';

  @override
  String get questionOptionJustExploring => 'Solo explorando';

  @override
  String get questionOptionIn03Months => 'En 0–3 meses';

  @override
  String get questionOptionIn36Months => 'En 3–6 meses';

  @override
  String get questionOptionIn612Months => 'En 6–12 meses';

  @override
  String get questionOptionIn12PlusMonths => 'En más de 12 meses';

  @override
  String get questionOptionDepends => 'Depende / estoy viendo';

  @override
  String get questionOptionLowCost => 'Costo de vida más bajo';

  @override
  String get questionOptionJobOpportunities => 'Más oportunidades de trabajo';

  @override
  String get questionOptionSafetyPriority => 'Seguridad / tranquilidad';

  @override
  String get questionOptionWarmClimateBeach => 'Clima más cálido / playa';

  @override
  String get questionOptionTransitInfra => 'Buena infraestructura y transporte';

  @override
  String get questionOptionNature => 'Naturaleza';

  @override
  String get questionOptionUniversity => 'Ambiente universitario';

  @override
  String get questionOptionCommunity => 'Comunidad / hacer amigos';

  @override
  String get questionOptionCloseToArgentina => 'Cerca de Argentina';

  @override
  String get questionOptionBalancedUnsure => 'Quiero un balance / no sé';

  @override
  String get questionOptionPreferSouth => 'Prefiero estar en el Sur';

  @override
  String get questionOptionNeedBigCity => 'Necesito ciudad grande';

  @override
  String get questionOptionPreferMidCity =>
      'Prefiero ciudad mediana o tranquila';

  @override
  String get questionOptionWantCoast => 'Quiero costa o playa';

  @override
  String get questionOptionPreferCooler => 'Prefiero clima más fresco';

  @override
  String get questionOptionNeedTransit => 'Necesito transporte fuerte';

  @override
  String get questionOptionAvoidExpensive => 'Quiero evitar ciudades caras';

  @override
  String get planReasonBudgetFit =>
      'Mejor encaje si querés cuidar el presupuesto.';

  @override
  String get planReasonJobMobility =>
      'Más opciones para buscar trabajo y moverte.';

  @override
  String get planReasonSafety => 'Encaja con tu prioridad de tranquilidad.';

  @override
  String get planReasonClimateNature =>
      'Buen punto de partida si buscás clima y aire libre.';

  @override
  String get planReasonTransit => 'Más práctico para moverte sin auto.';

  @override
  String get planReasonProximityArgentina =>
      'Más cerca para volver a Argentina cuando lo necesites.';

  @override
  String get planReasonUniversity => 'Más alineado si tu plan es estudiar.';

  @override
  String get planReasonCommunity => 'Más chances de armar red y comunidad.';

  @override
  String get planReasonBalancedProfile =>
      'Aparece como una opción equilibrada para empezar.';

  @override
  String get archetypeJobHunter => 'Búsqueda laboral';

  @override
  String get archetypeJobHunterWithOffer => 'Trabajo con oferta';

  @override
  String get archetypeJobHunterSearching => 'Búsqueda laboral activa';

  @override
  String get archetypeRemoteWorker => 'Trabajo remoto';

  @override
  String get archetypeRemoteStable => 'Trabajo remoto estable';

  @override
  String get archetypeStudent => 'Estudio';

  @override
  String get archetypeFamilyMove => 'Mudanza familiar';

  @override
  String get archetypeFreshStart => 'Nuevo comienzo';

  @override
  String get archetypeExplorer => 'Exploración';

  @override
  String get planStepTitleChooseBaseCity => 'Elegí tu ciudad base';

  @override
  String get planStepTitleResidencePath => 'Entendé la ruta de residencia';

  @override
  String get planStepTitleCpfStart => 'Empezá tu CPF';

  @override
  String get planStepDescriptionChooseBaseCityExplore =>
      'Elegí 1 ciudad para empezar y mirá barrios, costo de vida y movilidad básica. No es definitivo: es para arrancar con claridad.';

  @override
  String get planStepDescriptionChooseBaseCityBalanced =>
      'Definí una ciudad base y compará 2 barrios, alquiler y movilidad para pasar de la idea a un plan concreto.';

  @override
  String get planStepDescriptionChooseBaseCityUrgent =>
      'Definí ciudad base y fecha tentativa esta semana para ordenar las decisiones más urgentes.';

  @override
  String get planStepDescriptionChooseBaseCityOffer =>
      'Como ya tenés una oferta o contrato, elegí la ciudad base y validá barrio, tiempo de traslado y costo de entrada.';

  @override
  String get planStepDescriptionResidencePathExplore =>
      'Revisá la ruta de residencia más común para Argentina→Brasil y qué documentos base vas a necesitar después.';

  @override
  String get planStepDescriptionResidencePathBalanced =>
      'Entendé la ruta de residencia y empezá a juntar los documentos base antes de entrar en burocracia fina.';

  @override
  String get planStepDescriptionResidencePathUrgent =>
      'Revisá la ruta de residencia y separá ya los documentos base para no trabarte en la ejecución.';

  @override
  String get planStepDescriptionResidencePathFundingUnknown =>
      'Antes de avanzar, entendé la ruta de residencia y aclará cómo vas a sostenerte los primeros meses para evitar bloqueos.';

  @override
  String get planStepDescriptionCpfStart =>
      'El CPF te destraba muchas cosas en Brasil. Empezá con la guía oficial y seguí después en Movaro paso a paso.';

  @override
  String get migrationPlanPrepHeroTitle =>
      'Prepará la mudanza sin perderte en el proceso';

  @override
  String get migrationPlanPrepHeroBody =>
      'La idea acá no es marcar checklist. Primero entendé qué emitir, dónde abrir cada tema y qué guía resuelve tu próximo paso.';

  @override
  String get migrationPlanPrepHeroBodyCompact =>
      'Abrí la etapa correcta y prepará la mudanza sin perder el orden del plan.';

  @override
  String get migrationPlanPrepTabOverview => 'Resumen';

  @override
  String get migrationPlanPrepTabDocuments => 'Documentos';

  @override
  String get migrationPlanPrepTabHousing => 'Vivienda y costos';

  @override
  String get migrationPlanPrepTabWork => 'Trabajo y vida práctica';

  @override
  String get migrationPlanPrepTabArrival => 'Llegada';

  @override
  String get migrationPlanPrepOverviewTitle =>
      'Empezá por la parte que realmente destraba la mudanza';

  @override
  String get migrationPlanPrepOverviewBody =>
      'En vez de un checklist largo, esta área pasó a ser una guía práctica. Primero documentos, después vivienda, costos, trabajo y llegada.';

  @override
  String get migrationPlanPrepChooseCityTitle =>
      'Elegí una ciudad para destrabar la preparación';

  @override
  String get migrationPlanPrepChooseCityBody =>
      'La preparación sólo tiene sentido con una ciudad base confirmada. Primero elegí la ciudad que va a guiar vivienda, costos, trabajo y llegada.';

  @override
  String get migrationPlanPrepChooseCityAction => 'Elegir ciudad del plan';

  @override
  String get migrationPlanPrepQuestionDocsTitle =>
      '¿Cómo regularizo mis documentos?';

  @override
  String get migrationPlanPrepQuestionDocsBody =>
      'Abrí CPF, registro, banco y contratos de una forma más guiada, sin caer en un flujo burocrático suelto.';

  @override
  String get migrationPlanPrepQuestionRentTitle =>
      '¿Qué necesito para alquilar?';

  @override
  String get migrationPlanPrepQuestionRentBody =>
      'Mirá garantías, depósito, alquiler temporal y lo que suelen pedir para entrar a vivienda al principio.';

  @override
  String get migrationPlanPrepQuestionMoneyTitle =>
      '¿Cuánto dinero debería llevar?';

  @override
  String get migrationPlanPrepQuestionMoneyBody =>
      'Usá una mirada más conservadora de la llegada, con margen de seguridad y sin empujar números irreales.';

  @override
  String get migrationPlanPrepQuestionHealthTitle =>
      '¿La salud es pública o privada?';

  @override
  String get migrationPlanPrepQuestionHealthBody =>
      'Entendé cuándo conviene SUS, puesto de salud, hospital o plan privado sin mezclar todo.';

  @override
  String get migrationPlanPrepQuestionWorkTitle =>
      '¿Puedo trabajar y abrir cuenta?';

  @override
  String get migrationPlanPrepQuestionWorkBody =>
      'Abrí trabajo formal, ingresos, banco y contratos de forma práctica, con foco en lo que destraba la vida real.';

  @override
  String get migrationPlanPrepQuestionArrivalTitle =>
      '¿Qué resuelvo apenas llego?';

  @override
  String get migrationPlanPrepQuestionArrivalBody =>
      'Ordená los primeros días, la primera base de vivienda y la rutina inicial para no improvisar todo.';

  @override
  String get migrationPlanPrepQuestionFlightsTitle =>
      '¿Cómo consulto vuelos a esta ciudad?';

  @override
  String get migrationPlanPrepQuestionFlightsBody =>
      'Abrí una búsqueda externa de vuelos para comparar rutas hasta la ciudad elegida en Brasil.';

  @override
  String get migrationPlanPrepPrimaryEyebrow => 'Primer paso';

  @override
  String get migrationPlanPrepCardToneGuide => 'Guía rápida';

  @override
  String get migrationPlanPrepCardTonePractical => 'Resolver ahora';

  @override
  String get migrationPlanPrepCardTonePriority => 'Alta prioridad';

  @override
  String get migrationPlanPrepCardToneArrival => 'Primeros pasos';

  @override
  String get migrationPlanPrepOpenSection => 'Abrir esta área';

  @override
  String get migrationPlanPrepOpenOfficialSource => 'Abrir fuente oficial';

  @override
  String get migrationPlanPrepExternalToolHint =>
      'Usá este atajo como orientación rápida. El siguiente paso abre la fuente oficial dentro de la app para que sigas sin perder contexto.';

  @override
  String get migrationPlanPrepOpenGuide => 'Abrir guía completa';

  @override
  String get migrationPlanPrepBackToOverview => 'Volver al resumen';

  @override
  String get migrationPlanPrepDocumentsTitle => 'Documentos y residencia';

  @override
  String get migrationPlanPrepDocumentsBody =>
      'Mirá qué emitir primero, cómo funcionan CPF y registro en la práctica y dónde abrir la orientación correcta sin caer en una investigación dispersa.';

  @override
  String get migrationPlanPrepHousingTitle => 'Vivienda y costos';

  @override
  String get migrationPlanPrepHousingBody =>
      'Entendé reserva, entrada al alquiler, garantías y plan de vivienda temporal antes de que la llegada se vuelva ajustada.';

  @override
  String get migrationPlanPrepWorkTitle => 'Trabajo y vida práctica';

  @override
  String get migrationPlanPrepWorkBody =>
      'Abrí trabajo, salud y movilidad en bloques más directos para resolver la vida práctica sin exceso de lectura.';

  @override
  String get migrationPlanPrepArrivalTitle => 'Primeros días en Brasil';

  @override
  String get migrationPlanPrepArrivalBody =>
      'Ordená la llegada por horizonte corto: primera semana, primer mes y los 90 días que estabilizan la mudanza.';

  @override
  String get migrationPlanPrepDocumentsGuideTitle =>
      'Empezá por documentos, no por un checklist';

  @override
  String get migrationPlanPrepDocumentsGuideBody =>
      'Si la capa documental está confusa, el resto se traba. Por eso esta área te lleva directo a qué emitir, cómo funciona y dónde seguir.';

  @override
  String get migrationPlanPrepOpenDocumentsTopic => 'Abrir tema de documentos';

  @override
  String get migrationPlanPrepDocumentsCpfTitle =>
      'CPF y lo que realmente destraba';

  @override
  String get migrationPlanPrepDocumentsCpfBody =>
      'Abrí esta parte para entender cuándo el CPF ayuda, qué no resuelve por sí solo y cómo entra en banco, contratos y vida práctica.';

  @override
  String get migrationPlanPrepDocumentsResidenceTitle =>
      'Registro y residencia sin lenguaje burocrático';

  @override
  String get migrationPlanPrepDocumentsResidenceBody =>
      'Entendé cuál es la ruta de residencia más común, el papel del protocolo y cómo eso conversa con la llegada.';

  @override
  String get migrationPlanPrepDocumentsBankTitle =>
      'Banco, registros y contratos';

  @override
  String get migrationPlanPrepDocumentsBankBody =>
      'Mirá qué suelen pedir para abrir cuenta, firmar alquiler y no trabar la vida práctica apenas empezás.';

  @override
  String get migrationPlanPrepTaxesTitle =>
      'Cómo funcionan impuestos y residencia fiscal';

  @override
  String get migrationPlanPrepTaxesBody =>
      'Abrí la guía oficial de la Receita para entender entrada a Brasil, residencia fiscal y cuándo esto empieza a importar.';

  @override
  String get migrationPlanPrepDeadlinesTitle => 'Qué plazos no podés perder';

  @override
  String get migrationPlanPrepDeadlinesBody =>
      'Abrí la ruta oficial de residencia para no descubrir demasiado tarde plazos de registro, emisión y etapas críticas.';

  @override
  String get migrationPlanPrepHousingGuideTitle =>
      'Convertí la mudanza en números reales';

  @override
  String get migrationPlanPrepHousingGuideBody =>
      'Acá revisás reserva, costo de entrada, garantías y soft landing con una lectura mucho más práctica que un bloque de checklist.';

  @override
  String get migrationPlanPrepWorkGuideTitle =>
      'Vida práctica después de elegir ciudad';

  @override
  String get migrationPlanPrepWorkGuideBody =>
      'Usá estos bloques para abrir rápido trabajo, salud y movilidad. Son los temas que más se vuelven duda después de decidir la ciudad.';

  @override
  String get migrationPlanPrepWorkSignalsTitle =>
      'Señales de trabajo de la ciudad';

  @override
  String get migrationPlanPrepWorkSignalsBody =>
      'Hoy Movaro muestra señales de mercado laboral, actividad económica y desempleo. El ingreso promedio todavía no está integrado al catálogo.';

  @override
  String get migrationPlanPrepMoneyPracticeTitle =>
      'Banco y dinero en la práctica';

  @override
  String get migrationPlanPrepMoneyPracticeBody =>
      'Abrí la guía pública del Banco Central para entender cuenta, Pix, pagos y organización financiera para migrantes.';

  @override
  String get migrationPlanPrepDiplomaTitle => 'Reconocer diploma y profesión';

  @override
  String get migrationPlanPrepDiplomaBody =>
      'Abrí la ruta oficial para revalidar diploma extranjero y entender cuándo la profesión puede exigir un paso extra en Brasil.';

  @override
  String get migrationPlanPrepWorkSignalJobs => 'Mercado laboral';

  @override
  String get migrationPlanPrepWorkSignalEconomic => 'Actividad económica';

  @override
  String get migrationPlanPrepWorkSignalUnemployment => 'Desempleo';

  @override
  String get migrationPlanPrepArrivalGuideTitle =>
      'Qué resolver primero cuando llegás';

  @override
  String get migrationPlanPrepArrivalGuideBody =>
      'En vez de marcar tareas sueltas, mirá la llegada como una secuencia corta: aterrizar, estabilizar y consolidar la nueva rutina.';

  @override
  String get migrationPlanPrepArrivalWeekTitle => 'Primera semana';

  @override
  String get migrationPlanPrepArrivalWeekBody =>
      'Enfocate en dónde quedarte, cómo moverte, qué comprar al principio y cómo evitar los primeros errores de vivienda.';

  @override
  String get migrationPlanPrepArrivalMonthTitle => 'Primer mes';

  @override
  String get migrationPlanPrepArrivalMonthBody =>
      'Ajustá documentos, rutina de barrio, cuenta, alquiler y los puntos que hacen que la llegada deje de ser improvisada.';

  @override
  String get migrationPlanPrepArrivalQuarterTitle => 'Primeros 90 días';

  @override
  String get migrationPlanPrepArrivalQuarterBody =>
      'Consolidá trabajo, organización financiera, rutina de salud y los próximos pasos para que la mudanza sea sostenible.';

  @override
  String get migrationPlanPrepSupportNetworkTitle =>
      'Dónde buscar red de apoyo';

  @override
  String get migrationPlanPrepSupportNetworkBody =>
      'Abrí redes públicas de apoyo a migrantes y refugiados para entender dónde buscar atención, orientación y acogida.';

  @override
  String get migrationPlanPrepArgentineNetworkTitle =>
      'Embajada y consulados de Argentina';

  @override
  String get migrationPlanPrepArgentineNetworkBody =>
      'Abrí la lista oficial de la embajada y los consulados de Argentina en Brasil para consultar trámites, contactos y orientación consular oficial.';

  @override
  String get migrationPlanPrepFamilyTitle => 'Cómo quedan familia e hijos';

  @override
  String get migrationPlanPrepFamilyBody =>
      'Abrí la guía pública sobre matrícula y derechos de niños y adolescentes migrantes en Brasil.';

  @override
  String get migrationPlanPrepRiskAlertsTitle =>
      'Estafas y riesgos para evitar';

  @override
  String get migrationPlanPrepRiskAlertsBody =>
      'Abrí alertas públicas sobre ofertas engañosas, falsas promesas y riesgos que suelen afectar a quienes se mudan de país.';

  @override
  String get migrationPlanPrepFlightsPlannerTitle =>
      'Planificá la búsqueda de vuelo';

  @override
  String migrationPlanPrepFlightsPlannerBody(Object city) {
    return 'Elegí la ciudad de salida en Argentina y la fecha en la que pensás mudarte para abrir la búsqueda lista hacia $city.';
  }

  @override
  String get migrationPlanPrepFlightsOriginLabel => 'Ciudad de salida';

  @override
  String get migrationPlanPrepFlightsDateLabel => 'Fecha estimada de mudanza';

  @override
  String get migrationPlanPrepFlightsDatePlaceholder => 'Elegí una fecha';

  @override
  String get migrationPlanPrepFlightsDisclaimer =>
      'Los valores finales cambian según la fecha, la anticipación y la disponibilidad. Usá esta búsqueda como punto de partida y compará antes de comprar.';

  @override
  String get migrationPlanPrepFlightsOpenGoogle =>
      'Consultar en Google Flights';

  @override
  String get migrationPlanPrepOfficialIncomeTitle =>
      'Ver ingreso e indicadores oficiales';

  @override
  String get migrationPlanPrepOfficialIncomeBody =>
      'Abrí la página oficial del IBGE de esta ciudad para consultar indicadores municipales, incluido el panorama usado como fuente confiable.';

  @override
  String get migrationPlanPrepOfficialJobsTitle =>
      'Buscar empleo en Emprega Brasil';

  @override
  String get migrationPlanPrepOfficialJobsBodyNoCity =>
      'Abrí el portal oficial de empleo del gobierno para buscar vacantes formales y usar tu región como base de la búsqueda.';

  @override
  String migrationPlanPrepOfficialJobsBodyWithCity(Object city, Object state) {
    return 'Abrí el portal oficial de empleo del gobierno para buscar vacantes formales y usar $city ($state) como referencia de la búsqueda.';
  }

  @override
  String get migrationPlanPrepOfficialStudyCatalogTitle =>
      'Ver universidades publicas oficiales';

  @override
  String get migrationPlanPrepOfficialStudyCatalogBodyNoCity =>
      'Abrí el catalogo oficial del MEC para buscar instituciones publicas de educacion superior y filtrar por estado o ciudad.';

  @override
  String migrationPlanPrepOfficialStudyCatalogBodyWithCity(
    Object city,
    Object state,
  ) {
    return 'Abrí el catalogo oficial del MEC para buscar instituciones publicas de educacion superior y filtrar por $city ($state) o por la region mas cercana.';
  }

  @override
  String get migrationPlanPrepOfficialStudyForeignersTitle =>
      'Entender ingreso de extranjeros';

  @override
  String get migrationPlanPrepOfficialStudyForeignersBody =>
      'Abrí la ruta oficial del PEC-G para entender como funciona el ingreso de extranjeros y que universidades participantes ya reciben ese proceso.';

  @override
  String get migrationPlanPrepRentalSearchTitle =>
      'Buscar alquiler en esta ciudad';

  @override
  String migrationPlanPrepRentalSearchBody(Object city, Object state) {
    return 'Abrí una búsqueda de alquiler ya filtrada para $city ($state) dentro de la app y compará opciones por zona.';
  }

  @override
  String get migrationPlanPrepRentalProviderLabel => 'Portal de alquiler';

  @override
  String get migrationPlanPrepRentalProviderZap => 'ZAP Imóveis';

  @override
  String get migrationPlanPrepRentalProviderVivaReal => 'Viva Real';

  @override
  String get migrationPlanPrepRentalProviderChaves => 'Chaves na Mão';

  @override
  String get migrationPlanPrepRentalSearchDisclaimer =>
      'La cobertura y los avisos pueden variar según la ciudad y la disponibilidad del momento. Revisá más de una fuente antes de decidir.';

  @override
  String get migrationPlanPrepRentalSearchOpen => 'Abrir búsqueda de alquiler';

  @override
  String get migrationPlanPrepScamsTitle => 'Cómo evitar estafas en alquiler';

  @override
  String get migrationPlanPrepScamsBody =>
      'Abrí una alerta pública sobre fraudes comunes en avisos y alquileres para no decidir sólo por precio o urgencia.';

  @override
  String get phase_before_travel => 'Antes de viajar';

  @override
  String get phase_first_days => 'Primeros días';

  @override
  String get phase_documentation => 'Documentación';

  @override
  String get phase_life_working => 'Vida funcionando';

  @override
  String get phase_integration => 'Integración';

  @override
  String get phase_desc_before_travel =>
      'Qué preparar en Argentina para llegar sin sorpresas';

  @override
  String get phase_desc_first_days =>
      'Llegaste a Brasil. Foco en establecerte y poder comunicarte.';

  @override
  String get phase_desc_documentation =>
      'Los documentos que desbloquean todo. Hacelos en este orden exacto.';

  @override
  String get phase_desc_life_working =>
      'Con CPF y residencia en proceso, ahora armás la estructura del día a día.';

  @override
  String get phase_desc_integration =>
      'Adaptar tu vida completa a Brasil y garantizar la permanencia a largo plazo.';

  @override
  String get item_next_action_tag => 'PRÓXIMA ACCIÓN';

  @override
  String get item_external_tag => 'ACCIÓN EXTERNA';

  @override
  String get item_tool_tag => 'USA UNA HERRAMIENTA';

  @override
  String get item_checklist_tag => 'PARA COMPLETAR';

  @override
  String deadline_badge(Object date) {
    return 'Solicitar antes del $date';
  }

  @override
  String get deadline_alert_title => 'El plazo se acerca';

  @override
  String deadline_alert_body(Object days) {
    return 'Tu residencia temporaria vence en $days días. Solicitá la permanente antes.';
  }

  @override
  String get guide_completed_title => '¡Plan completado!';

  @override
  String guide_completed_subtitle(Object city) {
    return 'Completaste todos los pasos de tu guía para $city.';
  }

  @override
  String get guide_no_plan_title => 'Elegí tu ciudad primero';

  @override
  String get guide_no_plan_subtitle =>
      'Confirmá la ciudad de tu plan para comenzar la guía';

  @override
  String get infoGuideEyebrow => 'Guía rápida';

  @override
  String get infoGuideTitle => 'Tu centro de información migratoria';

  @override
  String get infoGuideBody =>
      'Encontrá respuestas sobre documentos, vivienda, salud, trabajo y costos para tu país de destino — todo en un solo lugar.';

  @override
  String get infoGuideStepOneTitle => 'Navegá por categoría';

  @override
  String get infoGuideStepOneBody =>
      'Tocá una tarjeta de sección para ver guías detalladas con fuentes oficiales de cada tema.';

  @override
  String get infoGuideStepTwoTitle => 'Buscá cualquier tema';

  @override
  String get infoGuideStepTwoBody =>
      'Usá la barra de búsqueda para encontrar respuestas sobre CPF, visa, SUS o cualquier otro asunto.';

  @override
  String get infoGuideStepThreeTitle => 'Preguntale al asistente IA';

  @override
  String get infoGuideStepThreeBody =>
      'Tocá el botón azul en la esquina inferior derecha para chatear con nuestro asistente y obtener respuestas personalizadas.';

  @override
  String get aiChatTitle => 'Asistente Movaro';

  @override
  String get aiChatSubtitle => 'Resolvé tus dudas sobre migración';

  @override
  String get aiChatClearTooltip => 'Limpiar conversación';

  @override
  String get aiChatInputHint => 'Preguntá sobre migración...';

  @override
  String get aiChatWelcomeTitle => '¿Cómo puedo ayudarte?';

  @override
  String get aiChatWelcomeBody =>
      'Preguntá sobre documentación, vivienda, salud, trabajo y más';

  @override
  String get aiChatErrorRateLimit =>
      'Límite de solicitudes alcanzado. Esperá un momento.';

  @override
  String get aiChatErrorApiLimit =>
      'Límite de API alcanzado. Intentá de nuevo en unos minutos.';

  @override
  String get aiChatErrorGeneric =>
      'Error al procesar tu pregunta. Intentá de nuevo.';

  @override
  String get aiChatNotInitialized =>
      'Servicio no inicializado. Intentá de nuevo.';

  @override
  String get aiChatSuggestPassport =>
      '¿Necesito pasaporte para viajar a Brasil?';

  @override
  String get aiChatSuggestCpf => '¿Cómo obtener el CPF?';

  @override
  String get aiChatSuggestSus => '¿Cómo funciona el SUS?';

  @override
  String get aiChatSuggestWork => '¿Puedo trabajar con visa de turista?';

  @override
  String get aiChatSuggestCosts => '¿Cuánto cuesta mudarse?';

  @override
  String get aiChatSuggestLicense => '¿Cómo validar mi licencia de conducir?';
}
