import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/education/domain/entities/article.dart';
import 'package:nahriva/features/education/domain/entities/quiz.dart';
import 'package:nahriva/features/education/presentation/providers/education_providers.dart';
import 'package:nahriva/features/education/presentation/screens/article_reader_screen.dart';
import 'package:nahriva/features/education/presentation/screens/quiz_screen.dart';
import 'package:nahriva/features/education/presentation/widgets/article_card.dart';
import 'package:nahriva/features/education/presentation/widgets/quiz_card.dart';

class EducationHubScreen extends ConsumerWidget {
  const EducationHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final articlesAsync = ref.watch(articlesProvider);
    final quizzesAsync = ref.watch(quizzesProvider);
    final completedAsync = ref.watch(completedContentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Hub'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(articlesProvider);
          ref.invalidate(quizzesProvider);
          ref.invalidate(completedContentProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Articles', Icons.article),
              const SizedBox(height: 8),
              articlesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (articles) => completedAsync.when(
                  data: (completed) => Column(
                    children: articles.map((a) => ArticleCard(
                      article: a,
                      isRead: completed.contains(a.id),
                      onTap: () => _openArticle(context, a, completed.contains(a.id)),
                    )).toList(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => Column(
                    children: articles.map((a) => ArticleCard(article: a, onTap: () => _openArticle(context, a, false))).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Quizzes', Icons.quiz_outlined),
              const SizedBox(height: 8),
              quizzesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (quizzes) => completedAsync.when(
                  data: (completed) => Column(
                    children: quizzes.map((q) => QuizCard(
                      quiz: q,
                      isCompleted: completed.contains(q.id),
                      onTap: () => _openQuiz(context, q),
                    )).toList(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => Column(
                    children: quizzes.map((q) => QuizCard(quiz: q, onTap: () => _openQuiz(context, q))).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.primaryDark.withValues(alpha: 0.8), const Color(0xFF1A3A3A)]
              : [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.menu_book, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Learn & Earn', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                const Text(
                  'Education Hub',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Read articles and take quizzes to earn points',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _openArticle(BuildContext context, Article article, bool isRead) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ArticleReaderScreen(article: article, isRead: isRead),
    ));
  }

  void _openQuiz(BuildContext context, Quiz quiz) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuizScreen(quiz: quiz),
    ));
  }
}
