import 'package:drippsafe/models/user_settings.dart';
import 'package:drippsafe/providers/settings_provider.dart';
import 'package:drippsafe/services/cycle_calculator.dart';
import 'package:drippsafe/screens/constants/widgets/info_rect.dart';
import 'package:drippsafe/screens/constants/widgets/infocard.dart';
import 'package:drippsafe/screens/constants/widgets/tipcard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  AnimationController? _bgController;
  bool _bgStarted = false;

  // Centralized phase definitions (label, color, description)
  static final Map<CyclePhase, _PhaseMeta> _phaseMeta = {
    CyclePhase.menstrual: const _PhaseMeta(
      label: 'Menstrual',
      color: Color(0xFFE91E63),
      description:
          'Menstrual Phase:\nShedding of the uterine lining. Energy may be lower; focus on rest, nourishment, and gentle movement.',
    ),
    CyclePhase.follicular: const _PhaseMeta(
      label: 'Follicular',
      color: Color(0xFF42A5F5),
      description:
          'Follicular Phase:\nEstrogen rises as follicles mature. Often improved mood, creativity, and energy. Great for planning and learning.',
    ),
    CyclePhase.fertile: const _PhaseMeta(
      label: 'Fertile Window',
      color: Color(0xFF00BFA5),
      description:
          'Fertile Window:\nDays leading up to ovulation when conception is most likely. Cervical fluid may become clear/stretchy.',
    ),
    CyclePhase.ovulation: const _PhaseMeta(
      label: 'Ovulation',
      color: Color(0xFF7C4DFF),
      description:
          'Ovulation:\nRelease of an egg (estimated). Peak fertility + possible slight temperature rise. Some feel mild one‑sided discomfort.',
    ),
    CyclePhase.luteal: const _PhaseMeta(
      label: 'Luteal',
      color: Color(0xFFFFB74D),
      description:
          'Luteal Phase:\nProgesterone dominant. Can bring calm focus early, then possible PMS symptoms late. Prioritize balanced nutrition and stress care.',
    ),
  };

  Color _phaseColor(CyclePhase? phase, {bool dim = false}) {
    if (phase == null) return Colors.grey.withOpacity(dim ? .18 : .25);
    final c = _phaseMeta[phase]!.color;
    return dim ? c.withOpacity(.18) : c;
  }

  void _showPhasePopup(CyclePhase phase) {
    final meta = _phaseMeta[phase]!;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return Opacity(
          opacity: curved.value,
          child: Transform.scale(
            scale: .88 + (.12 * curved.value),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white.withOpacity(.18)),
                  boxShadow: [
                    BoxShadow(
                      color: meta.color.withOpacity(.45),
                      blurRadius: 28,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: meta.color,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(meta.label,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .4)),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, size: 20),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meta.description,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '* Educational guidance only; not a diagnostic tool.',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorLegend() {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calendar Legend',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final entry in _phaseMeta.entries)
                  GestureDetector(
                    onTap: () => _showPhasePopup(entry.key),
                    child: InfoRect(
                      title: entry.value.label,
                      color: entry.value.color,
                      textColor: entry.value.color.computeLuminance() > .55
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('* Predictions are estimates and not medical advice.',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();
      if (!settingsProvider.isConfigured) {
        _showSetupReminder();
      }
    });
  }

  void _showSetupReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please configure your app in Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to settings
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ),
    );
  }

  void _ensureBgAnimation() {
    if (_bgController == null) {
      _bgController = AnimationController(
          vsync: this, duration: const Duration(seconds: 16));
    }
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
                    Colors.pink.shade400, Colors.indigo.shade500, 1 - t)!,
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
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              if (settingsProvider.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              final settings = settingsProvider.settings;
              final now = DateTime.now();
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    backgroundColor: theme.colorScheme.surface.withOpacity(.08),
                    title: const Text('DrippSafe',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    actions: [
                      IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full-bleed glass welcome card
                        _AnimatedSection(child: _buildWelcomeSection(settings)),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AnimatedSection(
                                  child: _buildQuickStats(now), delay: .05),
                              const SizedBox(height: 18),
                              _AnimatedSection(
                                  child: _buildColorLegend(), delay: .1),
                              const SizedBox(height: 18),
                              _AnimatedSection(
                                  child:
                                      _buildCalendarSection(settingsProvider),
                                  delay: .15),
                              const SizedBox(height: 18),
                              _AnimatedSection(
                                  child: _buildTipsSection(), delay: .2),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(UserSettings settings) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: _GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${settings.name.isNotEmpty ? settings.name : ''}!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Track your cycle with confidence',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 194, 193, 193),
                      fontSize: 15,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(DateTime now) {
    final items = [
      InfoCard(title: 'Year', value: DateFormat('yyyy').format(now)),
      InfoCard(title: 'Month', value: DateFormat('MM').format(now)),
      InfoCard(title: 'Day', value: DateFormat('dd').format(now)),
    ];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(child: items[i]),
          if (i != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  // (Interactive color legend defined earlier; old static version removed)

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Widget _buildCalendarSection(SettingsProvider settingsProvider) {
    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth);
    final matrix = settingsProvider.monthMatrix(_focusedMonth);
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous Month',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                ),
                Expanded(
                  child: Center(
                    child: Text(monthLabel,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(
                  tooltip: 'Next Month',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DowLabel('Mon'),
                _DowLabel('Tue'),
                _DowLabel('Wed'),
                _DowLabel('Thu'),
                _DowLabel('Fri'),
                _DowLabel('Sat'),
                _DowLabel('Sun'),
              ],
            ),
            const SizedBox(height: 8),
            for (final week in matrix) ...[
              Row(
                children: [
                  for (final date in week)
                    Expanded(child: _buildDayCell(settingsProvider, date)),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _focusedMonth =
                    DateTime(DateTime.now().year, DateTime.now().month)),
                icon: const Icon(Icons.today, size: 18),
                label: const Text('Today'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(SettingsProvider provider, DateTime date) {
    final info = provider.dayInfo(date);
    final today = DateTime.now();
    final isCurrentMonth = date.month == _focusedMonth.month;
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    Color bg = _phaseColor(info?.phase);
    if (!isCurrentMonth) {
      bg = bg.withOpacity(.18);
    } else if (info?.isPredicted == true) {
      bg = bg.withOpacity(.55);
    }
    final textColor = (info?.phase == CyclePhase.menstrual ||
            info?.phase == CyclePhase.ovulation)
        ? Colors.white
        : Colors.black87;
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: info == null ? null : () => _showDayDialog(info),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: bg,
              border:
                  isToday ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow: [
                if (info?.phase == CyclePhase.ovulation)
                  BoxShadow(
                      color: const Color(0xFF7C4DFF).withOpacity(.6),
                      blurRadius: 8,
                      spreadRadius: 1),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${date.day}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textColor)),
                if (info?.phase == CyclePhase.ovulation)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child:
                        Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDayDialog(CycleDayInfo info) {
    showDialog(
      context: context,
      builder: (_) {
        String phaseLabel =
            info.phase.name[0].toUpperCase() + info.phase.name.substring(1);
        return AlertDialog(
          title: Text(DateFormat('EEEE, MMM d').format(info.date)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phase: $phaseLabel'),
              const SizedBox(height: 6),
              Text('Day ${info.dayOfCycle} of cycle'),
              const SizedBox(height: 6),
              Text('Cycle Index: ${info.cycleIndex}'),
              const SizedBox(height: 6),
              Text(
                  'Expected next period: ${DateFormat('MMM d, yyyy').format(info.expectedNextPeriodStart)}'),
              if (info.phase == CyclePhase.ovulation) ...[
                const SizedBox(height: 6),
                const Text('Ovulation (estimated)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
              if (info.isPredicted) ...[
                const SizedBox(height: 10),
                const Text('Predicted data – subject to variation',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _buildTipsSection() {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const TipCard(
              title: 'Stay Hydrated',
              imgName: 'assets/images/workout.png',
            ),
            const SizedBox(height: 12),
            const TipCard(
              title: 'Exercise Regularly',
              imgName: 'assets/images/sleep.png',
            ),
          ],
        ),
      ),
    );
  }
}

// Simple fade+slide in wrapper for section appearance
class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final double delay; // 0-1 relative delay fraction
  const _AnimatedSection({required this.child, this.delay = 0, Key? key})
      : super(key: key);

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, .12), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: (widget.delay * 600).round()), () {
        if (mounted) _controller.forward();
      });
    });
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
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// Glass-like card container to match tips/favourites look
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.14),
        border: Border.all(color: Colors.white.withOpacity(.15)),
      ),
      child: child,
    );
  }
}

class _DowLabel extends StatelessWidget {
  final String text;
  const _DowLabel(this.text, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: .3,
          ),
        ),
      ),
    );
  }
}

// Internal metadata holder for cycle phase legend and popups
class _PhaseMeta {
  final String label;
  final Color color;
  final String description;
  const _PhaseMeta({
    required this.label,
    required this.color,
    required this.description,
  });
}
