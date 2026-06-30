import 'package:nahriva/features/report/domain/repositories/report_repository.dart';

class VoteReport {
  final ReportRepository _repository;

  VoteReport(this._repository);

  Future<void> call(String reportId, String userId, int voteValue) {
    return _repository.voteReport(reportId, userId, voteValue);
  }
}
