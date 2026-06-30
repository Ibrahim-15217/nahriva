import 'package:cloud_firestore/cloud_firestore.dart';

class ReportEntity {
  final String id;
  final String userId;
  final String wasteType;
  final String description;
  final String photoUrl;
  final GeoPoint location;
  final String address;
  final DateTime timestamp;
  final String status;
  final int trustScore;
  final List<String> upvotes;
  final Map<String, int> votes;

  const ReportEntity({
    required this.id,
    required this.userId,
    required this.wasteType,
    required this.description,
    required this.photoUrl,
    required this.location,
    required this.address,
    required this.timestamp,
    this.status = 'pending',
    this.trustScore = 0,
    this.upvotes = const [],
    this.votes = const {},
  });

  ReportEntity copyWith({
    String? id,
    String? userId,
    String? wasteType,
    String? description,
    String? photoUrl,
    GeoPoint? location,
    String? address,
    DateTime? timestamp,
    String? status,
    int? trustScore,
    List<String>? upvotes,
    Map<String, int>? votes,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wasteType: wasteType ?? this.wasteType,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      trustScore: trustScore ?? this.trustScore,
      upvotes: upvotes ?? this.upvotes,
      votes: votes ?? this.votes,
    );
  }

  int get voteCount {
    int count = 0;
    for (final v in votes.values) {
      if (v > 0) count++;
    }
    return count;
  }
}
