import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

void main() {
  group('Enums', () {
    group('Visibility', () {
      test('toJson converts Visibility to string correctly', () {
        expect(Visibility.private.toJson(), 'PRIVATE');
        expect(Visibility.protected.toJson(), 'PROTECTED');
        expect(Visibility.public.toJson(), 'PUBLIC');
      });

      test('fromJson parses Visibility from string correctly', () {
        expect(Visibility.fromJson('PRIVATE'), Visibility.private);
        expect(Visibility.fromJson('PROTECTED'), Visibility.protected);
        expect(Visibility.fromJson('PUBLIC'), Visibility.public);
      });

      test('fromJson is case-insensitive', () {
        expect(Visibility.fromJson('private'), Visibility.private);
        expect(Visibility.fromJson('Protected'), Visibility.protected);
        expect(Visibility.fromJson('public'), Visibility.public);
      });

      test('fromJson throws on invalid value', () {
        expect(
          () => Visibility.fromJson('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('TripStatus', () {
      test('toJson converts TripStatus to string correctly', () {
        expect(TripStatus.planned.toJson(), 'PLANNED');
        expect(TripStatus.ongoing.toJson(), 'ONGOING');
        expect(TripStatus.paused.toJson(), 'PAUSED');
        expect(TripStatus.finished.toJson(), 'FINISHED');
      });

      test('fromJson parses TripStatus from string correctly', () {
        expect(TripStatus.fromJson('PLANNED'), TripStatus.planned);
        expect(TripStatus.fromJson('ONGOING'), TripStatus.ongoing);
        expect(TripStatus.fromJson('PAUSED'), TripStatus.paused);
        expect(TripStatus.fromJson('FINISHED'), TripStatus.finished);
      });

      test('fromJson is case-insensitive', () {
        expect(TripStatus.fromJson('planned'), TripStatus.planned);
        expect(TripStatus.fromJson('Ongoing'), TripStatus.ongoing);
      });

      test('fromJson throws on invalid value', () {
        expect(
          () => TripStatus.fromJson('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
