import 'package:drippsafe/providers/settings_provider.dart';
import 'package:drippsafe/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _loadingNameController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsProvider = context.read<SettingsProvider>();
    final settings = settingsProvider.settings;

    setState(() {
      _nameController.text = settings.name;
      _loadingNameController.text = settings.loadingName;
      _cycleLengthController.text = settings.cycleLength.toString();
      _startDate = settings.startDate;
      _endDate = settings.endDate;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          // Auto-calculate end date if start date is selected
          if (_endDate == null || _startDate!.isAfter(_endDate!)) {
            _endDate = _startDate!.add(const Duration(days: 4));
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showErrorSnackBar('Please select both start and end dates');
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      _showErrorSnackBar('Start date cannot be after end date');
      return;
    }

    final cycleLength = int.tryParse(_cycleLengthController.text);
    if (cycleLength == null || cycleLength < 21 || cycleLength > 35) {
      _showErrorSnackBar('Cycle length must be between 21 and 35 days');
      return;
    }

    try {
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.saveSettings(
        name: _nameController.text.trim(),
        loadingName: _loadingNameController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        cycleLength: cycleLength,
      );

      _showSuccessSnackBar('Settings saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to save settings: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Consolidated dispose will also dispose background controller below

  AnimationController? _bgController;
  bool _bgStarted = false;

  void _ensureBgAnimation() {
    if (_bgController == null) {
      _bgController = AnimationController(
          vsync: this, duration: const Duration(seconds: 14));
    }
    if (!_bgStarted) {
      _bgController!.repeat(reverse: true);
      _bgStarted = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _loadingNameController.dispose();
    _cycleLengthController.dispose();
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
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    backgroundColor: theme.colorScheme.surface.withOpacity(.08),
                    title: const Text('Settings',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AnimatedSection(
                              child: _GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Profile',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _nameController,
                                        labelText: 'Your Name',
                                        hintText: 'Enter your name',
                                        keyboardType: TextInputType.text,
                                        validator: (value) => (value == null ||
                                                value.trim().isEmpty)
                                            ? 'Please enter your name'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _loadingNameController,
                                        labelText: 'Loading Name',
                                        hintText:
                                            'Name shown on loading screen',
                                        keyboardType: TextInputType.text,
                                        validator: (value) => (value == null ||
                                                value.trim().isEmpty)
                                            ? 'Please enter a loading name'
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _AnimatedSection(
                              delay: .05,
                              child: _GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Period Settings',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller: _cycleLengthController,
                                        labelText: 'Cycle Length (days)',
                                        hintText: '28',
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty)
                                            return 'Please enter cycle length';
                                          final length = int.tryParse(value);
                                          if (length == null ||
                                              length < 21 ||
                                              length > 35)
                                            return 'Cycle length must be between 21 and 35 days';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Text('Last Period Dates',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  color: Colors.white70)),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        Expanded(
                                            child: _buildDateButton(
                                                'Start Date',
                                                _startDate,
                                                () => _selectDate(
                                                    context, true))),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: _buildDateButton(
                                                'End Date',
                                                _endDate,
                                                () => _selectDate(
                                                    context, false))),
                                      ]),
                                      if (_startDate != null &&
                                          _endDate != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withOpacity(.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: theme.colorScheme.primary
                                                    .withOpacity(.3)),
                                          ),
                                          child: Row(children: [
                                            Icon(Icons.info_outline,
                                                color:
                                                    theme.colorScheme.primary),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                  'Period length: ${_endDate!.difference(_startDate!).inDays + 1} days',
                                                  style: TextStyle(
                                                      color: theme
                                                          .colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ]),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _AnimatedSection(
                              delay: .1,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveSettings,
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18))),
                                  child: const Text('Save Settings',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            if (settingsProvider.error != null) ...[
                              const SizedBox(height: 20),
                              _AnimatedSection(
                                delay: .15,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error
                                        .withOpacity(.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: theme.colorScheme.error),
                                  ),
                                  child: Row(children: [
                                    Icon(Icons.error_outline,
                                        color: theme.colorScheme.error),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(settingsProvider.error!,
                                            style: TextStyle(
                                                color:
                                                    theme.colorScheme.error))),
                                  ]),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color: date != null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white24,
              width: 1.2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('MMM dd, yyyy').format(date)
                  : 'Select date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: date != null ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse animation & glass card patterns from dashboard
class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final double delay;
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
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.14),
        border: Border.all(color: Colors.white.withOpacity(.15)),
      ),
      child: child,
    );
  }
}
