enum GuideToolkitKind {
  finance,
  costs,
  housing,
  work,
  tax,
  family,
  dependencies,
  health,
  petsCustoms,
  utilities,
  protection,
  consumer,
  longTerm,
}

class GuideToolkitRequest {
  const GuideToolkitRequest({required this.kind});

  final GuideToolkitKind kind;
}

class GuideToolkitResult {
  const GuideToolkitResult({
    required this.status,
    required this.actionIds,
    this.monthlyTotal,
    this.entryTotal,
    this.reserveTotal,
    this.requiresProfessional = false,
  });

  final String status;
  final List<String> actionIds;
  final double? monthlyTotal;
  final double? entryTotal;
  final double? reserveTotal;
  final bool requiresProfessional;
}
