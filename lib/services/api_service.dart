import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/posts';
  static const Duration timeoutDuration = Duration(seconds: 10);
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await _client
          .get(Uri.parse(baseUrl))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          'Failed to load posts (Server returned ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<PostModel> createPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(baseUrl),
            headers: defaultHeaders,
            body: jsonEncode({
              'title': title,
              'body': body,
              'userId': userId,
            }),
          )
          .timeout(timeoutDuration);

      // JSONPlaceholder returns HTTP 201 Created on successful creation
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return PostModel.fromJson(data);
      } else {
        throw ApiException(
          'Failed to create post (Server returned ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<PostModel> updatePost({
    required int id,
    required String title,
    required String body,
    int userId = 1,
  }) async {
    // JSONPlaceholder only stores posts 1-100 on the server.
    // For client-created mock posts (id > 100), simulating the update locally prevents 500 error.
    if (id > 100) {
      return PostModel(id: id, userId: userId, title: title, body: body);
    }

    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/$id'),
            headers: defaultHeaders,
            body: jsonEncode({
              'id': id,
              'title': title,
              'body': body,
              'userId': userId,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return PostModel.fromJson(data);
      } else {
        throw ApiException(
          'Failed to update post (Server returned ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<bool> deletePost(int id) async {
    // For client-created mock posts (id > 100), return true directly
    if (id > 100) return true;

    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(
          'Failed to delete post (Server returned ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
}
