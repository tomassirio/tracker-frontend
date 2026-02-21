import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

void main() {
  group('TripPromotionModels', () {
    group('TripPromotion', () {
      test('fromJson creates TripPromotion from JSON', () {
        final json = {
          'tripId': 'trip123',
          'donationLink': 'https://buymeacoffee.com/user',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-02T00:00:00.000Z',
        };

        final promotion = TripPromotion.fromJson(json);

        expect(promotion.tripId, 'trip123');
        expect(promotion.donationLink, 'https://buymeacoffee.com/user');
        expect(promotion.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
        expect(promotion.updatedAt, DateTime.parse('2024-01-02T00:00:00.000Z'));
      });

      test('fromJson handles null donation link', () {
        final json = {
          'tripId': 'trip123',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-02T00:00:00.000Z',
        };

        final promotion = TripPromotion.fromJson(json);

        expect(promotion.tripId, 'trip123');
        expect(promotion.donationLink, null);
      });

      test('toJson converts TripPromotion correctly', () {
        final promotion = TripPromotion(
          tripId: 'trip123',
          donationLink: 'https://buymeacoffee.com/user',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );

        final json = promotion.toJson();

        expect(json['tripId'], 'trip123');
        expect(json['donationLink'], 'https://buymeacoffee.com/user');
        expect(json['createdAt'], '2024-01-01T00:00:00.000Z');
        expect(json['updatedAt'], '2024-01-02T00:00:00.000Z');
      });

      test('toJson excludes null donation link', () {
        final promotion = TripPromotion(
          tripId: 'trip123',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );

        final json = promotion.toJson();

        expect(json.containsKey('donationLink'), false);
      });
    });

    group('PromotedTrip', () {
      test('fromJson creates PromotedTrip from JSON', () {
        final json = {
          'tripId': 'trip123',
          'tripName': 'Amazing Journey',
          'userId': 'user456',
          'username': 'johndoe',
          'donationLink': 'https://buymeacoffee.com/johndoe',
          'promotedAt': '2024-01-01T00:00:00.000Z',
        };

        final promotedTrip = PromotedTrip.fromJson(json);

        expect(promotedTrip.tripId, 'trip123');
        expect(promotedTrip.tripName, 'Amazing Journey');
        expect(promotedTrip.userId, 'user456');
        expect(promotedTrip.username, 'johndoe');
        expect(promotedTrip.donationLink, 'https://buymeacoffee.com/johndoe');
        expect(promotedTrip.promotedAt,
            DateTime.parse('2024-01-01T00:00:00.000Z'));
      });

      test('fromJson handles null donation link', () {
        final json = {
          'tripId': 'trip123',
          'tripName': 'Amazing Journey',
          'userId': 'user456',
          'username': 'johndoe',
          'promotedAt': '2024-01-01T00:00:00.000Z',
        };

        final promotedTrip = PromotedTrip.fromJson(json);

        expect(promotedTrip.donationLink, null);
      });

      test('toJson converts PromotedTrip correctly', () {
        final promotedTrip = PromotedTrip(
          tripId: 'trip123',
          tripName: 'Amazing Journey',
          userId: 'user456',
          username: 'johndoe',
          donationLink: 'https://buymeacoffee.com/johndoe',
          promotedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        final json = promotedTrip.toJson();

        expect(json['tripId'], 'trip123');
        expect(json['tripName'], 'Amazing Journey');
        expect(json['userId'], 'user456');
        expect(json['username'], 'johndoe');
        expect(json['donationLink'], 'https://buymeacoffee.com/johndoe');
        expect(json['promotedAt'], '2024-01-01T00:00:00.000Z');
      });

      test('toJson excludes null donation link', () {
        final promotedTrip = PromotedTrip(
          tripId: 'trip123',
          tripName: 'Amazing Journey',
          userId: 'user456',
          username: 'johndoe',
          promotedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        final json = promotedTrip.toJson();

        expect(json.containsKey('donationLink'), false);
      });
    });

    group('PromoteTripRequest', () {
      test('toJson with donation link', () {
        final request = PromoteTripRequest(
          donationLink: 'https://buymeacoffee.com/user',
        );

        final json = request.toJson();

        expect(json['donationLink'], 'https://buymeacoffee.com/user');
      });

      test('toJson without donation link', () {
        final request = PromoteTripRequest();

        final json = request.toJson();

        expect(json.containsKey('donationLink'), false);
      });

      test('toJson with empty donation link', () {
        final request = PromoteTripRequest(donationLink: '');

        final json = request.toJson();

        expect(json.containsKey('donationLink'), false);
      });
    });

    group('UpdatePromotionRequest', () {
      test('toJson with donation link', () {
        final request = UpdatePromotionRequest(
          donationLink: 'https://buymeacoffee.com/user',
        );

        final json = request.toJson();

        expect(json['donationLink'], 'https://buymeacoffee.com/user');
      });

      test('toJson without donation link', () {
        final request = UpdatePromotionRequest();

        final json = request.toJson();

        expect(json.containsKey('donationLink'), false);
      });

      test('toJson with empty donation link', () {
        final request = UpdatePromotionRequest(donationLink: '');

        final json = request.toJson();

        expect(json.containsKey('donationLink'), false);
      });
    });
  });
}
