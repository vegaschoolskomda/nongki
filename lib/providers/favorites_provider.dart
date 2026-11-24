import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/place_model.dart';
import 'app_providers.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({'plc_001', 'plc_004'});

  bool isFavorite(String placeId) => state.contains(placeId);

  void toggleFavorite(String placeId) {
    if (state.contains(placeId)) {
      state = Set.from(state)..remove(placeId);
    } else {
      state = Set.from(state)..add(placeId);
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

final favoritePlacesProvider = FutureProvider<List<PlaceModel>>((ref) async {
  final favoriteIds = ref.watch(favoritesProvider);
  final repo = ref.watch(placeRepositoryProvider);
  return repo.getFavorites(favoriteIds.toList());
});
