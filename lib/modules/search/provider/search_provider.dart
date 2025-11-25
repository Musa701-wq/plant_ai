// lib/modules/search/provider/search_provider.dart
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart'; // optional - used in scoring if you want tighter matching
import '../helper/all_plant_keyword.dart';
import '../model/search_model.dart';
import '../repo/search_repo.dart';
import '../helper/keyword_helper.dart'; // categoryKeywords
import '../helper/keyword_matcher.dart'; // extractShortName

class ProcessedPlant {
  final SearchModel raw;
  final String shortName;
  final double score;

  ProcessedPlant({
    required this.raw,
    required this.shortName,
    required this.score,
  });
}

class SearchProvider extends ChangeNotifier {
  final SearchRepository repository;

  SearchProvider(this.repository);

  static const int itemsPerPage = 20;
  static const int maxItems = 100;

  // raw API results (paginated)
  List<SearchModel> _rawResults = [];
  List<ProcessedPlant> _processedResults = [];

  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  // Caching per category
  final Map<String, List<SearchModel>> _cachedRawByCategory = {};
  final Map<String, List<ProcessedPlant>> _cachedProcessedByCategory = {};
  final Map<String, int> _cachedPageByCategory = {};


  List<SearchModel> get results => _rawResults;
  List<ProcessedPlant> get processedResults => _processedResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// Search plants (Pexels)
  Future<void> searchPlants(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return;
    _setLoading(true);

    try {
      final plants = await repository.searchPlants(query, page: page);

      if (page == 1) {
        _rawResults = plants;
      } else {
        _rawResults = [..._rawResults, ...plants];
      }

      _currentPage = page;
      _hasMore = plants.isNotEmpty;

      // For global search we may not have a single category. Use combined keywords fallback.
      // Use 'all' as a pseudo-category and fallback keyword list (allPlantKeywords from keyword_helper if available).
      _processedResults = _processAndDeduplicate(
        _rawResults,
        widgetCategory: null,
      );
    } catch (e) {
      _handleError("Failed to fetch plants: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch by category -> central processing/dedupe happens here
  Future<void> fetchByCategory(String category, {int page = 1}) async {
    if (_isLoading) return;

    final categoryKey = category.toLowerCase();

    // ✅ 1. Immediately clear visible results if we are loading fresh (page == 1)
    if (page == 1) {
      _rawResults = [];
      _processedResults = [];
      _errorMessage = null;
      _hasMore = true;
      notifyListeners();
    }

    // ✅ 2. Check cache first (only for first page)
    if (page == 1 && _cachedProcessedByCategory.containsKey(categoryKey)) {
      _rawResults = List<SearchModel>.from(_cachedRawByCategory[categoryKey]!);
      _processedResults =
      List<ProcessedPlant>.from(_cachedProcessedByCategory[categoryKey]!);
      _currentPage = _cachedPageByCategory[categoryKey] ?? 1;
      _isLoading = false;
      _hasMore = _processedResults.length < maxItems;
      notifyListeners();
      debugPrint("🟢 Loaded '${categoryKey}' plants from cache.");
      return;
    }

    _setLoading(true);
    try {
      final plants = await repository.getPlantsByCategory(category, page: page);

      if (page == 1) {
        _rawResults = plants;

        // reset processed
        _processedResults = _processAndDeduplicate(
          plants,
          widgetCategory: category,
        );
      } else {
        _rawResults = [..._rawResults, ...plants];

        // process only the new batch
        final newProcessed = _processAndDeduplicate(
          plants,
          widgetCategory: category,
        );

        // dedupe across pages by shortName
        final existingKeys = _processedResults
            .map((e) => e.shortName.toLowerCase())
            .toSet();

        final uniqueNew = newProcessed.where(
          (p) => !existingKeys.contains(p.shortName.toLowerCase()),
        );

        // append only unique new items → no reshuffle
        _processedResults.addAll(uniqueNew);
      }

      _currentPage = page;
      // stop when reached max or no more from API
      if (_processedResults.length >= maxItems || plants.isEmpty) {
        _hasMore = false;
      } else {
        _hasMore = plants.length >= itemsPerPage;
      }

      // ✅ 4. Cache results after successful fetch
      _cachedRawByCategory[categoryKey] = List<SearchModel>.from(_rawResults);
      _cachedProcessedByCategory[categoryKey] =
      List<ProcessedPlant>.from(_processedResults);
      _cachedPageByCategory[categoryKey] = _currentPage;
      debugPrint("💾 Cached '${categoryKey}' with ${_processedResults.length} plants.");
    } catch (e) {
      _handleError("Failed to load category: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Load more
  Future<void> loadMore({String? query, String? category}) async {
    if (!_hasMore || _isLoading) return;
    final nextPage = _currentPage + 1;
    if (query != null && query.isNotEmpty) {
      await searchPlants(query, page: nextPage);
    } else if (category != null && category.isNotEmpty) {
      await fetchByCategory(category, page: _currentPage + 1);
    }
  }

  void clearResults() {
    _rawResults = [];
    _processedResults = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear cache for all categories
  void clearAllCache() {
    _cachedRawByCategory.clear();
    _cachedProcessedByCategory.clear();
    _cachedPageByCategory.clear();
    debugPrint("🗑️ Cleared all category caches");
  }

  /// Clear cache for a specific category
  void clearCacheFor(String category) {
    final key = category.toLowerCase();
    _cachedRawByCategory.remove(key);
    _cachedProcessedByCategory.remove(key);
    _cachedPageByCategory.remove(key);
    debugPrint("🗑️ Cleared cache for '$key'");
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleError(String message) {
    _errorMessage = message;
    _rawResults = [];
    _processedResults = [];
    notifyListeners();
  }

  /// --- Core processing ---
  /// Turn raw API items into deduped ProcessedPlant list for the given category.
  /// If widgetCategory is null, we fallback to global keywords.
  List<ProcessedPlant> _processAndDeduplicate(
      List<SearchModel> items, {
        String? widgetCategory,
        int limit = maxItems,
      }) {
    final Map<String, ProcessedPlant> map = {};
    final categoryKey = (widgetCategory ?? "").toLowerCase();
    final categoryList = categoryKeywords[categoryKey] ?? allPlantKeywords;

    // --- Step 1: strict keyword matching ---
    for (final plant in items) {
      final alt = ((plant.commonName ?? "") + " " + (plant.description ?? ""))
          .trim()
          .toLowerCase();

      String matchedName = "";
      for (final kw in categoryList) {
        if (alt.contains(kw.toLowerCase())) {
          matchedName = kw; // exact dictionary name
          break;
        }
      }

      if (matchedName.isEmpty) continue;

      final score = _computeScore(alt, matchedName, plant, categoryList);
      final key = matchedName.toLowerCase();

      final existing = map[key];
      if (existing == null || score > existing.score) {
        map[key] = ProcessedPlant(raw: plant, shortName: matchedName, score: score);
      }
    }

    // --- Step 2: fallback mode if too few matches ---
    if (map.isEmpty || map.length < 10) {
      debugPrint("⚠️ Fallback triggered: using similarity scoring for ${items.length} items");

      for (final plant in items) {
        final alt = ((plant.commonName ?? "") + " " + (plant.description ?? ""))
            .trim()
            .toLowerCase();

        // compare with category keywords via string_similarity
        final similarity = StringSimilarity.findBestMatch(
          alt,
          categoryList.map((e) => e.toLowerCase()).toList(),
        );

        final bestMatch = similarity.bestMatch;
        if (bestMatch.rating != null && bestMatch.rating! > 0.35) {
          final suggestion = categoryList.firstWhere(
                (k) => k.toLowerCase() == bestMatch.target,
            orElse: () => "",
          );

          if (suggestion.isNotEmpty) {
            final score = _computeScore(alt, suggestion, plant, categoryList) +
                (bestMatch.rating! * 2.0); // small boost
            final key = suggestion.toLowerCase();

            final existing = map[key];
            if (existing == null || score > existing.score) {
              map[key] =
                  ProcessedPlant(raw: plant, shortName: suggestion, score: score);
            }
          }
        }
      }
    }

    // --- Step 3: sort & limit ---
    final list = map.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return list.length > limit ? list.sublist(0, limit) : list;
  }



  /// A small heuristic to prefer better candidates when duplicates exist.
  double _computeScore(
    String alt,
    String shortName,
    SearchModel plant,
    List<String> categoryList,
  ) {
    var score = 0.0;
    final altLower = alt.toLowerCase();
    final shortLower = shortName.toLowerCase();

    // direct contains = strong signal
    if (altLower.contains(shortLower)) score += 3.0;

    // token overlap
    final shortTokens = shortLower
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    for (final t in shortTokens) {
      if (altLower.contains(t)) score += 0.6;
    }

    // count of category keywords present (extra boost)
    int kwMatches = 0;
    for (final kw in categoryList) {
      if (kw.trim().isNotEmpty && altLower.contains(kw.toLowerCase()))
        kwMatches++;
    }
    score += kwMatches * 0.2;

    // prefer items with images
    if ((plant.imageUrl ?? "").isNotEmpty) score += 0.7;

    // length penalty: very generic shortName (1 token) gets slightly lower unless matched strongly
    if (shortTokens.length == 1) score *= 0.95;

    // As an optional improvement: incorporate string_similarity
    try {
      final sim = StringSimilarity.compareTwoStrings(shortLower, altLower);
      score += sim; // small contribution
    } catch (_) {

    }

    return score;
  }
}
