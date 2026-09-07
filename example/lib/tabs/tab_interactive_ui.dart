import 'package:flutter/material.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';
import '../theme.dart';

class TabInteractiveUI extends StatefulWidget {
  const TabInteractiveUI({super.key});

  @override
  State<TabInteractiveUI> createState() => _TabInteractiveUIState();
}

class _TabInteractiveUIState extends State<TabInteractiveUI> {
  // SwipeableCard state
  final GlobalKey<SwipeableCardState> _cardKey = GlobalKey<SwipeableCardState>();
  String _swipeFeedback = 'Drag card or press action buttons below';
  int _cardIndex = 1;

  // SpringSegmentedControl state
  final List<String> _segments = const ['Trending', 'Critique', 'Vault'];
  String _selectedSegment = 'Trending';

  // SpringFilterChip state
  final Set<String> _selectedFilters = {'4K HDR', 'Dolby Atmos'};
  final List<String> _availableFilters = const [
    '4K HDR',
    'Dolby Atmos',
    'IMAX Enhanced',
    'Directors Cut',
    '70mm Film',
  ];

  void _resetCard() {
    setState(() {
      _cardIndex++;
      _swipeFeedback = 'Card #$_cardIndex ready';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('1. SwipeableCard (4-Way Drag Physics)', colors),
        const SizedBox(height: 8),
        Text(
          'Velocity-aware drag-to-commit deck physics with HouseSpring settle and programmatic flyOff hooks.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 16),

        Center(
          child: SizedBox(
            width: 300,
            height: 230,
            child: SwipeableCard(
              key: _cardKey,
              isInteractive: true,
              onDirectionChanged: (dir) {
                if (dir != null) {
                  setState(() => _swipeFeedback = 'Dragging: $dir');
                }
              },
              onCommitDecided: (dir) {
                setState(() => _swipeFeedback = 'Committed: $dir');
              },
              onSwipeCommitted: (dir) {
                _resetCard();
              },
              builder: (context, dragState) {
                return Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'CARD #$_cardIndex',
                                    style: TextStyle(color: colors.accent, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                Icon(Icons.swipe, color: colors.accent, size: 24),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blade Runner 2049',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Denis Villeneuve • Sci-Fi Noir',
                                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              _swipeFeedback,
                              style: TextStyle(color: colors.accent, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      // Live direction hint overlay
                      if (dragState.activeDirection != null && dragState.hintOpacity > 0.0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: (dragState.activeDirection == 'right'
                                        ? Colors.green
                                        : dragState.activeDirection == 'left'
                                            ? Colors.red
                                            : colors.accent)
                                    .withValues(alpha: dragState.hintOpacity * 0.25),
                              ),
                              child: Center(
                                child: Text(
                                  dragState.activeDirection!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),
        // Programmatic flyOff action triggers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PressableScale(
              onTap: () => _cardKey.currentState?.flyOff('Left', _resetCard),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 24),
              ),
            ),
            const SizedBox(width: 20),
            PressableScale(
              onTap: () => _cardKey.currentState?.flyOff('Up', _resetCard),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
                ),
                child: Icon(Icons.star, color: colors.accent, size: 24),
              ),
            ),
            const SizedBox(width: 20),
            PressableScale(
              onTap: () => _cardKey.currentState?.flyOff('Right', _resetCard),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.favorite, color: Colors.green, size: 24),
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),
        _buildSectionHeader('2. SpringSegmentedControl<T> (Animated Pill)', colors),
        const SizedBox(height: 12),
        SpringSegmentedControl<String>(
          items: _segments,
          selectedItem: _selectedSegment,
          labelBuilder: (item) => item,
          onSelected: (item) => setState(() => _selectedSegment = item),
          trackColor: colors.surfaceVariant,
          trackBorderColor: colors.border,
          selectedPillColor: colors.accent,
          selectedTextColor: Colors.black,
          unselectedTextColor: colors.textSecondary,
        ),

        const SizedBox(height: 36),
        _buildSectionHeader('3. SpringFilterChip (Selection Physics)', colors),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filter in _availableFilters)
              SpringFilterChip(
                label: filter,
                isSelected: _selectedFilters.contains(filter),
                onTap: () {
                  setState(() {
                    if (_selectedFilters.contains(filter)) {
                      _selectedFilters.remove(filter);
                    } else {
                      _selectedFilters.add(filter);
                    }
                  });
                },
                selectedDecoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.accent),
                ),
                unselectedDecoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.border),
                ),
                selectedTextColor: Colors.black,
                unselectedTextColor: colors.textSecondary,
              ),
          ],
        ),

        const SizedBox(height: 36),
        _buildSectionHeader('4. DragToDismissSheet & PressableScale', colors),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PressableScale(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (sheetContext) {
                      return DragToDismissSheet(
                        onDismiss: () => Navigator.of(sheetContext).pop(),
                        handleColor: colors.accent,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Velocity-Aware Dismiss Sheet',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Drag down gently to test HouseSpring snap-back, or fling downwards past velocity threshold to dismiss cleanly.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 24),
                              PressableScale(
                                onTap: () => Navigator.of(sheetContext).pop(),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: colors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Close Sheet',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.vertical_align_bottom, color: colors.accent),
                        const SizedBox(width: 8),
                        Text(
                          'Open Bottom Sheet',
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
}
