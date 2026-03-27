import 'package:flutter/foundation.dart';

import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';
import 'package:movaro_app/features/city_insights/domain/repositories/city_insight_repository.dart';

class CityInsightController extends ChangeNotifier {
  CityInsightController({required CityInsightRepository repository})
    : _repository = repository;

  final CityInsightRepository _repository;
  static const int initialVisibleCount = 2;

  List<CityInsightEntity> _items = const [];
  bool _isLoading = false;
  Object? _error;
  String? _activeKey;
  int _visibleCount = initialVisibleCount;
  Future<void>? _pendingRequest;

  List<CityInsightEntity> get items => _items;
  List<CityInsightEntity> get visibleItems =>
      _items.take(_visibleCount).toList(growable: false);
  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get hasMore => _items.length > _visibleCount;
  bool get hasItems => _items.isNotEmpty;

  Future<void> load({
    required String cityId,
    String? goal,
    String? timeline,
    required String locale,
    bool forceRefresh = false,
  }) async {
    final requestKey = [
      cityId,
      goal ?? 'none',
      timeline ?? 'none',
      locale,
    ].join('::');
    if (!forceRefresh && _activeKey == requestKey && _items.isNotEmpty) {
      return;
    }

    final pendingRequest = _pendingRequest;
    if (pendingRequest != null && _activeKey == requestKey && !forceRefresh) {
      return pendingRequest;
    }

    _activeKey = requestKey;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final request = _performLoad(
      cityId: cityId,
      goal: goal,
      timeline: timeline,
      locale: locale,
      forceRefresh: forceRefresh,
    );
    _pendingRequest = request;
    await request;
  }

  Future<void> _performLoad({
    required String cityId,
    String? goal,
    String? timeline,
    required String locale,
    required bool forceRefresh,
  }) async {
    try {
      final items = await _repository.getCityInsights(
        cityId: cityId,
        goal: goal,
        timeline: timeline,
        locale: locale,
        forceRefresh: forceRefresh,
      );
      _items = items;
      _visibleCount = items.length < initialVisibleCount
          ? items.length
          : initialVisibleCount;
    } catch (error) {
      _error = error;
      _items = const [];
      _visibleCount = initialVisibleCount;
    } finally {
      _isLoading = false;
      _pendingRequest = null;
      notifyListeners();
    }
  }

  Future<void> refresh({
    required String cityId,
    String? goal,
    String? timeline,
    required String locale,
  }) {
    return load(
      cityId: cityId,
      goal: goal,
      timeline: timeline,
      locale: locale,
      forceRefresh: true,
    );
  }

  void showMore() {
    if (!hasMore) {
      return;
    }
    _visibleCount = _items.length;
    notifyListeners();
  }

  void clear() {
    _items = const [];
    _error = null;
    _isLoading = false;
    _activeKey = null;
    _visibleCount = initialVisibleCount;
    notifyListeners();
  }

  Future<List<CityInsightExplorePlaceEntity>> getExplorePlaces({
    required String cityId,
    required CityInsightTheme theme,
    required String locale,
    String? seedPlace,
    bool forceRefresh = false,
  }) {
    return _repository.getExplorePlaces(
      cityId: cityId,
      theme: theme,
      locale: locale,
      seedPlace: seedPlace,
      forceRefresh: forceRefresh,
    );
  }
}
