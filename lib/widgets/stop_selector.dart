import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../data/schedule_repository.dart';
import '../models/stop.dart';
import '../models/poi.dart';
import '../models/stop_or_poi.dart';

Future<StopOrPoi?> showStopPicker(
  BuildContext context, {
  required String title,
  required List<Stop> stops,
  required List<Poi> pois,
}) {
  return showModalBottomSheet<StopOrPoi>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) =>
        _StopPickerSheet(title: title, options: stops, pois: pois),
  );
}

class StopSelectorField extends StatelessWidget {
  final String label;
  final IconData icon;
  final StopOrPoi? value;
  final List<Stop> options;
  final List<Poi> pois;
  final ValueChanged<StopOrPoi> onChanged;

  const StopSelectorField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    this.pois = const [],
  });

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<StopOrPoi>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          _StopPickerSheet(title: label, options: options, pois: pois),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(
                    value?.displayName ??
                        AppLocalizations.of(context)!.selectStop,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (value?.isPoi == true)
                    Text(
                      value!.displaySubtitle,
                      style: TextStyle(
                          fontSize: 11, color: scheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _StopPickerSheet extends StatefulWidget {
  final String title;
  final List<Stop> options;
  final List<Poi> pois;
  const _StopPickerSheet({
    required this.title,
    required this.options,
    required this.pois,
  });

  @override
  State<_StopPickerSheet> createState() => _StopPickerSheetState();
}

class _StopPickerSheetState extends State<_StopPickerSheet> {
  String _query = '';

  List<Stop> get _filteredStops => widget.options
      .where((s) =>
          s.name.toLowerCase().contains(_query.toLowerCase()) ||
          s.city.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  List<Poi> get _filteredPois => _query.isEmpty
      ? widget.pois
      : widget.pois
          .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filteredStops = _filteredStops;
    final filteredPois = _filteredPois;
    final l = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(widget.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: l.searchStopOrCity,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    if (filteredPois.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
                        child: Text(l.poiSectionTitle,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 0.8)),
                      ),
                      for (final poi in filteredPois) _PoiTile(poi: poi),
                      const SizedBox(height: 8),
                    ],
                    if (filteredStops.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
                        child: Text(l.stopsSectionTitle,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 0.8)),
                      ),
                      for (final stop in filteredStops) _StopTile(stop: stop),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PoiTile extends StatelessWidget {
  final Poi poi;
  const _PoiTile({required this.poi});

  @override
  Widget build(BuildContext context) {
    final icon =
        poi.isNightlife ? Icons.nightlife_rounded : Icons.school_rounded;
    final color = poi.isNightlife ? Colors.deepPurple : Colors.teal;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(poi.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        final stop =
            ScheduleRepository.instance.stopById(poi.nearestStopId);
        Navigator.of(context)
            .pop(StopOrPoi.fromPoi(stop: stop, poiRef: poi));
      },
    );
  }
}

class _StopTile extends StatelessWidget {
  final Stop stop;
  const _StopTile({required this.stop});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(Icons.directions_bus_filled_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20),
      ),
      title: Text(stop.name),
      subtitle: Text(stop.city),
      onTap: () => Navigator.of(context).pop(StopOrPoi.fromStop(stop)),
    );
  }
}
