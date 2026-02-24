import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/services/admin_service.dart';
import 'package:tracker_frontend/data/client/clients.dart';

void main() {
  group('AdminService', () {
    late MockTripCommandClient mockTripCommandClient;
    late AdminService adminService;

    setUp(() {
      mockTripCommandClient = MockTripCommandClient();
      adminService = AdminService(tripCommandClient: mockTripCommandClient);
    });

    group('deleteTrip', () {
      test('deletes trip successfully', () async {
        await adminService.deleteTrip('trip-123');

        expect(mockTripCommandClient.deleteTripCalled, true);
        expect(mockTripCommandClient.lastTripId, 'trip-123');
      });

      test('passes through errors when deleting trip', () async {
        mockTripCommandClient.shouldThrowError = true;

        expect(() => adminService.deleteTrip('trip-123'), throwsException);
      });

      test('handles unauthorized errors', () async {
        mockTripCommandClient.errorMessage = 'Unauthorized';
        mockTripCommandClient.shouldThrowError = true;

        expect(
          () => adminService.deleteTrip('trip-123'),
          throwsA(predicate((e) => e.toString().contains('Unauthorized'))),
        );
      });

      test('handles not found errors', () async {
        mockTripCommandClient.errorMessage = 'Trip not found';
        mockTripCommandClient.shouldThrowError = true;

        expect(
          () => adminService.deleteTrip('nonexistent-trip'),
          throwsA(predicate((e) => e.toString().contains('not found'))),
        );
      });
    });

    group('User management', () {
      late MockAdminCommandClient mockAdminCommandClient;
      late MockAdminQueryClient mockAdminQueryClient;
      late AdminService serviceWithAdmin;

      setUp(() {
        mockAdminCommandClient = MockAdminCommandClient();
        mockAdminQueryClient = MockAdminQueryClient();
        serviceWithAdmin = AdminService(
          tripCommandClient: mockTripCommandClient,
          adminCommandClient: mockAdminCommandClient,
          adminQueryClient: mockAdminQueryClient,
        );
      });

      group('promoteUserToAdmin', () {
        test('promotes user successfully', () async {
          await serviceWithAdmin.promoteUserToAdmin('user-123');

          expect(mockAdminCommandClient.promoteToAdminCalled, true);
          expect(mockAdminCommandClient.lastUserId, 'user-123');
        });

        test('passes through errors when promoting user', () async {
          mockAdminCommandClient.shouldThrowError = true;
          mockAdminCommandClient.errorMessage = 'User already has admin role';

          expect(
            () => serviceWithAdmin.promoteUserToAdmin('user-123'),
            throwsException,
          );
        });
      });

      group('demoteUserFromAdmin', () {
        test('demotes user successfully', () async {
          await serviceWithAdmin.demoteUserFromAdmin('user-456');

          expect(mockAdminCommandClient.demoteFromAdminCalled, true);
          expect(mockAdminCommandClient.lastUserId, 'user-456');
        });

        test('passes through errors when demoting user', () async {
          mockAdminCommandClient.shouldThrowError = true;
          mockAdminCommandClient.errorMessage = 'User does not have admin role';

          expect(
            () => serviceWithAdmin.demoteUserFromAdmin('user-456'),
            throwsException,
          );
        });
      });

      group('getUserRoles', () {
        test('returns list of roles', () async {
          mockAdminQueryClient.rolesResponse = ['USER', 'ADMIN'];

          final roles = await serviceWithAdmin.getUserRoles('user-123');

          expect(roles, ['USER', 'ADMIN']);
          expect(mockAdminQueryClient.getUserRolesCalled, true);
          expect(mockAdminQueryClient.lastUserId, 'user-123');
        });

        test('returns single role', () async {
          mockAdminQueryClient.rolesResponse = ['USER'];

          final roles = await serviceWithAdmin.getUserRoles('user-456');

          expect(roles, ['USER']);
          expect(roles.length, 1);
        });

        test('passes through errors when getting roles', () async {
          mockAdminQueryClient.shouldThrowError = true;

          expect(
            () => serviceWithAdmin.getUserRoles('user-123'),
            throwsException,
          );
        });
      });

      group('deleteUser', () {
        test('deletes user successfully', () async {
          await serviceWithAdmin.deleteUser('user-789');

          expect(mockAdminCommandClient.deleteUserCalled, true);
          expect(mockAdminCommandClient.lastUserId, 'user-789');
        });

        test('passes through errors when deleting user', () async {
          mockAdminCommandClient.shouldThrowError = true;
          mockAdminCommandClient.errorMessage = 'Cannot delete last admin';

          expect(
            () => serviceWithAdmin.deleteUser('user-789'),
            throwsA(
                predicate((e) => e.toString().contains('Cannot delete last'))),
          );
        });

        test('handles not found errors', () async {
          mockAdminCommandClient.shouldThrowError = true;
          mockAdminCommandClient.errorMessage = 'User not found';

          expect(
            () => serviceWithAdmin.deleteUser('nonexistent'),
            throwsA(predicate((e) => e.toString().contains('not found'))),
          );
        });
      });
    });

    group('AdminService initialization', () {
      test('creates with provided client', () {
        final tripClient = MockTripCommandClient();
        final service = AdminService(tripCommandClient: tripClient);

        expect(service, isNotNull);
      });

      test('creates with default client when not provided', () {
        final service = AdminService();

        expect(service, isNotNull);
      });

      test('creates with admin command client', () {
        final adminClient = MockAdminCommandClient();
        final service = AdminService(adminCommandClient: adminClient);

        expect(service, isNotNull);
      });

      test('creates with admin query client', () {
        final adminQueryClient = MockAdminQueryClient();
        final service = AdminService(adminQueryClient: adminQueryClient);

        expect(service, isNotNull);
      });
    });
  });
}

// Mock TripCommandClient
class MockTripCommandClient extends TripCommandClient {
  bool deleteTripCalled = false;
  String? lastTripId;
  bool shouldThrowError = false;
  String errorMessage = 'Trip command failed';

  @override
  Future<String> deleteTrip(String tripId) async {
    deleteTripCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return tripId;
  }
}

// Mock AdminCommandClient
class MockAdminCommandClient extends AdminCommandClient {
  bool promoteToAdminCalled = false;
  bool demoteFromAdminCalled = false;
  bool deleteUserCalled = false;
  String? lastUserId;
  bool shouldThrowError = false;
  String errorMessage = 'Admin command failed';

  @override
  Future<void> promoteToAdmin(String userId) async {
    promoteToAdminCalled = true;
    lastUserId = userId;
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> demoteFromAdmin(String userId) async {
    demoteFromAdminCalled = true;
    lastUserId = userId;
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    deleteUserCalled = true;
    lastUserId = userId;
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }
}

// Mock AdminQueryClient
class MockAdminQueryClient extends AdminQueryClient {
  bool getUserRolesCalled = false;
  String? lastUserId;
  bool shouldThrowError = false;
  String errorMessage = 'Admin query failed';
  List<String> rolesResponse = ['USER'];

  @override
  Future<List<String>> getUserRoles(String userId) async {
    getUserRolesCalled = true;
    lastUserId = userId;
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return rolesResponse;
  }
}

// Mock CommentCommandClient (kept for potential future use)
class MockCommentCommandClient extends CommentCommandClient {
  bool shouldThrowError = false;
  String errorMessage = 'Comment command failed';
}
