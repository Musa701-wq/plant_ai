// lib/services/search_repository.dart

import '../model/search_model.dart';
import '../services/search_api_service.dart';

class SearchRepository {
  final SearchApiService apiService;

  SearchRepository(this.apiService);

  /// Search plants by name (using Pexels API search endpoint)
  Future<List<SearchModel>> searchPlants(String query, {int page = 1}) async {
    final data = await apiService.searchPlants(query, page: page);

    if (data['photos'] != null) {
      return (data['photos'] as List)
          .map((item) => SearchModel.fromJson(item))
          .toList();
    } else {
      return [];
    }
  }

  /// Get plants by category (trees, herbs, flowers, etc.)
  Future<List<SearchModel>> getPlantsByCategory(String category,
      {int page = 1}) async {
    final data = await apiService.getPlantsByCategory(category, page: page);

    if (data['photos'] != null) {
      return (data['photos'] as List)
          .map((item) => SearchModel.fromJson(item))
          .toList();
    } else {
      return [];
    }
  }
}
