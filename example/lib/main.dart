import 'package:flutter/material.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final themeController = PersistedThemeController<MockColors>(
    registry: mockThemeRegistry,
    prefs: prefs,
  );

  runApp(MockShowcaseApp(controller: themeController));
}

class MockShowcaseApp extends StatelessWidget {
  final PersistedThemeController<MockColors> controller;

  const MockShowcaseApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final currentTheme = controller.current;
        return MaterialApp(
          title: 'flutter_refined_kit Showcase',
          debugShowCheckedModeBanner: false,
          theme: currentTheme.themeData,
          home: ShowcaseHomeScreen(controller: controller),
        );
      },
    );
  }
}

class ShowcaseHomeScreen extends StatefulWidget {
  final PersistedThemeController<MockColors> controller;

  const ShowcaseHomeScreen({super.key, required this.controller});

  @override
  State<ShowcaseHomeScreen> createState() => _ShowcaseHomeScreenState();
}

class _ShowcaseHomeScreenState extends State<ShowcaseHomeScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabTitles = const [
    'Shaders & FX',
    'Glass & 3D Optics',
    'Interactive UI',
    'Algorithms & IO',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentTheme = widget.controller.current;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'flutter_refined_kit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              _tabTitles[_selectedTabIndex],
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.palette_outlined, color: colors.accent),
            tooltip: 'Select Theme (${currentTheme.displayName})',
            onSelected: (themeId) => widget.controller.setThemeById(themeId),
            itemBuilder: (context) {
              return mockThemeRegistry.themes.map((theme) {
                final isSelected = theme.id == currentTheme.id;
                return PopupMenuItem(
                  value: theme.id,
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? colors.accent : colors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(theme.displayName),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Text(
          'Tab ${_selectedTabIndex + 1}: ${_tabTitles[_selectedTabIndex]}',
          style: TextStyle(color: colors.textPrimary),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedTabIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.blur_on),
            label: 'Shaders',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            label: 'Glass & 3D',
          ),
          NavigationDestination(
            icon: Icon(Icons.touch_app_outlined),
            label: 'UI & Gestures',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            label: 'Algorithms',
          ),
        ],
      ),
    );
  }
}
