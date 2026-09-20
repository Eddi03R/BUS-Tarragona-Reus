import 'package:flutter/material.dart';
import '../services/theme_controller.dart';

class _ThemeOption {
  final String name;
  final Color color;
  const _ThemeOption(this.name, this.color);
}

const _themeOptions = [
  _ThemeOption('Verde Monbus', ThemeController.defaultSeed),
  _ThemeOption('Blu', Color(0xFF1565C0)),
  _ThemeOption('Indaco', Color(0xFF3949AB)),
  _ThemeOption('Viola', Color(0xFF7B1FA2)),
  _ThemeOption('Magenta', Color(0xFFAD1457)),
  _ThemeOption('Rosso corallo', Color(0xFFD84315)),
  _ThemeOption('Arancione', Color(0xFFEF6C00)),
  _ThemeOption('Ambra', Color(0xFFF9A825)),
  _ThemeOption('Turchese', Color(0xFF00838F)),
  _ThemeOption('Blu petrolio', Color(0xFF00695C)),
];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: AnimatedBuilder(
        animation: ThemeController.instance,
        builder: (context, _) {
          final current = ThemeController.instance.seedColor;
          final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Aspetto',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Chiaro, scuro o come da impostazioni del dispositivo.',
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Chiaro'), icon: Icon(Icons.light_mode_rounded)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Scuro'), icon: Icon(Icons.dark_mode_rounded)),
                  ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.smartphone_rounded)),
                ],
                selected: {ThemeController.instance.themeMode},
                onSelectionChanged: (s) => ThemeController.instance.setThemeMode(s.first),
              ),
              const SizedBox(height: 28),
              Text(
                'Colore del tema',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Scegli il colore principale dell\'app.',
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  for (final option in _themeOptions)
                    _ColorSwatch(
                      option: option,
                      selected: option.color.value == current.value,
                      onTap: () => ThemeController.instance.setSeedColor(option.color),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final _ThemeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: selected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2.5) : null,
                boxShadow: [
                  BoxShadow(color: option.color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              option.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
