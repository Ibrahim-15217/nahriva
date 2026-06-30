import 'package:nahriva/features/report/domain/entities/report_entity.dart';
import 'package:nahriva/features/report/domain/repositories/report_repository.dart';

class SubmitReport {
  final ReportRepository _repository;

  SubmitReport(this._repository);

  Future<void> call(ReportEntity report, String photoPath) {
    return _repository.submitReport(report, photoPath);
  }
}
