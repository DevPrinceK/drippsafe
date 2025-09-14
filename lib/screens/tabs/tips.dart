// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:drippsafe/db/hive/initial_data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _tips = [];
  List<Map<String, dynamic>> _filtered = [];
  String _query = '';
  AnimationController?
      _bgController; // nullable to survive hot reload additions
  bool _bgStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeTips();
  }

  void _ensureBgAnimation() {
    _bgController ??= AnimationController(
        vsync: this,
        duration: const Duration(seconds: 12),
      );
    if (!_bgStarted) {
      _bgController!.repeat(reverse: true);
      _bgStarted = true;
    }
  }

  @override
  void dispose() {
    _bgController?.dispose();
    super.dispose();
  }

  // Initialize / seed tips
  void _initializeTips() {
    final box = Hive.box('drippsafe_db');
    if (box.get('tips') == null || box.get('tips').isEmpty) {
      final seeded = <Map<String, dynamic>>[];
      for (final tip in initialTips) {
        final i = initialTips.indexOf(tip) + 1;
        seeded.add({
          'id': i.toString(),
          'title': tip['tip'],
          'description': tip['description'],
          'created_at': DateTime.now().toIso8601String(),
          'favourite': false,
        });
      }
      box.put('tips', seeded);
    }
    final list = (box.get('tips') as List)
        .cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    setState(() {
      _tips = list;
      _filtered = list;
    });
  }

  void _toggleFavourite(String id) {
    final box = Hive.box('drippsafe_db');
    final list = (box.get('tips') as List)
        .cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    final idx = list.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      list[idx]['favourite'] = !(list[idx]['favourite'] as bool);
      box.put('tips', list);
      setState(() {
        _tips = list;
        _applyFilter(_query, showSnack: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(list[idx]['favourite']
              ? 'Added to favourites'
              : 'Removed from favourites'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      );
    }
  }

  void _applyFilter(String value, {bool showSnack = false}) {
    setState(() {
      _query = value;
      _filtered = _tips
          .where((t) =>
              t['title'].toString().toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
    if (showSnack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_filtered.length} tip${_filtered.length == 1 ? '' : 's'} found'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          width: MediaQuery.of(context).size.width * 0.75,
        ),
      );
    }
  }

  void _openDetail(Map<String, dynamic> tip, int visualIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _DetailSheet(
          tip: tip,
          onToggleFavourite: () => _toggleFavourite(tip['id'] as String),
          heroTag: 'tipHero_${tip['id']}',
          index: visualIndex,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _ensureBgAnimation();
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController!,
            builder: (context, _) {
              final t = _bgController!.value;
              final colors = [
                Color.lerp(
                    Colors.pink.shade800, Colors.deepPurple.shade700, t)!,
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
                backgroundColor: theme.colorScheme.surface.withOpacity(0.1),
                elevation: 0,
                centerTitle: true,
                title: const Text('Wellness Tips',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                actions: [
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _initializeTips();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Tips refreshed'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(milliseconds: 1200),
                          width: MediaQuery.of(context).size.width * 0.7,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Curated guidance to feel your best.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white.withOpacity(.9)),
                      ),
                      const SizedBox(height: 12),
                      _SearchBar(
                        onChanged: (v) => _applyFilter(v),
                        onSubmitted: (v) => _applyFilter(v, showSnack: true),
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
                        const Icon(Icons.search_off,
                            size: 56, color: Colors.white70),
                        const SizedBox(height: 12),
                        Text('No tips match your search',
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
                      final tip = _filtered[index];
                      return _AnimatedTipCard(
                        key: ValueKey('tip_${tip['id']}'),
                        index: index,
                        total: _filtered.length,
                        heroTag: 'tipHero_${tip['id']}',
                        favourite: tip['favourite'] as bool,
                        title: tip['title'] as String,
                        onTap: () => _openDetail(tip, index + 1),
                        onFavourite: () =>
                            _toggleFavourite(tip['id'] as String),
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

// Search bar widget
class _SearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  const _SearchBar({required this.onChanged, this.onSubmitted});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
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
        hintText: 'Search tips...',
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

// Animated tip card
class _AnimatedTipCard extends StatefulWidget {
  final int index;
  final int total;
  final String heroTag;
  final bool favourite;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onFavourite;
  const _AnimatedTipCard({
    super.key,
    required this.index,
    required this.total,
    required this.heroTag,
    required this.favourite,
    required this.title,
    required this.onTap,
    required this.onFavourite,
  });

  @override
  State<_AnimatedTipCard> createState() => _AnimatedTipCardState();
}

class _AnimatedTipCardState extends State<_AnimatedTipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final delayFactor = min(widget.index / max(widget.total, 1), 1.0);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(delayFactor * .4, 1, curve: Curves.easeOut),
    );
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delayFactor * .35, 1, curve: Curves.easeOutCubic),
      ),
    );
    // Start after first frame to allow list build
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fav = widget.favourite;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Hero(
          tag: widget.heroTag,
          flightShuttleBuilder: (context, anim, direction, fromCtx, toCtx) {
            return ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              child: toCtx.widget,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(.14),
                  border: Border.all(color: Colors.white.withOpacity(.15)),
                ),
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: fav ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          fav ? Icons.favorite : Icons.lightbulb,
                          color: fav ? Colors.redAccent : Colors.amberAccent,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tip #${widget.index + 1}',
                              style: const TextStyle(
                                fontSize: 13,
                                letterSpacing: .5,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onFavourite,
                        icon: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          color: fav ? Colors.redAccent : Colors.white70,
                        ),
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

// Detail bottom sheet
class _DetailSheet extends StatelessWidget {
  final Map<String, dynamic> tip;
  final VoidCallback onToggleFavourite;
  final String heroTag;
  final int index;
  const _DetailSheet({
    required this.tip,
    required this.onToggleFavourite,
    required this.heroTag,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final fav = tip['favourite'] as bool;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
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
                                  Icon(
                                    fav ? Icons.favorite : Icons.lightbulb,
                                    color: fav
                                        ? Colors.redAccent
                                        : Colors.amber.shade700,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tip #$index',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                fontSize: 14,
                                                letterSpacing: .5,
                                                color: Colors.grey.shade600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tip['title'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                ?.copyWith(height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: onToggleFavourite,
                            icon: Icon(
                                fav ? Icons.favorite : Icons.favorite_border),
                            label:
                                Text(fav ? 'Favourited' : 'Add to favourites'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Close',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// (Removed custom blur helper; consider using BackdropFilter if a frosted glass effect is required.)
