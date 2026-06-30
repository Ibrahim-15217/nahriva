class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String imageUrl;
  final int readTimeMinutes;
  final DateTime publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    this.imageUrl = '',
    this.readTimeMinutes = 3,
    required this.publishedAt,
  });
}
