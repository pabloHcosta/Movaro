import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_guide_registry.dart';

enum DocumentPhase { beforeTravel, uponArrival }

enum DocumentPriority { critical, important, optional }

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.phase,
    required this.priority,
    required this.icon,
    required this.title,
    required this.description,
    required this.timeEstimate,
    this.tip,
    this.link,
    required this.isOptional,
  });

  final String id;
  final DocumentPhase phase;
  final DocumentPriority priority;
  final String icon;
  final String title;
  final String description;
  final String timeEstimate;
  final String? tip;
  final String? link;
  final bool isOptional;
}

class DocumentChecklistAdapter {
  const DocumentChecklistAdapter._();

  static List<DocumentItem> getItems({
    required AppLocalizations l10n,
    required String originCountry,
    required String destinationCountry,
    required String goal,
    required String travelGroup,
    required MigrationDocumentReadinessChecklist fallbackChecklist,
  }) {
    final corridorKey = MigrationGuideRegistry.corridorKey(
      originCountry,
      destinationCountry,
    );

    if (corridorKey == 'argentina->brasil') {
      return _argentinaToBrazilItems(
        l10n: l10n,
        goal: goal,
        travelGroup: travelGroup,
      );
    }

    if (corridorKey == 'uruguai->brasil') {
      return _uruguayToBrazilItems(l10n: l10n);
    }

    return _genericItems(fallbackChecklist);
  }

  static List<DocumentItem> _argentinaToBrazilItems({
    required AppLocalizations l10n,
    required String goal,
    required String travelGroup,
  }) {
    final items = <DocumentItem>[
      DocumentItem(
        id: 'dni_valid',
        phase: DocumentPhase.beforeTravel,
        priority: DocumentPriority.critical,
        icon: '🪪',
        title: _text(
          l10n,
          pt: 'DNI argentino vigente',
          es: 'DNI argentino vigente',
          en: 'Valid Argentine DNI',
        ),
        description: _text(
          l10n,
          pt: 'O DNI físico vigente pode ser aceito em viagens no Mercosul, mas a finalidade, a transportadora e a orientação oficial atual importam. Confirme antes do embarque; passaporte válido continua sendo uma alternativa.',
          es: 'El DNI físico vigente puede aceptarse en viajes Mercosur, pero importan la finalidad, el transportista y la orientación oficial actual. Confirmá antes de embarcar; el pasaporte válido sigue siendo una alternativa.',
          en: 'A current physical DNI may be accepted for Mercosur travel, but purpose, carrier, and current official guidance matter. Confirm before boarding; a valid passport remains an alternative.',
        ),
        timeEstimate: _text(
          l10n,
          pt: '5 min para verificar',
          es: '5 min para verificar',
          en: '5 min to check',
        ),
        tip: _text(
          l10n,
          pt: 'Dica: tire uma foto do seu DNI e salve no celular como backup.',
          es: 'Consejo: sacale una foto a tu DNI y guardala en el celular como respaldo.',
          en: 'Tip: take a photo of your DNI and keep it on your phone.',
        ),
        isOptional: false,
      ),
      DocumentItem(
        id: 'stay_rule',
        phase: DocumentPhase.beforeTravel,
        priority: DocumentPriority.critical,
        icon: '📅',
        title: _text(
          l10n,
          pt: 'Diferenciar visita e residência',
          es: 'Diferenciar visita y residencia',
          en: 'Separate visitor stay and residence',
        ),
        description: _text(
          l10n,
          pt: 'A estada como visitante e o pedido de residência são temas diferentes. Argentinos elegíveis podem usar o acordo bilateral Brasil–Argentina para residência permanente. Confirme sua rota na Polícia Federal.',
          es: 'La estadía como visitante y la residencia son temas distintos. Argentinos elegibles pueden usar el acuerdo bilateral Brasil–Argentina para residencia permanente. Confirmá tu ruta en la Policía Federal.',
          en: 'Visitor stay and residence are separate matters. Eligible Argentines may use the Brazil–Argentina bilateral route to permanent residence. Confirm your route with Federal Police.',
        ),
        timeEstimate: _text(
          l10n,
          pt: '2 min para ler',
          es: '2 min para leer',
          en: '2 min to read',
        ),
        isOptional: false,
      ),
      DocumentItem(
        id: 'cpf',
        phase: DocumentPhase.uponArrival,
        priority: DocumentPriority.critical,
        icon: '📋',
        title: _text(
          l10n,
          pt: 'CPF na Receita Federal',
          es: 'CPF en la Receita Federal',
          en: 'CPF with Receita Federal',
        ),
        description: _text(
          l10n,
          pt: 'O CPF e o numero fiscal do Brasil. Voce vai precisar dele para abrir conta, alugar, assinar contrato e resolver quase tudo no dia a dia. O pedido e gratuito.',
          es: 'El CPF es el numero fiscal de Brasil. Lo vas a necesitar para abrir cuenta, alquilar, firmar contrato y resolver casi todo en el dia a dia. El tramite es gratuito.',
          en: 'CPF is Brazil s tax ID. You will need it to open a bank account, rent, sign contracts, and handle most practical tasks. The request is free.',
        ),
        timeEstimate: _text(
          l10n,
          pt: 'Prazo variável',
          es: 'Plazo variable',
          en: 'Timing varies',
        ),
        tip: _text(
          l10n,
          pt: 'Voce pode fazer o CPF antes da viagem no Consulado do Brasil em Buenos Aires.',
          es: 'Tambien podes hacer el CPF antes del viaje en el Consulado de Brasil en Buenos Aires.',
          en: 'You can also request CPF before traveling at the Brazilian Consulate in Buenos Aires.',
        ),
        link: 'https://www.gov.br/pt-br/servicos/inscrever-no-cpf-no-exterior',
        isOptional: false,
      ),
      DocumentItem(
        id: 'residencia_mercosul',
        phase: DocumentPhase.uponArrival,
        priority: DocumentPriority.critical,
        icon: '🏛️',
        title: _text(
          l10n,
          pt: 'Residência pelo Acordo Brasil–Argentina',
          es: 'Residencia por el Acuerdo Brasil–Argentina',
          en: 'Residence under the Brazil–Argentina Agreement',
        ),
        description: _text(
          l10n,
          pt: 'Argentinos elegíveis podem pedir residência permanente pelo acordo bilateral. Confirme requisitos e base legal na página atual da Polícia Federal; o RNM/CRNM aparece como etapa própria.',
          es: 'Argentinos elegibles pueden pedir residencia permanente por el acuerdo bilateral. Confirmá requisitos y base legal en la página vigente de la Policía Federal; el RNM/CRNM es un paso propio.',
          en: 'Eligible Argentines may request permanent residence under the bilateral agreement. Confirm current requirements and legal basis on the Federal Police page; RNM/CRNM is a separate step.',
        ),
        timeEstimate: _text(
          l10n,
          pt: '1 a 2 dias para protocolar',
          es: '1 a 2 dias para iniciar',
          en: '1 to 2 days to file',
        ),
        tip: _text(
          l10n,
          pt: 'Agendar cedo pode ajudar, mas não é um prazo legal universal. Use a página oficial para decidir a rota.',
          es: 'Agendar temprano puede ayudar, pero no es un plazo legal universal. Usá la página oficial para elegir la ruta.',
          en: 'Booking early may help, but it is not a universal legal deadline. Use the official page to choose the route.',
        ),
        link:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-brasil-e-argentina',
        isOptional: false,
      ),
    ];

    if (goal == 'work' || goal == 'find_job_br') {
      items.add(
        DocumentItem(
          id: 'carteira_trabalho',
          phase: DocumentPhase.uponArrival,
          priority: DocumentPriority.important,
          icon: '💼',
          title: _text(
            l10n,
            pt: 'CTPS digital',
            es: 'CTPS digital',
            en: 'Digital work card',
          ),
          description: _text(
            l10n,
            pt: 'Se a ideia for trabalhar com contrato formal, voce vai precisar da Carteira de Trabalho Digital depois de ter CPF e o protocolo de residencia.',
            es: 'Si la idea es trabajar con contrato formal, vas a necesitar la Carteira de Trabalho Digital despues de tener CPF y el protocolo de residencia.',
            en: 'If you plan to work formally, you will need the Digital Work Card after you have CPF and your residence protocol.',
          ),
          timeEstimate: _text(
            l10n,
            pt: '10 min online',
            es: '10 min online',
            en: '10 min online',
          ),
          isOptional: false,
        ),
      );
    }

    if (travelGroup == 'family_kids') {
      items.insert(
        2,
        DocumentItem(
          id: 'docs_criancas',
          phase: DocumentPhase.beforeTravel,
          priority: DocumentPriority.critical,
          icon: '👶',
          title: _text(
            l10n,
            pt: 'DNI dos filhos e autorizacao de viagem',
            es: 'DNI de los hijos y autorizacion de viaje',
            en: 'Children s DNI and travel authorization',
          ),
          description: _text(
            l10n,
            pt: 'Cada crianca precisa do proprio DNI. Se viajar com apenas um dos pais, e preciso levar a autorizacao do outro. Se os dois viajarem juntos, isso nao entra como exigencia extra.',
            es: 'Cada chico necesita su propio DNI. Si viaja con uno solo de los padres, hace falta la autorizacion del otro. Si viajan ambos, no se suma ese requisito.',
            en: 'Each child needs their own DNI. If traveling with only one parent, authorization from the other parent is required. If both travel together, no extra authorization is needed.',
          ),
          timeEstimate: _text(
            l10n,
            pt: 'Conferir antes da viagem',
            es: 'Revisar antes del viaje',
            en: 'Check before traveling',
          ),
          isOptional: false,
        ),
      );
    }

    return items;
  }

  static List<DocumentItem> _uruguayToBrazilItems({
    required AppLocalizations l10n,
  }) {
    return <DocumentItem>[
      DocumentItem(
        id: 'uy_doc_travel_basis',
        phase: DocumentPhase.beforeTravel,
        priority: DocumentPriority.critical,
        icon: '🛂',
        title: _text(
          l10n,
          pt: 'Validar o documento de entrada para mudança',
          es: 'Validar el documento de entrada para la mudanza',
          en: 'Validate the entry document for relocation',
        ),
        description: _text(
          l10n,
          pt: 'Para mudança, estudo ou trabalho, confirme o documento de viagem e a lógica de entrada antes de embarcar. Evite tratar a viagem como turismo genérico.',
          es: 'Para mudanza, estudio o trabajo, confirmá el documento de viaje y la lógica de entrada antes de viajar. Evitá tratar el viaje como turismo genérico.',
          en: 'For relocation, study, or work, confirm the travel document and entry logic before departure. Do not treat the trip as generic tourism.',
        ),
        timeEstimate: _text(
          l10n,
          pt: '10 min para revisar',
          es: '10 min para revisar',
          en: '10 min to review',
        ),
        link: 'https://www.gov.br/pf/pt-br/assuntos/imigracao',
        isOptional: false,
      ),
      DocumentItem(
        id: 'uy_doc_mercosur',
        phase: DocumentPhase.beforeTravel,
        priority: DocumentPriority.critical,
        icon: '🏛️',
        title: _text(
          l10n,
          pt: 'Entender a residência Mercosul',
          es: 'Entender la residencia Mercosur',
          en: 'Understand Mercosur residence',
        ),
        description: _text(
          l10n,
          pt: 'Para uruguaios que vão viver no Brasil, a residência Mercosul tende a ser a base principal de regularização.',
          es: 'Para personas uruguayas que van a vivir en Brasil, la residencia Mercosur suele ser la base principal de regularización.',
          en: 'For Uruguayans planning to live in Brazil, Mercosur residence tends to be the main regularization path.',
        ),
        timeEstimate: _text(
          l10n,
          pt: '20 min para mapear',
          es: '20 min para mapear',
          en: '20 min to map',
        ),
        tip: _text(
          l10n,
          pt: 'Trate isso como etapa central da mudança, não como pergunta de turismo.',
          es: 'Tratala como una etapa central de la mudanza, no como una duda de turismo.',
          en: 'Treat this as a central relocation step, not as a tourism question.',
        ),
        link:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-para-nacionais-dos-estados-partes-do-mercosul-bolivia-e-chile',
        isOptional: false,
      ),
      DocumentItem(
        id: 'uy_doc_cpf',
        phase: DocumentPhase.uponArrival,
        priority: DocumentPriority.critical,
        icon: '📋',
        title: _text(
          l10n,
          pt: 'Resolver o CPF cedo',
          es: 'Resolver el CPF temprano',
          en: 'Sort out CPF early',
        ),
        description: _text(
          l10n,
          pt: 'CPF destrava banco, aluguel e contratos. O canal e os documentos aceitos variam conforme sua situação migratória.',
          es: 'El CPF desbloquea banco, alquiler y contratos. El canal y los documentos aceptados varían según tu situación migratoria.',
          en: 'CPF unlocks banking, rent, and contracts. The channel and accepted documents vary with your migration status.',
        ),
        timeEstimate: _text(
          l10n,
          pt: '20 a 30 min',
          es: '20 a 30 min',
          en: '20 to 30 min',
        ),
        link:
            'https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/cpf/assuntos-relacionados/perguntas-e-respostas',
        isOptional: false,
      ),
      DocumentItem(
        id: 'uy_doc_bank',
        phase: DocumentPhase.uponArrival,
        priority: DocumentPriority.important,
        icon: '🏦',
        title: _text(
          l10n,
          pt: 'Abrir conta depois da base documental',
          es: 'Abrir cuenta después de la base documental',
          en: 'Open a bank account after the document base',
        ),
        description: _text(
          l10n,
          pt: 'Conta bancária normalmente entra melhor depois de CPF e de uma situação migratória coerente.',
          es: 'La cuenta bancaria normalmente encaja mejor después del CPF y de una situación migratoria coherente.',
          en: 'A bank account usually fits better after CPF and a coherent migration status.',
        ),
        timeEstimate: _text(l10n, pt: '30 min', es: '30 min', en: '30 min'),
        isOptional: false,
      ),
    ];
  }

  static List<DocumentItem> _genericItems(
    MigrationDocumentReadinessChecklist checklist,
  ) {
    return checklist.items
        .map((item) {
          return DocumentItem(
            id: item.id,
            phase: item.priority == MigrationDocumentReadinessPriority.arrival
                ? DocumentPhase.uponArrival
                : DocumentPhase.beforeTravel,
            priority: switch (item.priority) {
              MigrationDocumentReadinessPriority.critical =>
                DocumentPriority.critical,
              MigrationDocumentReadinessPriority.prepare =>
                DocumentPriority.important,
              MigrationDocumentReadinessPriority.arrival =>
                DocumentPriority.optional,
            },
            icon: _iconEmoji(item.icon),
            title: item.title,
            description: item.description,
            timeEstimate: _timeEstimateForPriority(item.priority),
            tip: null,
            link: null,
            isOptional:
                item.priority == MigrationDocumentReadinessPriority.arrival,
          );
        })
        .toList(growable: false);
  }

  static String _iconEmoji(IconData icon) {
    if (icon == Icons.badge_outlined || icon == Icons.account_box_outlined) {
      return '🪪';
    }
    if (icon == Icons.translate_outlined) {
      return '🌐';
    }
    if (icon == Icons.house_siding_outlined || icon == Icons.wallet_outlined) {
      return '🏠';
    }
    if (icon == Icons.cloud_done_outlined ||
        icon == Icons.folder_shared_outlined ||
        icon == Icons.inventory_2_outlined) {
      return '📁';
    }
    if (icon == Icons.gavel_outlined) {
      return '⚖️';
    }
    return '📄';
  }

  static String _timeEstimateForPriority(
    MigrationDocumentReadinessPriority priority,
  ) {
    return switch (priority) {
      MigrationDocumentReadinessPriority.critical => '5-30 min',
      MigrationDocumentReadinessPriority.prepare => '30-60 min',
      MigrationDocumentReadinessPriority.arrival => 'after arrival',
    };
  }

  static String _text(
    AppLocalizations l10n, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (l10n.localeName.split('_').first) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }
}
