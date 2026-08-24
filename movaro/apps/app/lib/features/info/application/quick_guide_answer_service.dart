import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/features/info/domain/entities/quick_guide_answer.dart';

class QuickGuideAnswerService {
  QuickGuideAnswerService({required NetworkClient client}) : _client = client;

  final NetworkClient _client;

  Future<QuickGuideAnswer> resolve({
    required String question,
    required String originCountry,
    required String destinationCountry,
    required String locale,
    String? cityId,
    Map<String, String> answers = const {},
  }) async {
    final normalizedQuestion = question.trim();
    final body = <String, dynamic>{
      'message': normalizedQuestion,
      'originCountry': originCountry.trim().isEmpty
          ? 'argentina'
          : originCountry,
      'destinationCountry': destinationCountry.trim().isEmpty
          ? 'brasil'
          : destinationCountry,
      'locale': _normalizeLocale(locale),
      if (cityId != null && cityId.trim().isNotEmpty)
        'highlightedCityId': cityId,
      if (answers.isNotEmpty) 'answers': answers,
    };

    try {
      final data = await _client.postJsonMap('/api/v1/guide/resolve', body);
      final answer = QuickGuideAnswer.fromJson(data);
      if (answer.answer.trim().isNotEmpty) {
        return answer;
      }
    } catch (_) {
      // The guide is offline-first. A reviewed on-device answer remains
      // available when the structured endpoint cannot be reached.
    }

    return _localAnswer(
      question: normalizedQuestion,
      originCountry: body['originCountry']! as String,
      destinationCountry: body['destinationCountry']! as String,
      locale: body['locale']! as String,
      cityId: cityId,
    );
  }

  QuickGuideAnswer _localAnswer({
    required String question,
    required String originCountry,
    required String destinationCountry,
    required String locale,
    required String? cityId,
  }) {
    final topic = _detectTopic(question);
    final profile = _localProfile(topic, locale, question);
    final practicalGuidance = _localPracticalGuidance(topic, locale);
    return QuickGuideAnswer(
      resolutionId: 'quick-help-$topic-offline',
      entryId: 'quick-guide-$topic-local',
      topic: topic,
      question: question,
      answer: profile.answer,
      coverage: QuickGuideCoverage.partial,
      coverageReason: _tr(
        locale,
        pt: 'Você está offline. Esta é uma orientação local sem verificação atual das fontes.',
        es: 'Estás sin conexión. Esta es una orientación local sin verificación actual de las fuentes.',
        en: 'You are offline. This is local guidance without a current source check.',
      ),
      trust: QuickGuideTrust(
        reason: _tr(
          locale,
          pt: 'Conecte-se para verificar evidências, escopo e vigência.',
          es: 'Conectate para verificar evidencias, alcance y vigencia.',
          en: 'Connect to verify evidence, scope, and freshness.',
        ),
        evidenceCoverage: 0,
        freshness: QuickGuideFreshness.notAvailable,
      ),
      context: QuickGuideContext(
        originCountry: originCountry,
        destinationCountry: destinationCountry,
        cityId: cityId,
      ),
      actions: const [],
      nextSteps: practicalGuidance.$1,
      fallbackPath: practicalGuidance.$2,
      caveats: profile.caveats,
      // Offline content is intentionally not presented as reviewed evidence.
      sources: const [],
      offline: true,
    );
  }

  _LocalQuickGuideProfile _localProfile(
    String topic,
    String locale,
    String question,
  ) {
    final exploreLabel = _tr(
      locale,
      pt: 'Explorar este tema',
      es: 'Explorar este tema',
      en: 'Explore this topic',
    );
    final sensitiveCaveat = _tr(
      locale,
      pt: 'Regras e atendimentos podem mudar conforme o caso. Confirme a fonte oficial antes de tomar uma decisão.',
      es: 'Las reglas y la atención pueden cambiar según el caso. Confirmá la fuente oficial antes de decidir.',
      en: 'Rules and service details can vary by case. Confirm the official source before deciding.',
    );

    switch (topic) {
      case 'education':
        final isUniversity = _normalize(question).contains('univers');
        return _LocalQuickGuideProfile(
          reviewed: true,
          answer: _tr(
            locale,
            pt: isUniversity
                ? 'O ingresso na universidade depende do processo de cada instituição, como Sisu, vestibular ou seleção própria. Confirme também se seus documentos escolares precisam de tradução ou validação.'
                : 'Crianças e adolescentes migrantes podem se matricular na educação básica. Procure a rede municipal ou estadual responsável pelo endereço, leve os documentos disponíveis e peça orientação por escrito se algo faltar.',
            es: isUniversity
                ? 'El ingreso a la universidad depende del proceso de cada institución, como Sisu, examen o selección propia. Confirmá también si tus documentos escolares necesitan traducción o validación.'
                : 'Niños y adolescentes migrantes pueden matricularse en la educación básica. Buscá la red municipal o estadual del domicilio, llevá los documentos disponibles y pedí orientación por escrito si falta algo.',
            en: isUniversity
                ? 'University admission depends on each institution through Sisu, an entrance exam, or its own process. Also confirm whether your school records need translation or validation.'
                : 'Migrant children and adolescents can enroll in basic education. Contact the municipal or state network for the address, bring the documents you have, and request written guidance if something is missing.',
          ),
          action: QuickGuideAction(
            type: 'open_topic',
            target: 'education',
            label: exploreLabel,
          ),
          sources: [
            QuickGuideSource(
              title: _tr(
                locale,
                pt: 'Educação básica',
                es: 'Educación básica',
                en: 'Basic education',
              ),
              publisher: 'Ministério da Educação',
              url: 'https://www.gov.br/mec/pt-br/assuntos/eb',
              checkedAt: '2026-08-18',
            ),
          ],
        );
      case 'housing':
        return _LocalQuickGuideProfile(
          reviewed: true,
          answer: _tr(
            locale,
            pt: 'O locador pode pedir uma das garantias previstas em lei, como caução, fiador ou seguro-fiança, mas não deve acumular mais de uma no mesmo contrato. Antes de pagar, confirme o imóvel, a identidade de quem recebe e todas as condições por escrito.',
            es: 'El propietario puede pedir una de las garantías previstas por ley, como depósito, garante o seguro, pero no debe acumular más de una en el mismo contrato. Antes de pagar, verificá el inmueble, la identidad de quien cobra y todas las condiciones por escrito.',
            en: 'A landlord may request one legally permitted guarantee, such as a deposit, guarantor, or insurance, but should not stack multiple guarantees in one contract. Before paying, verify the property, the recipient’s identity, and all written terms.',
          ),
          action: QuickGuideAction(
            type: 'open_topic',
            target: 'housing',
            label: exploreLabel,
          ),
          caveats: [sensitiveCaveat],
          sources: [
            QuickGuideSource(
              title: _tr(
                locale,
                pt: 'Lei do Inquilinato',
                es: 'Ley de alquileres de Brasil',
                en: 'Brazilian Tenancy Law',
              ),
              publisher: 'Planalto',
              url: 'https://www.planalto.gov.br/ccivil_03/leis/l8245.htm',
              checkedAt: '2026-08-18',
            ),
          ],
        );
      case 'health':
        return _LocalQuickGuideProfile(
          reviewed: true,
          answer: _tr(
            locale,
            pt: 'Migrantes podem acessar o SUS. Uma urgência não deve ser adiada por falta de CPF ou Cartão SUS; para acompanhamento, procure a UBS da região e confirme os documentos usados no cadastro local. Em uma emergência médica, ligue para o SAMU 192.',
            es: 'Las personas migrantes pueden acceder al SUS. Una urgencia no debe postergarse por falta de CPF o Tarjeta SUS; para seguimiento, buscá la UBS de la zona y confirmá los documentos del registro local. En una emergencia médica, llamá al SAMU 192.',
            en: 'Migrants can access SUS. Urgent care should not be delayed because you lack a CPF or SUS card; for ongoing care, find the local UBS and confirm its registration documents. In a medical emergency, call SAMU 192.',
          ),
          action: QuickGuideAction(
            type: 'open_topic',
            target: 'health',
            label: exploreLabel,
          ),
          caveats: [sensitiveCaveat],
          sources: [
            QuickGuideSource(
              title: _tr(
                locale,
                pt: 'Acesso de estrangeiros ao SUS',
                es: 'Acceso de extranjeros al SUS',
                en: 'SUS access for foreign nationals',
              ),
              publisher: 'Ministério da Saúde',
              url:
                  'https://www.gov.br/saude/pt-br/assuntos/noticias/2025/marco/sus-estrangeiros-podem-contar-com-acesso-ao-sistema-publico-de-saude',
              checkedAt: '2026-08-18',
            ),
          ],
        );
      case 'work':
        return _LocalQuickGuideProfile(
          reviewed: true,
          answer: _tr(
            locale,
            pt: 'Comece definindo a área e a cidade, adapte o currículo ao português e pesquise vagas em mais de um canal. Para trabalho formal, confirme sua situação migratória e o acesso à Carteira de Trabalho Digital; nunca pague inscrição, curso ou treinamento para ser contratado.',
            es: 'Empezá por definir el área y la ciudad, adaptá el currículum al portugués y buscá vacantes en más de un canal. Para trabajo formal, confirmá tu situación migratoria y el acceso a la Libreta de Trabajo Digital; nunca pagues inscripción, curso o capacitación para ser contratado.',
            en: 'Start by choosing the field and city, adapt your résumé to Portuguese, and search through more than one channel. For formal work, confirm your migration status and access to the Digital Work Card; never pay an application, course, or training fee to be hired.',
          ),
          action: QuickGuideAction(
            type: 'open_topic',
            target: 'work',
            label: exploreLabel,
          ),
          sources: [
            QuickGuideSource(
              title: _tr(
                locale,
                pt: 'Carteira de Trabalho Digital',
                es: 'Libreta de Trabajo Digital',
                en: 'Digital Work Card',
              ),
              publisher: 'Ministério do Trabalho e Emprego',
              url:
                  'https://www.gov.br/pt-br/servicos/obter-a-carteira-de-trabalho',
              checkedAt: '2026-08-18',
            ),
          ],
        );
      case 'finance':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Conta bancária, Pix, acesso ao gov.br e remessas internacionais dependem de verificações diferentes. Sem conexão, não consigo confirmar os requisitos atuais da instituição ou do serviço para o seu caso.',
            es: 'La cuenta bancaria, Pix, el acceso a gov.br y las transferencias internacionales requieren verificaciones diferentes. Sin conexión, no puedo confirmar los requisitos actuales de la institución o del servicio para tu caso.',
            en: 'Bank accounts, Pix, gov.br access, and international transfers involve different checks. While offline, I cannot confirm the institution’s or service’s current requirements for your case.',
          ),
          action: QuickGuideAction(
            type: 'open_tool',
            target: 'finance',
            label: exploreLabel,
          ),
          caveats: [sensitiveCaveat],
        );
      case 'tax':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Residência fiscal não é a mesma coisa que residência migratória. Datas de entrada, tipo de permanência, renda e bens no exterior podem mudar a análise; conecte-se para consultar a orientação oficial vigente antes de declarar ou pagar.',
            es: 'La residencia fiscal no es lo mismo que la residencia migratoria. Las fechas de ingreso, el tipo de permanencia, los ingresos y bienes en el exterior pueden cambiar el análisis; conectate para consultar la orientación oficial vigente antes de declarar o pagar.',
            en: 'Tax residence is not the same as immigration residence. Entry dates, type of stay, foreign income, and assets can change the analysis; connect to check current official guidance before filing or paying.',
          ),
          action: QuickGuideAction(
            type: 'open_tool',
            target: 'tax',
            label: exploreLabel,
          ),
          caveats: [sensitiveCaveat],
        );
      case 'family':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Reunião familiar, documentos de cada dependente e viagem de menores são processos relacionados, mas separados. Sem conexão, não consigo confirmar qual autorização ou prova é exigida no seu caso.',
            es: 'La reunificación familiar, los documentos de cada dependiente y el viaje de menores son procesos relacionados, pero separados. Sin conexión, no puedo confirmar qué autorización o prueba exige tu caso.',
            en: 'Family reunification, each dependent’s documents, and minor travel are related but separate processes. While offline, I cannot confirm which authorization or evidence your case requires.',
          ),
          action: QuickGuideAction(
            type: 'open_tool',
            target: 'family',
            label: exploreLabel,
          ),
          caveats: [sensitiveCaveat],
        );
      case 'pets_customs':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Pets, alimentos, medicamentos, bagagem, mudança e veículos seguem controles diferentes. Sem conexão, não consigo confirmar a exigência vigente para o item e a data da viagem.',
            es: 'Mascotas, alimentos, medicamentos, equipaje, mudanza y vehículos siguen controles diferentes. Sin conexión, no puedo confirmar el requisito vigente para el ítem y la fecha del viaje.',
            en: 'Pets, food, medicines, baggage, household goods, and vehicles follow different controls. While offline, I cannot confirm the current requirement for the item and travel date.',
          ),
          caveats: [sensitiveCaveat],
        );
      case 'utilities':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Telefone, internet, energia e água têm prestadoras e listas de documentos diferentes. Peça a exigência e guarde o protocolo; conecte-se para verificar o canal regulatório correspondente.',
            es: 'Teléfono, internet, energía y agua tienen prestadoras y listas de documentos diferentes. Pedí el requisito y guardá el protocolo; conectate para verificar el canal regulatorio correspondiente.',
            en: 'Phone, internet, electricity, and water have different providers and document lists. Request the requirement and keep the protocol; connect to verify the relevant regulatory channel.',
          ),
          caveats: [sensitiveCaveat],
        );
      case 'protection':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Se houver perigo imediato, procure agora o serviço de emergência adequado e uma pessoa ou local seguro. A Central não monitora risco nem envia denúncias.',
            es: 'Si hay peligro inmediato, buscá ahora el servicio de emergencia adecuado y una persona o lugar seguro. La Central no monitorea riesgos ni envía denuncias.',
            en: 'If there is immediate danger, contact the appropriate emergency service now and move to a safe person or place. Help does not monitor risk or file reports.',
          ),
          caveats: [sensitiveCaveat],
        );
      case 'consumer':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Guarde oferta, contrato, comprovantes, capturas e protocolos. Sem conexão, não consigo confirmar o canal atual da empresa ou do regulador; em fraude ativa, proteja primeiro contas e meios de pagamento.',
            es: 'Guardá oferta, contrato, comprobantes, capturas y protocolos. Sin conexión, no puedo confirmar el canal actual de la empresa o del regulador; ante fraude activo, protegé primero cuentas y medios de pago.',
            en: 'Keep the offer, contract, receipts, screenshots, and protocols. While offline, I cannot confirm the current company or regulator channel; during active fraud, secure accounts and payment methods first.',
          ),
          caveats: [sensitiveCaveat],
        );
      case 'long_term':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Previdência internacional e naturalização são processos separados. Preserve registros de cada país e conecte-se para verificar acordo, modalidade e requisitos vigentes.',
            es: 'La previsión internacional y la naturalización son procesos separados. Conservá registros de cada país y conectate para verificar acuerdo, modalidad y requisitos vigentes.',
            en: 'International social security and naturalization are separate processes. Keep each country’s records and connect to verify the current agreement, type, and requirements.',
          ),
          caveats: [sensitiveCaveat],
        );
      case 'documents':
        return _LocalQuickGuideProfile(
          reviewed: true,
          answer: _tr(
            locale,
            pt: 'CPF, documento de entrada e registro migratório têm funções diferentes. O CPF ajuda em cadastros, mas não substitui a regularização migratória. Confirme na Polícia Federal qual rota de residência corresponde ao seu caso e use a Receita Federal para o CPF.',
            es: 'El CPF, el documento de ingreso y el registro migratorio cumplen funciones distintas. El CPF ayuda con registros, pero no reemplaza la regularización migratoria. Confirmá en la Policía Federal qué vía de residencia corresponde a tu caso y usá la Receita Federal para el CPF.',
            en: 'CPF, entry documents, and migration registration serve different purposes. CPF helps with registrations but does not replace regular migration status. Confirm your residence route with Federal Police and use the Federal Revenue service for CPF.',
          ),
          action: QuickGuideAction(
            type: 'open_topic',
            target: 'documents',
            label: exploreLabel,
          ),
          caveats: [sensitiveCaveat],
          sources: [
            QuickGuideSource(
              title: _tr(
                locale,
                pt: 'Inscrição no CPF',
                es: 'Inscripción en el CPF',
                en: 'CPF registration',
              ),
              publisher: 'Receita Federal',
              url:
                  'https://www.gov.br/pt-br/servicos/inscrever-no-cpf?id=10416&origem=servico',
              checkedAt: '2026-08-18',
            ),
          ],
        );
      case 'driving':
        return _LocalQuickGuideProfile(
          reviewed: true,
          answer: _tr(
            locale,
            pt: 'A possibilidade de dirigir com habilitação estrangeira depende do país emissor, da validade do documento e do tempo de permanência no Brasil. Leve a habilitação original válida e um documento de identificação; consulte a Senatran e o Detran do estado antes de dirigir ou iniciar a troca pela CNH.',
            es: 'La posibilidad de conducir con una licencia extranjera depende del país emisor, la vigencia del documento y el tiempo de permanencia en Brasil. Llevá la licencia original vigente y un documento de identidad; consultá Senatran y el Detran del estado antes de conducir o iniciar el cambio por la CNH.',
            en: 'Whether you may drive with a foreign licence depends on the issuing country, document validity, and your length of stay in Brazil. Carry the valid original licence and identification; check Senatran and the state Detran before driving or starting a CNH exchange.',
          ),
          action: QuickGuideAction(
            type: 'open_topic',
            target: 'driving',
            label: exploreLabel,
          ),
          caveats: [sensitiveCaveat],
          sources: [
            QuickGuideSource(
              title: _tr(
                locale,
                pt: 'Dirigir no Brasil',
                es: 'Conducir en Brasil',
                en: 'Driving in Brazil',
              ),
              publisher: 'Senatran',
              url:
                  'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-Senatran/dirigir-no-brasil',
              checkedAt: '2026-08-18',
            ),
          ],
        );
      case 'costs':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'O custo mensal muda bastante por cidade, bairro e composição familiar. Para uma estimativa útil, separe moradia e condomínio, alimentação, transporte, saúde, educação e uma reserva para imprevistos; compare sempre na mesma moeda e trate o resultado como faixa, não como valor garantido.',
            es: 'El costo mensual cambia mucho según la ciudad, el barrio y la composición familiar. Para una estimación útil, separá vivienda y expensas, alimentación, transporte, salud, educación y una reserva para imprevistos; compará siempre en la misma moneda y tratá el resultado como un rango, no como un valor garantizado.',
            en: 'Monthly costs vary widely by city, neighbourhood, and household. For a useful estimate, separate housing and fees, food, transport, health, education, and an emergency buffer; compare in one currency and treat the result as a range, not a guaranteed amount.',
          ),
          action: QuickGuideAction(
            type: 'open_topic',
            target: 'costs',
            label: exploreLabel,
          ),
          caveats: [
            _tr(
              locale,
              pt: 'Valores mudam com frequência e dependem do seu padrão de vida.',
              es: 'Los valores cambian con frecuencia y dependen de tu estilo de vida.',
              en: 'Prices change frequently and depend on your lifestyle.',
            ),
          ],
        );
      case 'flights':
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Você pode comparar aeroportos, datas e sazonalidade sem criar ou alterar um plano. Use a ferramenta de voos e ajuste livremente a origem e o destino sugeridos.',
            es: 'Podés comparar aeropuertos, fechas y estacionalidad sin crear ni cambiar un plan. Usá la herramienta de vuelos y ajustá libremente el origen y el destino sugeridos.',
            en: 'You can compare airports, dates, and seasonality without creating or changing a plan. Use the flight tool and freely adjust the suggested origin and destination.',
          ),
          action: QuickGuideAction(
            type: 'open_tool',
            target: 'flights',
            label: _tr(
              locale,
              pt: 'Abrir busca de voos',
              es: 'Abrir búsqueda de vuelos',
              en: 'Open flight search',
            ),
          ),
        );
      default:
        return _LocalQuickGuideProfile(
          reviewed: false,
          answer: _tr(
            locale,
            pt: 'Ainda não encontrei uma resposta revisada específica para essa dúvida. Explore os temas do Guia ou reformule a pergunta com o assunto principal, como escola, documentos, moradia, saúde, trabalho ou custos.',
            es: 'Todavía no encontré una respuesta revisada específica para esa duda. Explorá los temas de la Guía o reformulá la pregunta con el tema principal, como escuela, documentos, vivienda, salud, trabajo o costos.',
            en: 'I did not find a specific reviewed answer for that question yet. Explore Guide topics or rephrase using the main subject, such as school, documents, housing, health, work, or costs.',
          ),
          caveats: [
            _tr(
              locale,
              pt: 'Esta resposta é apenas uma orientação de navegação.',
              es: 'Esta respuesta es sólo una orientación de navegación.',
              en: 'This answer is navigation guidance only.',
            ),
          ],
        );
    }
  }

  (List<String>, List<String>) _localPracticalGuidance(
    String topic,
    String locale,
  ) {
    return switch (topic) {
      'education' => (
        [
          _tr(
            locale,
            pt: 'Identifique a rede municipal ou estadual responsável pelo endereço.',
            es: 'Identificá la red municipal o estadual responsable del domicilio.',
            en: 'Identify the municipal or state school network for the address.',
          ),
          _tr(
            locale,
            pt: 'Peça a lista atual de documentos e o calendário de matrícula.',
            es: 'Pedí la lista actual de documentos y el calendario de inscripción.',
            en: 'Request the current document list and enrollment calendar.',
          ),
        ],
        [
          _tr(
            locale,
            pt: 'Se houver bloqueio, peça a exigência e a orientação da rede por escrito.',
            es: 'Si hay un bloqueo, pedí por escrito el requisito y la orientación de la red.',
            en: 'If blocked, request the requirement and the network’s guidance in writing.',
          ),
        ],
      ),
      'housing' => (
        [
          _tr(
            locale,
            pt: 'Confirme por escrito qual garantia será usada no contrato.',
            es: 'Confirmá por escrito qué garantía se usará en el contrato.',
            en: 'Confirm in writing which guarantee the contract will use.',
          ),
          _tr(
            locale,
            pt: 'Verifique o imóvel, o contrato e a identidade antes de pagar.',
            es: 'Verificá el inmueble, el contrato y la identidad antes de pagar.',
            en: 'Verify the property, contract, and identity before paying.',
          ),
        ],
        [
          _tr(
            locale,
            pt: 'Se houver pressão ou cobrança duvidosa, não pague e preserve anúncio e mensagens.',
            es: 'Si hay presión o un cobro dudoso, no pagues y guardá el anuncio y los mensajes.',
            en: 'If pressured or charged suspiciously, do not pay and keep the listing and messages.',
          ),
        ],
      ),
      'work' => (
        [
          _tr(
            locale,
            pt: 'Confirme sua situação migratória e o acesso à Carteira de Trabalho Digital.',
            es: 'Confirmá tu situación migratoria y el acceso a la Libreta de Trabajo Digital.',
            en: 'Confirm your migration status and access to the Digital Work Card.',
          ),
          _tr(
            locale,
            pt: 'Adapte o currículo ao português e pesquise em mais de um canal.',
            es: 'Adaptá el currículum al portugués y buscá en más de un canal.',
            en: 'Adapt your résumé to Portuguese and search through more than one channel.',
          ),
        ],
        [
          _tr(
            locale,
            pt: 'Não pague inscrição, curso ou treinamento para ser contratado.',
            es: 'No pagues inscripción, curso o capacitación para ser contratado.',
            en: 'Do not pay an application, course, or training fee to be hired.',
          ),
        ],
      ),
      'health' => (
        [
          _tr(
            locale,
            pt: 'Em urgência, procure atendimento imediato; para acompanhamento, localize a UBS da região.',
            es: 'Ante una urgencia, buscá atención inmediata; para seguimiento, localizá la UBS de la zona.',
            en: 'For urgent needs, seek immediate care; for follow-up, find the local UBS.',
          ),
          _tr(
            locale,
            pt: 'Confirme na unidade quais documentos são usados no cadastro local.',
            es: 'Confirmá en la unidad qué documentos se usan para el registro local.',
            en: 'Ask the unit which documents it uses for local registration.',
          ),
        ],
        [
          _tr(
            locale,
            pt: 'Em uma emergência médica, ligue para o SAMU 192.',
            es: 'En una emergencia médica, llamá al SAMU 192.',
            en: 'In a medical emergency, call SAMU 192.',
          ),
        ],
      ),
      'documents' || 'driving' => (
        [
          _tr(
            locale,
            pt: 'Identifique o documento ou serviço exato antes de reunir comprovantes.',
            es: 'Identificá el documento o servicio exacto antes de reunir comprobantes.',
            en: 'Identify the exact document or service before gathering evidence.',
          ),
          _tr(
            locale,
            pt: 'Confirme a lista vigente no canal oficial responsável.',
            es: 'Confirmá la lista vigente en el canal oficial responsable.',
            en: 'Confirm the current list through the responsible official channel.',
          ),
        ],
        [
          _tr(
            locale,
            pt: 'Se houver recusa, peça o motivo por escrito e guarde o protocolo.',
            es: 'Si hay un rechazo, pedí el motivo por escrito y guardá el protocolo.',
            en: 'If refused, request the reason in writing and keep the protocol.',
          ),
        ],
      ),
      'finance' || 'tax' || 'costs' => (
        [
          _tr(
            locale,
            pt: 'Identifique primeiro o bloqueio ou valor que precisa confirmar.',
            es: 'Identificá primero el bloqueo o valor que necesitás confirmar.',
            en: 'First identify the blockage or amount you need to confirm.',
          ),
          _tr(
            locale,
            pt: 'Peça requisitos, taxas e motivo de recusa por um canal oficial.',
            es: 'Pedí requisitos, tasas y motivo de rechazo por un canal oficial.',
            en: 'Request requirements, fees, and refusal reasons through an official channel.',
          ),
        ],
        [
          _tr(
            locale,
            pt: 'Não envie dinheiro ou documentos a intermediários não verificados.',
            es: 'No envíes dinero ni documentos a intermediarios no verificados.',
            en: 'Do not send money or documents to unverified intermediaries.',
          ),
        ],
      ),
      _ => (
        [
          _tr(
            locale,
            pt: 'Confirme a orientação atual no canal oficial responsável.',
            es: 'Confirmá la orientación actual en el canal oficial responsable.',
            en: 'Confirm current guidance through the responsible official channel.',
          ),
        ],
        const <String>[],
      ),
    };
  }

  String _detectTopic(String value) {
    final normalized = _normalize(value);
    bool has(List<String> values) => values.any(normalized.contains);
    if (has(['escola', 'escuela', 'school', 'universidade', 'universidad'])) {
      return 'education';
    }
    if (has(['aluguel', 'alquiler', 'rent', 'moradia', 'vivienda', 'fiador'])) {
      return 'housing';
    }
    if (has(['sus', 'saude', 'salud', 'health', 'hospital', 'medicamento'])) {
      return 'health';
    }
    if (has([
      'perigo',
      'peligro',
      'danger',
      'xenofobia',
      'xenophobia',
      'discriminacao',
      'discriminacion',
      'discrimination',
      'exploracao',
      'explotacion',
      'exploitation',
      'assistencia juridica',
      'asistencia juridica',
      'legal aid',
    ])) {
      return 'protection';
    }
    if (has([
      'reclamar',
      'reclamo',
      'complaint',
      'consumidor',
      'procon',
      'fraude',
      'fraud',
      'golpe',
      'estafa',
      'scam',
    ])) {
      return 'consumer';
    }
    if (has([
      'chip',
      'sim',
      'internet',
      'energia',
      'electricidad',
      'electricity',
      'conta de luz',
      'factura de luz',
      'agua',
      'water',
      'comprovante de endereco',
      'comprobante de domicilio',
      'proof of address',
    ])) {
      return 'utilities';
    }
    if (has([
      'pet',
      'mascota',
      'cachorro',
      'perro',
      'dog',
      'gato',
      'cat',
      'alfandega',
      'aduana',
      'customs',
      'bagagem',
      'equipaje',
      'baggage',
    ])) {
      return 'pets_customs';
    }
    if (has([
      'previdencia',
      'prevision',
      'social security',
      'aposentadoria',
      'jubilacion',
      'retirement',
      'naturalizacao',
      'naturalizacion',
      'naturalization',
      'cidadania',
      'ciudadania',
      'citizenship',
    ])) {
      return 'long_term';
    }
    if (has(['trabalho', 'trabajo', 'work', 'emprego', 'empleo', 'vaga'])) {
      return 'work';
    }
    if (has([
      'banco',
      'bank',
      'cuenta',
      'conta',
      'pix',
      'gov.br',
      'remessa',
      'remesa',
      'transferencia internacional',
      'international transfer',
    ])) {
      return 'finance';
    }
    if (has([
      'imposto',
      'impuesto',
      'tax',
      'residente fiscal',
      'residencia fiscal',
      'renda no exterior',
      'ingresos del exterior',
      'foreign income',
    ])) {
      return 'tax';
    }
    if (has([
      'reuniao familiar',
      'reunificacion familiar',
      'family reunification',
      'dependente',
      'dependiente',
      'viagem de menor',
      'viaje de menor',
      'minor travel',
      'meu filho',
      'mi hijo',
      'my child',
    ])) {
      return 'family';
    }
    if (has([
      'dirigir',
      'conducir',
      'driving',
      'cnh',
      'habilitacao',
      'licencia',
    ])) {
      return 'driving';
    }
    if (has(['custo', 'costo', 'cost', 'gasto', 'orcamento', 'presupuesto'])) {
      return 'costs';
    }
    if (has(['voo', 'vuelo', 'flight', 'passagem', 'pasaje'])) {
      return 'flights';
    }
    if (has([
      'documento',
      'document',
      'cpf',
      'residencia',
      'visto',
      'visa',
      'passaporte',
      'pasaporte',
    ])) {
      return 'documents';
    }
    return 'general';
  }

  String _normalize(String value) {
    const replacements = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };
    var result = value.toLowerCase();
    replacements.forEach((from, to) => result = result.replaceAll(from, to));
    return result;
  }

  String _normalizeLocale(String locale) {
    if (locale.startsWith('es')) return 'es';
    if (locale.startsWith('en')) return 'en';
    return 'pt';
  }

  String _tr(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) {
    if (locale.startsWith('es')) return es;
    if (locale.startsWith('en')) return en;
    return pt;
  }
}

class _LocalQuickGuideProfile {
  const _LocalQuickGuideProfile({
    required this.reviewed,
    required this.answer,
    this.action,
    this.caveats = const [],
    this.sources = const [],
  });

  final bool reviewed;
  final String answer;
  final QuickGuideAction? action;
  final List<String> caveats;
  final List<QuickGuideSource> sources;
}
