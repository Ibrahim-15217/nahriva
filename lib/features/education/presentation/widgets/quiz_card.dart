import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/education/domain/entities/quiz.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final bool isCompleted;
  final int? lastScore;
  final VoidCallback? onTap;

  const QuizCard({super.key, required this.quiz, this.isCompleted = false, this.lastScore, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: isDark
                      ? [Colors.green.shade900.withValues(alpha: 0.5), Colors.grey.shade800]
                      : [Colors.green.shade50, Colors.white])
              : null,
          color: isCompleted ? null : (isDark ? Colors.grey.shade800 : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? (isDark ? Colors.green.shade300 : Colors.green.shade200)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.checklist : Icons.quiz_outlined,
                color: isCompleted ? Colors.green : AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.help_outline, size: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.totalQuestions} questions',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.eco, size: 12, color: isDark ? AppColors.primaryDark : AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '+${quiz.rewardPoints} pts',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.primaryDark : AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isCompleted && lastScore != null) ...[
              const SizedBox(width: 8),
              Column(
                children: [
                  Text(
                    '$lastScore%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: lastScore! >= quiz.passingScore ? Colors.green : AppColors.error,
                    ),
                  ),
                  Text('Score', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
