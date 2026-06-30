import 'package:nahriva/features/report/domain/entities/report_entity.dart';
import 'package:nahriva/features/report/domain/repositories/report_repository.dart';

class GetReports {
  final ReportRepository _repository;

  GetReports(this._repository);

  Stream<List<ReportEntity>> call() => _repository.reportsStream;
}
