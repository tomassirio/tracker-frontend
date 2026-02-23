/// Request to promote a trip
class PromoteTripRequest {
  final String? donationLink;

  PromoteTripRequest({this.donationLink});

  Map<String, dynamic> toJson() => {
        if (donationLink != null && donationLink!.isNotEmpty)
          'donationLink': donationLink,
      };
}
