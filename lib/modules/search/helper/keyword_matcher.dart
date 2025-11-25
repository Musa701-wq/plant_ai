import 'package:string_similarity/string_similarity.dart';

/// Common stop words & filler words often in Pexels captions
final Set<String> _stopWords = {
  'a','an','the','and','of','in','up','down','to','from','as','with','on','at','for','from','by','to',
  'photo','image','photograph','picture','photographer','stock',
  'beautiful','lovely','stunning','experience','tranquility','serenity',
  'nature','outdoors','outdoor','landscape','scenery','closeup','macro',
  'lush','green','sunlit','peaceful','detailed','view','stary','sky', 'looking', 'bike paths','walkaway'
};


String _normalize(String s) {
  var text = s.toLowerCase();
  // Remove non-letters and collapse spaces
  text = text.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

/// Improved short-name extractor
String extractShortName(String altText, List<String> categoryList) {
  if (altText.trim().isEmpty) return "";

  final normalized = _normalize(altText);
  if (normalized.isEmpty) return "";

  final tokens = normalized
      .split(" ")
      .where((t) => t.isNotEmpty && !_stopWords.contains(t))
      .toList();

  final keywordLowerList = categoryList.map((k) => k.toLowerCase()).toList();

  // 1️⃣ Direct contains (high confidence)
  for (final key in keywordLowerList) {
    if (normalized.contains(key)) {
      return categoryList.firstWhere((k) => k.toLowerCase() == key);
    }
  }

  // 2️⃣ Exact token match
  for (final t in tokens) {
    final idx = keywordLowerList.indexOf(t);
    if (idx != -1) return categoryList[idx];
  }

  // 3️⃣ Token fuzzy match (strict)
  double bestTokenScore = 0.0;
  String bestTokenMatch = "";
  for (final t in tokens) {
    final sim = StringSimilarity.findBestMatch(t, keywordLowerList);
    final bm = sim.bestMatch;
    if (bm.rating != null && bm.rating! > bestTokenScore) {
      bestTokenScore = bm.rating!;
      bestTokenMatch = bm.target ?? "";
    }
  }
  if (bestTokenScore >= 0.85 && bestTokenMatch.isNotEmpty) {
    return categoryList.firstWhere(
          (k) => k.toLowerCase() == bestTokenMatch,
      orElse: () => bestTokenMatch,
    );
  }

  // 4️⃣ Whole-sentence fuzzy match (looser)
  final simWhole = StringSimilarity.findBestMatch(normalized, keywordLowerList);
  if (simWhole.bestMatch.rating != null &&
      simWhole.bestMatch.rating! >= 0.6 &&
      simWhole.bestMatch.target != null) {
    return categoryList.firstWhere(
          (k) => k.toLowerCase() == simWhole.bestMatch.target,
      orElse: () => simWhole.bestMatch.target ?? "",
    );
  }

  // 5️⃣ Last fallback → first 2 tokens capitalized
  if (tokens.isNotEmpty) {
    if (tokens.length >= 2) {
      return "${tokens[0][0].toUpperCase()}${tokens[0].substring(1)} "
          "${tokens[1][0].toUpperCase()}${tokens[1].substring(1)}";
    }
    return tokens.first[0].toUpperCase() + tokens.first.substring(1);
  }

  return "";
}
