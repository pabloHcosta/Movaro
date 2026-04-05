import 'package:flutter/material.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class UruguayBrazilGuideDataSource {
  const UruguayBrazilGuideDataSource._();

  static bool isUruguayToBrazil(String origin, String destination) {
    final o = origin.toUpperCase();
    final d = destination.toUpperCase();
    return (o == 'URUGUAY' || o == 'URUGUAI' || o == 'UY') &&
        (d == 'BRAZIL' || d == 'BR' || d == 'BRASIL');
  }

  static List<GuideActionItem> build(
    MigrationPlan plan, {
    LocationData? currentLocation,
    String? localeCode,
    CopilotExchangeRates? exchangeRates,
  }) {
    final locale = _locale(localeCode);
    return <GuideActionItem>[
      GuideActionItem(
        id: 'uybr_prep_travel_document',
        title: _t(
          locale,
          pt: 'Fechar o documento de entrada para mudança',
          es: 'Cerrar el documento de entrada para la mudanza',
          en: 'Lock the entry document for the move',
        ),
        shortDescription: _t(
          locale,
          pt: 'Para mudança, trate a viagem como não turística e confirme o documento aceito antes de embarcar.',
          es: 'Para mudanza, tratá el viaje como no turístico y confirmá el documento aceptado antes de viajar.',
          en: 'For relocation, treat the trip as non-tourism and confirm the accepted travel document before departure.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.preparation,
        orderIndex: 0,
        isCompleted: false,
        icon: Icons.badge_outlined,
        context: _t(
          locale,
          pt: 'O ponto crítico aqui não é turismo de fim de semana, e sim entrada coerente com residência, estudo ou trabalho.',
          es: 'El punto crítico acá no es turismo de fin de semana, sino una entrada coherente con residencia, estudio o trabajo.',
          en: 'The critical point here is not weekend tourism, but entry aligned with residence, study, or work.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Entrar com a lógica errada atrasa toda a regularização posterior.',
          es: 'Entrar con la lógica equivocada retrasa toda la regularización posterior.',
          en: 'Entering with the wrong logic delays all later regularization.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver orientação da PF',
          es: 'Ver orientación de PF',
          en: 'See Federal Police guidance',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: 'https://www.gov.br/pf/pt-br/assuntos/imigracao',
        steps: _list(
          locale,
          pt: [
            'Confirme se sua viagem já é de mudança, estudo ou trabalho.',
            'Valide o documento de viagem aceito para a sua situação.',
            'Evite embarcar assumindo regra turística genérica.',
          ],
          es: [
            'Confirmá si tu viaje ya es de mudanza, estudio o trabajo.',
            'Validá el documento de viaje aceptado para tu situación.',
            'Evitá viajar asumiendo una regla turística genérica.',
          ],
          en: [
            'Confirm whether your trip is already relocation, study, or work.',
            'Validate the travel document accepted for your case.',
            'Do not board assuming a generic tourism rule.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '10 min',
          es: '10 min',
          en: '10 min',
        ),
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.urgent,
        urgencySignal: _t(
          locale,
          pt: 'Resolva isso antes da viagem para não contaminar o resto da rota migratória.',
          es: 'Resolvé esto antes del viaje para no contaminar el resto de la ruta migratoria.',
          en: 'Solve this before travel so it does not contaminate the rest of the migration route.',
        ),
      ),
      GuideActionItem(
        id: 'uybr_doc_residence',
        title: _t(
          locale,
          pt: 'Mapear a residência Mercosul',
          es: 'Mapear la residencia Mercosur',
          en: 'Map the Mercosur residence path',
        ),
        shortDescription: _t(
          locale,
          pt: 'Para uruguaios no Brasil, a residência Mercosul tende a ser a base de regularização.',
          es: 'Para personas uruguayas en Brasil, la residencia Mercosur suele ser la base de regularización.',
          en: 'For Uruguayans in Brazil, Mercosur residence usually becomes the regularization base.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.documents,
        orderIndex: 1,
        isCompleted: false,
        icon: Icons.account_balance_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Abrir acordo Mercosul',
          es: 'Abrir acuerdo Mercosur',
          en: 'Open Mercosur agreement guidance',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget:
            'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-para-nacionais-dos-estados-partes-do-mercosul-bolivia-e-chile',
        steps: _list(
          locale,
          pt: [
            'Entenda se sua permanência já exige base migratória regular.',
            'Separe a documentação civil e antecedentes que podem ser exigidos.',
            'Evite deixar o protocolo para o fim da janela inicial no Brasil.',
          ],
          es: [
            'Entendé si tu permanencia ya exige una base migratoria regular.',
            'Separá la documentación civil y antecedentes que pueden ser exigidos.',
            'Evitá dejar el trámite para el final de la ventana inicial en Brasil.',
          ],
          en: [
            'Understand whether your stay already requires a regular migration basis.',
            'Prepare civil documents and criminal records that may be required.',
            'Do not leave the filing for the end of the initial window in Brazil.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.medium,
        estimatedTimeLabel: _t(
          locale,
          pt: '30-60 min',
          es: '30-60 min',
          en: '30-60 min',
        ),
        urgencyLevel: GuideUrgencyLevel.watch,
      ),
      GuideActionItem(
        id: 'uybr_doc_cpf',
        title: _t(
          locale,
          pt: 'Planejar o CPF como primeiro destravador',
          es: 'Planear el CPF como primer desbloqueo',
          en: 'Plan CPF as the first unlock',
        ),
        shortDescription: _t(
          locale,
          pt: 'O CPF entra cedo porque destrava banco, aluguel, contratos e parte da operação prática no Brasil.',
          es: 'El CPF entra temprano porque desbloquea banco, alquiler, contratos y parte de la operación práctica en Brasil.',
          en: 'CPF comes early because it unlocks banking, rent, contracts, and part of the practical setup in Brazil.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.documents,
        orderIndex: 2,
        isCompleted: false,
        icon: Icons.receipt_long_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Abrir instruções da Receita',
          es: 'Abrir instrucciones de Receita',
          en: 'Open Receita instructions',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget:
            'https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/cpf/assuntos-relacionados/perguntas-e-respostas',
        steps: _list(
          locale,
          pt: [
            'Confira o canal certo para a sua situação migratória.',
            'Separe documento de identificação e comprovantes exigidos.',
            'Resolva isso antes de depender de banco ou aluguel estável.',
          ],
          es: [
            'Revisá el canal correcto para tu situación migratoria.',
            'Separá documento de identificación y comprobantes exigidos.',
            'Resolvé esto antes de depender de banco o alquiler estable.',
          ],
          en: [
            'Check the correct channel for your migration status.',
            'Prepare identification and required supporting documents.',
            'Solve this before depending on banking or stable rent.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '20 min',
          es: '20 min',
          en: '20 min',
        ),
        urgencyLevel: GuideUrgencyLevel.watch,
      ),
      GuideActionItem(
        id: 'uybr_housing_soft_landing',
        title: _t(
          locale,
          pt: 'Chegar com moradia temporária fechada',
          es: 'Llegar con vivienda temporal resuelta',
          en: 'Arrive with temporary housing booked',
        ),
        shortDescription: _t(
          locale,
          pt: 'Moradia temporária reduz o atrito até CPF, documentos e garantias estarem alinhados.',
          es: 'La vivienda temporal reduce el roce hasta que CPF, documentos y garantías estén alineados.',
          en: 'Temporary housing reduces friction until CPF, documents, and guarantees are aligned.',
        ),
        type: GuideActionType.informative,
        phase: GuidePhase.housing,
        orderIndex: 3,
        isCompleted: false,
        icon: Icons.home_work_outlined,
        steps: _list(
          locale,
          pt: [
            'Feche 2 a 6 semanas de moradia de chegada.',
            'Evite contrato longo antes de entender bairro e exigências.',
            'Guarde reserva para caução, garantia e instalação.',
          ],
          es: [
            'Cerrá 2 a 6 semanas de vivienda de llegada.',
            'Evitá un contrato largo antes de entender barrio y exigencias.',
            'Guardá reserva para depósito, garantía e instalación.',
          ],
          en: [
            'Book 2 to 6 weeks of arrival housing.',
            'Avoid a long contract before understanding neighborhood and requirements.',
            'Keep reserve for deposit, guarantees, and setup.',
          ],
        ),
        tips: _list(
          locale,
          pt: [
            'O maior bloqueio no começo costuma ser comprovação, não falta de imóvel.',
          ],
          es: [
            'El mayor bloqueo al principio suele ser la comprobación, no la falta de inmueble.',
          ],
          en: [
            'The biggest early blocker is usually proof, not property supply.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.medium,
        estimatedTimeLabel: _t(locale, pt: '1-2 h', es: '1-2 h', en: '1-2 h'),
      ),
      GuideActionItem(
        id: 'uybr_work_bank_account',
        title: _t(
          locale,
          pt: 'Abrir conta depois da base documental',
          es: 'Abrir cuenta después de la base documental',
          en: 'Open a bank account after the document base',
        ),
        shortDescription: _t(
          locale,
          pt: 'Banco entra melhor depois de CPF e de uma situação migratória mais coerente.',
          es: 'El banco encaja mejor después del CPF y de una situación migratoria más coherente.',
          en: 'Banking fits better after CPF and a more coherent migration status.',
        ),
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 4,
        isCompleted: false,
        icon: Icons.account_balance_outlined,
        whyItMatters: _t(
          locale,
          pt: 'Conta bancária normalmente vira dependência para salário, aluguel e rotina financeira.',
          es: 'La cuenta bancaria normalmente se vuelve dependencia para salario, alquiler y rutina financiera.',
          en: 'A bank account usually becomes a dependency for salary, rent, and daily finances.',
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '30 min',
          es: '30 min',
          en: '30 min',
        ),
      ),
      GuideActionItem(
        id: 'uybr_arrival_health',
        title: _t(
          locale,
          pt: 'Organizar sua porta de saúde logo na chegada',
          es: 'Organizar tu puerta de salud al llegar',
          en: 'Set up your health entry point after arrival',
        ),
        shortDescription: _t(
          locale,
          pt: 'SUS e rede local de atendimento devem entrar cedo na sua rotina de chegada.',
          es: 'SUS y la red local de atención deben entrar temprano en tu rutina de llegada.',
          en: 'SUS and the local care network should enter your arrival routine early.',
        ),
        type: GuideActionType.informative,
        phase: GuidePhase.arrival,
        orderIndex: 5,
        isCompleted: false,
        icon: Icons.local_hospital_outlined,
        steps: _list(
          locale,
          pt: [
            'Descubra a UBS ou ponto de atendimento do bairro.',
            'Assim que possível, alinhe CPF e comprovante de endereço.',
            'Não trate urgência como algo que depende de documentação perfeita.',
          ],
          es: [
            'Descubrí la UBS o punto de atención del barrio.',
            'Apenas sea posible, alineá CPF y comprobante de domicilio.',
            'No trates una urgencia como algo que dependa de documentación perfecta.',
          ],
          en: [
            'Find the neighborhood health unit or care point.',
            'As soon as possible, align CPF and proof of address.',
            'Do not treat urgent care as something that depends on perfect paperwork.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '20 min',
          es: '20 min',
          en: '20 min',
        ),
      ),
    ];
  }

  static String _locale(String? localeCode) {
    if (localeCode == 'es' || localeCode == 'en') {
      return localeCode!;
    }
    return 'pt';
  }

  static String _t(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (locale) {
      'es' => es,
      'en' => en,
      _ => pt,
    };
  }

  static List<String> _list(
    String locale, {
    required List<String> pt,
    required List<String> es,
    required List<String> en,
  }) {
    return switch (locale) {
      'es' => es,
      'en' => en,
      _ => pt,
    };
  }
}
