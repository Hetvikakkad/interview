
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interview/models/UserResponseModel.dart';

class UserProvider with ChangeNotifier {
  List<UserList> _posts = [];
  bool _isLoading = false;

  List<UserList> get posts => _posts;
  bool get isLoading => _isLoading;

  final String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _posts = data
            .map((json) => UserList.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load posts: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> updatePut(
      int id,
      String newTitle,
      String newBody,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': id,
          'title': newTitle,
          'body': newBody,
        }),
      );

      if (response.statusCode == 200) {
        // Find existing post
        final int index = _posts.indexWhere(
              (post) => post.id == id,
        );

        if (index != -1) {
          // Remove old position
          final UserList updatedPost = UserList(
            id: id,
            title: newTitle,
            body: newBody,
          );

          _posts.removeAt(index);
          _posts.insert(0, updatedPost);

          notifyListeners();
        }

        return true;
      }

      debugPrint(
        'Update failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Error updating data: $e');
    }

    return false;
  }

  Future<bool> updatePost(
      int id,
      String newTitle,
      String newBody,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': newTitle,
          'body': newBody,
          'userId': 1,
        }),
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final int index = _posts.indexWhere(
              (post) => post.id == id,
        );

        if (index != -1) {
          final UserList updatedPost = UserList(
            id: id,
            title: newTitle,
            body: newBody,
          );

          // Remove old item
          _posts.removeAt(index);

          // Move updated item to first position
          _posts.insert(0, updatedPost);

          notifyListeners();
        }

        return true;
      }

      debugPrint(
        'Update failed: ${response.statusCode}',
      );

      return false;
    } catch (e) {
      debugPrint('Error updating data: $e');
      return false;
    }
  }


  Future<bool> deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
      );

      print(response);

      if (response.statusCode == 200) {
        _posts.removeWhere(
              (post) => post.id == id,
        );

        notifyListeners();

        return true;
      }

      debugPrint(
        'Delete failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Error deleting data: $e');
    }

    return false;
  }
}