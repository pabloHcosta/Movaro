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
}
