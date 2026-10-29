import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../data/models/article_model.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;
  final bool isFeatured;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: isFeatured
              ? _buildFeaturedContent(context, isDark)
              : _buildStandardContent(context, isDark),
        ),
      ),
    );
  }

  Widget _buildStandardContent(BuildContext context, bool isDark) {
    final hasImage =
        article.urlToImage != null && article.urlToImage!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[_buildThumbnail(84, 84), const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSourceRow(isDark),
              const SizedBox(height: 4),
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              _buildBottomMetaRow(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedContent(BuildContext context, bool isDark) {
    final hasImage =
        article.urlToImage != null && article.urlToImage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[_buildHeroImage(context), const SizedBox(height: 10)],
        _buildSourceRow(isDark),
        const SizedBox(height: 6),
        Text(
          article.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        if (article.description != null && article.description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            article.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
        const SizedBox(height: 10),
        _buildBottomMetaRow(isDark),
      ],
    );
  }

  Widget _buildThumbnail(double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: article.urlToImage!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: const Color(0xFFE5E7EB),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: const Color(0xFFE5E7EB),
          child: const Icon(
            Icons.newspaper_outlined,
            size: 24,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: article.urlToImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: const Color(0xFFE5E7EB)),
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildSourceRow(bool isDark) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.brandOrange,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            (article.sourceName ?? 'News').toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.brandOrange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomMetaRow(bool isDark) {
    final relativeTime = DateFormatter.formatRelative(article.publishedAt);
    final readTime = DateFormatter.estimateReadTime(
      article.content,
      article.description,
    );

    return Row(
      children: [
        if (relativeTime.isNotEmpty) ...[
          Text(
            relativeTime,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '•',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          readTime,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        const Spacer(),
        _FavoriteButton(article: article),
      ],
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final ArticleModel article;

  const _FavoriteButton({required this.article});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
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
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onToggle() {
    _animController.forward(from: 0.0);
    context.read<FavoritesCubit>().toggleFavorite(widget.article);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) =>
          previous.isFavorite(widget.article.url) !=
          current.isFavorite(widget.article.url),
      builder: (context, state) {
        final isFav = state.isFavorite(widget.article.url);

        return ScaleTransition(
          scale: _scaleAnimation,
          child: InkWell(
            onTap: _onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isFav ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: isFav ? AppColors.brandOrange : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
