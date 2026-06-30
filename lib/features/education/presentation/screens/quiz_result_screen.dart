import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/education/domain/entities/quiz.dart';
import 'package:nahriva/features/education/presentation/providers/education_providers.dart';

class QuizResultScreen extends ConsumerWidget {
  final Quiz quiz;
  final int score;
  final int total;
  final int correct;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.total,
    required this.correct,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passed = score >= quiz.passingScore;

    ref.read(submitQuizResultProvider((quizId: quiz.id, score: score, total: quiz.totalQuestions)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Complete'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _goBack(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScoreCircle(context, isDark, passed),
              const SizedBox(height: 24),
              Text(
                passed ? 'Congratulations!' : 'Keep Trying!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.green : AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                passed ? 'You passed the quiz!' : 'You need ${quiz.passingScore}% to pass.',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _buildStatRow('Correct', '$correct / $total', Colors.green),
              const SizedBox(height: 8),
              _buildStatRow('Passing Score', '${quiz.passingScore}%', Colors.grey),
              if (passed) ...[
                const SizedBox(height: 8),
                _buildStatRow('Reward', '+${quiz.rewardPoints} GreenPoints', AppColors.primary),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _goBack(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Education Hub', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context, bool isDark, bool passed) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: passed
              ? [Colors.green, AppColors.primary, Colors.green]
              : [AppColors.error, Colors.orange, AppColors.error],
        ),
        boxShadow: [
          BoxShadow(
            color: (passed ? Colors.green : AppColors.error).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.grey.shade900 : Colors.white,
        ),
        child: Center(
          child: Text(
            '$score%',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: passed ? Colors.green : AppColors.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
