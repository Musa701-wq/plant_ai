import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import '../provider/search_provider.dart';
import 'keyword_helper.dart';

/// 🌍 Master keyword list for global search
final List<String> allPlantKeywords = [
  ...treeNames,
  ...flowerNames,
  ...herbNames,
  ...succulentNames,
  ...cactusNames,
  ...indoorPlantNames,
];

void handleSearch(BuildContext context, String query) {
  final provider = context.read<SearchProvider>();
  if (query.trim().isEmpty) return;

  final lowerQuery = query.toLowerCase();

  // ✅ Exact match check
  final matched = allPlantKeywords.firstWhere(
        (keyword) => keyword.toLowerCase() == lowerQuery,
    orElse: () => "",
  );

  if (matched.isNotEmpty) {
    provider.searchPlants(matched);
    return;
  }

  // ❌ Not found → use bestMatch
  final similarity = StringSimilarity.findBestMatch(
    lowerQuery,
    allPlantKeywords.map((e) => e.toLowerCase()).toList(),
  );

  final bestMatch = similarity.bestMatch;
  if (bestMatch.rating! > 0.4) {
    final suggestion = allPlantKeywords.firstWhere(
          (k) => k.toLowerCase() == bestMatch.target,
      orElse: () => "",
    );

    if (suggestion.isNotEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Did you mean: $suggestion?"),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: "Search",
            onPressed: () {
              provider.searchPlants(suggestion);
            },
          ),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ No related plants found."),
        backgroundColor: Colors.red,
      ),
    );
  }
}
