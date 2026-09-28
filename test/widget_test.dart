import 'package:flutter_test/flutter_test.dart';
import 'package:interview/models/post_model.dart';
import 'package:interview/models/employee_model.dart';
import 'package:interview/provider/user_provider.dart';
import 'package:interview/services/api_service.dart';

class MockApiService extends ApiService {
  final List<PostModel> mockPosts;

  MockApiService({this.mockPosts = const []});

  @override
  Future<List<PostModel>> fetchPosts() async {
    return List.from(mockPosts);
  }

  @override
  Future<PostModel> createPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    return PostModel(
      id: 101,
      userId: userId,
      title: title,
      body: body,
    );
  }

  @override
  Future<PostModel> updatePost({
    required int id,
    required String title,
    required String body,
    int userId = 1,
  }) async {
    return PostModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
    );
  }

  @override
  Future<bool> deletePost(int id) async {
    return true;
  }
}

void main() {
  group('PostModel Tests', () {
    test('fromJson and toJson work correctly', () {
      final json = {
        'id': 1,
        'userId': 2,
        'title': 'Test Title',
        'body': 'Test Body',
      };

      final post = PostModel.fromJson(json);
      expect(post.id, 1);
      expect(post.userId, 2);
      expect(post.title, 'Test Title');
      expect(post.body, 'Test Body');

      final serialized = post.toJson();
      expect(serialized['id'], 1);
      expect(serialized['title'], 'Test Title');
      expect(serialized['body'], 'Test Body');
    });
  });

  group('Employee Model Tests', () {
    test('fromMap and toMap work correctly', () {
      final map = {
        'id': 10,
        'name': 'John Doe',
        'number': '1234567890',
        'email': 'john@example.com',
      };

      final employee = Employee.fromMap(map);
      expect(employee.id, 10);
      expect(employee.name, 'John Doe');
      expect(employee.number, '1234567890');
      expect(employee.email, 'john@example.com');

      final serialized = employee.toMap();
      expect(serialized['id'], 10);
      expect(serialized['name'], 'John Doe');
      expect(serialized['number'], '1234567890');
      expect(serialized['email'], 'john@example.com');
    });
  });

  group('UserProvider State Tests', () {
    test('fetchPosts populates posts', () async {
      final mock = MockApiService(
        mockPosts: [
          const PostModel(id: 1, title: 'Post 1', body: 'Body 1'),
          const PostModel(id: 2, title: 'Post 2', body: 'Body 2'),
        ],
      );

      final provider = UserProvider(apiService: mock);
      expect(provider.posts, isEmpty);

      await provider.fetchPosts();
      expect(provider.posts.length, 2);
      expect(provider.posts.first.title, 'Post 1');
      expect(provider.isLoading, isFalse);
    });

    test('createPost inserts new post at top', () async {
      final mock = MockApiService(
        mockPosts: [
          const PostModel(id: 1, title: 'Old Post', body: 'Old Body'),
        ],
      );

      final provider = UserProvider(apiService: mock);
      await provider.fetchPosts();

      final success = await provider.createPost(
        title: 'New Created Post',
        body: 'New Body',
      );

      expect(success, isTrue);
      expect(provider.posts.length, 2);
      expect(provider.posts.first.id, 101);
      expect(provider.posts.first.title, 'New Created Post');
    });

    test('updatePost updates existing post in list', () async {
      final mock = MockApiService(
        mockPosts: [
          const PostModel(id: 1, title: 'Initial Title', body: 'Initial Body'),
        ],
      );

      final provider = UserProvider(apiService: mock);
      await provider.fetchPosts();

      final success = await provider.updatePost(
        id: 1,
        title: 'Updated Title',
        body: 'Updated Body',
      );

      expect(success, isTrue);
      expect(provider.posts.first.title, 'Updated Title');
      expect(provider.posts.first.body, 'Updated Body');
    });

    test('deletePost removes post from list', () async {
      final mock = MockApiService(
        mockPosts: [
          const PostModel(id: 1, title: 'To Delete', body: 'Body'),
          const PostModel(id: 2, title: 'Keep', body: 'Body'),
        ],
      );

      final provider = UserProvider(apiService: mock);
      await provider.fetchPosts();

      final success = await provider.deletePost(1);
      expect(success, isTrue);
      expect(provider.posts.length, 1);
      expect(provider.posts.first.id, 2);
    });
  });
}
