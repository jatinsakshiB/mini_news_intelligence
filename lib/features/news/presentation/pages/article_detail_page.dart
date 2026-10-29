import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../data/models/article_model.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _launchSourceUrl() async {
    final url = widget.article.url.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        final fallbackLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (!fallbackLaunched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open external browser for this article.',
              ),
            ),
          );
        }
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open link in browser.')),
          );
        }
      }
    }
  }

  void _onToggleFavorite(bool currentFav) {
    _animController.forward(from: 0.0);
    HapticFeedback.lightImpact();
    context.read<FavoritesCubit>().toggleFavorite(widget.article);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !currentFav ? 'Saved to offline Favorites' : 'Removed from Favorites',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasImage =
        article.urlToImage != null && article.urlToImage!.isNotEmpty;
    final hasValidWebUrl =
        article.url.trim().isNotEmpty &&
        (article.url.startsWith('http://') ||
            article.url.startsWith('https://'));
    final fullDate = DateFormatter.formatFull(article.publishedAt);
    final readTime = DateFormatter.estimateReadTime(
      article.content,
      article.description,
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.surfaceLight,
      appBar: AppBar(
        title: Text(
          article.sourceName ?? 'Article',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final isFav = state.isFavorite(article.url);
              return ScaleTransition(
                scale: _scaleAnimation,
                child: IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark : Icons.bookmark_border,
                    color: isFav ? AppColors.brandOrange : null,
                  ),
                  tooltip: isFav
                      ? 'Remove from favorites'
                      : 'Save to favorites',
                  onPressed: () => _onToggleFavorite(isFav),
                ),
              );
            },
          ),
          if (hasValidWebUrl)
            IconButton(
              icon: const Icon(Icons.open_in_browser_outlined),
              tooltip: 'Open in browser',
              onPressed: _launchSourceUrl,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            if (hasImage)
              Hero(
                tag: 'image_${article.url}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: article.urlToImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isDark
                          ? const Color(0xFF1E232A)
                          : const Color(0xFFE5E7EB),
                    ),
                    errorWidget: (context, url, error) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and reading time metadata
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.brandOrange.withValues(alpha: 0.15)
                              : AppColors.brandOrangeLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (article.sourceName ?? 'NEWS').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.brandOrange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        readTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Headline
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.3,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author and Date
                  if (article.author != null &&
                      article.author!.trim().isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            article.author!.trim(),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  if (fullDate.isNotEmpty)
                    Text(
                      fullDate,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),

                  const SizedBox(height: 16),
                  Divider(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  const SizedBox(height: 16),

                  // Description / Summary
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    Text(
                      article.description!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Content Body
                  if (article.content != null &&
                      article.content!.isNotEmpty) ...[
                    Text(
                      article.content!.replaceAll(
                        RegExp(r'\[\+\d+ chars\]'),
                        '',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Read Full Story Action (shown only if URL is available)
                  if (hasValidWebUrl) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Coverage Available at Publisher',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Read the complete unedited article, tables, and media on ${article.sourceName ?? "the source website"}.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Read Full Story on Web',
                            icon: Icons.launch_outlined,
                            onPressed: _launchSourceUrl,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
