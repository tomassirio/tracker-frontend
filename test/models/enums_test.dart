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
        expect(TripStatus.created.toJson(), 'PLANNED');
        expect(TripStatus.in_progress.toJson(), 'IN_PROGRESS');
        expect(TripStatus.paused.toJson(), 'PAUSED');
        expect(TripStatus.finished.toJson(), 'FINISHED');
      });

      test('fromJson parses TripStatus from string correctly', () {
        expect(TripStatus.fromJson('PLANNED'), TripStatus.created);
        expect(TripStatus.fromJson('IN_PROGRESS'), TripStatus.in_progress);
        expect(TripStatus.fromJson('PAUSED'), TripStatus.paused);
        expect(TripStatus.fromJson('FINISHED'), TripStatus.finished);
      });

      test('fromJson is case-insensitive', () {
        expect(TripStatus.fromJson('created'), TripStatus.created);
        expect(TripStatus.fromJson('In_progress'), TripStatus.in_progress);
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
