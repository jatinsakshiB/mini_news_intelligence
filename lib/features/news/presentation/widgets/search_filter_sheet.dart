import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SearchFilterSheet extends StatelessWidget {
  final String currentSortBy;
  final ValueChanged<String> onSortByChanged;

  const SearchFilterSheet({
    super.key,
    required this.currentSortBy,
    required this.onSortByChanged,
  });

  static void show(
    BuildContext context, {
    required String currentSortBy,
    required ValueChanged<String> onSortByChanged,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SearchFilterSheet(
        currentSortBy: currentSortBy,
        onSortByChanged: onSortByChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final options = [
      {'label': 'Latest First (Published Date)', 'value': 'publishedAt'},
      {'label': 'Most Popular (Top Engagement)', 'value': 'popularity'},
      {'label': 'Most Relevant (Best Match)', 'value': 'relevancy'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sort Articles By',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((option) {
              final isSelected = currentSortBy == option['value'];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.brandOrange
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check,
                        color: AppColors.brandOrange,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onSortByChanged(option['value']!);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
