enum CoverageStatus {
  full,
  partial,
  unsupported;

  static CoverageStatus fromJson(String? value) {
    return switch (value) {
      'full' => CoverageStatus.full,
      'partial' => CoverageStatus.partial,
      _ => CoverageStatus.unsupported,
    };
  }

  String toJson() => name;
}

class CountryCoverage {
  const CountryCoverage({
    required this.originStatus,
    required this.destinationStatus,
    this.publicContentStatus = CoverageStatus.partial,
    this.supportedDestinationIds = const <String>[],
  });

  final CoverageStatus originStatus;
  final CoverageStatus destinationStatus;
  final CoverageStatus publicContentStatus;
  final List<String> supportedDestinationIds;

  bool get canChooseAsOrigin => originStatus != CoverageStatus.unsupported;
  bool get canChooseAsDestination =>
      destinationStatus != CoverageStatus.unsupported;
  bool get canPlanAsOrigin => originStatus == CoverageStatus.full;
  bool get canPlanAsDestination => destinationStatus == CoverageStatus.full;
  bool get hasPublicContent =>
      publicContentStatus != CoverageStatus.unsupported;

  bool supportsDestination(String destinationCountryId) {
    return supportedDestinationIds.contains(destinationCountryId);
  }

  Map<String, dynamic> toJson() => {
    'originStatus': originStatus.toJson(),
    'destinationStatus': destinationStatus.toJson(),
    'publicContentStatus': publicContentStatus.toJson(),
    'supportedDestinationIds': supportedDestinationIds,
  };
}
