import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/features/report/data/datasources/report_remote_data_source.dart';
import 'package:nahriva/features/report/data/repositories/report_repository_impl.dart';
import 'package:nahriva/features/report/domain/entities/report_entity.dart';
import 'package:nahriva/features/report/domain/repositories/report_repository.dart';
import 'package:nahriva/features/report/domain/usecases/get_reports.dart';
import 'package:nahriva/features/report/domain/usecases/submit_report.dart';
import 'package:nahriva/features/report/domain/usecases/vote_report.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSource();
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dataSource = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(dataSource);
});

final submitReportProvider = Provider<SubmitReport>((ref) {
  return SubmitReport(ref.watch(reportRepositoryProvider));
});

final voteReportProvider = Provider<VoteReport>((ref) {
  return VoteReport(ref.watch(reportRepositoryProvider));
});

final getReportsProvider = Provider<GetReports>((ref) {
  return GetReports(ref.watch(reportRepositoryProvider));
});

final reportsStreamProvider = StreamProvider<List<ReportEntity>>((ref) {
  return ref.watch(getReportsProvider).call();
});
