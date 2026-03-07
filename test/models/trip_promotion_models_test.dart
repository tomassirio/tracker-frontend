import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/data/models/trip_models.dart';

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
          'id': 'promo-1',
          'tripId': 'trip123',
          'tripName': 'Amazing Journey',
          'donationLink': 'https://buymeacoffee.com/johndoe',
          'promotedBy': 'admin-1',
          'promotedByUsername': 'admin_user',
          'tripOwnerId': 'user456',
          'tripOwnerUsername': 'johndoe',
          'promotedAt': '2024-01-01T00:00:00.000Z',
        };

        final promotedTrip = PromotedTrip.fromJson(json);

        expect(promotedTrip.id, 'promo-1');
        expect(promotedTrip.tripId, 'trip123');
        expect(promotedTrip.tripName, 'Amazing Journey');
        expect(promotedTrip.promotedBy, 'admin-1');
        expect(promotedTrip.promotedByUsername, 'admin_user');
        expect(promotedTrip.tripOwnerId, 'user456');
        expect(promotedTrip.tripOwnerUsername, 'johndoe');
        expect(promotedTrip.donationLink, 'https://buymeacoffee.com/johndoe');
        expect(promotedTrip.promotedAt,
            DateTime.parse('2024-01-01T00:00:00.000Z'));
        expect(promotedTrip.isPreAnnounced, false);
        expect(promotedTrip.countdownStartDate, null);
      });

      test('fromJson parses isPreAnnounced and countdownStartDate', () {
        final json = {
          'id': 'promo-2',
          'tripId': 'trip456',
          'tripName': 'Coming Soon Trip',
          'promotedBy': 'admin-1',
          'promotedByUsername': 'admin_user',
          'tripOwnerId': 'user789',
          'tripOwnerUsername': 'pilgrim',
          'promotedAt': '2024-01-01T00:00:00.000Z',
          'preAnnounced': true,
          'countdownStartDate': '2025-06-01T08:00:00.000Z',
        };

        final promotedTrip = PromotedTrip.fromJson(json);

        expect(promotedTrip.isPreAnnounced, true);
        expect(promotedTrip.countdownStartDate,
            DateTime.parse('2025-06-01T08:00:00.000Z'));
      });

      test('fromJson handles null donation link', () {
        final json = {
          'id': 'promo-1',
          'tripId': 'trip123',
          'tripName': 'Amazing Journey',
          'promotedBy': 'admin-1',
          'promotedByUsername': 'admin_user',
          'tripOwnerId': 'user456',
          'tripOwnerUsername': 'johndoe',
          'promotedAt': '2024-01-01T00:00:00.000Z',
        };

        final promotedTrip = PromotedTrip.fromJson(json);

        expect(promotedTrip.donationLink, null);
      });

      test('toJson converts PromotedTrip correctly', () {
        final promotedTrip = PromotedTrip(
          id: 'promo-1',
          tripId: 'trip123',
          tripName: 'Amazing Journey',
          donationLink: 'https://buymeacoffee.com/johndoe',
          promotedBy: 'admin-1',
          promotedByUsername: 'admin_user',
          tripOwnerId: 'user456',
          tripOwnerUsername: 'johndoe',
          promotedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        final json = promotedTrip.toJson();

        expect(json['id'], 'promo-1');
        expect(json['tripId'], 'trip123');
        expect(json['tripName'], 'Amazing Journey');
        expect(json['promotedBy'], 'admin-1');
        expect(json['promotedByUsername'], 'admin_user');
        expect(json['tripOwnerId'], 'user456');
        expect(json['tripOwnerUsername'], 'johndoe');
        expect(json['donationLink'], 'https://buymeacoffee.com/johndoe');
        expect(json['promotedAt'], '2024-01-01T00:00:00.000Z');
        expect(json['preAnnounced'], false);
        expect(json.containsKey('countdownStartDate'), false);
      });

      test('toJson includes countdownStartDate when pre-announced', () {
        final startDate = DateTime.parse('2025-06-01T08:00:00.000Z');
        final promotedTrip = PromotedTrip(
          id: 'promo-2',
          tripId: 'trip456',
          tripName: 'Coming Soon',
          promotedBy: 'admin-1',
          promotedByUsername: 'admin_user',
          tripOwnerId: 'user789',
          tripOwnerUsername: 'pilgrim',
          promotedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          isPreAnnounced: true,
          countdownStartDate: startDate,
        );

        final json = promotedTrip.toJson();

        expect(json['preAnnounced'], true);
        expect(json['countdownStartDate'], startDate.toIso8601String());
      });

      test('toJson excludes null donation link', () {
        final promotedTrip = PromotedTrip(
          id: 'promo-1',
          tripId: 'trip123',
          tripName: 'Amazing Journey',
          promotedBy: 'admin-1',
          promotedByUsername: 'admin_user',
          tripOwnerId: 'user456',
          tripOwnerUsername: 'johndoe',
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

      test('toJson with isPreAnnounced and countdownStartDate', () {
        final startDate = DateTime.parse('2025-06-01T08:00:00.000Z');
        final request = PromoteTripRequest(
          isPreAnnounced: true,
          countdownStartDate: startDate,
        );

        final json = request.toJson();

        expect(json['isPreAnnounced'], true);
        expect(json['countdownStartDate'],
            startDate.toUtc().toIso8601String());
      });

      test('toJson excludes countdownStartDate when null', () {
        final request = PromoteTripRequest(isPreAnnounced: false);

        final json = request.toJson();

        expect(json['isPreAnnounced'], false);
        expect(json.containsKey('countdownStartDate'), false);
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

      test('toJson with isPreAnnounced and countdownStartDate', () {
        final startDate = DateTime.parse('2025-09-15T00:00:00.000Z');
        final request = UpdatePromotionRequest(
          isPreAnnounced: true,
          countdownStartDate: startDate,
        );

        final json = request.toJson();

        expect(json['isPreAnnounced'], true);
        expect(json['countdownStartDate'],
            startDate.toUtc().toIso8601String());
      });

      test('toJson excludes countdownStartDate when null', () {
        final request = UpdatePromotionRequest(isPreAnnounced: false);

        final json = request.toJson();

        expect(json['isPreAnnounced'], false);
        expect(json.containsKey('countdownStartDate'), false);
      });
    });
  });
}
