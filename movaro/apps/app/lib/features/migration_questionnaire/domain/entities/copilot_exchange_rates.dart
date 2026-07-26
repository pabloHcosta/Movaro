class CopilotExchangeRates {
  const CopilotExchangeRates({
    required this.usdToBrl,
    required this.brlToUsd,
    required this.brlToArs,
    required this.arsToBrl,
    required this.usdToArs,
    required this.arsToUsd,
    required this.brlToEur,
    required this.brlToClp,
    required this.brlToUyu,
    required this.brlToCop,
    required this.brlToPen,
    required this.brlToPyg,
    required this.brlToBob,
    required this.fetchedAt,
    required this.source,
    required this.sources,
    this.referenceDate,
    this.isIndicative = true,
  });

  final double usdToBrl;
  final double brlToUsd;
  final double brlToArs;
  final double arsToBrl;
  final double usdToArs;
  final double arsToUsd;

  /// BRL to other currencies
  final double brlToEur;
  final double brlToClp;
  final double brlToUyu;
  final double brlToCop;
  final double brlToPen;
  final double brlToPyg;
  final double brlToBob;

  final String fetchedAt;
  final String source;
  final List<String> sources;
  final String? referenceDate;
  final bool isIndicative;

  bool get hasValidRates {
    final values = <double>[
      usdToBrl,
      brlToUsd,
      brlToArs,
      arsToBrl,
      usdToArs,
      arsToUsd,
      brlToEur,
      brlToClp,
      brlToUyu,
      brlToCop,
      brlToPen,
      brlToPyg,
      brlToBob,
    ];
    return values.every((value) => value.isFinite && value > 0);
  }

  bool isFresh({
    DateTime? now,
    Duration maxFetchAge = const Duration(hours: 96),
    Duration maxReferenceAge = const Duration(days: 8),
  }) {
    if (!hasValidRates) return false;
    final effectiveNow = now ?? DateTime.now();
    final fetched = DateTime.tryParse(fetchedAt);
    if (fetched == null ||
        effectiveNow.difference(fetched.toLocal()) > maxFetchAge ||
        fetched.toLocal().isAfter(effectiveNow.add(const Duration(hours: 1)))) {
      return false;
    }
    final reference = DateTime.tryParse(referenceDate ?? '');
    if (reference == null ||
        effectiveNow.difference(reference.toLocal()) > maxReferenceAge ||
        reference.toLocal().isAfter(
          effectiveNow.add(const Duration(hours: 1)),
        )) {
      return false;
    }
    return true;
  }
}
