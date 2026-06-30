import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';
import 'package:nahriva/features/education/data/datasources/education_remote_data_source.dart';
import 'package:nahriva/features/education/domain/entities/article.dart';
import 'package:nahriva/features/education/domain/entities/quiz.dart';

final educationDataSourceProvider = Provider<EducationRemoteDataSource>((ref) {
  return EducationRemoteDataSource();
});

final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final dataSource = ref.watch(educationDataSourceProvider);
  final data = await dataSource.getArticles();

  if (data.isNotEmpty) {
    return data.map((d) => Article(
      id: d['id'] as String,
      title: d['title'] as String? ?? '',
      summary: d['summary'] as String? ?? '',
      content: d['content'] as String? ?? '',
      category: d['category'] as String? ?? 'General',
      imageUrl: d['imageUrl'] as String? ?? '',
      readTimeMinutes: d['readTimeMinutes'] as int? ?? 3,
      publishedAt: (d['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    )).toList();
  }

  return EducationRemoteDataSource.defaultArticles().map((d) => Article(
    id: d['id'] as String,
    title: d['title'] as String,
    summary: d['summary'] as String,
    content: d['content'] as String,
    category: d['category'] as String,
    imageUrl: d['imageUrl'] as String? ?? '',
    readTimeMinutes: d['readTimeMinutes'] as int? ?? 3,
    publishedAt: d['publishedAt'] as DateTime,
  )).toList();
});

final articleByIdProvider = FutureProvider.family<Article?, String>((ref, id) async {
  final articles = await ref.watch(articlesProvider.future);
  try {
    return articles.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});

final quizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  final dataSource = ref.watch(educationDataSourceProvider);
  final data = await dataSource.getQuizzes();

  if (data.isNotEmpty) {
    return data.map((d) {
      final questions = (d['questions'] as List<dynamic>?)?.map((q) {
        final qm = q as Map<String, dynamic>;
        return QuizQuestion(
          question: qm['question'] as String? ?? '',
          options: (qm['options'] as List<dynamic>?)?.cast<String>() ?? [],
          correctIndex: qm['correctIndex'] as int? ?? 0,
        );
      }).toList() ?? [];
      return Quiz(
        id: d['id'] as String,
        title: d['title'] as String? ?? '',
        description: d['description'] as String? ?? '',
        category: d['category'] as String? ?? 'General',
        questions: questions,
        rewardPoints: d['rewardPoints'] as int? ?? 15,
        passingScore: d['passingScore'] as int? ?? 60,
      );
    }).toList();
  }

  return EducationRemoteDataSource.defaultQuizzes().map((d) {
    final questions = (d['questions'] as List<dynamic>).map((q) {
      final qm = q as Map<String, dynamic>;
      return QuizQuestion(
        question: qm['question'] as String,
        options: (qm['options'] as List).cast<String>(),
        correctIndex: qm['correctIndex'] as int,
      );
    }).toList();
    return Quiz(
      id: d['id'] as String,
      title: d['title'] as String,
      description: d['description'] as String,
      category: d['category'] as String,
      questions: questions,
      rewardPoints: d['rewardPoints'] as int? ?? 15,
      passingScore: d['passingScore'] as int? ?? 60,
    );
  }).toList();
});

final quizByIdProvider = FutureProvider.family<Quiz?, String>((ref, id) async {
  final quizzes = await ref.watch(quizzesProvider.future);
  try {
    return quizzes.firstWhere((q) => q.id == id);
  } catch (_) {
    return null;
  }
});

final completedContentProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final dataSource = ref.watch(educationDataSourceProvider);
  return dataSource.getCompletedContentIds(user.uid);
});

final markArticleReadProvider = FutureProvider.family<void, String>((ref, articleId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  final dataSource = ref.watch(educationDataSourceProvider);
  await dataSource.markArticleRead(user.uid, articleId);
  ref.invalidate(completedContentProvider);
});

final submitQuizResultProvider = FutureProvider.family<void, ({String quizId, int score, int total})>((ref, params) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  final dataSource = ref.watch(educationDataSourceProvider);
  await dataSource.saveQuizResult(user.uid, params.quizId, params.score, params.total);
  final quiz = await ref.watch(quizByIdProvider(params.quizId).future);
  if (quiz != null && params.score >= quiz.passingScore) {
    await dataSource.awardPoints(user.uid, quiz.rewardPoints);
  }
  ref.invalidate(completedContentProvider);
  ref.invalidate(currentUserProvider);
});
