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
  String get splashInitializingLabel => 'Inicializando experiencia';

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
      'Movaro usa esta elección para armar la experiencia correcta para vos. Hoy el beta está disponible para Argentina -> Brasil, pero la estructura ya está pensada para crecer a nivel global.';

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
      'Hoy solo el trayecto Argentina -> Brasil está disponible para uso completo. Los demás países ya aparecen para señalar la dirección global del producto.';

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
      'Movaro hoy está diseñado para quienes están evaluando una mudanza de Argentina a Brasil. En vez de mostrar todo de una sola vez, te ayuda a elegir el mejor primer paso.';

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
      'Primero definí si necesitás un plan guiado, comparar ciudades o solo una vista rápida de lo que resuelve el producto.';

  @override
  String get publicHomeTrustFastTitle => 'Entrada rápida';

  @override
  String get publicHomeTrustFastBody =>
      'Podés empezar sin un formulario largo ni un bloqueo inicial.';

  @override
  String get publicHomeTrustGuestTitle => 'Sin login ahora';

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
      'Mira sugerencias por costo, trabajo y popularidad entre argentinos.';

  @override
  String get publicHomeCitiesAction => 'Ver ciudades';

  @override
  String get publicHomePlanTitle => 'Crear mi plan';

  @override
  String get publicHomePlanBody =>
      'Responde pocas preguntas y recibe un punto de partida simple.';

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
      'Usá la señal de adaptación con el idioma para ver qué lugares se sienten más fáciles si todavía dependés del español.';

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
      'El plan guiado convierte esa duda en una lista corta en vez de una investigación interminable.';

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
      'La sección Explorar junta ciudades, documentación y otros caminos en un solo lugar.';

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
      'Entiende documentos, salud, licencia, trabajo y cuenta bancaria con lenguaje simple.';

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
  String get exploreChecklistTitle => 'Checklist migratorio';

  @override
  String get exploreChecklistDescription =>
      'Las personas visitantes pueden responder un flujo corto y generar un plan migratorio inicial antes de iniciar sesión.';

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
  String get exploreTrailDocsTitle => 'Entender burocracia práctica';

  @override
  String get exploreTrailDocsBody =>
      'Mirá alquiler, SUS, CPF, trabajo, conducir y costos iniciales en bloques más claros y con menos ruido.';

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
  String get documentationPageTitle => 'Documentación y vida práctica';

  @override
  String get documentationHeroEyebrow => 'Guía práctica';

  @override
  String get documentationHeroTitle =>
      'Lo que suele destrabar la vida práctica en Brasil';

  @override
  String get documentationHeroDescription =>
      'Sin texto infinito. Acá ves documentos, salud, movilidad y costos aproximados de lo que suele importar primero para quien va a vivir en Brasil.';

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
  String get documentationPathsTitle => 'Empieza por tu duda principal';

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
      'Usá estos bloques para encontrar más rápido alquiler, SUS, trabajo, conducir y costos sin leer toda la página de una sola vez.';

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
      'Entendé trabajo con registro, PJ y cómo eso se relaciona con la previsión.';

  @override
  String get documentationPathCostsTitle => 'Costos iniciales';

  @override
  String get documentationPathCostsBody =>
      'Leé costos aproximados en reales, pesos y dólares sin confundir referencia con precio final.';

  @override
  String get documentationOpenTopicAction => 'Abrir tema';

  @override
  String get documentationQuickAnswersTitle =>
      'Respuestas rápidas para las dudas más comunes';

  @override
  String get documentationQuickAnswersBody =>
      'Antes de abrir cada card, empieza por estas respuestas cortas. Si alguna ya responde tu duda, ahorras tiempo.';

  @override
  String get documentationAnswerWorkQuestion =>
      '¿Puedo trabajar solo con visa de visita?';

  @override
  String get documentationAnswerWorkAnswer =>
      'No. Para trabajo formal, necesitás una situación migratoria compatible y registro regular.';

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
      'En general, sí, por un período limitado, con documento válido y según la regla del acuerdo aplicable. Después conviene confirmar con el Detran del estado.';

  @override
  String get documentationAnswerBrazilianLicenseQuestion =>
      '¿Después puedo sacar la licencia brasileña?';

  @override
  String get documentationAnswerBrazilianLicenseAnswer =>
      'Sí, si estás regular en el país y cumplís los requisitos del Detran. El proceso y las tasas cambian por estado.';

  @override
  String get documentationAnswerWorkCardQuestion =>
      '¿Sigue existiendo el trabajo con registro y cómo funciona?';

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
  String get documentationAnswerInssQuestion =>
      '¿La previsión pública en Brasil es el INSS?';

  @override
  String get documentationAnswerInssAnswer =>
      'Sí. El INSS es la puerta central de la previsión pública para beneficios como jubilación, siempre que existan aportes y requisitos cumplidos.';

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
      'Lo importante es entender la función de cada camino. La salud pública no es un plan barato, y la salud privada no reemplaza por sí sola una buena lectura de cobertura.';

  @override
  String get documentationWorkSectionTitle =>
      'Cómo trabajo y previsión se conectan';

  @override
  String get documentationWorkSectionBody =>
      'Acá conviene separar el modelo de trabajo del modo de aportar. Trabajo con registro, trabajo por CNPJ y aporte al INSS no significan exactamente lo mismo.';

  @override
  String get documentationDrivingSectionTitle =>
      'Cómo pensar la licencia sin complicarlo';

  @override
  String get documentationDrivingSectionBody =>
      'El flujo más seguro es separar tres preguntas: puedo manejar ahora, qué tengo que validar en el estado y cuándo conviene iniciar la licencia brasileña.';

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
      'Cuando existe un valor nacional o una referencia oficial util, la app muestra la conversion aproximada para ayudarte en una primera lectura.';

  @override
  String documentationCostsUpdatedAt(String value) {
    return 'Tipo de cambio aproximado actualizado en $value';
  }

  @override
  String get documentationCostsUnavailable =>
      'No fue posible actualizar la cotización ahora. Los valores en reales siguen como referencia.';

  @override
  String get documentationCostsDisclaimer =>
      'Usá esto como orientación inicial. Los costos cambian por estado, convenio, edad, cobertura y reglas locales.';

  @override
  String get documentationCostFreeValue => 'Gratis';

  @override
  String get documentationCostVariableValue => 'Variable';

  @override
  String get documentationCostCpfTitle => 'Pedido oficial de CPF';

  @override
  String get documentationCostCpfSupporting =>
      'El tramite oficial es gratuito; la app lo trata como costo cero.';

  @override
  String get documentationCostSusCardTitle =>
      'Tarjeta del SUS y registro inicial';

  @override
  String get documentationCostSusCardSupporting =>
      'La emisión y el registro público no suelen exigir pago directo.';

  @override
  String get documentationCostPublicCareTitle => 'Atencion inicial en el SUS';

  @override
  String get documentationCostPublicCareSupporting =>
      'UBS y otras puertas públicas de entrada no funcionan como una consulta particular paga.';

  @override
  String get documentationCostDrivingTitle => 'Primera licencia';

  @override
  String get documentationCostDrivingValue => 'Ejemplo oficial';

  @override
  String get documentationCostDrivingSupporting =>
      'Referencia reciente del Detran-ES: R\\\$ 533,34. Tu estado y tu autoescuela pueden cobrar distinto.';

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
      'Una persona extranjera puede pedir CPF; en Brasil, el tramite puede hacerse online o en entidad conveniada.';

  @override
  String get documentationCpfBulletTwo =>
      'El servicio oficial informa un plazo estimado de hasta 30 días corridos.';

  @override
  String get documentationCpfBulletThree =>
      'El CPF no reemplaza el documento migratorio, pero suele destrabar gran parte de la vida práctica.';

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
      'Antes de que termine ese plazo, podés pedir conversión a residencia por tiempo indeterminado si cumplís los requisitos.';

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
      'Urgencias y emergencias siguen otra logica de acceso; no esperes tener todo resuelto en el registro antes de pedir ayuda.';

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
      'Usa UPA u hospital cuando el caso sea urgente, agudo o no pueda esperar una agenda basica.';

  @override
  String get documentationHealthFlowBulletThree =>
      'Meu SUS Digital y la secretaría local ayudan a ubicar unidades, exámenes e información de seguimiento.';

  @override
  String get documentationHealthPrivateTitle => 'Salud privada';

  @override
  String get documentationHealthPrivateSummary =>
      'Un plan privado puede acelerar la red y la conveniencia, pero entra como costo recurrente y exige comparar cobertura con cuidado.';

  @override
  String get documentationHealthPrivateBulletOne =>
      'El plan de salud privado es pago y está regulado por la ANS.';

  @override
  String get documentationHealthPrivateBulletTwo =>
      'Precio, red, alcance y carencias cambian según contrato, edad y operadora.';

  @override
  String get documentationHealthPrivateBulletThree =>
      'Antes de contratar, compara red, cobertura y reglas en el material oficial de la ANS, no solo el precio.';

  @override
  String get documentationWorkCltTitle => 'Trabajo con registro';

  @override
  String get documentationWorkCltSummary =>
      'En el trabajo formal, la relación laboral sigue la CLT y el registro aparece en la Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletOne =>
      'El trabajo con registro es la forma más reconocible de trabajo formal en Brasil.';

  @override
  String get documentationWorkCltBulletTwo =>
      'El historial laboral puede seguirse en la Carteira de Trabalho Digital.';

  @override
  String get documentationWorkCltBulletThree =>
      'En este modelo, la relación con el aporte previsional suele estar más integrada a la nómina salarial.';

  @override
  String get documentationWorkPjTitle => 'PJ, CNPJ y trabajo por cuenta';

  @override
  String get documentationWorkPjSummary =>
      'Trabajar como PJ o con CNPJ cambia la lógica del vínculo. Puede recordar al monotributo en la comparación cultural, pero no es la misma estructura jurídica.';

  @override
  String get documentationWorkPjBulletOne =>
      'PJ no es trabajo con registro; el vínculo es empresarial o autónomo, no laboral.';

  @override
  String get documentationWorkPjBulletTwo =>
      'Abrir CNPJ y aportar a la previsión son temas conectados, pero no automáticos en todos los casos.';

  @override
  String get documentationWorkPjBulletThree =>
      'Antes de aceptar este formato, conviene entender impuestos, contrato y cómo va a funcionar el aporte previsional.';

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
  String get documentationDrivingTitle => 'Primera licencia en Brasil';

  @override
  String get documentationDrivingSummary =>
      'Si vas a vivir en Brasil, la licencia brasileña depende del Detran del estado y de un proceso local con etapas obligatorias.';

  @override
  String get documentationDrivingBulletOne =>
      'El proceso suele incluir examen médico y psicológico, clases, examen teórico y examen práctico.';

  @override
  String get documentationDrivingBulletTwo =>
      'Una persona extranjera regularizada puede iniciar el proceso si cumple las exigencias de identificacion y residencia del estado.';

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
      'La posibilidad de manejar con licencia extranjera depende de validez, identificación y regla aplicable a tu caso.';

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
  String get startNewPlanAction => 'Iniciar nuevo plan';

  @override
  String get questionnairePageTitle => 'Tu plan inicial';

  @override
  String get questionnaireLoadingLabel => 'Preparando tus preguntas';

  @override
  String get questionnaireSupportText =>
      'Toma menos de un minuto. Una pregunta por vez.';

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
  String get migrationPlanPageTitle => 'Tu plan inicial';

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
  String get planNextActionsTitle => 'Lo que suele venir justo despues';

  @override
  String get planNextActionsBody =>
      'Si este resultado te ayudo, el siguiente paso suele ser confirmar documentos, comparar la ciudad sugerida con otras opciones o rehacer el plan con otra prioridad.';

  @override
  String get planNextActionDocumentsTitle =>
      'Confirmar documentos antes de avanzar';

  @override
  String get planNextActionDocumentsBody =>
      'Usá la guía práctica para revisar CPF, registro, permanencia, trabajo y banco sin caer en investigación dispersa.';

  @override
  String get planNextActionCitiesTitle =>
      'Comparar otras ciudades antes de decidir';

  @override
  String get planNextActionCitiesBody =>
      'Mira si la ciudad sugerida sigue teniendo sentido cuando la comparas por costo, idioma, seguridad y trabajo.';

  @override
  String get planNextActionRetakeTitle => 'Rehacer el plan con otra prioridad';

  @override
  String get planNextActionRetakeBody =>
      'Si tu prioridad cambio, conviene responder de nuevo y ver si tambien cambia el orden de los pasos.';

  @override
  String get readinessSectionTitle =>
      'Checklist practico para la siguiente fase';

  @override
  String get readinessStageNow => 'Empieza ahora';

  @override
  String get readinessStageSoon => 'Prepara despues';

  @override
  String get readinessStageLanding => 'Antes de llegar';

  @override
  String get readinessSummaryResearching =>
      'Como todavía estás explorando, el mejor paso ahora es reducir incertidumbre antes de abrir demasiados frentes.';

  @override
  String get readinessSummaryTwelveMonths =>
      'Todavía tienes tiempo para preparar bien la mudanza, así que usa este checklist para reducir fricción con anticipación.';

  @override
  String get readinessSummarySixMonths =>
      'Seis meses ya alcanzan para salir de la improvisación y estructurar documentos, dinero y ciudad.';

  @override
  String get readinessSummaryAsap =>
      'Como el plan está cerca, la prioridad ahora es ordenar lo esencial y evitar errores evitables.';

  @override
  String get readinessItemMigrationPathTitle =>
      'Confirma primero la ruta migratoria';

  @override
  String get readinessItemMigrationPathBody =>
      'Antes de banco, vivienda o trabajo, valida qué camino de residencia encaja mejor con tu entrada a Brasil.';

  @override
  String get readinessItemDocumentsTitle =>
      'Arma el paquete documental esencial';

  @override
  String get readinessItemDocumentsBody =>
      'Separa pasaporte, antecedentes, necesidad de apostilla y documentos que todavía pueden requerir traducción.';

  @override
  String get readinessItemBudgetTitle => 'Prueba el presupuesto de aterrizaje';

  @override
  String get readinessItemBudgetBody =>
      'Proyecta lo que van a exigir los primeros 30 a 90 días, no solo el costo mensual una vez instalada la rutina.';

  @override
  String get readinessItemCityTitle => 'Convierte la ciudad en un filtro real';

  @override
  String get readinessItemCityBody =>
      'Usa tu selección actual de ciudades para reducir incertidumbre de vivienda, transporte y rutina antes de bajar al nivel de barrio.';

  @override
  String readinessItemCityBodyWithCity(String city) {
    return 'Usa $city como primer filtro y compárala con alternativas antes de decidir a nivel barrio.';
  }

  @override
  String get readinessItemLanguageTitle => 'Prepara tu primera capa de idioma';

  @override
  String get readinessItemLanguageBody =>
      'Concéntrate en el portugués que reduce fricción en la vida diaria: vivienda, transporte, banco y servicios.';

  @override
  String get readinessItemLanguageWorkBody =>
      'Concéntrate en el portugués que afecta entrevistas, rutina laboral, negociación y pedidos básicos de servicio.';

  @override
  String get readinessItemLanguageStudyBody =>
      'Concéntrate en el portugués necesario para clases, inscripción, rutina diaria y comunicación institucional.';

  @override
  String get readinessGoalWorkTitle => 'Mapea empleabilidad antes de llegar';

  @override
  String get readinessGoalWorkBody =>
      'Revisa qué tipo de trabajo puedes buscar al inicio, qué documentos pueden frenarte y cómo la ciudad cambia tus posibilidades.';

  @override
  String get readinessGoalRemoteTitle =>
      'Estabiliza la base del trabajo remoto';

  @override
  String get readinessGoalRemoteBody =>
      'Chequea internet, flujo bancario, costo diario y la estructura local mínima antes de depender del ingreso remoto.';

  @override
  String get readinessGoalStudyTitle => 'Valida la ruta de estudio';

  @override
  String get readinessGoalStudyBody =>
      'Revisa admisión, costo de rutina, tiempos de estudiante y qué debe regularizarse antes de tomar el estudio como base.';

  @override
  String get readinessGoalEntrepreneurTitle =>
      'Planifica la entrada para emprender';

  @override
  String get readinessGoalEntrepreneurBody =>
      'Mapea la capa práctica inicial: documentos locales, banco, ciudad y estructura mínima para operar con más seguridad.';

  @override
  String get readinessGoalRetireTitle => 'Protege rutina y previsibilidad';

  @override
  String get readinessGoalRetireBody =>
      'Prioriza acceso a salud, rutina de barrio, costo recurrente y los documentos que protegen una llegada tranquila.';

  @override
  String get readinessGoalQualityTitle =>
      'Convierte calidad de vida en criterio';

  @override
  String get readinessGoalQualityBody =>
      'Transforma estilo de vida en filtros reales: seguridad, rutina, adaptación al idioma y costo de permanencia.';

  @override
  String get readinessItemCpfBankTitle =>
      'Prepara CPF y la primera base bancaria';

  @override
  String get readinessItemCpfBankBody =>
      'CPF y situación regular influyen en banco, contrato y buena parte de la estructura práctica de la llegada.';

  @override
  String get readinessItemHousingTitle =>
      'Reduce la fricción de vivienda antes de buscar';

  @override
  String get readinessItemHousingBody =>
      'Revisa garantía, reserva financiera, prioridad de barrio y comprobantes que pueden pedirte antes de hablar con propietarios.';

  @override
  String get readinessItemArrivalTitle => 'Arma un plan de llegada de 30 días';

  @override
  String get readinessItemArrivalBody =>
      'Lista lo que debe funcionar en el primer mes: conectividad, salud, transporte, pagos y seguimiento documental.';

  @override
  String readinessProgressLabel(int done, int total) {
    return '$done de $total items completados';
  }

  @override
  String planStepMeta(String category, int days) {
    return 'Category: $category  Estimated days: $days';
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
      'Si tu intencion ya es vivir en Brasil, conviene resolver esto antes de asumir alquiler o trabajo.';

  @override
  String get planStepOpenCpfEyebrow => 'Documento fiscal';

  @override
  String get planStepOpenCpfSummary =>
      'El CPF ayuda a destrabar banco, contrato, registro y gran parte de la vida práctica al comienzo.';

  @override
  String get planStepOpenCpfPointOne =>
      'El tramite puede empezar online, según la orientacion oficial.';

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
      'Empieza comparando cuenta digital para una rutina simple y banco tradicional si necesitas atencion fisica.';

  @override
  String get planStepOpenHousingEyebrow => 'Vivienda y barrios';

  @override
  String get planStepOpenHousingSummary =>
      'Antes de cerrar vivienda, conviene comparar barrios con mejor rutina, acceso y costo.';

  @override
  String planStepOpenHousingSummaryCity(String city) {
    return 'For $city, compare neighborhoods with better daily routine, access, and cost before closing a housing deal.';
  }

  @override
  String get planStepOpenHousingPointOne =>
      'Priorizá barrios con buena conexión a lo que necesitás: trabajo, transporte y servicios.';

  @override
  String get planStepOpenHousingPointTwo =>
      'Usa la lectura de costo de la ciudad como punto de partida, pero confirma alquiler y contrato antes de decidir.';

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
      'Resuelve primero lo esencial para no abrir demasiados frentes al mismo tiempo.';

  @override
  String get planStepOpenGeneralPointTwo =>
      'Cuando la etapa dependa de un documento oficial, confirmá el requisito más reciente antes de presentar nada.';

  @override
  String get planStepOpenGeneralPointThree =>
      'Usa el plan como orden sugerido, no como una regla fija para todos los casos.';

  @override
  String get planStepOpenTagMercosur => 'Mercosur';

  @override
  String get planStepOpenTagVisitor => 'Visita no autoriza trabajo';

  @override
  String get planStepOpenTagOnline => 'Tramite online';

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
      'Mira sugerencias por intencion y entiende por que cada ciudad aparece aqui.';

  @override
  String get citiesLoadingLabel => 'Cargando ciudades';

  @override
  String get citiesMethodologyNote =>
      'Rankings basados en datos publicos y metodología de Movaro.';

  @override
  String get citiesExplorePopularTitle => 'Más elegidas por argentinos';

  @override
  String get citiesExploreLanguageTitle =>
      'Más fáciles si todavía dependés del español';

  @override
  String get citiesExploreEconomicalTitle =>
      'Buenas opciones si priorizas costo';

  @override
  String get citiesExploreWorkTitle => 'Buenas opciones si buscas trabajo';

  @override
  String get citiesExploreHousingEasyTitle =>
      'Mejores para una llegada mas liviana';

  @override
  String get citiesExploreHousingPressureTitle => 'Piden mas caja al entrar';

  @override
  String get citiesExploreSoftLandingTitle =>
      'Buenas para llegar con menos friccion';

  @override
  String get citiesExploreFamilyStabilityTitle =>
      'Buenas para llegar con mas previsibilidad';

  @override
  String get citiesExploreIncomeStartTitle =>
      'Buenas para llegar buscando ingresos';

  @override
  String get citiesExploreCoastalTitle =>
      'Buenas para quien quiere vivir cerca de la playa';

  @override
  String get citiesExploreCoastalSoftLandingTitle =>
      'Playa con llegada mas liviana';

  @override
  String get citiesExploreCoastalBalancedTitle =>
      'Playa con mejor equilibrio de rutina';

  @override
  String get citiesHighlightPopularLabel =>
      'Entre las ciudades analizadas por Movaro';

  @override
  String get citiesHighlightLanguageLabel =>
      'Buena opción si la adaptación con el idioma importa para ti';

  @override
  String get citiesHighlightEconomicalLabel =>
      'Buena opción si priorizas costo';

  @override
  String get citiesHighlightWorkLabel =>
      'Buena opción si buscás más oportunidades de trabajo';

  @override
  String get citiesHighlightHousingEasyLabel => 'Buena para soft landing';

  @override
  String get citiesHighlightHousingPressureLabel => 'Presion de vivienda alta';

  @override
  String get citiesHighlightSoftLandingLabel =>
      'Buena para un aterrizaje inicial con menos friccion';

  @override
  String get citiesHighlightFamilyStabilityLabel =>
      'Buena para equilibrar seguridad, vivienda y rutina';

  @override
  String get citiesHighlightIncomeStartLabel =>
      'Buena si necesitas activar ingresos mas temprano';

  @override
  String get citiesHighlightCoastalLabel => 'Buena para rutina de litoral';

  @override
  String get citiesHighlightMetropolisLabel =>
      'Buena si queres un ritmo mas urbano';

  @override
  String get citiesHighlightInlandLabel =>
      'Buena si buscas una rutina mas tranquila';

  @override
  String get citiesHighlightBorderLabel =>
      'Buena si queres leer mejor una ciudad de frontera';

  @override
  String get citiesHighlightCoastalSoftLandingLabel =>
      'Playa con soft landing mejor';

  @override
  String get citiesHighlightCoastalBalancedLabel =>
      'Playa con mejor equilibrio entre rutina y costo';

  @override
  String get citiesExploreEmptyTitle => 'Seguimos ampliando este catalogo';

  @override
  String get citiesExploreEmptyDescription =>
      'Las sugerencias de ciudades van a aparecer aca a medida que la base de Movaro crezca.';

  @override
  String get citiesSearchTitle => 'Buscar ciudades';

  @override
  String get citiesSearchHeadline =>
      'Encuentra una ciudad en el catalogo inicial';

  @override
  String get citiesSearchDescription =>
      'Busca por nombre o recorre la lista actual de Movaro.';

  @override
  String get citiesSearchHint => 'Buscar ciudad';

  @override
  String get citiesSearchFieldLabel => 'Nombre de la ciudad';

  @override
  String get citiesQuickFilterAll => 'Vista general';

  @override
  String get citiesQuickFilterPopular => 'Mas populares';

  @override
  String get citiesQuickFilterLowCost => 'Mejor costo';

  @override
  String get citiesQuickFilterWork => 'Mas trabajo';

  @override
  String get citiesQuickFilterLanguage => 'Idioma mas facil';

  @override
  String get citiesQuickFilterHousingEasy => 'Llegada liviana';

  @override
  String get citiesQuickFilterHousingPressure => 'Mas caja';

  @override
  String get citiesQuickFilterSoftLanding => 'Menos friccion';

  @override
  String get citiesQuickFilterFamilyStability => 'Mas previsible';

  @override
  String get citiesQuickFilterIncomeStart => 'Ingresos rapidos';

  @override
  String get citiesQuickFilterCoastal => 'Playa';

  @override
  String get citiesSearchingLabel => 'Buscando ciudades';

  @override
  String get citiesCatalogLoadingLabel => 'Cargando catalogo';

  @override
  String get citiesSearchEmptyTitle => 'No encontramos esa ciudad';

  @override
  String get citiesSearchEmptyDescription =>
      'Prueba con otro nombre o explora el catalogo inicial de Movaro.';

  @override
  String get citiesCatalogEmptyTitle => 'El catalogo aun esta vacio';

  @override
  String get citiesCatalogEmptyDescription =>
      'Las ciudades del catalogo de Movaro apareceran aqui.';

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
      'Usa estos indicadores como punto de partida, no como verdad absoluta.';

  @override
  String get cityLifestyleCoastalLabel => 'Estilo de vida de litoral';

  @override
  String get cityLifestyleMetropolisLabel => 'Ritmo de metropoli';

  @override
  String get cityLifestyleBorderLabel => 'Ciudad de frontera';

  @override
  String get cityLifestyleInlandLabel => 'Rutina de interior';

  @override
  String get cityDetailMapTitle => 'Donde queda la ciudad';

  @override
  String get cityDetailMapDescription =>
      'Mira la ubicacion de la ciudad en el mapa antes de comparar contexto, distancia y region.';

  @override
  String get cityDetailSnapshotTitle => 'Vista rápida';

  @override
  String get cityDetailPopulationLabel => 'Poblacion';

  @override
  String get cityDetailCostLabel => 'Costo';

  @override
  String get cityDetailRentLabel => 'Alquiler';

  @override
  String get cityDetailSafetyLabel => 'Seguridad';

  @override
  String get cityDetailPopularityLabel => 'Popularidad entre argentinos';

  @override
  String get cityDetailLanguageLabel => 'Adaptacion con el idioma';

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
  String get cityDetailReasonsTitle => 'Por que Movaro la recomienda';

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
  String get citySourceTerritorialTitle => 'Identidad territorial';

  @override
  String get citySourceTerritorialDescription =>
      'Nombre oficial, provincia, código IBGE y región municipal.';

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
      'Actualmente proviene del dataset curado de Movaro. Las sustituciones oficiales prioritarias son Atlas da Violencia (seguridad), Novo Caged (empleo), FipeZAP (alquiler) e IBGE PIB dos Municipios (actividad económica).';

  @override
  String get citySourceRankingTitle => 'Metodología de puntaje';

  @override
  String get citySourceRankingDescription =>
      'Puntajes de Movaro calculados sobre datos públicos y el dataset curado.';

  @override
  String get cityDetailSaveAction => 'Guardar ciudad';

  @override
  String get cityDetailSavedAction => 'Ciudad guardada';

  @override
  String get cityDetailSavedFeedback =>
      'Ciudad guardada temporalmente en este dispositivo.';

  @override
  String get cityDetailCompareAction => 'Comparar otras ciudades';

  @override
  String get cityDetailPlanAction => 'Armar mi plan';

  @override
  String get cityDetailFooterNote =>
      'Estos indicadores ayudan en la exploracion inicial y no reemplazan un analisis individual.';

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
      'Consultá documentación cuando la necesites';

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
  String get introSkipAction => 'Saltar introducción';

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
      'Se ve más fácil que el promedio para alguien que llega hablando español, porque combina mejor adaptación con el idioma y familiaridad argentina.';

  @override
  String get cityPracticalLanguageMedium =>
      'Se ve manejable, pero igual conviene llegar con una base de portugués para la rutina.';

  @override
  String get cityPracticalLanguageHard =>
      'Probablemente te exija adaptarte más rápido al portugués, porque el soporte cotidiano en español parece menor.';

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
      'Conviene mirarla con más cuidado y validar mejor el contexto local antes de tomarla como opción simple.';

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
      'Más liviano para el presupuesto del dia a dia.';

  @override
  String get cityMetricCostMediumHeadline => 'Costo moderado';

  @override
  String get cityMetricCostMediumSupporting =>
      'Un equilibrio razonable entre rutina e infraestructura.';

  @override
  String get cityMetricCostHighHeadline => 'Costo alto';

  @override
  String get cityMetricCostHighSupporting =>
      'Va a exigir más cuidado con alquiler y gastos mensuales.';

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
      'Conviene validar mejor la ciudad antes de tomarla como mudanza simple.';

  @override
  String get cityMetricLanguageEasyHeadline => 'Adaptacion facil';

  @override
  String get cityMetricLanguageEasySupporting =>
      'Suele ser más amigable para quien llega hablando español.';

  @override
  String get cityMetricLanguageMediumHeadline => 'Adaptacion moderada';

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
      'Una lectura solida de desarrollo humano en la referencia oficial.';

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
  String get cityHousingViabilityEasyHeadline => 'Entrada mas liviana';

  @override
  String get cityHousingViabilityEasySupporting =>
      'Tiende a permitir un aterrizaje mas suave, con menos presion de alquiler y mas margen para ajustar barrio y rutina.';

  @override
  String get cityHousingViabilityEasyBadge => 'Buena para soft landing';

  @override
  String get cityHousingViabilityBalancedHeadline => 'Entrada equilibrada';

  @override
  String get cityHousingViabilityBalancedSupporting =>
      'Puede funcionar bien si llegas con reserva y validas barrio, garantia y costo total antes de firmar.';

  @override
  String get cityHousingViabilityBalancedBadge => 'Necesita validacion';

  @override
  String get cityHousingViabilityHardHeadline => 'Exige mas caja';

  @override
  String get cityHousingViabilityHardSupporting =>
      'Aca alquiler y entrada suelen pesar mas. Conviene tratar vivienda como filtro serio antes de elegir la ciudad.';

  @override
  String get cityHousingViabilityHardBadge => 'Presion de vivienda alta';

  @override
  String get citySnapshotPopularityHigh => 'Muy buscada';

  @override
  String get citySnapshotPopularityHighSupporting =>
      'Ya aparece con fuerte afinidad entre argentinos.';

  @override
  String get citySnapshotPopularityMedium => 'Popularidad moderada';

  @override
  String get citySnapshotPopularityMediumSupporting =>
      'Tiene una familiaridad razonable dentro del catalogo actual.';

  @override
  String get citySnapshotPopularityLow => 'Menos recurrente';

  @override
  String get citySnapshotPopularityLowSupporting =>
      'Todavía aparece menos en el recorte inicial de interes argentino.';

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
  String get protectedCommunityCreateTitle => 'Crear publicación';

  @override
  String get protectedCommunityCreateDescription =>
      'Este espacio va a permitir crear publicaciones cuando la comunidad esté habilitada.';

  @override
  String get questionOriginCountryTitle => '¿De dónde venís?';

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
  String get questionOptionBasicPortuguese => 'Me manejo con portugués basico';

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
      'Adaptacion más facil si todavía dependes del español';

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
      'Hace más sentido para quien busca más seguridad y un costo más controlado.';

  @override
  String get planReasonGoalQualityOfLife =>
      'Se ajusta mejor a una búsqueda de más calidad de vida y adaptación gradual.';

  @override
  String get planReasonGoalBeachLife =>
      'Tiene más sentido si querés priorizar litoral, playa y una rutina más conectada con el mar.';

  @override
  String get planReasonLanguageNeedsSupport =>
      'Como dijiste que todavía dependes del español, dimos más peso a ciudades con mejor adaptación linguistica.';

  @override
  String get planReasonLanguageBasic =>
      'Como dijiste que te manejas con portugués basico, la adaptación con el idioma todavía influye en la recomendacion.';

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
  String get planStepTitleSettleDocuments => 'Regularizar documentación local';

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
  String get planBeachDecisionTitle => 'Litoral en la decision';

  @override
  String get planBeachDecisionIntro =>
      'Si playa y litoral entran en tu criterio, no alcanza con mirar belleza o turismo. El filtro real pasa por vivienda, ritmo de la ciudad y aterrizaje inicial.';

  @override
  String get planBeachDecisionCoastalHeadline =>
      'La recomendacion ya apunta al litoral';

  @override
  String planBeachDecisionCoastalBody(Object cityName) {
    return '$cityName ya entra en el recorte de ciudad costera. El siguiente filtro es entender si la entrada de vivienda y la rutina local encajan con tu momento.';
  }

  @override
  String get planBeachDecisionNotCoastalHeadline =>
      'Tu criterio de playa pide una comparacion extra';

  @override
  String get planBeachDecisionNotCoastalBody =>
      'Incluso con este objetivo, conviene comparar ciudades de playa antes de cerrar la decision. No toda ciudad fuerte en el plan entrega la rutina costera que tal vez buscas.';

  @override
  String get planBeachDecisionPriorityNote =>
      'Si la playa es prioridad, trata vivienda y rutina local como filtro principal.';

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
  String get sourceProviderReceitaFederalGovBr => 'Receita Federal / Gov.br';

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
  String get sourceProviderBancoCentralBrasil => 'Banco Central de Brasil';

  @override
  String get sourceProviderMovaro => 'Movaro';

  @override
  String get documentReadinessSectionTitle =>
      'Preparacion documental antes de la mudanza';

  @override
  String get documentReadinessPriorityCritical => 'Critico ahora';

  @override
  String get documentReadinessPriorityPrepare => 'Prepara con anticipacion';

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
      'Tratà CPF y estatus regular como una sola capa';

  @override
  String get documentReadinessCpfBodyBrazil =>
      'CPF, seguimiento de residencia y primer comprobante local suelen destrabar la vida práctica. Dejá ese bloque listo para ejecutar rápido.';

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
      'Usá documentos para reducir fricción, no solo para cumplir';

  @override
  String get documentReadinessGoalQualityBodyBrazil =>
      'Incluso cuando la prioridad es calidad de vida, la mudanza más suave es la que llega a Brasil con identidad, comprobaciones y carpeta de llegada ya ordenadas.';

  @override
  String get documentReadinessGoalQualityBodyGeneric =>
      'Incluso cuando la prioridad es calidad de vida, la mudanza más suave es la que llega con identidad, comprobaciones y carpeta de llegada ya ordenadas.';

  @override
  String get documentReadinessRiskBlocking => 'Puede trabar la mudanza';

  @override
  String get documentReadinessRiskCaution => 'Evita demora y retrabajo';

  @override
  String get documentReadinessRiskReview => 'Revisar en la etapa correcta';

  @override
  String get documentReadinessReviewBeforeBooking =>
      'Revisá antes de comprar pasaje';

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
      'La vivienda es una decision critica antes de la ciudad';

  @override
  String housingDecisionSectionTitleWithCity(Object city) {
    return 'La vivienda puede definir si $city te sirve de verdad';
  }

  @override
  String get housingDecisionSectionBody =>
      'Antes de decidir la ciudad, conviene entender como funcionan alquiler y garantias en Brasil. El mayor riesgo no es solo el precio mensual: es llegar sin un camino viable para contrato, barrio e instalacion inicial.';

  @override
  String housingDecisionSectionBodyWithCity(Object city) {
    return 'Antes de asumir que $city es la mejor opcion, validá si alquiler, garantias e instalacion inicial parecen viables para tu momento. El riesgo no esta solo en el precio, sino en el camino real para cerrar vivienda.';
  }

  @override
  String get housingDecisionGuaranteesTitle =>
      'Las garantias pueden trabar el alquiler';

  @override
  String get housingDecisionGuaranteesBody =>
      'El fiador local todavia pesa en muchos contratos. Si eso no es realista para vos, compará caucion, seguro-fianza, titulo de capitalizacion y exigencia de ingresos antes de contar con un barrio.';

  @override
  String get housingDecisionSoftLandingTitle =>
      'Una llegada suave evita errores caros';

  @override
  String get housingDecisionSoftLandingBody =>
      'Temporal, amoblado, coliving o contrato corto por 30 a 90 dias suele ser mas seguro que tomar un alquiler largo antes de entender la rutina local.';

  @override
  String get housingDecisionProofPackTitle =>
      'Llevá la carpeta que destraba la conversacion';

  @override
  String get housingDecisionProofPackBody =>
      'Agrupá identidad, ingresos, reserva, referencias y comprobantes digitales en una sola carpeta. No garantiza aprobacion, pero reduce friccion desde el primer contacto.';

  @override
  String get housingDecisionCityReadTitle =>
      'Leé la ciudad por la presion de vivienda';

  @override
  String housingDecisionCityReadTitleWithCity(Object city) {
    return 'Leé $city por la presion de vivienda';
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
      'Movaro hoy organiza el contexto para decidir mejor. Contrato, garantia aceptada y politica de cada propietario o plataforma todavia deben validarse en la fuente antes de cerrar vivienda.';

  @override
  String get housingEntrySectionTitle =>
      'Estimacion del costo de entrada a la vivienda';

  @override
  String housingEntrySectionTitleWithCity(Object city) {
    return 'Cuanto puede exigir la vivienda para entrar en $city';
  }

  @override
  String get housingEntrySectionBody =>
      'Un alquiler que parece accesible en el anuncio puede exigir mucho mas al entrar. Usá esta lectura para simular caucion, seguro-fianza o un aterrizaje temporario antes de decidir la ciudad.';

  @override
  String housingEntrySectionBodyWithCity(Object city) {
    return 'En $city, no mires solo el alquiler mensual. Usá esta lectura para estimar cuanto puede exigir la entrada con caucion, seguro-fianza o un aterrizaje temporario.';
  }

  @override
  String housingEntryRentLabel(Object amount) {
    return 'Alquiler mensual de referencia: $amount';
  }

  @override
  String get housingEntryModeDeposit => 'Caucion';

  @override
  String get housingEntryModeInsurance => 'Seguro-fianza';

  @override
  String get housingEntryModeTemporary => 'Temporal';

  @override
  String get housingEntryModeDepositBody =>
      'Lectura comun cuando el contrato pide cerca de 3 meses de caucion mas el primer mes.';

  @override
  String get housingEntryModeInsuranceBody =>
      'Lectura comun cuando el fiador se reemplaza por una tasa anual de seguro o garantia digital.';

  @override
  String get housingEntryModeTemporaryBody =>
      'Una lectura mas liviana para los primeros 30 a 90 dias, priorizando flexibilidad antes de tomar un contrato largo.';

  @override
  String get housingEntryTotalTitle => 'Cuánto puede costar entrar';

  @override
  String get housingEntryFirstMonthLabel => 'Primer mes';

  @override
  String get housingEntryGuaranteeLabel => 'Garantia / caucion';

  @override
  String get housingEntrySetupLabel => 'Tasas e instalacion';

  @override
  String get housingEntryPlatformsTitle => 'Plataformas y caminos utiles';

  @override
  String get housingEntryPlatformsHeadline =>
      'Usá el canal correcto para tu nivel de riesgo';

  @override
  String get housingEntryPlatformsBody =>
      'La mejor plataforma depende menos del anuncio lindo y mas de la burocracia que realmente podés sostener ahora.';

  @override
  String get housingEntryPlatformsQuintoAndar =>
      'Digital y sin fiador, pero igual exige ingresos y documentacion consistentes.';

  @override
  String get housingEntryPlatformsZap =>
      'Usá filtros como alquiler sin fiador para reducir tiempo perdido en la busqueda.';

  @override
  String get housingEntryPlatformsCredPago =>
      'Garantia digital aceptada por muchas inmobiliarias como reemplazo del fiador.';

  @override
  String get housingEntryPlatformsAirbnb =>
      'Sirve para los primeros 15 a 30 dias mientras visitas barrios antes de tomar un contrato mas largo.';

  @override
  String get housingEntryDisclaimer =>
      'Esta simulacion es direccional. El valor real cambia por ciudad, barrio, plataforma, comprobacion de ingresos y politica del propietario. La idea es evitar subestimar el costo de entrada.';

  @override
  String get housingSoftLandingTitle =>
      'Como suelen aterrizar los argentinos antes del alquiler fijo';

  @override
  String get housingSoftLandingBody =>
      'En los primeros dias, el camino comun no es ir directo al contrato tradicional. La secuencia suele ser llegada, vivienda temporaria y solo despues la busqueda de una base mas estable con menos riesgo.';

  @override
  String get housingSoftLandingTemporaryTitle =>
      'Aterrizá por temporada o flat';

  @override
  String get housingSoftLandingTemporaryBody =>
      'Airbnb con descuento mensual, apart hotel y flat ayudan a aterrizar sin fiador ni comprobacion local. Eso compra tiempo para visitar barrios y entender la ciudad en la practica.';

  @override
  String get housingSoftLandingDirectTitle =>
      'Busqueda directa con dueño o grupos locales';

  @override
  String get housingSoftLandingDirectBody =>
      'Facebook Marketplace, OLX y contactos directos suelen ser mas flexibles que la inmobiliaria tradicional. A cambio, sube el riesgo de estafa y la validacion del inmueble debe ser mas estricta.';

  @override
  String get housingSoftLandingGuaranteeTitle =>
      'La moneda de cambio es la garantia';

  @override
  String get housingSoftLandingGuaranteeBody =>
      'Sin fiador, el argumento mas fuerte suele ser caucion, seguro-fianza, titulo de capitalizacion o algunos meses pagados por adelantado. El punto no es prometer de mas, sino llegar con una estructura creible.';

  @override
  String get housingSoftLandingSurvivalTitle =>
      'Checklist de supervivencia al llegar';

  @override
  String get housingSoftLandingSurvivalChip =>
      'Comprá un chip brasilero rapido. Sin numero local, inmobiliarias y propietarios suelen responder menos.';

  @override
  String get housingSoftLandingSurvivalCpf =>
      'Si el CPF todavia no esta resuelto, tratá eso como prioridad. Pesa en plataformas, banco y conversaciones de alquiler.';

  @override
  String get housingSoftLandingSurvivalLocation =>
      'En los primeros dias, priorizá quedarte cerca de mercado, farmacia, transporte y puesto de salud para bajar costo y friccion.';

  @override
  String get housingSoftLandingSurvivalScam =>
      'No envies reserva sin visitar el inmueble o tener a alguien de confianza validando en el lugar.';

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
      'Sirve como referencia si pensás llegar con gasto más controlado, vivienda más simple y decisiones iniciales más apretadas.';

  @override
  String get landingBudgetBalancedTitle => 'Equilibrado';

  @override
  String get landingBudgetBalancedBody =>
      'Una lectura intermedia para quien quiere reducir estrés sin asumir una instalación premium desde el día uno.';

  @override
  String get landingBudgetComfortableTitle => 'Cómodo';

  @override
  String get landingBudgetComfortableBody =>
      'Un margen más seguro si querés más aire para fricción con vivienda, adaptación más lenta o costos inesperados de instalación.';

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
  String get arrivalExecutionSectionTitle => 'Primeros 7 / 30 / 90 días';

  @override
  String get arrivalExecutionStageWeek => 'Primeros 7 días';

  @override
  String get arrivalExecutionStageMonth => 'Primeros 30 días';

  @override
  String get arrivalExecutionStageQuarter => 'Primeros 90 días';

  @override
  String get arrivalExecutionSummaryResearching =>
      'Esta es la capa de ejecucion despues de llegar. Usala ahora para entender que van a exigir las primeras semanas ademas del papeleo.';

  @override
  String get arrivalExecutionSummaryTwelveMonths =>
      'Con mas tiempo, esta capa ayuda a ver que va a exigir la instalacion, para que la mudanza no se planee solo por documentos y reserva.';

  @override
  String get arrivalExecutionSummarySixMonths =>
      'Seis meses ya alcanzan para planear la llegada como secuencia operativa, y no solo como decision de destino.';

  @override
  String get arrivalExecutionSummaryAsap =>
      'Si la llegada esta cerca, esta capa 7 / 30 / 90 dias importa ahora. Ahi suele aparecer primero la friccion cotidiana.';

  @override
  String get arrivalExecutionConnectivityTitle =>
      'Resolvé conectividad desde el dia uno';

  @override
  String get arrivalExecutionConnectivityBody =>
      'Empezá con chip local, internet movil y la estructura digital minima para mapas, banco y seguimiento documental.';

  @override
  String get arrivalExecutionTransportTitle =>
      'Aprendé la primera rutina de traslado';

  @override
  String get arrivalExecutionTransportBody =>
      'Mapeá como te vas a mover en la primera semana para que vivienda, servicios y burocracia no dependan de improvisacion.';

  @override
  String arrivalExecutionTransportBodyWithCity(String city) {
    return 'Mapeá como te vas a mover en $city durante la primera semana para que vivienda, servicios y burocracia no dependan de improvisacion.';
  }

  @override
  String get arrivalExecutionHealthTitle =>
      'Definí tu primer respaldo de salud';

  @override
  String get arrivalExecutionHealthBody =>
      'Sabé cual es tu primera puerta de entrada en salud publica o privada para que un problema simple no se vuelva caos al llegar.';

  @override
  String get arrivalExecutionBankTitle => 'Estabilizá pagos y flujo bancario';

  @override
  String get arrivalExecutionBankBody =>
      'Asegurá que tu primer flujo local de pagos funcione: cuenta, Pix, uso de tarjeta y como va a circular el dinero en el primer mes.';

  @override
  String get arrivalExecutionHousingTitle =>
      'Convertí vivienda en rutina, no solo en entrada';

  @override
  String get arrivalExecutionHousingBody =>
      'Despues de llegar, confirmá si la zona elegida realmente sostiene trabajo, transporte, seguridad y el ritmo de vida que necesitás.';

  @override
  String get arrivalExecutionGoalWorkTitle =>
      'Convertí la llegada en empleabilidad';

  @override
  String get arrivalExecutionGoalWorkBody =>
      'Usá el primer mes para probar como documentos, idioma y ciudad afectan de verdad tu chance de conseguir trabajo.';

  @override
  String get arrivalExecutionGoalRemoteTitle =>
      'Convertí la llegada en base remota estable';

  @override
  String get arrivalExecutionGoalRemoteBody =>
      'Validá calidad de internet, rutina silenciosa, flujo bancario y costo real de sostener trabajo remoto desde la nueva ciudad.';

  @override
  String get arrivalExecutionGoalStudyTitle =>
      'Convertí la llegada en rutina de estudio';

  @override
  String get arrivalExecutionGoalStudyBody =>
      'Usá el primer mes para confirmar si matricula, traslado, clases y costo diario siguen sosteniendo estudio como base del plan.';

  @override
  String get arrivalExecutionGoalEntrepreneurTitle =>
      'Convertí la llegada en capacidad de operar';

  @override
  String get arrivalExecutionGoalEntrepreneurBody =>
      'Usá el primer mes para validar si banco, documentos, rutina local y contexto de ciudad realmente sostienen operar con seguridad.';

  @override
  String get arrivalExecutionGoalRetireTitle =>
      'Convertí la llegada en rutina previsible';

  @override
  String get arrivalExecutionGoalRetireBody =>
      'Usá el primer mes para probar si acceso a salud, rutina de barrio y costos recurrentes se sienten sostenibles en la practica.';

  @override
  String get arrivalExecutionGoalQualityTitle =>
      'Convertí la llegada en calidad de vida real';

  @override
  String get arrivalExecutionGoalQualityBody =>
      'Usá el primer mes para verificar si la ciudad se siente bien en la vida diaria, y no solo en el papel o en rankings.';

  @override
  String get arrivalExecutionRealityCheckTitle =>
      'Hacé reality check a los 90 dias';

  @override
  String get arrivalExecutionRealityCheckBody =>
      'Compará costo real, friccion de rutina y encaje de la ciudad con lo que sugeria el plan. Ahi la mudanza deja de ser hipotetica.';

  @override
  String get arrivalExecutionDocumentsTitle =>
      'Cerrá las puntas documentales abiertas';

  @override
  String get arrivalExecutionDocumentsBody =>
      'Hasta los primeros 90 dias, reducí pendientes de residencia, comprobaciones, banco y registros locales que todavia bloquean estabilidad.';

  @override
  String get arrivalExecutionReplanTitle =>
      'Replaneá antes de que la inercia mande';

  @override
  String get arrivalExecutionReplanBody =>
      'Si ciudad, costo o ritmo no estan encajando con el plan original, ajustá la ruta antes de que la friccion temporal se vuelva tu normal.';

  @override
  String arrivalExecutionReplanBodyWithCity(String city) {
    return 'Si $city no esta encajando con el plan original en la practica, ajustá la ruta antes de que la friccion temporal se vuelva tu normal.';
  }

  @override
  String get publicHomeResumePlanAction => 'Continuar mi plan';

  @override
  String get publicHomeResumePlanTitle => 'Retomá desde donde lo dejaste';

  @override
  String get publicHomeResumePlanBody =>
      'Tu ultimo plan de mudanza sigue aqui. Reabrilo para continuar el checklist, la preparacion documental y la reserva de aterrizaje.';

  @override
  String publicHomeResumePlanBodyWithCity(String city, String state) {
    return 'Tu ultimo plan sigue aqui, con $city ($state) como ciudad de referencia actual. Reabrilo para continuar el checklist, la preparacion documental y la reserva de aterrizaje.';
  }

  @override
  String get publicHomeRetakePlanAction => 'Rehacer plan';

  @override
  String get migrationPlanCopilotTitle => 'Preparación guiada';

  @override
  String get migrationPlanCopilotAction => 'Abrir preparación';

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
  String get migrationPlanDecisionLabel => 'Elección de ciudad';

  @override
  String migrationPlanDecisionTitle(Object goal) {
    return 'Ahora compará las ciudades que mejor combinan con $goal';
  }

  @override
  String migrationPlanDecisionBody(Object timeline) {
    return 'Segun tu plazo de $timeline, estas opciones aparecen primero porque se acercan mas al perfil que marcaste.';
  }

  @override
  String get migrationPlanDecisionSummaryTitle => 'Cómo usar esta etapa';

  @override
  String get migrationPlanDecisionSummaryBody =>
      'Primero elegi la ciudad que mas sentido tenga para vos. El checklist detallado entra solo despues de esa decision.';

  @override
  String get migrationPlanCandidateCitiesTitle =>
      'Ciudades mas alineadas con tu perfil';

  @override
  String get migrationPlanCandidateCitiesBody =>
      'La lista ya viene ordenada para dejar primero lo que tiende a hacer mas sentido para argentinos con este objetivo.';

  @override
  String get migrationPlanCandidateCitiesSheetBody =>
      'Abrí los detalles para entender mejor cada ciudad. La confirmación de la ciudad ocurre dentro de la pantalla de detalle, después de ver más contexto.';

  @override
  String get migrationPlanSelectedCityBadge => 'Elegida';

  @override
  String get migrationPlanSuggestedCityBadge => 'Va adelante ahora';

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
    return '$city aparece fuerte para tu contexto actual, con una lectura de entrada en vivienda en $housing. Si esta ciudad te cierra, ahi si vale abrir la preparacion guiada.';
  }

  @override
  String get migrationPlanPreparationTitle => 'Cuando pasar a la preparacion';

  @override
  String migrationPlanPreparationBody(Object city) {
    return 'Si decidis avanzar con $city, el copiloto abre checklist, documentos, vivienda y reserva de llegada enfocados en esa ciudad.';
  }

  @override
  String get languageSelectorSystem => 'Sistema';
}
