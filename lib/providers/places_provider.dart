import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/place_model.dart';
import '../data/models/menu_item_model.dart';
import '../core/services/location_service.dart';
import 'app_providers.dart';

// ─── User Location State ──────────────────────────────────────────────────────
class UserLocationNotifier extends StateNotifier<AsyncValue<UserLocation>> {
  UserLocationNotifier() : super(const AsyncValue.loading()) {
    refreshLocation();
  }

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    try {
      final loc = await LocationService.determinePosition();
      state = AsyncValue.data(loc);
    } catch (_) {
      state = const AsyncValue.data(UserLocation.defaultLocation);
    }
  }
}

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, AsyncValue<UserLocation>>((ref) {
  return UserLocationNotifier();
});

// ─── Filter State ─────────────────────────────────────────────────────────────
class PlaceFilterState {
  final String query;
  final String category;
  final int? minPrice;
  final int? maxPrice;
  final String sortBy; // 'recommended', 'nearest', 'price_asc', 'price_desc', 'rating'

  const PlaceFilterState({
    this.query = '',
    this.category = 'Semua',
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'recommended',
  });

  bool get hasActiveFilter =>
      category != 'Semua' || minPrice != null || maxPrice != null || sortBy != 'recommended';

  PlaceFilterState copyWith({
    String? query,
    String? category,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
    bool clearBudget = false,
  }) {
    return PlaceFilterState(
      query: query ?? this.query,
      category: category ?? this.category,
      minPrice: clearBudget ? null : (minPrice ?? this.minPrice),
      maxPrice: clearBudget ? null : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class PlaceFilterNotifier extends StateNotifier<PlaceFilterState> {
  PlaceFilterNotifier() : super(const PlaceFilterState());

  void setQuery(String q) {
    state = state.copyWith(query: q);
  }

  void setCategory(String cat) {
    state = state.copyWith(category: cat);
  }

  void setBudget(int? min, int? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void clearBudget() {
    state = state.copyWith(clearBudget: true);
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  void resetFilters() {
    state = const PlaceFilterState();
  }
}

final placeFilterProvider =
    StateNotifierProvider<PlaceFilterNotifier, PlaceFilterState>((ref) {
  return PlaceFilterNotifier();
});

// ─── Places List filtered by current filter state & location ──────────────────
final placesListProvider = FutureProvider<List<PlaceModel>>((ref) async {
  final filter = ref.watch(placeFilterProvider);
  final repo = ref.watch(placeRepositoryProvider);
  final locationAsync = ref.watch(userLocationProvider);
  final location = locationAsync.valueOrNull ?? UserLocation.defaultLocation;

  return repo.getPlaces(
    query: filter.query,
    category: filter.category,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    sortBy: filter.sortBy,
    userLat: location.latitude,
    userLng: location.longitude,
  );
});

// ─── Nearest Places (For Home recommendation) ─────────────────────────────────
final nearestPlacesProvider = FutureProvider<List<PlaceModel>>((ref) async {
  final repo = ref.watch(placeRepositoryProvider);
  final locationAsync = ref.watch(userLocationProvider);
  final location = locationAsync.valueOrNull ?? UserLocation.defaultLocation;

  return repo.getPlaces(
    sortBy: 'nearest',
    userLat: location.latitude,
    userLng: location.longitude,
  );
});

// ─── Single Place Detail ──────────────────────────────────────────────────────
final placeDetailProvider =
    FutureProvider.family<PlaceModel?, String>((ref, id) async {
  final repo = ref.watch(placeRepositoryProvider);
  final locationAsync = ref.watch(userLocationProvider);
  final location = locationAsync.valueOrNull ?? UserLocation.defaultLocation;

  return repo.getPlaceById(id, userLat: location.latitude, userLng: location.longitude);
});

// ─── Menu items for a place ───────────────────────────────────────────────────
final placeMenuProvider =
    FutureProvider.family<List<MenuItemModel>, String>((ref, placeId) async {
  final repo = ref.watch(placeRepositoryProvider);
  return repo.getMenuItems(placeId);
});
