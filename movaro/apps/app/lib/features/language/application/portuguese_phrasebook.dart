import 'package:flutter/material.dart';

/// A practical Portuguese phrase the user can say, with a translation in their
/// own language and a short note on when to use it. Portuguese is the #1 pain
/// for Argentine migrants — this turns "survival phrases" into a browsable,
/// situation-based phrasebook for bureaucracy and everyday life.
class PortuguesePhrase {
  const PortuguesePhrase({
    required this.pt,
    required this.es,
    required this.en,
    this.notePt,
    this.noteEs,
    this.noteEn,
  });

  /// The phrase to say, always in Portuguese.
  final String pt;

  /// Translations for understanding.
  final String es;
  final String en;

  /// Optional "when/why to use it" note.
  final String? notePt;
  final String? noteEs;
  final String? noteEn;

  String translation(String locale) {
    final l = locale.toLowerCase();
    if (l.startsWith('es')) return es;
    if (l.startsWith('en')) return en;
    return pt;
  }

  String? note(String locale) {
    final l = locale.toLowerCase();
    if (l.startsWith('es')) return noteEs;
    if (l.startsWith('en')) return noteEn;
    return notePt;
  }
}

class PhraseGroup {
  const PhraseGroup({
    required this.key,
    required this.icon,
    required this.titlePt,
    required this.titleEs,
    required this.titleEn,
    required this.phrases,
  });

  final String key;
  final IconData icon;
  final String titlePt;
  final String titleEs;
  final String titleEn;
  final List<PortuguesePhrase> phrases;

  String title(String locale) {
    final l = locale.toLowerCase();
    if (l.startsWith('es')) return titleEs;
    if (l.startsWith('en')) return titleEn;
    return titlePt;
  }
}

/// Curated, situation-based Portuguese phrasebook for the Argentina → Brazil
/// journey. Pure data so it can be unit-tested and rendered offline.
class PortuguesePhrasebook {
  const PortuguesePhrasebook._();

  static const List<PhraseGroup> groups = [
    PhraseGroup(
      key: 'documents',
      icon: Icons.badge_outlined,
      titlePt: 'Documentos e Polícia Federal',
      titleEs: 'Documentos y Policía Federal',
      titleEn: 'Documents & Federal Police',
      phrases: [
        PortuguesePhrase(
          pt: 'Preciso agendar o registro da minha residência.',
          es: 'Necesito agendar el registro de mi residencia.',
          en: 'I need to schedule my residency registration.',
          noteEs: 'En la Polícia Federal, para la residencia Mercosur.',
          noteEn: 'At the Federal Police, for Mercosur residency.',
          notePt: 'Na Polícia Federal, para a residência Mercosul.',
        ),
        PortuguesePhrase(
          pt: 'Onde eu tiro o CPF?',
          es: '¿Dónde saco el CPF?',
          en: 'Where do I get my CPF?',
        ),
        PortuguesePhrase(
          pt: 'Quais documentos eu preciso levar?',
          es: '¿Qué documentos tengo que llevar?',
          en: 'Which documents do I need to bring?',
        ),
        PortuguesePhrase(
          pt: 'Pode me dar o número do protocolo, por favor?',
          es: '¿Me puede dar el número de protocolo, por favor?',
          en: 'Can you give me the protocol number, please?',
        ),
      ],
    ),
    PhraseGroup(
      key: 'bank',
      icon: Icons.account_balance_outlined,
      titlePt: 'Banco',
      titleEs: 'Banco',
      titleEn: 'Bank',
      phrases: [
        PortuguesePhrase(
          pt: 'Quero abrir uma conta, por favor.',
          es: 'Quiero abrir una cuenta, por favor.',
          en: 'I would like to open an account, please.',
        ),
        PortuguesePhrase(
          pt: 'Sou estrangeiro, tenho CPF mas ainda não tenho comprovante de endereço.',
          es: 'Soy extranjero, tengo CPF pero todavía no tengo comprobante de domicilio.',
          en: 'I am a foreigner, I have a CPF but not yet a proof of address.',
        ),
        PortuguesePhrase(
          pt: 'Como eu ativo o Pix?',
          es: '¿Cómo activo el Pix?',
          en: 'How do I activate Pix?',
          noteEs: 'Pix es el sistema de pagos instantáneos de Brasil.',
          noteEn: 'Pix is Brazil’s instant payment system.',
          notePt: 'Pix é o sistema de pagamentos instantâneos do Brasil.',
        ),
      ],
    ),
    PhraseGroup(
      key: 'rental',
      icon: Icons.home_outlined,
      titlePt: 'Aluguel e moradia',
      titleEs: 'Alquiler y vivienda',
      titleEn: 'Rent & housing',
      phrases: [
        PortuguesePhrase(
          pt: 'Estou procurando um apartamento para alugar.',
          es: 'Estoy buscando un departamento para alquilar.',
          en: 'I am looking for an apartment to rent.',
        ),
        PortuguesePhrase(
          pt: 'Preciso de fiador? Tem opção com seguro-fiança?',
          es: '¿Necesito garante? ¿Hay opción con seguro de alquiler?',
          en: 'Do I need a guarantor? Is there a rental-insurance option?',
        ),
        PortuguesePhrase(
          pt: 'Qual é o valor do aluguel e do condomínio?',
          es: '¿Cuánto es el alquiler y las expensas?',
          en: 'How much is the rent and the building fee?',
        ),
      ],
    ),
    PhraseGroup(
      key: 'health',
      icon: Icons.local_hospital_outlined,
      titlePt: 'Saúde e SUS',
      titleEs: 'Salud y SUS',
      titleEn: 'Health & SUS',
      phrases: [
        PortuguesePhrase(
          pt: 'Quero tirar o Cartão SUS.',
          es: 'Quiero sacar la tarjeta del SUS.',
          en: 'I want to get my SUS card.',
          noteEs: 'El SUS es el sistema de salud público y gratuito.',
          noteEn: 'SUS is the free public health system.',
          notePt: 'O SUS é o sistema público de saúde, gratuito.',
        ),
        PortuguesePhrase(
          pt: 'Onde fica o posto de saúde mais próximo?',
          es: '¿Dónde queda el centro de salud más cercano?',
          en: 'Where is the nearest health clinic?',
        ),
        PortuguesePhrase(
          pt: 'Estou me sentindo mal, preciso de um médico.',
          es: 'Me siento mal, necesito un médico.',
          en: 'I am feeling unwell, I need a doctor.',
        ),
      ],
    ),
    PhraseGroup(
      key: 'work',
      icon: Icons.work_outline,
      titlePt: 'Trabalho e entrevista',
      titleEs: 'Trabajo y entrevista',
      titleEn: 'Work & interview',
      phrases: [
        PortuguesePhrase(
          pt: 'Estou procurando emprego na minha área.',
          es: 'Estoy buscando trabajo en mi área.',
          en: 'I am looking for a job in my field.',
        ),
        PortuguesePhrase(
          pt: 'Já tenho CPF e posso trabalhar legalmente.',
          es: 'Ya tengo CPF y puedo trabajar legalmente.',
          en: 'I already have a CPF and can work legally.',
        ),
        PortuguesePhrase(
          pt: 'Tenho experiência e aprendo rápido.',
          es: 'Tengo experiencia y aprendo rápido.',
          en: 'I have experience and learn fast.',
        ),
      ],
    ),
    PhraseGroup(
      key: 'everyday',
      icon: Icons.chat_bubble_outline,
      titlePt: 'Dia a dia',
      titleEs: 'Día a día',
      titleEn: 'Everyday',
      phrases: [
        PortuguesePhrase(
          pt: 'Quanto custa?',
          es: '¿Cuánto cuesta?',
          en: 'How much is it?',
        ),
        PortuguesePhrase(
          pt: 'Pode falar mais devagar, por favor?',
          es: '¿Puede hablar más despacio, por favor?',
          en: 'Can you speak more slowly, please?',
        ),
        PortuguesePhrase(
          pt: 'Não entendi, pode repetir?',
          es: 'No entendí, ¿puede repetir?',
          en: 'I didn’t understand, can you repeat?',
        ),
        PortuguesePhrase(
          pt: 'Onde fica o ponto de ônibus?',
          es: '¿Dónde está la parada de colectivo?',
          en: 'Where is the bus stop?',
        ),
      ],
    ),
  ];
}
