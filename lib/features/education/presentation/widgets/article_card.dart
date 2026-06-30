import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/education/domain/entities/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final bool isRead;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.isRead = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? (isDark ? Colors.green.shade300 : Colors.green.shade200)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _categoryColor(article.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(article.category), color: _categoryColor(article.category), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor(article.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.category,
                          style: TextStyle(fontSize: 10, color: _categoryColor(article.category), fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.schedule, size: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readTimeMinutes} min',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  if (isRead) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: isDark ? Colors.green.shade300 : Colors.green),
                        const SizedBox(width: 4),
                        Text('Read', style: TextStyle(fontSize: 11, color: isDark ? Colors.green.shade300 : Colors.green)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'recycling': return AppColors.primary;
      case 'environment': return AppColors.success;
      case 'lifestyle': return AppColors.warning;
      default: return AppColors.info;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'recycling': return Icons.recycling;
      case 'environment': return Icons.eco;
      case 'lifestyle': return Icons.self_improvement;
      default: return Icons.article;
    }
  }
}
