import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../app_version.dart';
import 'package:intl/intl.dart';
import '../services/ads_controller.dart';
import '../services/analytics_service.dart';
import '../services/locale_controller.dart';
import '../services/location_controller.dart';
import '../services/subscription_controller.dart';
import '../services/theme_controller.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/christmas_decorations.dart';
import '../widgets/themed_banner.dart';
import 'privacy_policy_screen.dart';
import 'support_screen.dart';

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
  _ThemeOption((_) => 'Halloween 🎃', ThemeController.halloweenSeed),
  _ThemeOption((_) => 'Natale 🎄', ThemeController.christmasSeed),
];

enum _DurationOption { oneMonth, twoMonths, threeMonths, custom }


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

/// Modalità chiaro/scuro effettiva: Halloween è sempre scuro, Natale sempre chiaro.
ThemeMode? _lockedMode() => ThemeController.instance.isHalloween
    ? ThemeMode.dark
    : ThemeController.instance.isChristmas
        ? ThemeMode.light
        : null;

// ============================================================ MENU PRINCIPALE
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  String _appearanceValue(AppLocalizations l) {
    final seed = ThemeController.instance.seedColor.value;
    final theme = _themeOptions
        .firstWhere((o) => o.color.value == seed, orElse: () => _themeOptions.first)
        .labelOf(l);
    final mode = _lockedMode() ?? ThemeController.instance.themeMode;
    final modeLabel = mode == ThemeMode.light
        ? l.light
        : mode == ThemeMode.dark
            ? l.dark
            : l.system;
    return '$theme · $modeLabel';
  }

  String _languageValue(AppLocalizations l) {
    final locale = LocaleController.instance.locale;
    return locale == null ? l.languageSystem : _languageName(l, locale.languageCode);
  }

  String _passValue(AppLocalizations l) {
    final s = SubscriptionController.instance;
    if (!s.hasSubscription) return l.notSet;
    final days = s.daysRemaining!;
    if (days < 0) return l.expiredDays(-days);
    return days == 0 ? l.expiresToday : l.expiresInDays(days);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ChristmasBackdrop(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            ThemeController.instance,
            LocaleController.instance,
            SubscriptionController.instance,
            LocationController.instance,
            AnalyticsService.instance,
          ]),
          builder: (context, _) {
            final analytics = AnalyticsService.instance;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (SupportScreen.available) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _open(context, const SupportScreen()),
                    child: ThemedBanner(
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, size: 30),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.supportTitle,
                                    style: const TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(l.supportBannerShort,
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.palette_rounded,
                        title: l.appearance,
                        value: _appearanceValue(l),
                        onTap: () => _open(context, const AppearanceScreen()),
                      ),
                      _MenuTile(
                        icon: Icons.language_rounded,
                        title: l.language,
                        value: _languageValue(l),
                        onTap: () => _open(context, const LanguageScreen()),
                      ),
                      _MenuTile(
                        icon: Icons.confirmation_number_rounded,
                        title: l.subscription,
                        value: _passValue(l),
                        onTap: () => _open(context, const TransportPassScreen()),
                      ),
                      _MenuTile(
                        icon: Icons.my_location_rounded,
                        title: l.locationTitle,
                        value: LocationController.instance.isEnabled
                            ? l.settingOn
                            : l.settingOff,
                        onTap: () => _open(context, const LocationScreen()),
                      ),
                      _MenuTile(
                        icon: Icons.shield_rounded,
                        title: l.privacyAndStats,
                        value: analytics.ready
                            ? '${l.analyticsSwitchTitle}: ${analytics.enabled ? l.settingOn : l.settingOff}'
                            : null,
                        onTap: () => _open(context, const PrivacySettingsScreen()),
                      ),
                      _MenuTile(
                        icon: Icons.info_rounded,
                        title: l.infoTitle,
                        value: kAppVersion,
                        onTap: () => _open(context, const AboutScreen()),
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(l.copyright,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool last;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(icon, color: scheme.onPrimaryContainer, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: value == null
              ? null
              : Text(value!, style: TextStyle(color: scheme.onSurfaceVariant)),
          trailing: Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          onTap: onTap,
        ),
        if (!last) Divider(height: 1, indent: 72, color: scheme.outlineVariant.withOpacity(0.5)),
      ],
    );
  }
}

/// Struttura comune delle sotto-pagine: barra, sfondo a tema e lista.
class _SubPage extends StatelessWidget {
  final String title;
  final Listenable? listenable;
  final List<Widget> Function(BuildContext context, AppLocalizations l) builder;
  const _SubPage({required this.title, required this.builder, this.listenable});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ChristmasBackdrop(
        child: ListenableBuilder(
          listenable: listenable ?? ThemeController.instance,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: builder(context, l),
          ),
        ),
      ),
    );
  }
}

Widget _heading(BuildContext context, String title, [String? subtitle]) {
  final sub = Theme.of(context).colorScheme.onSurfaceVariant;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: sub, fontSize: 13)),
      ],
    ],
  );
}

// ================================================================== ASPETTO
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubPage(
      title: AppLocalizations.of(context)!.appearance,
      builder: (context, l) {
        final current = ThemeController.instance.seedColor;
        final locked = _lockedMode();
        bool on(ThemeMode m) => locked == null || locked == m;
        final regular = _themeOptions.where((o) =>
            o.color.value != ThemeController.halloweenSeed.value &&
            o.color.value != ThemeController.christmasSeed.value);
        final special = _themeOptions.where((o) =>
            o.color.value == ThemeController.halloweenSeed.value ||
            o.color.value == ThemeController.christmasSeed.value);
        Widget swatches(Iterable<_ThemeOption> options) => Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                for (final option in options)
                  _ColorSwatch(
                    option: option,
                    selected: option.color.value == current.value,
                    onTap: () {
                      AnalyticsService.instance.log(
                          'theme_change', {'theme': option.color.value.toRadixString(16)});
                      ThemeController.instance.setSeedColor(option.color);
                    },
                  ),
              ],
            );
        return [
          ThemedBanner(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ErasBus Tarragona',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(l.titleDaylife,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _heading(context, l.appearance, l.appearanceSubtitle),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.light, enabled: on(ThemeMode.light), label: Text(l.light), icon: const Icon(Icons.light_mode_rounded)),
              ButtonSegment(value: ThemeMode.dark, enabled: on(ThemeMode.dark), label: Text(l.dark), icon: const Icon(Icons.dark_mode_rounded)),
              ButtonSegment(value: ThemeMode.system, enabled: on(ThemeMode.system), label: Text(l.system), icon: const Icon(Icons.smartphone_rounded)),
            ],
            selected: {locked ?? ThemeController.instance.themeMode},
            onSelectionChanged: locked != null
                ? null
                : (s) => ThemeController.instance.setThemeMode(s.first),
          ),
          const SizedBox(height: 28),
          _heading(context, l.themeColor, l.themeColorSubtitle),
          const SizedBox(height: 16),
          swatches(regular),
          const SizedBox(height: 28),
          _heading(context, l.specialThemes, l.specialThemesNote),
          const SizedBox(height: 16),
          swatches(special),
        ];
      },
    );
  }
}

// =================================================================== LINGUA
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubPage(
      title: AppLocalizations.of(context)!.language,
      listenable: LocaleController.instance,
      builder: (context, l) {
        final selected = LocaleController.instance.locale;
        return [
          _heading(context, l.language, l.languageSubtitle),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l.languageSystem),
                selected: selected == null,
                onSelected: (_) => LocaleController.instance.setLocale(null),
              ),
              for (final locale in LocaleController.supportedLocales)
                ChoiceChip(
                  label: Text(_languageName(l, locale.languageCode)),
                  selected: selected?.languageCode == locale.languageCode,
                  onSelected: (_) => LocaleController.instance.setLocale(locale),
                ),
            ],
          ),
        ];
      },
    );
  }
}

// ========================================================== ABBONAMENTO TRASPORTI
class TransportPassScreen extends StatefulWidget {
  const TransportPassScreen({super.key});

  @override
  State<TransportPassScreen> createState() => _TransportPassScreenState();
}

class _TransportPassScreenState extends State<TransportPassScreen> {
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
      appBar: AppBar(title: Text(l.subscription)),
      body: ChristmasBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l.subscriptionSubtitle,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _subscription,
              builder: (context, _) => _subscription.hasSubscription
                  ? _buildActiveSubscription(context, l)
                  : _buildSubscriptionForm(context, l),
            ),
          ],
        ),
      ),
    );
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

// ================================================================== POSIZIONE
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubPage(
      title: AppLocalizations.of(context)!.locationTitle,
      listenable: LocationController.instance,
      builder: (context, l) {
        final sub = Theme.of(context).colorScheme.onSurfaceVariant;
        return [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.my_location_rounded),
            title: Text(l.locationEnabled),
            subtitle: Text(l.locationEnabledSubtitle,
                style: TextStyle(fontSize: 12, color: sub)),
            value: LocationController.instance.isEnabled,
            onChanged: (v) async {
              final ok = await LocationController.instance.setEnabled(v);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.locationPermissionDenied)),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          Text(l.locationSubtitle, style: TextStyle(color: sub, fontSize: 13)),
        ];
      },
    );
  }
}

// ======================================================= PRIVACY E STATISTICHE
class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubPage(
      title: AppLocalizations.of(context)!.privacyAndStats,
      listenable: Listenable.merge([AnalyticsService.instance, AdsController.instance]),
      builder: (context, l) {
        final sub = Theme.of(context).colorScheme.onSurfaceVariant;
        return [
          if (AnalyticsService.instance.ready)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.insights_rounded),
              title: Text(l.analyticsSwitchTitle),
              subtitle: Text(l.analyticsSwitchSubtitle,
                  style: TextStyle(fontSize: 12, color: sub)),
              value: AnalyticsService.instance.enabled,
              onChanged: AnalyticsService.instance.setChoice,
            ),
          if (AdsController.instance.privacyOptionsRequired)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.ads_click_rounded),
              title: Text(l.adPrivacyOptions),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: AdsController.instance.showPrivacyOptions,
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyPolicyTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
        ];
      },
    );
  }
}

// ============================================================== INFORMAZIONI
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = Theme.of(context).colorScheme.onSurfaceVariant;
    return _SubPage(
      title: AppLocalizations.of(context)!.infoTitle,
      builder: (context, l) => [
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.directions_bus_rounded),
          title: Text('ErasBus Tarragona',
              style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Lume Labs App'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.tag_rounded),
          title: Text(kAppVersion),
        ),
        const SizedBox(height: 8),
        Text(l.copyright, style: TextStyle(fontSize: 12, color: sub)),
      ],
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
    final isHalloween = option.color.value == ThemeController.halloweenSeed.value;
    final isChristmas = option.color.value == ThemeController.christmasSeed.value;
    final displayColor = isHalloween ? const Color(0xFFFF6B00) : option.color;
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
                gradient: isHalloween
                    ? const RadialGradient(
                        colors: [Color(0xFFFF6B00), Color(0xFF1A0A00)],
                        center: Alignment(0, -0.3),
                        radius: 1.2,
                      )
                    : isChristmas
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFE53935), Color(0xFFE53935),
                              Color(0xFF2E9B4A), Color(0xFF2E9B4A),
                            ],
                            stops: [0, 0.5, 0.5, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                color: (isHalloween || isChristmas) ? null : displayColor,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(
                        color: isHalloween
                            ? const Color(0xFFFF6B00)
                            : Theme.of(context).colorScheme.onSurface,
                        width: 2.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: displayColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: isHalloween
                  ? const Center(child: Text('🎃', style: TextStyle(fontSize: 26)))
                  : isChristmas
                      ? const Center(child: Text('🎄', style: TextStyle(fontSize: 26)))
                      : selected
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
