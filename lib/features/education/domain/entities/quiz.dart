class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<QuizQuestion> questions;
  final int rewardPoints;
  final int passingScore;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
    this.rewardPoints = 15,
    this.passingScore = 60,
  });

  int get totalQuestions => questions.length;
}
