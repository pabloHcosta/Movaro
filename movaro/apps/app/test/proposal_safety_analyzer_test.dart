import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/safety_check/domain/proposal_safety_analyzer.dart';

void main() {
  group('ProposalSafetyAnalyzer', () {
    test('stops a housing flow with advance PIX and no viewing', () {
      final result = ProposalSafetyAnalyzer.analyze(
        kind: ProposalKind.housing,
        content:
            'O proprietário está no exterior. Para reservar, faça um PIX antecipado e as chaves chegam depois do pagamento.',
      );

      expect(result.level, ProposalSafetyLevel.stopAndVerify);
      expect(
        result.signals.map((signal) => signal.code),
        containsAll(<ProposalSafetySignalCode>[
          ProposalSafetySignalCode.advancePayment,
          ProposalSafetySignalCode.housingWithoutVerification,
        ]),
      );
    });

    test('recognizes a fake job fee in Spanish', () {
      final result = ProposalSafetyAnalyzer.analyze(
        kind: ProposalKind.job,
        content:
            'El puesto está garantizado. Paga el curso y una tasa de inscripción para comenzar.',
      );

      expect(result.level, ProposalSafetyLevel.stopAndVerify);
      expect(
        result.signals.map((signal) => signal.code),
        contains(ProposalSafetySignalCode.jobFee),
      );
    });

    test('recognizes natural English housing pressure and payment', () {
      final result = ProposalSafetyAnalyzer.analyze(
        kind: ProposalKind.housing,
        content:
            'The owner is abroad. Send a PIX advance payment before viewing and decide now or lose the apartment.',
      );

      expect(result.level, ProposalSafetyLevel.stopAndVerify);
      expect(
        result.signals.map((signal) => signal.code),
        containsAll(<ProposalSafetySignalCode>[
          ProposalSafetySignalCode.advancePayment,
          ProposalSafetySignalCode.pressure,
          ProposalSafetySignalCode.housingWithoutVerification,
        ]),
      );
    });

    test('treats a gov.br password request as critical', () {
      final result = ProposalSafetyAnalyzer.analyze(
        kind: ProposalKind.publicService,
        content:
            'Envie sua senha do gov.br e o código de verificação recebido por SMS.',
      );

      expect(result.level, ProposalSafetyLevel.stopAndVerify);
      expect(
        result.signals.map((signal) => signal.code),
        contains(ProposalSafetySignalCode.credentialRequest),
      );
    });

    test('uses caution for pressure without a critical pattern', () {
      final result = ProposalSafetyAnalyzer.analyze(
        kind: ProposalKind.housing,
        content: 'Última chance, decida agora para não perder a oportunidade.',
      );

      expect(result.level, ProposalSafetyLevel.caution);
      expect(result.signals, hasLength(1));
    });

    test('never invents a signal for a neutral contract review', () {
      final result = ProposalSafetyAnalyzer.analyze(
        kind: ProposalKind.housing,
        content:
            'Podemos marcar uma visita amanhã. Depois envio o contrato para você revisar.',
      );

      expect(result.level, ProposalSafetyLevel.noStrongSignal);
      expect(result.signals, isEmpty);
    });
  });
}
