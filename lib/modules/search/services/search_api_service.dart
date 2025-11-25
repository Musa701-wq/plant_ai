// lib/services/pexels/search_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchApiService {
  final Dio _dio;
  String pexelsKey = dotenv.env['PEXELS_API_KEY'] ?? "NOT_FOUND";


  SearchApiService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://api.pexels.com/v1/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Authorization':dotenv.env['PEXELS_API_KEY'] ?? "NOT_FOUND"
          },
        ),
      );

  /// Search plants by query (name)
  Future<Map<String, dynamic>> searchPlants(String query,
      {int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get(
        'search',
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': perPage,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Get plants by category (using query = category)
  Future<Map<String, dynamic>> getPlantsByCategory(
      String category, {
        int page = 1,
        int perPage = 200,
      }) async {
    try {
      final response = await _dio.get(
        'search',
        queryParameters: {
          'query': category,
          'page': page,
          'per_page': perPage,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Example: Get curated plant images (optional general feed)
  Future<Map<String, dynamic>> getCuratedPlants(
      {int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get(
        'curated',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return "Connection timeout, please try again.";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return "Receive timeout, please try again.";
    } else if (e.response != null) {
      return "Error: ${e.response?.statusCode} - ${e.response?.statusMessage}";
    } else {
      return "Unexpected error: ${e.message}";
    }
  }
}
