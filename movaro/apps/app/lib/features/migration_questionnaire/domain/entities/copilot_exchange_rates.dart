class CopilotExchangeRates {
  const CopilotExchangeRates({
    required this.usdToBrl,
    required this.brlToUsd,
    required this.brlToArs,
    required this.arsToBrl,
    required this.usdToArs,
    required this.arsToUsd,
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
  final String fetchedAt;
  final String source;
  final List<String> sources;
}
