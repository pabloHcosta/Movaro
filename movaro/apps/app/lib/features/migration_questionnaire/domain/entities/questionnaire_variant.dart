enum QuestionnaireVariant { lean, strategic }

extension QuestionnaireVariantX on QuestionnaireVariant {
  String get id => switch (this) {
    QuestionnaireVariant.lean => 'lean',
    QuestionnaireVariant.strategic => 'strategic',
  };

  static QuestionnaireVariant? fromId(String? value) {
    switch (value) {
      case 'lean':
        return QuestionnaireVariant.lean;
      case 'strategic':
        return QuestionnaireVariant.strategic;
      default:
        return null;
    }
  }
}
