class UiErrorState {
  const UiErrorState({
    required this.title,
    required this.description,
    required this.illustrationAsset,
    this.isRetryable = true,
  });

  final String title;
  final String description;
  final String illustrationAsset;
  final bool isRetryable;
}
