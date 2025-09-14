import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavouritScreen extends StatefulWidget {
  const FavouritScreen({super.key});

  @override
  State<FavouritScreen> createState() => _FavouritScreenState();
}

class _FavouritScreenState extends State<FavouritScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _favs = [];
  List<Map<String, dynamic>> _filtered = [];
  String _query = '';
  AnimationController? _bgController;
  bool _bgStarted = false;

  @override
  void initState() {
    super.initState();
    _loadFavs();
  }

  void _ensureBgAnimation() {
    if (_bgController == null) {
      _bgController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 14),
      );
    }
    if (!_bgStarted) {
      _bgController!.repeat(reverse: true);
      _bgStarted = true;
    }
  }

  void _loadFavs() {
    final box = Hive.box('drippsafe_db');
    final list = (box.get('tips') ?? []) as List;
    final favs = list
        .cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .where((m) => m['favourite'] == true)
        .toList();
    setState(() {
      _favs = favs;
      _applyFilter(_query, silent: true);
    });
  }

  void _applyFilter(String value, {bool silent = false}) {
    setState(() {
      _query = value;
      _filtered = _favs
          .where((f) =>
              f['title'].toString().toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_filtered.length} favourite tip${_filtered.length == 1 ? '' : 's'}'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * 0.75,
        ),
      );
    }
  }

  void _removeFavourite(String id) {
    final box = Hive.box('drippsafe_db');
    final list = (box.get('tips') as List)
        .cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    final idx = list.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      final previous = list[idx]['favourite'] as bool;
      list[idx]['favourite'] = false;
      box.put('tips', list);
      _loadFavs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from favourites'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              list[idx]['favourite'] = previous;
              box.put('tips', list);
              _loadFavs();
            },
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      );
    }
  }

  void _openDetail(Map<String, dynamic> tip, int visualIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FavDetailSheet(
        tip: tip,
        index: visualIndex,
        heroTag: 'favHero_${tip['id']}',
        onRemove: () => _removeFavourite(tip['id'] as String),
      ),
    );
  }

  @override
  void dispose() {
    _bgController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureBgAnimation();
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController!,
            builder: (_, __) {
              final t = _bgController!.value;
              final colors = [
                Color.lerp(
                    Colors.pink.shade900, Colors.deepPurple.shade700, t)!,
                Color.lerp(
                    Colors.pink.shade400, Colors.indigo.shade400, 1 - t)!,
              ];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
              );
            },
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.surface.withOpacity(.08),
                title: const Text('Favourite Tips',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                actions: [
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadFavs,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your saved wellness insights.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white.withOpacity(.9))),
                      const SizedBox(height: 12),
                      _FavSearchBar(
                        onChanged: (v) => _applyFilter(v, silent: true),
                        onSubmitted: (v) => _applyFilter(v),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (_filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.heart_broken,
                            size: 64, color: Colors.white70),
                        const SizedBox(height: 12),
                        Text(
                            _query.isEmpty ? 'No favourites yet' : 'No matches',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  sliver: SliverList.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final fav = _filtered[index];
                      return _AnimatedFavCard(
                        key: ValueKey('fav_${fav['id']}'),
                        index: index,
                        total: _filtered.length,
                        heroTag: 'favHero_${fav['id']}',
                        title: fav['title'] as String,
                        onTap: () => _openDetail(fav, index + 1),
                        onRemove: () => _removeFavourite(fav['id'] as String),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  const _FavSearchBar({required this.onChanged, this.onSubmitted});

  @override
  State<_FavSearchBar> createState() => _FavSearchBarState();
}

class _FavSearchBarState extends State<_FavSearchBar> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search favourites...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(.6)),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(.15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white, width: 1.2),
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              ),
      ),
    );
  }
}

class _AnimatedFavCard extends StatefulWidget {
  final int index;
  final int total;
  final String heroTag;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _AnimatedFavCard({
    super.key,
    required this.index,
    required this.total,
    required this.heroTag,
    required this.title,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_AnimatedFavCard> createState() => _AnimatedFavCardState();
}

class _AnimatedFavCardState extends State<_AnimatedFavCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 680));
    final delayFactor = min(widget.index / max(widget.total, 1), 1.0);
    _fade = CurvedAnimation(
        parent: _controller,
        curve: Interval(delayFactor * .4, 1, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, .18), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(delayFactor * .35, 1, curve: Curves.easeOutCubic)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Hero(
          tag: widget.heroTag,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(.14),
                  border: Border.all(color: Colors.white.withOpacity(.15)),
                ),
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite,
                          color: Colors.redAccent, size: 34),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: widget.onRemove,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white70),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavDetailSheet extends StatelessWidget {
  final Map<String, dynamic> tip;
  final int index;
  final String heroTag;
  final VoidCallback onRemove;
  const _FavDetailSheet({
    required this.tip,
    required this.index,
    required this.heroTag,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      maxChildSize: 0.95,
      minChildSize: 0.55,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: controller,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                          child: Hero(
                            tag: heroTag,
                            child: Material(
                              color: Colors.transparent,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.favorite,
                                      color: Colors.redAccent, size: 42),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Favourite #$index',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontSize: 14,
                                                  letterSpacing: .5,
                                                  color: Colors.grey.shade600,
                                                )),
                                        const SizedBox(height: 6),
                                        Text(
                                          tip['title'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                          child: Text(
                            tip['description'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(height: 1.42),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remove'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          tooltip: 'Close',
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade200),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
