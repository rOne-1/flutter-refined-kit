import 'package:flutter/material.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';
import '../theme.dart';

class TabAlgorithmsTheming extends StatefulWidget {
  final PersistedThemeController<MockColors> controller;

  const TabAlgorithmsTheming({super.key, required this.controller});

  @override
  State<TabAlgorithmsTheming> createState() => _TabAlgorithmsThemingState();
}

class _TabAlgorithmsThemingState extends State<TabAlgorithmsTheming> {
  // ScrollChromeTracker state
  final ScrollChromeTracker _chromeTracker = ScrollChromeTracker(collapseThreshold: 20.0);
  bool _chromeVisible = true;

  // Bayesian Weighted Rating state
  double _rawRating = 9.6;
  int _voteCount = 18;
  double _minVotesThreshold = 150.0;
  double _poolMean = 6.8;

  // File saver status
  String _ioStatus = 'Ready to test file export';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentTheme = widget.controller.current;

    final computedWeightedRating = weightedRating(
      r: _rawRating,
      v: _voteCount,
      m: _minVotesThreshold,
      c: _poolMean,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('1. ScrollChromeTracker (Hysteresis Direction)', colors),
        const SizedBox(height: 8),
        Text(
          'Scroll inside the feed below. Top bar collapses on downward scroll and immediately reveals on upward scroll using hysteresis damping.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 12),

        Container(
          height: 240,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  final newVisibility = _chromeTracker.handle(notification);
                  if (newVisibility != null && newVisibility != _chromeVisible) {
                    setState(() => _chromeVisible = newVisibility);
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 16),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Feed Item #${index + 1} — Scroll to test chrome collapse',
                        style: TextStyle(color: colors.textSecondary, fontSize: 13),
                      ),
                    );
                  },
                ),
              ),

              // Animated collapsing chrome
              AnimatedPositioned(
                duration: HouseSpring.duration,
                curve: HouseSpring.curve,
                top: _chromeVisible ? 0 : -50,
                left: 0,
                right: 0,
                height: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(bottom: BorderSide(color: colors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Collapsing Header Bar',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _chromeVisible ? 'VISIBLE' : 'HIDDEN',
                          style: TextStyle(color: colors.accent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),
        _buildSectionHeader('2. Bayesian Weighted Rating (IMDb Formula)', colors),
        const SizedBox(height: 8),
        Text(
          'WR = (v / (v + m)) * R + (m / (v + m)) * C\nPrevents low-vote titles from artificially topping ranking tables.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Raw Average', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        _rawRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      Text('($_voteCount votes)', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                    ],
                  ),
                  Icon(Icons.arrow_forward, color: colors.border),
                  Column(
                    children: [
                      Text('Bayesian Weighted', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        computedWeightedRating.toStringAsFixed(2),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.accent),
                      ),
                      Text('Rank Score', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 28),
              _buildSlider(
                label: 'Raw Title Rating (R): ${_rawRating.toStringAsFixed(1)}',
                value: _rawRating,
                min: 1.0,
                max: 10.0,
                onChanged: (v) => setState(() => _rawRating = v),
                colors: colors,
              ),
              _buildSlider(
                label: 'Vote Count (v): $_voteCount',
                value: _voteCount.toDouble(),
                min: 0.0,
                max: 1000.0,
                onChanged: (v) => setState(() => _voteCount = v.round()),
                colors: colors,
              ),
              _buildSlider(
                label: 'Min Threshold (m): ${_minVotesThreshold.round()}',
                value: _minVotesThreshold,
                min: 20.0,
                max: 500.0,
                onChanged: (v) => setState(() => _minVotesThreshold = v),
                colors: colors,
              ),
              _buildSlider(
                label: 'Pool Mean Rating (C): ${_poolMean.toStringAsFixed(1)}',
                value: _poolMean,
                min: 3.0,
                max: 9.0,
                onChanged: (v) => setState(() => _poolMean = v),
                colors: colors,
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),
        _buildSectionHeader('3. UniversalFileSaver (Cross-Platform IO)', colors),
        const SizedBox(height: 8),
        Text(
          'Cross-platform file save, share, and export bridge across Web, Desktop (Windows/macOS/Linux), and Mobile.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PressableScale(
                onTap: () async {
                  setState(() => _ioStatus = 'Saving sample JSON...');
                  try {
                    const sampleJson = '{"generator": "flutter_refined_kit", "version": "0.2.1"}';
                    final saved = await saveJsonFile(sampleJson, 'refined_kit_export.json');
                    setState(() => _ioStatus = saved ? 'File saved successfully' : 'Save cancelled');
                  } catch (e) {
                    setState(() => _ioStatus = 'Export error: $e');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, color: colors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Test Save File',
                          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _ioStatus,
          style: TextStyle(color: colors.accent, fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 36),
        _buildSectionHeader('4. Semantic Token Theme Engine & Elevation', colors),
        const SizedBox(height: 8),
        Text(
          'Instant live theme switching with SharedPreferences persistence. Card elevations use kit ShadowTokens.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            for (final theme in mockThemeRegistry.themes)
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.controller.setTheme(theme),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.id == currentTheme.id ? theme.colors.accent : theme.colors.border,
                        width: theme.id == currentTheme.id ? 2 : 1,
                      ),
                      boxShadow: buildThemeShadows(accent: theme.colors.accent, isDark: theme.isDark).cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          theme.displayName,
                          style: TextStyle(
                            color: theme.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          theme.isDark ? 'Dark' : 'Light',
                          style: TextStyle(color: theme.colors.textSecondary, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, MockColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required MockColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: colors.accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
