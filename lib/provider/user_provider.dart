import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService;

  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  UserProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<PostModel> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _apiService.fetchPosts();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String title,
    required String body,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPost = await _apiService.createPost(
        title: title,
        body: body,
      );

      // Place newly created post at the top of the list
      _posts.insert(0, newPost);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error creating post: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost({
    required int id,
    required String title,
    required String body,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedPost = await _apiService.updatePost(
        id: id,
        title: title,
        body: body,
      );

      final index = _posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating post: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(int id) async {
    try {
      final success = await _apiService.deletePost(id);
      if (success) {
        _posts.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error deleting post: $e');
      notifyListeners();
      return false;
    }
  }
}
