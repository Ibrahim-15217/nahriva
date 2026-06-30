import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/education/domain/entities/article.dart';
import 'package:nahriva/features/education/presentation/providers/education_providers.dart';

class ArticleReaderScreen extends ConsumerWidget {
  final Article article;
  final bool isRead;

  const ArticleReaderScreen({super.key, required this.article, this.isRead = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isRead) {
      ref.read(markArticleReadProvider(article.id));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        actions: [
          if (!isRead)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(Icons.eco, size: 14, color: Colors.white),
                label: Text('+5', style: TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: AppColors.primaryLight,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryColor(article.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(fontSize: 12, color: _categoryColor(article.category), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  '${article.readTimeMinutes} min read',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildContent(context, isDark, article.content),
            const SizedBox(height: 24),
            if (!isRead)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.green.shade700 : Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.eco, color: isDark ? Colors.green.shade300 : Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      'Thanks for reading! +5 GreenPoints earned.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, String content) {
    final paragraphs = content.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        final trimmed = para.trim();
        if (trimmed.isEmpty) return const SizedBox.shrink();

        if (trimmed.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              trimmed.substring(3),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
          );
        }

        if (trimmed.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              trimmed.substring(4),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
            ),
          );
        }

        if (trimmed.startsWith('- ')) {
          final items = trimmed.split('\n').where((l) => l.startsWith('- ')).map((l) {
            return l.substring(2);
          }).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                  Expanded(child: Text(item, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700))),
                ],
              ),
            )).toList(),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(trimmed, style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
        );
      }).toList(),
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
}
