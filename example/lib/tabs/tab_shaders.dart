import 'package:flutter/material.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';
import '../theme.dart';

class TabShaders extends StatefulWidget {
  const TabShaders({super.key});

  @override
  State<TabShaders> createState() => _TabShadersState();
}

class _TabShadersState extends State<TabShaders> {
  // ShaderGradient state
  double _shaderSpeed = 1.0;
  double _shaderFrequency = 1.0;
  double _shaderGrain = 0.06;
  int _paletteIndex = 0;

  final List<List<Color>> _palettes = const [
    [Color(0xFFFF007F), Color(0xFF7928CA), Color(0xFF00DFD8)],
    [Color(0xFFFF4500), Color(0xFFFF8C00), Color(0xFFFFD700), Color(0xFF9400D3)],
    [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFF000BA2), Color(0xFF0575E6), Color(0xFF00F260)],
  ];

  // LiquidMetal state
  double _metalSpeed = 1.0;
  double _metalDistortion = 2.2;
  final double _metalFrequency = 2.0;
  int _metalColorIndex = 0;

  final List<({Color base, Color highlight, String name})> _metalPresets = const [
    (base: Color(0xFF1E222A), highlight: Color(0xFFF1F5F9), name: 'Chrome'),
    (base: Color(0xFF2A1B18), highlight: Color(0xFFFFD1BA), name: 'Rose Gold'),
    (base: Color(0xFF181528), highlight: Color(0xFFD8B4FE), name: 'Cosmic'),
  ];

  // AuroraGlow state
  bool _auroraDarkTier = true;

  // NoiseGrainOverlay state
  double _grainOpacity = 0.18;
  BlendMode _grainBlendMode = BlendMode.overlay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('1. ShaderGradient (ruucm/shadergradient)', colors),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ShaderGradient(
            colors: _palettes[_paletteIndex],
            speed: _shaderSpeed,
            frequency: _shaderFrequency,
            grainStrength: _shaderGrain,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3D Procedural Simplex Gradient',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          label: 'Speed: ${_shaderSpeed.toStringAsFixed(1)}x',
          value: _shaderSpeed,
          min: 0.2,
          max: 3.0,
          onChanged: (v) => setState(() => _shaderSpeed = v),
          colors: colors,
        ),
        _buildSlider(
          label: 'Frequency: ${_shaderFrequency.toStringAsFixed(1)}x',
          value: _shaderFrequency,
          min: 0.5,
          max: 3.0,
          onChanged: (v) => setState(() => _shaderFrequency = v),
          colors: colors,
        ),
        _buildSlider(
          label: 'Grain Strength: ${_shaderGrain.toStringAsFixed(2)}',
          value: _shaderGrain,
          min: 0.0,
          max: 0.15,
          onChanged: (v) => setState(() => _shaderGrain = v),
          colors: colors,
        ),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 0; i < _palettes.length; i++)
              ChoiceChip(
                label: Text('Palette ${i + 1} (${_palettes[i].length} stops)'),
                selected: _paletteIndex == i,
                onSelected: (_) => setState(() => _paletteIndex = i),
              ),
          ],
        ),

        const SizedBox(height: 32),
        _buildSectionHeader('2. LiquidMetal (paper-design/liquid-logo)', colors),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: LiquidMetal(
            baseColor: _metalPresets[_metalColorIndex].base,
            highlightColor: _metalPresets[_metalColorIndex].highlight,
            flowSpeed: _metalSpeed,
            distortionScale: _metalDistortion,
            frequency: _metalFrequency,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_metalPresets[_metalColorIndex].name} Liquid Chrome',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          label: 'Flow Speed: ${_metalSpeed.toStringAsFixed(1)}x',
          value: _metalSpeed,
          min: 0.2,
          max: 3.0,
          onChanged: (v) => setState(() => _metalSpeed = v),
          colors: colors,
        ),
        _buildSlider(
          label: 'Distortion Scale: ${_metalDistortion.toStringAsFixed(1)}',
          value: _metalDistortion,
          min: 0.5,
          max: 4.5,
          onChanged: (v) => setState(() => _metalDistortion = v),
          colors: colors,
        ),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 0; i < _metalPresets.length; i++)
              ChoiceChip(
                label: Text(_metalPresets[i].name),
                selected: _metalColorIndex == i,
                onSelected: (_) => setState(() => _metalColorIndex = i),
              ),
          ],
        ),

        const SizedBox(height: 32),
        _buildSectionHeader('3. AuroraGlow (Organic Wave Interference)', colors),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: AuroraGlow(
            color1: const Color(0xFF00E5FF),
            color2: const Color(0xFFFF007F),
            baseColor: colors.surface,
            isDark: _auroraDarkTier,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
            child: Center(
              child: Text(
                'Harmonic Wave Interference Glow',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Dark Surface Peak-Alpha Tier',
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
          ),
          value: _auroraDarkTier,
          onChanged: (v) => setState(() => _auroraDarkTier = v),
        ),

        const SizedBox(height: 32),
        _buildSectionHeader('4. NoiseGrainOverlay (Tactile Film Texture)', colors),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.accent, colors.accentSecondary],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: NoiseGrainOverlay(
                    opacity: _grainOpacity,
                    tint: Colors.white,
                    blendMode: _grainBlendMode,
                  ),
                ),
                const Center(
                  child: Text(
                    'Velvet / Film Paper Texture Overlay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          label: 'Grain Opacity: ${_grainOpacity.toStringAsFixed(2)}',
          value: _grainOpacity,
          min: 0.0,
          max: 0.5,
          onChanged: (v) => setState(() => _grainOpacity = v),
          colors: colors,
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Overlay'),
              selected: _grainBlendMode == BlendMode.overlay,
              onSelected: (_) => setState(() => _grainBlendMode = BlendMode.overlay),
            ),
            ChoiceChip(
              label: const Text('Screen'),
              selected: _grainBlendMode == BlendMode.screen,
              onSelected: (_) => setState(() => _grainBlendMode = BlendMode.screen),
            ),
            ChoiceChip(
              label: const Text('Multiply'),
              selected: _grainBlendMode == BlendMode.multiply,
              onSelected: (_) => setState(() => _grainBlendMode = BlendMode.multiply),
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
