import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/info/application/guide_toolkit_engine.dart';
import 'package:movaro_app/features/info/domain/entities/guide_toolkit.dart';

void main() {
  const engine = GuideToolkitEngine();

  test('financial path only returns missing unlocks in safe order', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.finance,
      answers: const {'cpf', 'phone'},
    );

    expect(result.actionIds.first, 'finance_address_proof');
    expect(result.actionIds, isNot(contains('finance_get_cpf')));
    expect(result.actionIds, isNot(contains('finance_get_phone')));
    expect(result.actionIds.last, 'finance_strengthen_govbr');
  });

  test('arrival reserve separates monthly, entry and protected period', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.costs,
      answers: const {'reserve90', 'deposit'},
      amounts: const {
        'rent': 2000,
        'housingFees': 500,
        'living': 2500,
        'travel': 1000,
        'setup': 1500,
        'months': 3,
        'guaranteeMonths': 3,
      },
    );

    expect(result.monthlyTotal, 5000);
    expect(result.entryTotal, 8500);
    expect(result.reserveTotal, 23500);
  });

  test('tax tool always remains a professional screening', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.tax,
      answers: const {'foreignIncome', 'foreignAssets'},
    );

    expect(result.requiresProfessional, isTrue);
    expect(result.status, 'professional_review');
    expect(result.actionIds, contains('tax_find_cross_border_accountant'));
  });

  test('work path distinguishes CPF from work authorization', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.work,
      answers: const {'cpf', 'clt'},
    );

    expect(result.status, 'documents_pending');
    expect(result.actionIds, contains('work_confirm_status'));
    expect(result.actionIds, contains('work_enable_ctps'));
  });

  test('health path prioritizes emergency and preserves continuous care', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.health,
      answers: const {
        'emergency',
        'continuousMedication',
        'controlledMedication',
      },
    );

    expect(result.status, 'urgent_referral');
    expect(result.actionIds.first, 'health_emergency_channel');
    expect(result.actionIds, contains('health_book_local_care'));
    expect(result.requiresProfessional, isTrue);
  });

  test('pet and customs path separates pet, medicine and baggage checks', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.petsCustoms,
      answers: const {'dogCat', 'medicines', 'householdGoods'},
    );

    expect(result.actionIds, contains('moving_pet_cvi'));
    expect(result.actionIds, contains('moving_medicine_documents'));
    expect(result.actionIds, contains('moving_baggage_route'));
    expect(result.actionIds.last, 'moving_declare_uncertain');
  });

  test('utilities path flags a previous occupant debt separately', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.utilities,
      answers: const {'energy', 'previousDebt'},
    );

    expect(result.actionIds, contains('utilities_energy'));
    expect(result.actionIds, contains('utilities_previous_debt'));
    expect(result.actionIds.last, 'utilities_keep_protocol');
  });

  test('protection path puts immediate safety before documentation', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.protection,
      answers: const {'urgent', 'legalAid'},
    );

    expect(result.status, 'urgent_referral');
    expect(result.actionIds.first, 'protection_emergency');
    expect(result.actionIds.last, 'protection_preserve_evidence');
  });

  test('consumer path protects accounts before general escalation', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.consumer,
      answers: const {'bank', 'fraud'},
    );

    expect(result.status, 'protect_first');
    expect(result.actionIds, contains('consumer_fraud_response'));
    expect(result.actionIds, contains('consumer_escalate'));
  });

  test('long-term path keeps pension records and naturalization distinct', () {
    final result = engine.evaluate(
      kind: GuideToolkitKind.longTerm,
      answers: const {'argentinaContributions', 'retirement', 'naturalization'},
    );

    expect(result.requiresProfessional, isTrue);
    expect(result.actionIds, contains('longterm_argentina_records'));
    expect(result.actionIds, contains('longterm_agreement'));
    expect(result.actionIds, contains('longterm_naturalization_type'));
  });
}
