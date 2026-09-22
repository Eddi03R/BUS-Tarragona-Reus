import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../services/locale_controller.dart';
import '../services/subscription_controller.dart';
import '../services/theme_controller.dart';
import '../widgets/app_date_picker.dart';

class _ThemeOption {
  final String Function(AppLocalizations) labelOf;
  final Color color;
  const _ThemeOption(this.labelOf, this.color);
}

final _themeOptions = [
  _ThemeOption((l) => l.colorGreen, ThemeController.defaultSeed),
  _ThemeOption((l) => l.colorBlue, const Color(0xFF1565C0)),
  _ThemeOption((l) => l.colorIndigo, const Color(0xFF3949AB)),
  _ThemeOption((l) => l.colorPurple, const Color(0xFF7B1FA2)),
  _ThemeOption((l) => l.colorMagenta, const Color(0xFFAD1457)),
  _ThemeOption((l) => l.colorCoral, const Color(0xFFD84315)),
  _ThemeOption((l) => l.colorOrange, const Color(0xFFEF6C00)),
  _ThemeOption((l) => l.colorAmber, const Color(0xFFF9A825)),
  _ThemeOption((l) => l.colorTeal, const Color(0xFF00838F)),
  _ThemeOption((l) => l.colorPetrol, const Color(0xFF00695C)),
];

enum _DurationOption { oneMonth, twoMonths, threeMonths, custom }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _subscription = SubscriptionController.instance;

  DateTime _formPurchaseDate = DateTime.now();
  DateTime? _formCustomExpiry;
  _DurationOption _formDuration = _DurationOption.oneMonth;

  DateTime _computeExpiry() {
    switch (_formDuration) {
      case _DurationOption.oneMonth:
        return DateTime(_formPurchaseDate.year, _formPurchaseDate.month + 1, _formPurchaseDate.day);
      case _DurationOption.twoMonths:
        return DateTime(_formPurchaseDate.year, _formPurchaseDate.month + 2, _formPurchaseDate.day);
      case _DurationOption.threeMonths:
        return DateTime(_formPurchaseDate.year, _formPurchaseDate.month + 3, _formPurchaseDate.day);
      case _DurationOption.custom:
        return _formCustomExpiry ?? _formPurchaseDate;
    }
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showAppDatePicker(
      context,
      initialDate: _formPurchaseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _formPurchaseDate = picked);
  }

  Future<void> _pickCustomExpiry() async {
    final picked = await showAppDatePicker(
      context,
      initialDate: _formCustomExpiry ?? _formPurchaseDate.add(const Duration(days: 30)),
      firstDate: _formPurchaseDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _formCustomExpiry = picked);
  }

  Future<void> _save(AppLocalizations l) async {
    if (_formDuration == _DurationOption.custom && _formCustomExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.chooseCustomExpiryWarning)),
      );
      return;
    }
    await _subscription.setSubscription(purchaseDate: _formPurchaseDate, expiryDate: _computeExpiry());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: AnimatedBuilder(
        animation: ThemeController.instance,
        builder: (context, _) {
          final current = ThemeController.instance.seedColor;
          final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l.appearance,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                l.appearanceSubtitle,
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.light, label: Text(l.light), icon: const Icon(Icons.light_mode_rounded)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(l.dark), icon: const Icon(Icons.dark_mode_rounded)),
                  ButtonSegment(value: ThemeMode.system, label: Text(l.system), icon: const Icon(Icons.smartphone_rounded)),
                ],
                selected: {ThemeController.instance.themeMode},
                onSelectionChanged: (s) => ThemeController.instance.setThemeMode(s.first),
              ),
              const SizedBox(height: 28),
              Text(
                l.themeColor,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                l.themeColorSubtitle,
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
              const SizedBox(height: 28),
              Text(
                l.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                l.languageSubtitle,
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: LocaleController.instance,
                builder: (context, _) {
                  final selectedLocale = LocaleController.instance.locale;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l.languageSystem),
                        selected: selectedLocale == null,
                        onSelected: (_) => LocaleController.instance.setLocale(null),
                      ),
                      for (final locale in LocaleController.supportedLocales)
                        ChoiceChip(
                          label: Text(_languageName(l, locale.languageCode)),
                          selected: selectedLocale?.languageCode == locale.languageCode,
                          onSelected: (_) => LocaleController.instance.setLocale(locale),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                l.subscription,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                l.subscriptionSubtitle,
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _subscription,
                builder: (context, _) => _subscription.hasSubscription
                    ? _buildActiveSubscription(context, l)
                    : _buildSubscriptionForm(context, l),
              ),
            ],
          );
        },
      ),
    );
  }

  String _languageName(AppLocalizations l, String code) {
    switch (code) {
      case 'it':
        return l.languageItalian;
      case 'ca':
        return l.languageCatalan;
      case 'es':
        return l.languageSpanish;
      case 'en':
        return l.languageEnglish;
      case 'de':
        return l.languageGerman;
      default:
        return code;
    }
  }

  Widget _buildActiveSubscription(BuildContext context, AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    final days = _subscription.daysRemaining!;
    final expired = days < 0;
    final soon = !expired && days <= 7;
    final color = expired ? Colors.red[700]! : (soon ? Colors.orange[700]! : Colors.green[700]!);
    final localeName = Localizations.localeOf(context).languageCode;
    final expiryDateLabel = DateFormat('d MMMM yyyy', localeName).format(_subscription.expiryDate!);
    final statusText = expired
        ? l.expiredDays(-days)
        : days == 0
            ? l.expiresToday
            : l.expiresInDays(days);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number_rounded, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                    Text(l.expiryLabel(expiryDateLabel), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _subscription.clear(),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l.removeSubscription),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionForm(BuildContext context, AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    final localeName = Localizations.localeOf(context).languageCode;
    final purchaseLabel = DateFormat('d MMMM yyyy', localeName).format(_formPurchaseDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.purchaseDate, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _pickPurchaseDate,
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(purchaseLabel),
          ),
          const SizedBox(height: 16),
          Text(l.duration, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l.oneMonth),
                selected: _formDuration == _DurationOption.oneMonth,
                onSelected: (_) => setState(() => _formDuration = _DurationOption.oneMonth),
              ),
              ChoiceChip(
                label: Text(l.twoMonths),
                selected: _formDuration == _DurationOption.twoMonths,
                onSelected: (_) => setState(() => _formDuration = _DurationOption.twoMonths),
              ),
              ChoiceChip(
                label: Text(l.threeMonths),
                selected: _formDuration == _DurationOption.threeMonths,
                onSelected: (_) => setState(() => _formDuration = _DurationOption.threeMonths),
              ),
              ChoiceChip(
                label: Text(l.customDuration),
                selected: _formDuration == _DurationOption.custom,
                onSelected: (_) => setState(() => _formDuration = _DurationOption.custom),
              ),
            ],
          ),
          if (_formDuration == _DurationOption.custom) ...[
            const SizedBox(height: 12),
            Text(l.expiryDate, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _pickCustomExpiry,
              icon: const Icon(Icons.event_rounded),
              label: Text(_formCustomExpiry == null
                  ? l.chooseDate
                  : DateFormat('d MMMM yyyy', localeName).format(_formCustomExpiry!)),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _save(l),
              child: Text(l.saveSubscription),
            ),
          ),
        ],
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
    final l = AppLocalizations.of(context)!;
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
              option.labelOf(l),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
