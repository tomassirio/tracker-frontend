/// Request to update a trip promotion
class UpdatePromotionRequest {
  final String? donationLink;

  UpdatePromotionRequest({this.donationLink});

  Map<String, dynamic> toJson() => {
        if (donationLink != null && donationLink!.isNotEmpty)
          'donationLink': donationLink,
      };
}
