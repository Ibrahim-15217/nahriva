import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nahriva/features/auth/data/models/user_model.dart';
import 'package:nahriva/features/report/data/datasources/report_remote_data_source.dart';
import 'package:nahriva/features/report/data/models/report_model.dart';
import 'package:nahriva/features/report/domain/entities/report_entity.dart';
import 'package:nahriva/features/report/domain/repositories/report_repository.dart';
import 'package:nahriva/features/report/domain/services/trust_score_service.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _dataSource;
  final FirebaseFirestore _firestore;

  ReportRepositoryImpl(this._dataSource) : _firestore = FirebaseFirestore.instance;

  @override
  Future<void> submitReport(ReportEntity report, String photoPath) async {
    final photoUrl = await _dataSource.uploadPhoto(report.id, photoPath);
    final model = ReportModel(
      id: report.id,
      userId: report.userId,
      wasteType: report.wasteType,
      description: report.description,
      photoUrl: photoUrl,
      location: report.location,
      address: report.address,
      timestamp: report.timestamp,
      status: 'pending',
      trustScore: 50,
      upvotes: [],
      votes: {},
    );
    await _dataSource.createReport(model);
  }

  @override
  Future<ReportEntity?> getReportById(String id) async {
    return await _dataSource.getReport(id);
  }

  @override
  Stream<List<ReportEntity>> get reportsStream {
    return _dataSource.getReportsStream().map(
      (models) => models.map((m) => m as ReportEntity).toList(),
    );
  }

  @override
  Future<List<ReportEntity>> getReports() async {
    final snapshot = await _dataSource.getReportsStream().first;
    return snapshot.map((m) => m as ReportEntity).toList();
  }

  @override
  Future<void> voteReport(String reportId, String userId, int voteValue) async {
    final report = await _dataSource.getReport(reportId);
    if (report == null) return;

    final updatedVotes = Map<String, int>.from(report.votes);
    final currentVote = updatedVotes[userId];

    if (currentVote == voteValue) {
      updatedVotes.remove(userId);
    } else {
      updatedVotes[userId] = voteValue;
    }

    final voterReputation = await _getVoterReputation(updatedVotes.keys.toList());
    final trustScore = TrustScoreService.calculateTrustScore(
      votes: updatedVotes,
      voterReputation: voterReputation,
    );
    final status = TrustScoreService.determineStatus(trustScore);

    final updatedUpvotes = updatedVotes.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();

    await _dataSource.updateReport(reportId, {
      'votes': updatedVotes,
      'upvotes': updatedUpvotes,
      'trustScore': trustScore,
      'status': status,
    });

    if (status == 'verified' || status == 'resolved') {
      await _awardPointsToReporter(report.userId, status);
    }
  }

  Future<Map<String, int>> _getVoterReputation(List<String> uids) async {
    final result = <String, int>{};
    if (uids.isEmpty) return result;

    final snapshots = await Future.wait(
      uids.map((uid) => _firestore.collection('users').doc(uid).get()),
    );

    for (final doc in snapshots) {
      if (doc.exists) {
        final user = UserModel.fromFirestore(doc);
        result[user.uid] = user.points;
      }
    }
    return result;
  }

  Future<void> _awardPointsToReporter(String reporterUid, String status) async {
    final doc = await _firestore.collection('users').doc(reporterUid).get();
    if (!doc.exists) return;

    final user = UserModel.fromFirestore(doc);
    final points = status == 'resolved' ? 50 : 20;

    await _firestore.collection('users').doc(reporterUid).update({
      'points': user.points + points,
    });

    await _firestore.collection('users').doc(reporterUid).collection('notifications').add({
      'title': status == 'resolved' ? 'Report Resolved' : 'Report Verified',
      'body': status == 'resolved'
          ? 'Your report has been resolved! You earned 50 GreenPoints.'
          : 'Your report has been verified! You earned 20 GreenPoints.',
      'type': status == 'resolved' ? 'report_resolved' : 'report_verified',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
