/// 리스트·검색·페이지네이션·로딩/에러/빈 화면 등 공통 위젯.
import 'package:flutter/material.dart';
import 'package:gotogether/ui/app_theme.dart';

/// 공통 로딩 뷰
class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            '불러오는 중...',
            style: TextStyle(color: AppTheme.lightText, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// 에러 뷰 (재시도 버튼)
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({Key? key, required this.message, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.darkText, fontSize: 14, height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 빈 목록 뷰
class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView({Key? key, this.message = '데이터가 없습니다.', this.icon = Icons.inbox_outlined}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppTheme.lightText.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 모던 검색 바 (둥근 테두리)
class ModernSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;
  final void Function(String)? onSubmitted;

  const ModernSearchBar({
    Key? key,
    required this.controller,
    this.hintText = '검색',
    required this.onSearch,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingCard, vertical: AppTheme.radiusMd),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
                contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.paddingCard, vertical: 14),
              ),
              onSubmitted: onSubmitted != null ? (_) => onSearch() : null,
            ),
          ),
          SizedBox(width: AppTheme.radiusMd),
          FilledButton(
            onPressed: onSearch,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingScreen, vertical: AppTheme.paddingCard),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
            child: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }
}

/// 모던 리스트 카드 (둥근 모서리, 부드러운 그림자)
class ModernListCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const ModernListCard({Key? key, required this.child, this.onTap, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(color: AppTheme.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(padding: EdgeInsets.all(AppTheme.paddingCard), child: child),
      ),
    );
  }
}

/// 페이지네이션 바
class PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const PaginationBar({
    Key? key,
    required this.page,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (onPrev != null)
            TextButton.icon(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left),
              label: const Text('이전'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${page + 1} / $totalPages',
              style: const TextStyle(color: AppTheme.lightText, fontWeight: FontWeight.w500),
            ),
          ),
          if (onNext != null)
            TextButton.icon(
              onPressed: onNext,
              label: const Text('다음'),
              icon: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }
}
