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
  const PlayerProfileScreen({super.key});

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
    _boards = _load();
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
                  _nameCard(l),
                  const SizedBox(height: 14),
                  _summary(l),
                  const SizedBox(height: 14),
                  _perGame(l),
                  const SizedBox(height: 18),
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

  Widget _nameCard(AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    final name = _lb.name;
    if (name != null && !_editing) {
      return _card(Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: scheme.primaryContainer,
          child: Text(name[0].toUpperCase(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: scheme.onPrimaryContainer)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
        IconButton(
          tooltip: l.profileEditName,
          icon: const Icon(Icons.edit_rounded),
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
      ]));
    }
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

  Widget _summary(AppLocalizations l) {
    final stats = GameStats.instance;
    GameKind? top;
    var n = 0;
    for (final k in GameKind.values) {
      if (stats.plays(k.name) > n) {
        n = stats.plays(k.name);
        top = k;
      }
    }
    Widget tile(IconData icon, Color color, String label, String value) => Expanded(
          child: _card(Column(children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 6),
            Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ])),
        );
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        tile(Icons.emoji_events_rounded, const Color(0xFFB77900), l.profileTrophies, '${stats.recordCount}'),
        const SizedBox(width: 12),
        tile(Icons.sports_esports_rounded, Theme.of(context).colorScheme.primary, l.profileMostPlayed,
            top == null ? '–' : '${gameTitle(l, top)} · $n'),
      ]),
    );
  }

  Widget _perGame(AppLocalizations l) {
    final stats = GameStats.instance;
    final kinds = GameKind.values
        .where((k) => stats.plays(k.name) > 0 || _lb.wins(k) + _lb.losses(k) > 0)
        .toList()
      ..sort((a, b) => stats.plays(b.name).compareTo(stats.plays(a.name)));
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.profileByGame, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      if (kinds.isEmpty) Text(l.profileNoGames),
      for (final k in kinds)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(child: Text(gameTitle(l, k), style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(l.profileWinLoss(_lb.wins(k), _lb.losses(k))),
          ]),
        ),
    ]));
  }

  Widget _weekly(AppLocalizations l, List<WeekRow>? rows, List<WeekRow>? prev) {
    final scheme = Theme.of(context).colorScheme;
    final (game, diff) = Leaderboard.challengeFor(_week);
    final (pGame, pDiff) = Leaderboard.challengeFor(_week - 1);
    final level = difficultyLabel(l, diff);

    // chi ha giocato a più giochi diversi; chi ha vinto di più a ciascun gioco
    WeekRow? mostGames;
    final topWins = <String, (WeekRow, int)>{};
    WeekRow? chLeader;
    for (final r in rows ?? const <WeekRow>[]) {
      if (r.games > (mostGames?.games ?? 0)) mostGames = r;
      if (r.ch > (chLeader?.ch ?? 0)) chLeader = r;
      r.wins.forEach((g, n) {
        if (n > (topWins[g]?.$2 ?? 0)) topWins[g] = (r, n);
      });
    }
    final bestWins = topWins.entries.toList()..sort((a, b) => b.value.$2.compareTo(a.value.$2));
    WeekRow? lastLeader;
    for (final r in prev ?? const <WeekRow>[]) {
      if (r.ch > (lastLeader?.ch ?? 0)) lastLeader = r;
    }
    final myCh = GameStats.instance.value('wk${_week}_ch');

    const bold = TextStyle(fontWeight: FontWeight.w700);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.weeklyTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (rows == null)
          Text(l.weeklyUnavailable)
        else if (mostGames == null)
          Text(l.weeklyEmpty)
        else ...[
          Text(l.weeklyMostGames(mostGames.name, mostGames.games), style: bold),
          for (final e in bestWins.take(3))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.weeklyMostWins(
                    gameTitle(l, GameKind.values.firstWhere((k) => k.name == e.key, orElse: () => GameKind.busJam)),
                    e.value.$1.name,
                    e.value.$2),
                style: bold,
              ),
            ),
        ],
      ])),
      const SizedBox(height: 14),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.flag_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Text(l.challengeTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        Text(l.challengeText(gameTitle(l, game), level)),
        const SizedBox(height: 8),
        if (_lb.name == null)
          Text(l.challengeNoName, style: TextStyle(color: scheme.onSurfaceVariant))
        else
          Text(l.challengeYou(myCh), style: bold),
        if (chLeader != null) Text(l.challengeLeader(chLeader.name, chLeader.ch), style: bold),
        if (lastLeader != null) ...[
          const SizedBox(height: 10),
          Text(l.challengeLast(gameTitle(l, pGame), difficultyLabel(l, pDiff), lastLeader.name, lastLeader.ch),
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        ],
      ])),
    ]);
  }
}
