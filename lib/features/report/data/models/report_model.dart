import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nahriva/features/report/domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.userId,
    required super.wasteType,
    required super.description,
    required super.photoUrl,
    required super.location,
    required super.address,
    required super.timestamp,
    super.status,
    super.trustScore,
    super.upvotes,
    super.votes,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final votesRaw = data['votes'] as Map<String, dynamic>? ?? {};
    final votes = votesRaw.map((k, v) => MapEntry(k, (v as num).toInt()));

    return ReportModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      wasteType: data['wasteType'] as String? ?? 'other',
      description: data['description'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      address: data['address'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      trustScore: data['trustScore'] as int? ?? 0,
      upvotes: (data['upvotes'] as List<dynamic>?)?.cast<String>() ?? [],
      votes: votes,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'wasteType': wasteType,
      'description': description,
      'photoUrl': photoUrl,
      'location': location,
      'address': address,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'trustScore': trustScore,
      'upvotes': upvotes,
      'votes': votes,
    };
  }
}
