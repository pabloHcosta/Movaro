import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/config/api_keys.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/cities/application/services/places_photo_service.dart';
import 'package:movaro_app/features/cities/application/services/youtube_service.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_image_backdrop.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum ExploreState { loading, loaded, error, empty }

class CityExploreScreen extends StatefulWidget {
  const CityExploreScreen({
    required this.city,
    this.isPlanCity = false,
    super.key,
  });

  final City city;
  final bool isPlanCity;

  @override
  State<CityExploreScreen> createState() => _CityExploreScreenState();
}

class _CityExploreScreenState extends State<CityExploreScreen>
    with SingleTickerProviderStateMixin {
  final YouTubeService _youTubeService = YouTubeService();
  final PlacesPhotoService _photoService = PlacesPhotoService();

  ExploreState _videoState = ExploreState.loading;
  ExploreState _photoState = ExploreState.loading;
  YouTubeSearchResult? _videos;
  CityPhotosResult? _photos;
  String? _activeLanguageCode;
  late final TabController _tabController;

  bool get hasApiKey =>
      ApiKeys.youtubeApiKey.isNotEmpty &&
      ApiKeys.youtubeApiKey != 'SUA_CHAVE_AQUI';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Localizations.localeOf(context).languageCode;
    if (_activeLanguageCode == languageCode) {
      return;
    }
    _activeLanguageCode = languageCode;
    unawaited(_loadContent(languageCode));
  }

  Future<void> _loadContent(String languageCode) async {
    setState(() {
      _videoState = ExploreState.loading;
      _photoState = ExploreState.loading;
    });

    final futures = await Future.wait<Object?>([
      _youTubeService.searchVideos(
        cityId: widget.city.id,
        cityName: widget.city.name,
        stateName: widget.city.stateName,
        languageCode: languageCode,
      ),
      _photoService.getPhotos(
        cityId: widget.city.id,
        cityName: widget.city.name,
        stateName: widget.city.stateName,
      ),
    ]);

    if (!mounted) {
      return;
    }

    final videoResult = futures[0] as YouTubeSearchResult;
    final photoResult = futures[1] as CityPhotosResult;

    setState(() {
      _videos = videoResult;
      _photos = photoResult;
      _videoState = videoResult.hasInlineVideos
          ? ExploreState.loaded
          : (videoResult.quotaExceeded || videoResult.missingApiKey)
          ? ExploreState.error
          : ExploreState.empty;
      _photoState = photoResult.photos.isNotEmpty
          ? ExploreState.loaded
          : ExploreState.empty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: AppGlassHeader(
                    title: context.l10n.cityExploreTitle(),
                    onBack: () => Navigator.maybePop(context),
                    trailing: IconButton(
                      onPressed: _shareExplore,
                      icon: const Icon(Icons.share_outlined),
                      tooltip: context.l10n.cityExploreShareTooltip(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _MiniHero(
                        city: widget.city,
                        isPlanCity: widget.isPlanCity,
                      ),
                      const SizedBox(height: 16),
                      _ExploreTabSelector(
                        selectedIndex: _tabController.index,
                        videosLabel: context.l10n.cityExploreTabVideos(),
                        photosLabel: context.l10n.cityExploreTabPhotos(),
                        onTabChanged: (index) {
                          _tabController.animateTo(index);
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 720,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _VideosTab(
                              state: _videoState,
                              result: _videos,
                              city: widget.city,
                              hasApiKey: hasApiKey,
                              onOpenVideo: _openVideo,
                              onOpenMore: () => _openMoreOnYouTube(widget.city),
                            ),
                            _PhotosTab(
                              state: _photoState,
                              result: _photos,
                              city: widget.city,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _shareExplore() async {
    final url = _youtubeSearchUrl(widget.city);
    await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.cityExploreCopiedShareFeedback())),
      );
  }

  Future<void> _openVideo(YouTubeVideo video) async {
    final appUri = Uri.parse(video.youtubeAppUrl);
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }
    await launchUrl(
      Uri.parse(video.youtubeUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openMoreOnYouTube(City city) async {
    await launchUrl(
      Uri.parse(_youtubeSearchUrl(city)),
      mode: LaunchMode.externalApplication,
    );
  }

  String _youtubeSearchUrl(City city) {
    final query = Uri.encodeComponent(
      context.l10n.cityExploreSearchQuery(city.name),
    );
    return 'https://www.youtube.com/results?search_query=$query';
  }
}

class _ExploreTabSelector extends StatelessWidget {
  const _ExploreTabSelector({
    required this.selectedIndex,
    required this.videosLabel,
    required this.photosLabel,
    required this.onTabChanged,
  });

  final int selectedIndex;
  final String videosLabel;
  final String photosLabel;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E2636), width: 1),
        ),
      ),
      child: Row(
        children: [
          _ExploreTabSelectorItem(
            icon: const _YouTubeTabIcon(selected: true),
            label: videosLabel,
            isSelected: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _ExploreTabSelectorItem(
            icon: Icon(
              Icons.photo_camera_outlined,
              size: 14,
              color: selectedIndex == 1
                  ? const Color(0xFFF0F6FC)
                  : const Color(0xFF4B5563),
            ),
            label: photosLabel,
            isSelected: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ExploreTabSelectorItem extends StatelessWidget {
  const _ExploreTabSelectorItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFFF0F6FC)
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 2.5,
              width: isSelected ? 36 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF1F6FEB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 1),
          ],
        ),
      ),
    );
  }
}

class _YouTubeTabIcon extends StatelessWidget {
  const _YouTubeTabIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 13,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Center(
        child: CustomPaint(
          size: Size(7, 8),
          painter: _PlayIconPainter(),
        ),
      ),
    );
  }
}

class _PlayIconPainter extends CustomPainter {
  const _PlayIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniHero extends StatelessWidget {
  const _MiniHero({
    required this.city,
    required this.isPlanCity,
  });

  final City city;
  final bool isPlanCity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CityImageBackdrop(
          city: city,
          overlayOpacity: 0.72,
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              if (isPlanCity)
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.l10n.cityExplorePlanBadge(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${city.stateName} (${city.stateCode})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideosTab extends StatelessWidget {
  const _VideosTab({
    required this.state,
    required this.result,
    required this.city,
    required this.hasApiKey,
    required this.onOpenVideo,
    required this.onOpenMore,
  });

  final ExploreState state;
  final YouTubeSearchResult? result;
  final City city;
  final bool hasApiKey;
  final ValueChanged<YouTubeVideo> onOpenVideo;
  final VoidCallback onOpenMore;

  @override
  Widget build(BuildContext context) {
    final queries =
        result?.queries ??
        YouTubeService.buildQueries(
          city.name,
          city.stateName,
          languageCode: Localizations.localeOf(context).languageCode,
        );

    if (!hasApiKey || result?.quotaExceeded == true) {
      return _YouTubeFallbackPanel(
        city: city,
        queries: queries,
        onOpenMore: onOpenMore,
      );
    }

    switch (state) {
      case ExploreState.loading:
        return _LoadingPanel();
      case ExploreState.error:
        return _YouTubeFallbackPanel(
          city: city,
          queries: queries,
          onOpenMore: onOpenMore,
        );
      case ExploreState.empty:
        return _EmptyPanel(
          title: context.l10n.cityExploreEmptyTitle(),
          body: context.l10n.cityExploreEmptyBody(),
          actionLabel: context.l10n.cityExploreYouTubeAction(),
          onAction: onOpenMore,
        );
      case ExploreState.loaded:
        final videos = result?.videos ?? const <YouTubeVideo>[];
        final featured = videos.first;
        final extra = videos.skip(1).take(3).toList(growable: false);

        return ListView(
          children: [
            Text(
              context.l10n.cityExploreFeaturedLabel(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _FeaturedVideoCard(video: featured, onTap: () => onOpenVideo(featured)),
            if (extra.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                context.l10n.cityExploreMoreVideosLabel(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  for (var index = 0; index < extra.length; index++) ...[
                    _VideoRowCard(
                      video: extra[index],
                      onTap: () => onOpenVideo(extra[index]),
                    ),
                    if (index != extra.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 18),
            Text(
              context.l10n.cityExploreVideoQueriesLabel(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final query in queries)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2137),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF1D4A70)),
                    ),
                    child: Text(
                      query,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 7.5,
                        color: Color(0xFF60A5FA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onOpenMore,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: Text(context.l10n.cityExploreYouTubeAction()),
            ),
          ],
        );
    }
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({
    required this.state,
    required this.result,
    required this.city,
  });

  final ExploreState state;
  final CityPhotosResult? result;
  final City city;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ExploreState.loading:
        return _LoadingPanel();
      case ExploreState.error:
      case ExploreState.empty:
        return _EmptyPanel(
          title: context.l10n.cityExploreEmptyTitle(),
          body: context.l10n.cityExploreEmptyBody(),
        );
      case ExploreState.loaded:
        final photos = result?.photos ?? const <CityPhotoItem>[];
        final attribution = _attributionLabel(context, result);
        final previewPhotos = photos.take(5).toList(growable: false);
        return ListView(
          children: [
            _PhotoPreviewGrid(
              photos: previewPhotos,
              allPhotos: photos,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () => _openGallery(context, photos, 0, city.name),
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E2636)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.grid_view_rounded,
                      size: 18,
                      color: Color(0xFF60A5FA),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.cityExplorePhotosSeeAll(photos.length),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFF1E2636)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 16,
                    color: Color(0xFF4B5563),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attribution,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4B5563),
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  String _attributionLabel(BuildContext context, CityPhotosResult? result) {
    switch (result?.attributionSource) {
      case 'google_places':
        return context.l10n.cityExplorePhotosAttributionGooglePlaces();
      case 'pexels':
        return context.l10n.cityExplorePhotosAttributionPexels();
      default:
        return context.l10n.cityExplorePhotosAttributionGeneric();
    }
  }

  void _openGallery(
    BuildContext context,
    List<CityPhotoItem> photos,
    int initialIndex,
    String title,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PhotoGalleryScreen(
          photos: photos,
          initialIndex: initialIndex,
          title: title,
        ),
      ),
    );
  }
}

class _FeaturedVideoCard extends StatelessWidget {
  const _FeaturedVideoCard({
    required this.video,
    required this.onTap,
  });

  final YouTubeVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  fit: BoxFit.cover,
                  httpHeaders: const {'User-Agent': 'Movaro/1.0'},
                  placeholder: (_, _) => const SkeletonBox(height: 120),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: Color(0xFF0D1F38),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.3, 1],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'YT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _videoMeta(video),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 7.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoRowCard extends StatelessWidget {
  const _VideoRowCard({
    required this.video,
    required this.onTap,
  });

  final YouTubeVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      height: 52,
                      width: 80,
                      fit: BoxFit.cover,
                      httpHeaders: const {'User-Agent': 'Movaro/1.0'},
                      placeholder: (_, _) => const SkeletonBox(
                        height: 52,
                        width: 80,
                      ),
                      errorWidget: (_, _, _) => const ColoredBox(
                        color: Color(0xFF0D1F38),
                        child: SizedBox(height: 52, width: 80),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(child: _SmallPlayBadge()),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _videoMeta(video),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 7.5,
                        color: AppColors.textSoftFor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreviewGrid extends StatelessWidget {
  const _PhotoPreviewGrid({
    required this.photos,
    required this.allPhotos,
  });

  final List<CityPhotoItem> photos;
  final List<CityPhotoItem> allPhotos;

  @override
  Widget build(BuildContext context) {
    final hero = photos.first;
    final gridPhotos = photos.skip(1).take(4).toList(growable: false);

    return Column(
      children: [
        _PhotoHeroTile(
          item: hero,
          totalCount: allPhotos.length,
          onTap: () => _openGallery(context, 0),
        ),
        if (gridPhotos.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var index = 0; index < gridPhotos.length; index += 2) ...[
                      _PhotoTile(
                        item: gridPhotos[index],
                        height: 90,
                        onTap: () =>
                            _openGallery(context, photos.indexOf(gridPhotos[index])),
                      ),
                      if (index + 2 < gridPhotos.length) const SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  children: [
                    for (var index = 1; index < gridPhotos.length; index += 2) ...[
                      _PhotoTile(
                        item: gridPhotos[index],
                        height: 55,
                        onTap: () =>
                            _openGallery(context, photos.indexOf(gridPhotos[index])),
                      ),
                      if (index + 2 < gridPhotos.length) const SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _openGallery(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PhotoGalleryScreen(
          photos: allPhotos,
          initialIndex: initialIndex,
          title: '',
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.item,
    required this.height,
    required this.onTap,
  });

  final CityPhotoItem item;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: item.url,
                  fit: BoxFit.cover,
                  httpHeaders: const {'User-Agent': 'Movaro/1.0'},
                  placeholder: (_, _) => SizedBox(
                    height: height,
                    child: const SkeletonBox(),
                  ),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: Color(0xFF163457),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1],
                  ),
                ),
              ),
              if (item.label.trim().isNotEmpty)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 7,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 7,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoHeroTile extends StatelessWidget {
  const _PhotoHeroTile({
    required this.item,
    required this.totalCount,
    required this.onTap,
  });

  final CityPhotoItem item;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.url,
                  fit: BoxFit.cover,
                  httpHeaders: const {'User-Agent': 'Movaro/1.0'},
                  placeholder: (_, _) => const SkeletonBox(height: 90),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: Color(0xFF163457),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '1 / $totalCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (item.label.trim().isNotEmpty)
                Positioned(
                  left: 10,
                  bottom: 8,
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoGalleryScreen extends StatefulWidget {
  const _PhotoGalleryScreen({
    required this.photos,
    required this.initialIndex,
    required this.title,
  });

  final List<CityPhotoItem> photos;
  final int initialIndex;
  final String title;

  @override
  State<_PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<_PhotoGalleryScreen> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title.isEmpty ? widget.photos[_currentIndex].sourceLabel : widget.title;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  widget.photos[index].url,
                  headers: const {'User-Agent': 'Movaro/1.0'},
                ),
                heroAttributes: PhotoViewHeroAttributes(tag: '$index-$title'),
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, _) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.cityExploreGalleryTitle(
                        title,
                        _currentIndex,
                        widget.photos.length,
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SkeletonBox(height: 120),
        SizedBox(height: 16),
        SkeletonBox(height: 72),
        SizedBox(height: 16),
        SkeletonBox(height: 72),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _ErrorPanel(
      title: title,
      body: body,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _YouTubeFallbackPanel extends StatelessWidget {
  const _YouTubeFallbackPanel({
    required this.city,
    required this.queries,
    required this.onOpenMore,
  });

  final City city;
  final List<String> queries;
  final VoidCallback onOpenMore;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          const Icon(
            Icons.smart_display_rounded,
            size: 44,
            color: Color(0xFFFF0000),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.cityExploreFallbackTitle(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.cityExploreFallbackBody(city.name),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: AppColors.textSoftFor(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (var index = 0; index < queries.take(3).length; index++) ...[
                _FallbackQueryCard(query: queries[index]),
                if (index != queries.take(3).length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenMore,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: Text(context.l10n.cityExploreFallbackAction()),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.cityExploreFallbackFootnote(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 8,
              color: AppColors.textSoftFor(context).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackQueryCard extends StatelessWidget {
  const _FallbackQueryCard({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF1E2636)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF7F1D1D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              query,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallPlayBadge extends StatelessWidget {
  const _SmallPlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: const Icon(Icons.play_arrow_rounded, size: 12, color: Colors.white),
    );
  }
}

String _videoMeta(YouTubeVideo video) {
  final compactDate = video.publishedAt.length >= 10
      ? video.publishedAt.substring(0, 10)
      : video.publishedAt;
  if (compactDate.isEmpty) {
    return video.channelName;
  }
  return '${video.channelName} · $compactDate';
}
