import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/data/models/responses/page_response.dart';
import 'package:wanderer_frontend/data/models/user_models.dart';

void main() {
  group('PageResponse', () {
    test('fromJson creates PageResponse with content', () {
      final json = {
        'content': [
          {
            'id': 'user-1',
            'username': 'alice',
            'email': 'alice@example.com',
            'followersCount': 10,
            'followingCount': 5,
            'tripsCount': 3,
            'createdAt': '2024-01-15T10:30:00Z',
          },
          {
            'id': 'user-2',
            'username': 'bob',
            'email': 'bob@example.com',
            'followersCount': 20,
            'followingCount': 15,
            'tripsCount': 7,
            'createdAt': '2024-02-20T14:00:00Z',
          },
        ],
        'totalElements': 50,
        'totalPages': 3,
        'number': 0,
        'size': 20,
        'first': true,
        'last': false,
      };

      final page = PageResponse.fromJson(json, UserProfile.fromJson);

      expect(page.content.length, 2);
      expect(page.content[0].username, 'alice');
      expect(page.content[1].username, 'bob');
      expect(page.totalElements, 50);
      expect(page.totalPages, 3);
      expect(page.number, 0);
      expect(page.size, 20);
      expect(page.first, true);
      expect(page.last, false);
    });

    test('fromJson handles empty content', () {
      final json = {
        'content': [],
        'totalElements': 0,
        'totalPages': 0,
        'number': 0,
        'size': 20,
        'first': true,
        'last': true,
      };

      final page = PageResponse.fromJson(json, UserProfile.fromJson);

      expect(page.content, isEmpty);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
      expect(page.first, true);
      expect(page.last, true);
    });

    test('fromJson handles null content gracefully', () {
      final json = <String, dynamic>{
        'totalElements': 0,
        'totalPages': 0,
        'number': 0,
        'size': 20,
        'first': true,
        'last': true,
      };

      final page = PageResponse.fromJson(json, UserProfile.fromJson);

      expect(page.content, isEmpty);
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{
        'content': [],
      };

      final page = PageResponse.fromJson(json, UserProfile.fromJson);

      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
      expect(page.number, 0);
      expect(page.size, 20);
      expect(page.first, true);
      expect(page.last, true);
    });

    test('fromJson handles middle page correctly', () {
      final json = {
        'content': [
          {
            'id': 'user-3',
            'username': 'charlie',
            'email': 'charlie@example.com',
            'followersCount': 0,
            'followingCount': 0,
            'tripsCount': 0,
            'createdAt': '2024-03-01T09:00:00Z',
          },
        ],
        'totalElements': 50,
        'totalPages': 3,
        'number': 1,
        'size': 20,
        'first': false,
        'last': false,
      };

      final page = PageResponse.fromJson(json, UserProfile.fromJson);

      expect(page.number, 1);
      expect(page.first, false);
      expect(page.last, false);
      expect(page.content.length, 1);
      expect(page.content[0].username, 'charlie');
    });

    test('fromJson handles last page correctly', () {
      final json = {
        'content': [
          {
            'id': 'user-10',
            'username': 'zara',
            'email': 'zara@example.com',
            'followersCount': 5,
            'followingCount': 3,
            'tripsCount': 1,
            'createdAt': '2024-06-15T12:00:00Z',
          },
        ],
        'totalElements': 41,
        'totalPages': 3,
        'number': 2,
        'size': 20,
        'first': false,
        'last': true,
      };

      final page = PageResponse.fromJson(json, UserProfile.fromJson);

      expect(page.number, 2);
      expect(page.first, false);
      expect(page.last, true);
      expect(page.totalElements, 41);
    });
  });
}
