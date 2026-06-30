import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/education/domain/entities/quiz.dart';
import 'package:nahriva/features/education/presentation/screens/quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  final List<int> _answers = [];

  Quiz get quiz => widget.quiz;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = quiz.questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / quiz.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(context, isDark, progress),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Question ${_currentQuestion + 1} of ${quiz.totalQuestions}',
                          style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  ...question.options.asMap().entries.map((entry) => _buildOption(
                    context, isDark, entry.key, entry.value, question.correctIndex,
                  )),
                ],
              ),
            ),
          ),
          if (_answered) _buildBottomBar(context, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, bool isDark, double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.primaryDark : AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, bool isDark, int index, String text, int correctIndex) {
    Color? bgColor;
    Color? borderColor;
    Color? textColor;

    if (_answered) {
      if (index == correctIndex) {
        bgColor = isDark ? Colors.green.shade900.withValues(alpha: 0.5) : Colors.green.shade50;
        borderColor = Colors.green;
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
      } else if (index == _selectedAnswer && _selectedAnswer != correctIndex) {
        bgColor = isDark ? Colors.red.shade900.withValues(alpha: 0.5) : Colors.red.shade50;
        borderColor = Colors.red;
        textColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
      }
    } else if (index == _selectedAnswer) {
      bgColor = (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1);
      borderColor = isDark ? AppColors.primaryDark : AppColors.primary;
      textColor = isDark ? AppColors.primaryDark : AppColors.primary;
    }

    final defaultBorder = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return GestureDetector(
      onTap: _answered ? null : () => _selectAnswer(index),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor ?? (isDark ? Colors.grey.shade800 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? defaultBorder, width: borderColor != null ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor?.withValues(alpha: 0.1),
                border: Border.all(color: borderColor ?? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14, color: textColor ?? (isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
              ),
            ),
            if (_answered && index == correctIndex)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (_answered && index == _selectedAnswer && _selectedAnswer != correctIndex)
              const Icon(Icons.cancel, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    final isLast = _currentQuestion == quiz.totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              if (isLast) {
                _finishQuiz();
              } else {
                setState(() {
                  _currentQuestion++;
                  _selectedAnswer = null;
                  _answered = false;
                });
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isLast ? 'See Results' : 'Next Question', style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _answers.add(index);
    });
  }

  void _finishQuiz() {
    int correct = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (_answers[i] == quiz.questions[i].correctIndex) correct++;
    }
    final score = (correct / quiz.totalQuestions * 100).round();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => QuizResultScreen(quiz: quiz, score: score, total: quiz.totalQuestions, correct: correct),
    ));
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Continue')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
