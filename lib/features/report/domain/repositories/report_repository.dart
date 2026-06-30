import 'package:nahriva/features/report/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<void> submitReport(ReportEntity report, String photoPath);
  Future<List<ReportEntity>> getReports();
  Future<ReportEntity?> getReportById(String id);
  Future<void> voteReport(String reportId, String userId, int voteValue);
  Stream<List<ReportEntity>> get reportsStream;
}
