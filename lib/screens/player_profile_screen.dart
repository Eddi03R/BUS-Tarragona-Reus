import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../games/game_art.dart';
import '../games/game_common.dart';
import '../games/game_intro_screen.dart' show gameTitle;
import '../services/leaderboard.dart';
import '../widgets/christmas_decorations.dart';

/// Mini profilo del giocatore (si apre dalla coppa nell'elenco giochi):
/// nome utente, trofei, gioco più usato, vinte/perse per gioco, classifica
/// della settimana e sfida.
class PlayerProfileScreen extends StatefulWidget {
  /// Solo per i test: classifiche già pronte (questa settimana, la scorsa) al posto di Firestore.
  final Future<(List<WeekRow>?, List<WeekRow>?)>? boards;
  const PlayerProfileScreen({super.key, this.boards});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final _lb = Leaderboard.instance;
  final _ctrl = TextEditingController();
  late final int _week = Leaderboard.weekOf(DateTime.now());
  late Future<(List<WeekRow>?, List<WeekRow>?)> _boards;
  bool _editing = false;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _boards = widget.boards ?? _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<(List<WeekRow>?, List<WeekRow>?)> _load() async {
    await _lb.sync(); // così la riga di questa settimana c'è anche per te
    return (await _lb.fetchWeek(_week), await _lb.fetchWeek(_week - 1));
  }

  Future<void> _save(AppLocalizations l) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await _lb.setName(_ctrl.text);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = switch (r) {
        null => null,
        'invalid' => l.profileNameInvalid,
        'bad' => l.profileNameBad,
        'taken' => l.profileNameTaken,
        'locked' => _lockedText(l),
        _ => l.profileNameOffline,
      };
      if (r == null) {
        _editing = false;
        _boards = _load();
      }
    });
  }

  String _lockedText(AppLocalizations l) => l.profileNameLocked(
      MaterialLocalizations.of(context).formatMediumDate(_lb.nextRename ?? DateTime.now()));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final named = _lb.name != null && !_editing;
    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: ChristmasBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListenableBuilder(
              listenable: Listenable.merge([_lb, GameStats.instance]),
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  if (named) ...[
                    _hero(l),
                    const SizedBox(height: 14),
                  ] else ...[
                    _nameEntry(l),
                    const SizedBox(height: 14),
                    _tiles(l),
                    const SizedBox(height: 14),
                  ],
                  _perGame(l),
                  const SizedBox(height: 14),
                  FutureBuilder(
                    future: _boards,
                    builder: (context, snap) => snap.connectionState != ConnectionState.done
                        ? const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                        : _weekly(l, snap.data?.$1, snap.data?.$2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Card(
        margin: EdgeInsets.zero,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );

  Widget _title(String t, {String? side}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(flex: 3, child: Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          if (side != null)
            Flexible(
              flex: 2,
              child: Text(side,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
        ],
      );

  /// Intestazione colorata: avatar, nome, livello (1 ogni 5 trofei) e, sotto, i tre numeri.
  Widget _hero(AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    final name = _lb.name!;
    final level = 1 + GameStats.instance.recordCount ~/ 5;
    return Column(children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 8, 56),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, Color.lerp(scheme.primary, Colors.black, 0.4)!],
            ),
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: scheme.onPrimary,
              child: Text(name[0].toUpperCase(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: scheme.primary)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: scheme.onPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: scheme.onPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
                  child: Text('★ ${l.profileLevel(level)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.onPrimary)),
                ),
              ]),
            ),
            IconButton(
              tooltip: l.profileEditName,
              icon: Icon(Icons.edit_rounded, color: scheme.onPrimary),
              onPressed: () {
                // un cambio al mese: se è presto, la matita spiega perché non si può
                if (_lb.nextRename != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(_lockedText(l))));
                  return;
                }
                setState(() {
                  _editing = true;
                  _error = null;
                  _ctrl.text = name;
                });
              },
            ),
          ]),
        ),
        // i tre numeri a cavallo del bordo inferiore
        Positioned(left: 12, right: 12, bottom: -36, child: SizedBox(height: 74, child: _tiles(l))),
        ],
      ),
      const SizedBox(height: 36), // lo spazio sotto, dove i tre numeri sporgono dall'intestazione
    ]);
  }

  Widget _tiles(AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    var won = 0, lost = 0;
    for (final k in GameKind.values) {
      won += _lb.wins(k);
      lost += _lb.losses(k);
    }
    Widget tile(String value, String label, Color color) => Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
        );
    return Row(children: [
      tile('${GameStats.instance.recordCount}', l.profileTrophies, const Color(0xFFB77900)),
      const SizedBox(width: 8),
      tile('$won', l.profileWon, Colors.green.shade600),
      const SizedBox(width: 8),
      tile('$lost', l.profileLost, Colors.red.shade600),
    ]);
  }

  /// Scelta (o cambio) del nome utente.
  Widget _nameEntry(AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.profileChooseName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(l.profileNameInfo, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 4),
      Text(l.profileNameOnceMonth, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      TextField(
        controller: _ctrl,
        maxLength: 16,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(l),
        decoration: InputDecoration(border: const OutlineInputBorder(), errorText: _error),
      ),
      const SizedBox(height: 4),
      GameButton(
        icon: Icons.check_rounded,
        label: l.profileSave,
        onPressed: _saving ? null : () => _save(l),
      ),
    ]));
  }

  /// Una barra verde/rossa (vinte/perse) per ogni gioco, dal più giocato.
  Widget _perGame(AppLocalizations l) {
    final stats = GameStats.instance;
    final kinds = GameKind.values
        .where((k) => stats.plays(k.name) > 0 || _lb.wins(k) + _lb.losses(k) > 0)
        .toList()
      ..sort((a, b) => stats.plays(b.name).compareTo(stats.plays(a.name)));
    final top = kinds.isEmpty ? null : kinds.first;
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title(l.profileByGame),
      if (top != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('${l.profileMostPlayed}: ${gameTitle(l, top)} · ${stats.plays(top.name)}',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      const SizedBox(height: 10),
      if (kinds.isEmpty) Text(l.profileNoGames),
      for (final k in kinds)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(
              flex: 5,
              child: Text(gameTitle(l, k), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 4, child: _winBar(_lb.wins(k), _lb.losses(k))),
            SizedBox(
              width: 56,
              child: Text('${_lb.wins(k)} · ${_lb.losses(k)}',
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ]),
        ),
    ]));
  }

  Widget _winBar(int won, int lost) => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          height: 10,
          child: won + lost == 0
              ? ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)
              : Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (won > 0) Expanded(flex: won, child: ColoredBox(key: const ValueKey('bar-won'), color: Colors.green.shade600)),
                  if (lost > 0) Expanded(flex: lost, child: ColoredBox(key: const ValueKey('bar-lost'), color: Colors.red.shade400)),
                ]),
        ),
      );

  Widget _weekly(AppLocalizations l, List<WeekRow>? rows, List<WeekRow>? prev) {
    final scheme = Theme.of(context).colorScheme;
    final (game, diff) = Leaderboard.challengeFor(_week);
    final (pGame, pDiff) = Leaderboard.challengeFor(_week - 1);
    final level = difficultyLabel(l, diff);

    // chi ha giocato a più giochi diversi; chi ha vinto di più a ciascun gioco
    WeekRow? mostGames;
    final topWins = <String, (WeekRow, int)>{};
    for (final r in rows ?? const <WeekRow>[]) {
      if (r.games > (mostGames?.games ?? 0)) mostGames = r;
      r.wins.forEach((g, n) {
        if (n > (topWins[g]?.$2 ?? 0)) topWins[g] = (r, n);
      });
    }
    final bestWins = topWins.entries.toList()..sort((a, b) => b.value.$2.compareTo(a.value.$2));
    // podio della sfida: i primi tre per vittorie nel gioco e livello della settimana
    final podium = [for (final r in rows ?? const <WeekRow>[]) if (r.ch > 0) r]..sort((a, b) => b.ch.compareTo(a.ch));
    WeekRow? lastLeader;
    for (final r in prev ?? const <WeekRow>[]) {
      if (r.ch > (lastLeader?.ch ?? 0)) lastLeader = r;
    }
    final myCh = GameStats.instance.value('wk${_week}_ch');

    // ordine di disposizione: 2°, 1°, 3°
    Widget pod(int rank) {
      if (rank >= podium.length) return const Expanded(child: SizedBox());
      final r = podium[rank];
      final first = rank == 0;
      final me = r.uid == _lb.myUid;
      return Expanded(
        flex: first ? 12 : 10,
        child: Container(
          padding: EdgeInsets.fromLTRB(4, 10, 4, first ? 16 : 10),
          decoration: BoxDecoration(
            color: first ? const Color(0xFFFBE3B0) : scheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: me ? Border.all(color: scheme.primary, width: 2) : null,
          ),
          child: Column(children: [
            Text('${rank + 1}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFB77900))),
            Text(r.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: first ? const Color(0xFF4A3300) : null)),
            Text(l.profileWinsCount(r.ch),
                style: TextStyle(fontSize: 12, color: first ? const Color(0xFF4A3300) : scheme.onSurfaceVariant)),
          ]),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.flag_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: _title(l.challengeTitle, side: '${gameTitle(l, game)} · $level')),
        ]),
        const SizedBox(height: 8),
        Text(l.challengeText(gameTitle(l, game), level)),
        const SizedBox(height: 12),
        if (podium.isEmpty)
          Text(l.weeklyEmpty, style: TextStyle(color: scheme.onSurfaceVariant))
        else
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            pod(1),
            const SizedBox(width: 8),
            pod(0),
            const SizedBox(width: 8),
            pod(2),
          ]),
        const SizedBox(height: 10),
        if (_lb.name == null)
          Text(l.challengeNoName, style: TextStyle(color: scheme.onSurfaceVariant))
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Text(l.challengeYou(myCh), style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onPrimaryContainer)),
          ),
        if (lastLeader != null) ...[
          const SizedBox(height: 10),
          Text(l.challengeLast(gameTitle(l, pGame), difficultyLabel(l, pDiff), lastLeader.name, lastLeader.ch),
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        ],
      ])),
      const SizedBox(height: 14),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _title(l.weeklyTitle),
        const SizedBox(height: 12),
        if (rows == null)
          Text(l.weeklyUnavailable)
        else if (mostGames == null)
          Text(l.weeklyEmpty)
        else
          for (final (i, e) in [
            (l.weeklyLabelMostGames, mostGames, mostGames.games),
            for (final w in bestWins.take(3))
              (
                gameTitle(l, GameKind.values.firstWhere((k) => k.name == w.key, orElse: () => GameKind.busJam)),
                w.value.$1,
                w.value.$2
              ),
          ].indexed) ...[
            if (i > 0) Divider(height: 20, color: scheme.outlineVariant),
            _rankRow(scheme, e.$1, e.$2, e.$3, gold: i == 0),
          ],
      ])),
    ]);
  }

  /// Una riga della classifica: iniziale del giocatore, categoria, nome e numero.
  Widget _rankRow(ColorScheme scheme, String what, WeekRow r, int n, {bool gold = false}) {
    final me = r.uid == _lb.myUid;
    return Row(children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: gold ? const Color(0xFFB77900) : scheme.primaryContainer,
        child: Text(r.name[0].toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w800, color: gold ? Colors.white : scheme.onPrimaryContainer)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(what, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          Text(r.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      ),
      const SizedBox(width: 8),
      Container(
        constraints: const BoxConstraints(minWidth: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: me ? scheme.primary : scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$n',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: me ? scheme.onPrimary : scheme.onPrimaryContainer)),
      ),
    ]);
  }
}
