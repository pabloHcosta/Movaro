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
          pt: 'Com o DNI voce ja entra no Brasil. Nao precisa de passaporte. Argentina e Brasil fazem parte do Mercosul. Verifique se a foto ainda esta reconhecivel e se o documento nao venceu.',
          es: 'Con el DNI ya podes entrar a Brasil. No hace falta pasaporte. Argentina y Brasil forman parte del Mercosur. Verifica que la foto siga siendo reconocible y que el documento no este vencido.',
          en: 'Your DNI is enough to enter Brazil. You do not need a passport. Argentina and Brazil are part of Mercosur. Check that the photo is still recognizable and that the document is not expired.',
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
          pt: 'Entender a regra dos 90 dias',
          es: 'Entender la regla de los 90 dias',
          en: 'Understand the 90-day rule',
        ),
        description: _text(
          l10n,
          pt: 'Com o DNI, voce pode ficar no Brasil por ate 90 dias como turista. Para morar de forma regular, a regularizacao deve ser iniciada dentro desse prazo e isso e feito ja no Brasil.',
          es: 'Con el DNI podes quedarte en Brasil hasta 90 dias como turista. Para vivir de forma regular, la regularizacion debe iniciarse dentro de ese plazo y se hace ya en Brasil.',
          en: 'With your DNI, you can stay in Brazil for up to 90 days as a tourist. To live there regularly, you need to start regularization within that period, and that happens after arrival in Brazil.',
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
          pt: '30 min · gratuito',
          es: '30 min · gratis',
          en: '30 min · free',
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
          pt: 'Residencia pelo Acordo Mercosul',
          es: 'Residencia por el Acuerdo Mercosur',
          en: 'Residence under the Mercosur Agreement',
        ),
        description: _text(
          l10n,
          pt: 'Argentinos podem pedir residencia no Brasil pelo Acordo Mercosul. O protocolo precisa acontecer dentro do prazo de 90 dias, e o registro RNM/CRNM depois aparece como etapa separada.',
          es: 'Los argentinos pueden pedir residencia en Brasil por el Acuerdo Mercosur. El tramite debe entrar dentro del plazo de 90 dias y el registro RNM/CRNM aparece despues como etapa separada.',
          en: 'Argentine citizens can apply for residence in Brazil under the Mercosur Agreement. The filing must happen within the 90-day period, and RNM/CRNM registration appears later as a separate step.',
        ),
        timeEstimate: _text(
          l10n,
          pt: '1 a 2 dias para protocolar',
          es: '1 a 2 dias para iniciar',
          en: '1 to 2 days to file',
        ),
        tip: _text(
          l10n,
          pt: 'Em cidades com fila, agendar cedo ajuda. Mas o ponto central e nao deixar o protocolo para a reta final dos 90 dias.',
          es: 'En ciudades con cola, agendar temprano ayuda. Pero el punto central es no dejar el tramite para la recta final de los 90 dias.',
          en: 'In cities with long queues, booking early helps. But the key point is not leaving the filing to the final stretch of the 90 days.',
        ),
        link:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia-resolucao-mercosul',
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
